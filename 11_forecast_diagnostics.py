"""Stage 11 – Chẩn đoán sai số dự báo: theo ngành, chân trời, thứ, ngày đôi; SKU khó dự báo; phần dư mô hình chiến dịch theo loại ngày."""
import numpy as np
import pandas as pd

from src.common import PAL, Timer, log_run, plt, read_csv, savefig, write_csv, write_json
from src.data import io
from src.scenarios.megasale import CampaignModel

ST = "11_diagnostics"
RES = {}
with Timer("Sai số mô hình toàn cục 100 SKU"):
    lp = read_csv("05_models", "predictions_100.csv", parse_dates=["date"])
    lp["cat"] = lp.sid.str.rsplit("_", n=1).str[0]
    lp["dow"] = lp.date.dt.dayofweek; lp["double_day"] = (lp.date.dt.day == lp.date.dt.month).astype(int)
    M = ["Global_LGBM_scaled", "Local_HW", "SNaive7"]

    def wape(g, m):
        return float(np.abs(g.y - g[m]).sum() / g.y.sum() * 100)

    tabs = {}
    for key in ["h", "dow", "cat", "double_day"]:
        t = pd.DataFrame([dict(**{key: k}, **{m: wape(g, m) for m in M}, n=len(g)) for k, g in lp.groupby(key)])
        tabs[key] = t; write_csv(t, ST, f"wape_by_{key}.csv")
    sku = pd.DataFrame([dict(sid=s, cat=g.cat.iloc[0], mean_y=g.y.mean(), cv=g.y.std() / g.y.mean(), **{m: wape(g, m) for m in M}) for s, g in lp.groupby("sid")])
    sku["global_better"] = sku.Global_LGBM_scaled < sku.Local_HW
    write_csv(sku.sort_values("Global_LGBM_scaled", ascending=False), ST, "wape_by_sku.csv")
    RES["sku"] = dict(share_global_better=float(sku.global_better.mean()), worst=sku.nlargest(5, "Global_LGBM_scaled")[["sid", "Global_LGBM_scaled", "Local_HW"]].to_dict("records"),
                      corr_cv_wape=float(sku.cv.corr(sku.Global_LGBM_scaled)))
    RES["by"] = {k: v.to_dict("records") for k, v in tabs.items()}

with Timer("Phần dư mô hình chiến dịch theo loại ngày"):
    d = io.ecommerce_90days(); u = io.unit_econ()
    cm = CampaignModel(d, float(u.COGS.sum() / u.GMV.sum()))
    d["resid"] = cm.m_orders.resid.values
    d["weekend"] = (d.dow >= 5).astype(int)
    by = d.groupby(["Mega", "weekend"]).resid.agg(["mean", "std", "count"]).reset_index()
    write_csv(by, ST, "campaign_residuals.csv")
    RES["campaign_resid"] = dict(table=by.to_dict("records"), resid_sd=cm.resid_sd, mega_resid=d.loc[d.Mega == 1, "resid"].round(3).tolist())

fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.6))
for i, m in enumerate(M):
    ax[0].plot(tabs["h"].h, tabs["h"][m], marker=".", color=PAL[i], label={"Global_LGBM_scaled": "LGBM toàn cục", "Local_HW": "HW cục bộ", "SNaive7": "Naive mùa vụ 7"}.get(m, m))
ax[0].set_xlabel("h"); ax[0].set_title("(a) WAPE theo chân trời")
fig.legend(*ax[0].get_legend_handles_labels(), loc="lower left", ncol=3, fontsize=6.8, bbox_to_anchor=(0.02, -0.04))
fig.tight_layout(rect=(0, 0.07, 1, 1)); fig._keep_layout = True
lab = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
ax[1].bar(np.arange(7) - .2, tabs["dow"].Global_LGBM_scaled, .4, color=PAL[0], label="Toàn cục"); ax[1].bar(np.arange(7) + .2, tabs["dow"].Local_HW, .4, color=PAL[1], label="HW")
ax[1].set_xticks(range(7)); ax[1].set_xticklabels(lab); ax[1].set_title("(b) WAPE theo thứ"); ax[1].legend(fontsize=6)
ax[2].scatter(sku.cv, sku.Global_LGBM_scaled, s=10, c=[PAL[["ACC_CABLE", "FMCG_FOOD", "TECH_PHONE"].index(c)] for c in sku.cat])
ax[2].set_xlabel("Hệ số biến thiên của chuỗi"); ax[2].set_ylabel("WAPE (%)"); ax[2].set_title("(c) WAPE theo SKU")
savefig(fig, ST, "s11_diagnostics.png")
write_json(RES, ST, "results.json")
log_run(ST, {})
print(tabs["cat"].round(3)); print(tabs["double_day"].round(3)); print(RES["sku"]); print(by.round(3))
