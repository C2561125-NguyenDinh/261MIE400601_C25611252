"""Stage 07 – Phân bổ ngân sách quảng cáo giữa các ngành (slide Chương 5: kiến trúc đa tác tử, hàm mục tiêu có trọng số).

E7.1 Đường phản hồi ln(Ads) theo ngành và kinh tế đơn vị
E7.2 So sánh chính sách ở mức ngân sách hiện tại: hiện trạng, chia đều, theo ROAS (heuristic), tối ưu lợi nhuận, tối ưu GMV
E7.3 Quét trọng số w2 (chi phí) với w1 = 1 – nối với nghiệm giải tích F(x*) của slide
E7.4 Quét mức ngân sách 50%–150%, giá bóng λ (lợi nhuận biên của 1 triệu VNĐ ngân sách)
E7.5 Bất định tham số: bootstrap đường phản hồi, phân phối lợi nhuận của từng chính sách, xác suất chính sách tối ưu thua hiện trạng
"""
import numpy as np
import pandas as pd

from src.budget.allocate import Response, evaluate, fit_log_response, objective, optimize_allocation, shadow_price
from src.common import CFG, GREY, PAL, SEED, Timer, log_run, plt, savefig, write_csv, write_json
from src.data import io

ST = "07_budget"
RES = {}
MIN = CFG["budget"]["min_share"]

with Timer("E7.1 Đường phản hồi"):
    p = io.panel(); u = io.unit_econ()
    resp = fit_log_response(p, u)
    cats = list(resp)
    R = [resp[c] for c in cats]
    cur = p.groupby("Category").Ad_Spend.mean().reindex(cats).values          # ngân sách ngày hiện tại theo ngành
    B0 = float(cur.sum())
    roas = (p.groupby("Category").GMV.sum() / p.groupby("Category").Ad_Spend.sum()).reindex(cats).values
    RES["E7_1"] = dict(budget_now=B0, current=dict(zip(cats, cur.tolist())), roas=dict(zip(cats, roas.tolist())),
                       response={c: dict(alpha=r.alpha, beta=r.beta, aov=r.aov, cogs=r.cogs, gm=r.aov - r.cogs, a_range=r.a_range,
                                         marginal_profit_at_current=(r.aov - r.cogs) * r.beta / cur[i] - 1) for i, (c, r) in enumerate(resp.items())})

with Timer("E7.2 So sánh chính sách"):
    pols = {"Hiện trạng (TB 30 ngày)": cur, "Chia đều": np.full(len(cats), B0 / len(cats)),
            "Theo ROAS trung bình (heuristic)": B0 * roas / roas.sum(),
            "Tối ưu lợi nhuận (w1 = w2 = 1)": optimize_allocation(R, B0, 1, 1, MIN),
            "Tối ưu GMV (w2 = 0)": optimize_allocation(R, B0, 1, 0, MIN),
            "Tối ưu lợi nhuận trong vùng dữ liệu": optimize_allocation(R, B0, 1, 1, MIN, within_data=True)}
    rows = []
    for k, a in pols.items():
        ev = evaluate(a, R)
        rows.append(dict(policy=k, **{f"ads_{c}": ev["by_cat"][c]["ads"] for c in cats}, gmv=ev["gmv"], profit=ev["profit"], all_in_range=ev["all_in_range"]))
    pol = pd.DataFrame(rows)
    write_csv(pol, ST, "policy_comparison.csv")
    RES["E7_2"] = pol.to_dict("records")

with Timer("E7.3 Quét trọng số"):
    sw = []
    for w2 in [0.0, 0.25, 0.5, 0.75, 0.9, 1.0, 1.1, 1.25, 1.5]:
        a = optimize_allocation(R, B0, 1.0, w2, MIN); ev = evaluate(a, R)
        sw.append(dict(w2=w2, **{f"ads_{c}": ev["by_cat"][c]["ads"] for c in cats}, gmv=ev["gmv"], profit=ev["profit"]))
    sw = pd.DataFrame(sw)
    write_csv(sw, ST, "weight_sweep.csv")
    RES["E7_3"] = sw.to_dict("records")

