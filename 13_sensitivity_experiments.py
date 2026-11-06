"""Stage 13 – Thí nghiệm độ nhạy.
S1 Giả định giá vốn (theo GMV vs theo giá niêm yết) và tỷ lệ giá vốn ±10% → biên đóng góp ngày Mega Sale
S2 Tỷ trọng tối thiểu mỗi ngành trong phân bổ ngân sách
S3 Ngưỡng HITL (phân vị ngân sách, ngưỡng chiết khấu) → số đề xuất chuyển con người
S4 Siêu tham số mô hình toàn cục (num_leaves, min_data_in_leaf) ở gốc cuối
S5 Độ nhạy biên lợi nhuận của tối ưu ngân sách khi biên gộp/đơn thay đổi ±20%
"""
import numpy as np
import pandas as pd

from src.budget.allocate import Response, evaluate, fit_log_response, optimize_allocation
from src.common import CFG, SEED, Timer, log_run, read_json, write_csv, write_json
from src.data import io
from src.evaluation.metrics import point_metrics
from src.features.build import FEATS, make_frame, static_100
from src.models.train import fit_global
from src.scenarios.megasale import CampaignModel

ST = "13_sensitivity"
RES = {}
d = io.ecommerce_90days(); u = io.unit_econ(); p = io.panel()
base_ratio = float(u.COGS.sum() / u.GMV.sum())

with Timer("S1 Giả định giá vốn"):
    rows = []
    for mult in [0.9, 1.0, 1.1]:
        cm = CampaignModel(d, base_ratio * mult, seed=SEED)
        for basis in ["gmv", "list"]:
            for r in d[d.Mega == 1].itertuples():
                pr = cm.predict(float(r.Ad_Spend), float(r.Discount), 1, cost_basis=basis)
                rows.append(dict(cogs_mult=mult, basis=basis, date=str(r.Date.date()), cm_p50=pr["cm_p50"], cost_share=pr["cost_share"]))
    s1 = pd.DataFrame(rows); write_csv(s1, ST, "s1_cost_basis.csv"); RES["S1"] = s1.to_dict("records")

with Timer("S2 Tỷ trọng tối thiểu"):
    resp = fit_log_response(p, u); R = list(resp.values()); cats = list(resp)
    B0 = float(p.groupby("Category").Ad_Spend.mean().sum())
    rows = []
    for m in [0.0, 0.05, 0.1, 0.15, 0.2, 0.3]:
        a = optimize_allocation(R, B0, 1, 1, m); ev = evaluate(a, R)
        rows.append(dict(min_share=m, **{f"ads_{c}": ev["by_cat"][c]["ads"] for c in cats}, profit=ev["profit"], gmv=ev["gmv"]))
    s2 = pd.DataFrame(rows); write_csv(s2, ST, "s2_min_share.csv"); RES["S2"] = s2.to_dict("records")

with Timer("S3 Ngưỡng HITL"):
    plans = pd.DataFrame(read_json("08_genai", "results.json")["E8_3"]["plans"])
    rows = []
    for qb in [0.90, 0.95, 0.99]:
        thr = float(np.quantile(d.Ad_Spend, qb))
        for dr in [0.3, 0.4, 0.5]:
            legal = plans.discount <= np.where(plans.request_id == "R08", 1.0, 0.5)
            flag = (plans.ads_per_day > thr) | (plans.discount >= dr) | (plans.cm_p50 < 0) | (plans.p_cm_negative > .2) | plans.extrapolation
            rows.append(dict(budget_q=qb, budget_thr=thr, discount_review=dr, auto=int((legal & ~flag).sum()), review=int((legal & flag).sum()), rejected=int((~legal).sum())))
    s3 = pd.DataFrame(rows); write_csv(s3, ST, "s3_hitl_thresholds.csv"); RES["S3"] = s3.to_dict("records")

with Timer("S4 Siêu tham số mô hình toàn cục"):
    W = io.hist100_wide(); static = static_100(io.fin100()); H = CFG["global_models"]["horizon"]
    T0 = len(W) - 1 - H
    ftr = make_frame(W.iloc[: T0 + 1], static, list(range(35, T0 - H + 1)), H); fte = make_frame(W, static, [T0], H)
    rows = []
    for nl in [7, 15, 31, 63]:
        for md in [20, 40, 100]:
            m = fit_global(ftr, True, params=dict(num_leaves=nl, min_data_in_leaf=md))
            rows.append(dict(num_leaves=nl, min_data_in_leaf=md, **point_metrics(fte.y, m.predict(fte[FEATS]) * fte.m28)))
    s4 = pd.DataFrame(rows); write_csv(s4, ST, "s4_hyperparams.csv"); RES["S4"] = dict(table=s4.to_dict("records"), wape_range=[float(s4.WAPE.min()), float(s4.WAPE.max())])

with Timer("S5 Biên gộp và phân bổ"):
    rows = []
    for c_mod in cats:
        for f in [0.8, 1.0, 1.2]:
            Rm = [Response(r.name, r.alpha, r.beta, r.aov, r.cogs if r.name != c_mod else r.aov - (r.aov - r.cogs) * f, r.a_range) for r in R]
            a = optimize_allocation(Rm, B0, 1, 1, CFG["budget"]["min_share"]); ev = evaluate(a, Rm)
            rows.append(dict(category_changed=c_mod, gm_factor=f, **{f"ads_{c}": ev["by_cat"][c]["ads"] for c in cats}, profit=ev["profit"]))
    s5 = pd.DataFrame(rows); write_csv(s5, ST, "s5_margin_allocation.csv"); RES["S5"] = s5.to_dict("records")

write_json(RES, ST, "results.json")
log_run(ST, {})
print(s1.round(3).to_string()); print(s2.round(3).to_string()); print(s3.to_string()); print(s4.round(3).to_string()); print(s5.round(3).to_string())
