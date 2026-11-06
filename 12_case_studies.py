"""Stage 12 – Trường hợp điển hình.
C1 Giải phẫu hai ngày Mega Sale (15/08 và 19/09/2026): đơn, AOV, quảng cáo, chiết khấu, biên đóng góp theo hai giả định giá vốn
C2 Ngành FMCG lỗ dù đơn nhiều: lộ trình combo/giảm giá vốn để vượt ROAS hòa vốn
C3 Bẫy vốn lưu động của chiến dịch (độ trễ đối soát × lead time × phí sàn) và phần vốn bị khóa thêm do Mega Sale
C4 Kế hoạch hàng cho một SKU điện thoại theo q* trong cửa sổ chiến dịch
"""
import numpy as np
import pandas as pd

from src.cashflow.sim import mega_increment, simulate
from src.common import CFG, PAL, Timer, log_run, plt, read_csv, savefig, write_csv, write_json
from src.data import io
from src.scenarios.megasale import CampaignModel

ST = "12_cases"
RES = {}
d = io.ecommerce_90days(); u = io.unit_econ()
cogs_ratio = float(u.COGS.sum() / u.GMV.sum())
cm = CampaignModel(d, cogs_ratio)

with Timer("C1 Hai ngày Mega Sale"):
    rows = []
    normal = d[d.Mega == 0]
    for r in d[d.Mega == 1].itertuples():
        for basis in ["gmv", "list"]:
            share = cogs_ratio if basis == "gmv" else cm.kappa / (1 - r.Discount)
            rows.append(dict(date=str(r.Date.date()), basis=basis, GMV=r.GMV, Orders=r.Orders, AOV=r.AOV, Ads=r.Ad_Spend, Discount=r.Discount,
                             cost_share=share, CM=r.GMV * (1 - share) - r.Ad_Spend))
    nb = dict(GMV=normal.GMV.mean(), Orders=normal.Orders.mean(), AOV=normal.AOV.mean(), Ads=normal.Ad_Spend.mean(), Discount=normal.Discount.mean())
    for basis in ["gmv", "list"]:
        share = cogs_ratio if basis == "gmv" else float((cm.kappa / (1 - normal.Discount) * normal.GMV).sum() / normal.GMV.sum())
        nb[f"CM_{basis}"] = float((normal.GMV * (1 - (cogs_ratio if basis == "gmv" else cm.kappa / (1 - normal.Discount))) - normal.Ad_Spend).mean())
    c1 = pd.DataFrame(rows)
    write_csv(c1, ST, "c1_mega_days.csv")
    RES["C1"] = dict(days=c1.to_dict("records"), normal_mean=nb, kappa=cm.kappa, cogs_ratio=cogs_ratio)

with Timer("C2 FMCG"):
    sens = read_csv("02_marketing", "unit_econ_sensitivity.csv")
    f = sens[sens.Category.str.startswith("FMCG")]
    first_pos = f[f.CM > 0].sort_values(["dAOV", "dCOGS"], ascending=[True, False]).head(3)
    ue = read_csv("02_marketing", "unit_economics.csv")
    fm = ue[ue.Category.str.startswith("FMCG")].iloc[0]
    RES["C2"] = dict(base=fm.to_dict(), min_aov_up_no_cogs=float(f[(f.dCOGS == 0) & (f.CM > 0)].dAOV.min()), first_positive=first_pos.to_dict("records"),
                     aov_needed=float(fm.CAC + fm.COGS_per_Order), aov_gap_pct=float((fm.CAC + fm.COGS_per_Order) / fm.AOV - 1))

with Timer("C3 Bẫy vốn lưu động"):
    dd = d.set_index("Date")[["GMV", "Ad_Spend"]]
    mega_days = d.loc[d.Mega == 1, "Date"].tolist()
    grid = []
    for lag in CFG["cashflow"]["settlement_lag_days"]:
        for lead in CFG["cashflow"]["lead_time_days"]:
            for fee in CFG["cashflow"]["platform_fee"]:
                s_ = simulate(dd, cogs_ratio, lag, lead, fee)
                grid.append(dict(lag=lag, lead=lead, fee=fee, cash_need=s_["cash_need"], date_min=s_["date_min"], end=s_["end"]))
    grid = pd.DataFrame(grid)
    inc = pd.DataFrame([dict(lag=lag, lead=lead, **mega_increment(dd, mega_days, cogs_ratio, lag, lead))
                        for lag in [0, 7, 10, 14] for lead in CFG["cashflow"]["lead_time_days"]])
    write_csv(grid, ST, "c3_cash_grid.csv"); write_csv(inc, ST, "c3_mega_increment.csv")
    RES["C3"] = dict(grid=grid.to_dict("records"), mega_increment=inc.to_dict("records"), total_gmv=float(d.GMV.sum()), total_ads=float(d.Ad_Spend.sum()))
    fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.8))
    for i, lag in enumerate([0, 7, 14]):
        s_ = simulate(dd, cogs_ratio, lag, 30)["series"]; ax[0].plot(s_.index, s_, color=PAL[i], label=f"Trễ đối soát {lag} ngày")
    ax[0].axhline(0, color="k", lw=.5); ax[0].legend(fontsize=6); ax[0].set_title("(a) Tiền mặt lũy kế (triệu VNĐ), lead time 30 ngày"); ax[0].tick_params(labelsize=6, axis="x", labelrotation=30)
    g0 = grid[(grid.fee == 0)]
    for i, lead in enumerate(CFG["cashflow"]["lead_time_days"]):
        x = g0[g0.lead == lead]; ax[1].plot(x.lag, x.cash_need, marker="o", color=PAL[i], label=f"Lead time {lead} ngày")
    ax[1].set_xlabel("Độ trễ đối soát (ngày)"); ax[1].legend(fontsize=6.5); ax[1].set_title("(b) Tiền mặt tối thiểu cần chuẩn bị (triệu VNĐ)")
    savefig(fig, ST, "s12_cash_trap.png")

with Timer("C4 Kế hoạch hàng SKU điện thoại"):
    q = read_csv("06_probabilistic", "quantile_forecasts_last_origin.csv", parse_dates=["date"])
    crit = read_csv("06_probabilistic", "sku_critical_ratio.csv")
    s = "TECH_PHONE_003"
    g = q[q.sid == s].sort_values("h")
    cr = crit[crit.sid == s].iloc[0]
    RES["C4"] = dict(sid=s, q_star=float(cr.q_star), strategy=cr.strategy, price=float(cr.Price), cost=float(cr.Cost), salvage=float(cr.Salvage),
                     sum_p10=float(g.QLGBM_P10.sum()), sum_p50=float(g.QLGBM_P50.sum()), sum_p90=float(g.QLGBM_P90.sum()), sum_y=float(g.y.sum()))
write_json(RES, ST, "results.json")
log_run(ST, {})
print(c1.round(3).to_string()); print(nb); print(RES["C2"]); print(grid[grid.fee == 0].round(1).to_string()); print(inc.round(2).to_string()); print(RES["C4"])