with Timer("E7.4 Quét ngân sách và giá bóng"):
    bl = []
    for lev in CFG["budget"]["levels"]:
        B = B0 * lev
        a = optimize_allocation(R, B, 1, 1, MIN); ev = evaluate(a, R)
        aw = optimize_allocation(R, B, 1, 1, MIN, within_data=True)
        pw = evaluate(aw, R)["profit"] if not np.isnan(aw).any() else np.nan
        bl.append(dict(level=lev, budget=B, **{f"ads_{c}": ev["by_cat"][c]["ads"] for c in cats}, gmv=ev["gmv"], profit=ev["profit"],
                       shadow_price=shadow_price(R, B, 1, 1, MIN), all_in_range=ev["all_in_range"], profit_within_data=pw,
                       shadow_within_data=shadow_price(R, B, 1, 1, MIN, within_data=True)))
    # không ràng buộc tổng: mức chi tối ưu riêng từng ngành (đạo hàm = 0 → a* = GM·β)
    free = {c: max(0.0, (r.aov - r.cogs) * r.beta) for c, r in resp.items()}
    bl = pd.DataFrame(bl)
    write_csv(bl, ST, "budget_levels.csv")
    RES["E7_4"] = dict(levels=bl.to_dict("records"), unconstrained_optimum=free)

with Timer("E7.5 Bất định tham số (bootstrap)"):
    rng = np.random.default_rng(SEED)
    Bn = 1000
    a_opt = pols["Tối ưu lợi nhuận (w1 = w2 = 1)"]
    sim = {k: [] for k in pols}
    wins = 0
    for b in range(Bn):
        Rb = []
        for c in cats:
            g = p[p.Category == c]
            i = rng.integers(0, len(g), len(g))
            X = np.column_stack([np.ones(len(i)), np.log(g.Ad_Spend.values[i])])
            a_, b_ = np.linalg.lstsq(X, g.Orders.values[i].astype(float), rcond=None)[0]
            Rb.append(Response(c, a_, b_, resp[c].aov, resp[c].cogs, resp[c].a_range))
        for k, a in pols.items():
            sim[k].append(objective(a, Rb, 1, 1))
        wins += objective(a_opt, Rb, 1, 1) > objective(cur, Rb, 1, 1)
    bs = pd.DataFrame({k: v for k, v in sim.items()})
    summ = pd.DataFrame({"policy": bs.columns, "profit_mean": bs.mean().values, "profit_p05": bs.quantile(.05).values, "profit_p95": bs.quantile(.95).values})
    write_csv(summ, ST, "bootstrap_policy_profit.csv")
    RES["E7_5"] = dict(summary=summ.to_dict("records"), p_opt_beats_current=wins / Bn, B=Bn,
                       mean_gain_vs_current=float((bs["Tối ưu lợi nhuận (w1 = w2 = 1)"] - bs["Hiện trạng (TB 30 ngày)"]).mean()))

fig, ax = plt.subplots(1, 3, figsize=(9.6, 3.2))
xs = np.linspace(1, 15, 100)
for i, (c, r) in enumerate(resp.items()):
    ax[0].plot(xs, r.profit(xs), color=PAL[i], label=c)
    ax[0].axvspan(*r.a_range, color=PAL[i], alpha=.06)
ax[0].axhline(0, color="k", lw=.5); ax[0].set_xlabel("Quảng cáo/ngày (triệu VNĐ)"); ax[0].legend(fontsize=6); ax[0].set_title("(a) LN gộp sau QC theo ngành")
xx = np.arange(len(pol)); bottom = np.zeros(len(pol))
for i, c in enumerate(cats):
    ax[1].bar(xx, pol[f"ads_{c}"], bottom=bottom, color=PAL[i], label=c); bottom += pol[f"ads_{c}"].values
ax[1].set_xticks(xx); ax[1].set_xticklabels(["Hiện trạng", "Chia đều", "Theo ROAS", "Tối ưu LN", "Tối ưu GMV", "Tối ưu LN\n(trong vùng DL)"], fontsize=5.5, rotation=20)
ax[1].set_title("(b) Phân bổ ngân sách/ngày"); ax[1].legend(fontsize=5.5, loc="upper center", bbox_to_anchor=(0.5, -0.32), ncol=3)
ax2 = ax[2]
ax2.plot(bl.level * 100, bl.profit, marker="o", color=PAL[0], label="Lợi nhuận tối ưu")
ax2.set_xlabel("Ngân sách (% hiện tại)"); ax2.set_title("(c) Lợi nhuận và giá bóng λ")
ax3 = ax2.twinx(); ax3.plot(bl.level * 100, bl.shadow_price, marker="s", color=PAL[1], label="λ"); ax3.axhline(0, color=PAL[1], lw=.5, ls=":")
ax3.grid(False)
savefig(fig, ST, "s07_budget.png")

write_json(RES, ST, "results.json")
log_run(ST, {})
print(pol.round(3).to_string()); print(sw.round(2).to_string()); print(bl.round(3).to_string()); print(summ.round(2)); print(RES["E7_5"]["p_opt_beats_current"], RES["E7_4"]["unconstrained_optimum"])
print({c: round(v["marginal_profit_at_current"], 3) for c, v in RES["E7_1"]["response"].items()})
