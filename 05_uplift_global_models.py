"""Stage 05 – Học máy cho dự báo quy mô lớn và ước lượng uplift khuyến mãi (slide Chương 3).

E5.0 Kiểm chứng ví dụ tính tay của slide (tabular hóa, đệ quy, Gradient Boosting cold-start)
E5.1 Sản phẩm mới có khuyến mãi (raw_sales_data): mô hình trên số thô vs mô hình uplift chuẩn hóa
E5.2 Uplift khuyến mãi theo sản phẩm (complex_retail_sales): walk-forward vs K-Fold xáo trộn; S-learner toàn cục, T-learner,
     chênh lệch trung bình; so với cơ chế sinh dữ liệu mô tả trên slide (tr.87)
E5.3 Toàn cục vs cục bộ trên 100 SKU (H = 14, 3 gốc) – có đặc trưng ngày đôi/ngày lương; Diebold–Mariano (HAC)
E5.4 Lặp lại trên 15 SKU (ecommerce_sales_multi_sku)
E5.5 Cold-start: SKU mới cho chiến dịch (giữ lại 10 SKU), warm-start 7 ngày
E5.6 Ngày đôi trong dữ liệu 100 SKU: có tồn tại đỉnh cầu không?
"""
import warnings

import lightgbm as lgb
import numpy as np
import pandas as pd
from scipy import stats
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from sklearn.model_selection import KFold, TimeSeriesSplit
from sklearn.tree import DecisionTreeRegressor

from src.common import vn, CFG, GREY, PAL, SEED, Timer, log_run, plt, savefig, write_csv, write_json
from src.data import io
from src.evaluation.metrics import point_metrics
from src.features.build import FEATS, make_frame, promo_frame, static_100
from src.models.train import MODEL_LABEL, PARAMS, dm_between, fit_global, long_predictions, run_suite

warnings.filterwarnings("ignore")
ST = "05_models"
H = CFG["global_models"]["horizon"]
RES = {}

# ================================================================ E5.0
with Timer("E5.0 Ví dụ tính tay Chương 3"):
    e = {}
    toy = pd.DataFrame({"sku": ["A"] * 3 + ["B"] * 3, "t": [1, 2, 3] * 2, "y": [100, 120, 150, 10, 12, 15]})
    toy["lag1"] = toy.groupby("sku").y.shift(1)
    tr = toy.dropna()
    lr = LinearRegression().fit(tr[["lag1"]], tr.y)
    e["toy_lr"] = dict(coef=float(lr.coef_[0]), intercept=float(lr.intercept_), pred_day4=lr.predict(pd.DataFrame({"lag1": [150, 15]})).round(3).tolist())
    lag = np.array([150., 15.]); path = []
    for _ in range(7):
        lag = lr.predict(pd.DataFrame({"lag1": lag})); path.append(lag.round(2).tolist())
    e["toy_recursive7"] = path
    X = pd.DataFrame({"temp": [36, 30, 37, 32, 31]}); yy = np.array([200, 50, 180, 40, 45.])
    F0 = yy.mean(); tree = DecisionTreeRegressor(max_depth=1, random_state=SEED).fit(X, yy - F0)
    e["gb_toy"] = dict(F0=F0, split=float(tree.tree_.threshold[0]), gamma=tree.predict(pd.DataFrame({"temp": [36, 31]})).tolist(),
                       yhat_C=float(F0 + tree.predict(pd.DataFrame({"temp": [36]}))[0]))
    RES["E5_0"] = e

# ================================================================ E5.1
with Timer("E5.1 Sản phẩm mới có khuyến mãi"):
    rs = io.gv("raw_sales").sort_values(["Product_ID", "Date"])
    mx = rs.Date.max()
    base = rs[rs.Date < mx].groupby("Product_ID").Sales.mean()
    rs["Baseline_30d"] = rs.Product_ID.map(base)
    rs["Uplift"] = (rs.Sales - rs.Baseline_30d) / rs.Baseline_30d
    rs["Lag_Sales_1"] = rs.groupby("Product_ID").Sales.shift(1)
    trn = rs.dropna()
    gm = GradientBoostingRegressor(n_estimators=50, random_state=SEED).fit(trn[["Price", "Discount", "Baseline_30d", "Lag_Sales_1"]], trn.Sales)
    newp = pd.DataFrame({"Price": [150000], "Discount": [1], "Baseline_30d": [500.], "Lag_Sales_1": [500.]})
    gu = GradientBoostingRegressor(n_estimators=50, random_state=SEED).fit(rs[["Discount"]], rs.Uplift)
    upl = float(gu.predict(pd.DataFrame({"Discount": [1]}))[0])
    RES["E5_1"] = dict(baseline=base.round(3).to_dict(), uplift_obs=rs[rs.Discount == 1].set_index("Product_ID").Uplift.round(4).to_dict(),
                       pred_new_raw=float(gm.predict(newp)[0]), uplift_model=upl, pred_new_scaled=500 * (1 + upl))

# ================================================================ E5.2
with Timer("E5.2 Uplift khuyến mãi theo sản phẩm"):
    pf = promo_frame(io.gv("complex_retail")).sort_values(["Date", "Product_ID"]).reset_index(drop=True)
    Xc, yc = pf[["Is_Weekend", "Discount", "Baseline_Sales"]], pf.Sales
    gbp = dict(n_estimators=100, max_depth=4, random_state=SEED)
    wf, kf = [], []
    for k, (a, b) in enumerate(TimeSeriesSplit(n_splits=3).split(Xc), 1):
        m = GradientBoostingRegressor(**gbp).fit(Xc.iloc[a], yc.iloc[a]); p = m.predict(Xc.iloc[b])
        wf.append(dict(fold=k, train=f"{pf.Date[a[0]].date()}→{pf.Date[a[-1]].date()}", test=f"{pf.Date[b[0]].date()}→{pf.Date[b[-1]].date()}",
                       r2=r2_score(yc.iloc[b], p), **{kk: v for kk, v in point_metrics(yc.iloc[b], p).items() if kk in ("MAE", "WAPE")}))
    for k, (a, b) in enumerate(KFold(n_splits=3, shuffle=True, random_state=SEED).split(Xc), 1):
        m = GradientBoostingRegressor(**gbp).fit(Xc.iloc[a], yc.iloc[a]); p = m.predict(Xc.iloc[b])
        kf.append(dict(fold=k, r2=r2_score(yc.iloc[b], p), **{kk: v for kk, v in point_metrics(yc.iloc[b], p).items() if kk in ("MAE", "WAPE")}))
    # S-learner: một mô hình toàn cục, uplift = f(x, KM=1)/f(x, KM=0)
    mS = GradientBoostingRegressor(**gbp).fit(Xc, yc)
    rows = []
    for pid, g in pf.groupby("Product_ID"):
        bsl = g.Baseline_Sales.iloc[0]
        f = lambda w, dd: float(mS.predict(pd.DataFrame({"Is_Weekend": [w], "Discount": [dd], "Baseline_Sales": [bsl]}))[0])
        wd0 = g[(g.Is_Weekend == 0) & (g.Discount == 0)].Sales.mean()
        wd1 = g[(g.Is_Weekend == 0) & (g.Discount == 1)].Sales
        we0 = g[(g.Is_Weekend == 1) & (g.Discount == 0)].Sales.mean()
        n_promo = int((g.Discount == 1).sum())
        # T-learner cục bộ: hồi quy log(Sales) trên Weekend + Discount riêng từng sản phẩm
        if n_promo > 0:
            Xl = np.column_stack([np.ones(len(g)), g.Is_Weekend, g.Discount]); bl = np.linalg.lstsq(Xl, np.log(g.Sales), rcond=None)[0]
            t_promo = float(np.exp(bl[2])); se_note = None
            ci = stats.t.interval(.95, len(wd1) - 1, loc=wd1.mean(), scale=wd1.std(ddof=1) / np.sqrt(len(wd1))) if len(wd1) > 1 else (np.nan, np.nan)
        else:
            t_promo = np.nan; ci = (np.nan, np.nan)
        rows.append(dict(product=pid, baseline=bsl, n_days=len(g), n_promo=n_promo, weekend_obs=we0 / wd0, weekend_S=f(1, 0) / f(0, 0),
                         promo_obs=(wd1.mean() / wd0) if len(wd1) else np.nan, promo_obs_ci_lo=ci[0] / wd0 if len(wd1) > 1 else np.nan,
                         promo_obs_ci_hi=ci[1] / wd0 if len(wd1) > 1 else np.nan, promo_S=f(0, 1) / f(0, 0), promo_T=t_promo,
                         promo_pooled_naive=float(pf[pf.Discount == 1].ratio.mean() / pf[pf.Discount == 0].ratio.mean())))
    upl = pd.DataFrame(rows)
    write_csv(upl, ST, "promo_uplift_by_product.csv")
    RES["E5_2"] = dict(walk_forward=wf, kfold_shuffled=kf, uplift=upl.to_dict("records"),
                       wf_mean_wape=float(np.mean([r["WAPE"] for r in wf])), kf_mean_wape=float(np.mean([r["WAPE"] for r in kf])))
    fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.8))
    xx = np.arange(len(upl)); w = .27
    ax[0].bar(xx - w, upl.promo_obs, w, color=GREY, label="Quan sát (ngày thường)")
    ax[0].bar(xx, upl.promo_S, w, color=PAL[0], label="S-learner toàn cục")
    ax[0].bar(xx + w, upl.promo_T, w, color=PAL[1], label="T-learner cục bộ (log)")
    ax[0].axhline(upl.promo_pooled_naive.iloc[0], color=PAL[3], ls="--", lw=1, label="Uplift gộp (một con số)")
    ax[0].set_xticks(xx); ax[0].set_xticklabels(upl["product"], fontsize=6.5, rotation=20); ax[0].set_ylim(0, 2.1); ax[0].legend(fontsize=5.6, ncol=2, loc="upper left"); ax[0].set_title("(a) Hệ số nhân khuyến mãi theo sản phẩm")
    ax[1].plot([r["fold"] for r in wf], [r["WAPE"] for r in wf], marker="o", color=PAL[0], label="Walk-forward")
    ax[1].plot([r["fold"] for r in kf], [r["WAPE"] for r in kf], marker="s", color=PAL[3], label="K-Fold xáo trộn")
    ax[1].set_xticks([1, 2, 3]); ax[1].set_xlabel("Lần chia"); ax[1].set_ylabel("WAPE (%)"); ax[1].legend(fontsize=6.5); ax[1].set_title("(b) Ước lượng sai số: walk-forward vs xáo trộn")
    savefig(fig, ST, "s05_uplift.png")

# ================================================================ E5.3
with Timer("E5.3 Toàn cục vs cục bộ – 100 SKU"):
    W = io.hist100_wide()
    fin = io.fin100()
    static = static_100(fin)
    n = len(W); origins = [n - 1 - k * H for k in range(CFG["global_models"]["n_origins"], 0, -1)]
    res100, P100, imp100 = run_suite(W, static, origins, H, "100SKU")
    models = list(MODEL_LABEL)
    lp = long_predictions(P100, origins, models)
    lp["cat"] = lp.sid.str.rsplit("_", n=1).str[0]
    write_csv(res100, ST, "global_vs_local_100.csv")
    summ = res100.groupby("model")[["WAPE", "MAE", "RMSE", "MASE", "Bias"]].mean().reset_index().sort_values("WAPE")
    write_csv(summ, ST, "global_vs_local_100_summary.csv")
    bycat = []
    for c, g in lp.groupby("cat"):
        for m in models:
            bycat.append(dict(cat=c, model=m, WAPE=float(np.abs(g.y - g[m]).sum() / g.y.sum() * 100)))
    bycat = pd.DataFrame(bycat)
    write_csv(bycat, ST, "global_vs_local_100_bycat.csv")
    write_csv(imp100.rename("gain_share").reset_index().rename(columns={"index": "feature"}), ST, "feature_importance_100.csv")
    write_csv(lp.round(4), ST, "predictions_100.csv")
    RES["E5_3"] = dict(summary=summ.to_dict("records"), dm_global_vs_hw=dm_between(lp, "Global_LGBM_scaled", "Local_HW", H),
                       dm_global_vs_local_lgbm=dm_between(lp, "Global_LGBM_scaled", "Local_LGBM", H),
                       dm_scaled_vs_raw=dm_between(lp, "Global_LGBM_scaled", "Global_LGBM_raw", H),
                       importance=imp100.round(5).to_dict(), origins=[str(W.index[o].date()) for o in origins],
                       timing=res100.dropna(subset=["t_global_s"])[["origin", "t_global_s", "t_local_s", "t_hw_s", "train_rows"]].to_dict("records"))
    fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.6))
    T0 = origins[-1]; fr = P100[(T0, "frame")]
    for a, s in zip(ax, ["TECH_PHONE_003", "FMCG_FOOD_010", "ACC_CABLE_020"]):
        a.plot(W.index[T0 - 41:T0 + 1], W[s].iloc[T0 - 41:T0 + 1], color="k", lw=.9, label="Lịch sử")
        a.plot(W.index[T0 + 1:T0 + 1 + H], W[s].iloc[T0 + 1:T0 + 1 + H], color=GREY, ls="--", label="Thực tế")
        b = (fr.sid == s).values
        a.plot(W.index[T0 + 1:T0 + 1 + H], P100[(T0, "Global_LGBM_scaled")][b], color=PAL[0], label="Toàn cục")
        a.plot(W.index[T0 + 1:T0 + 1 + H], P100[(T0, "Local_HW")][b], color=PAL[1], label="HW cục bộ")
        a.set_title(s, fontsize=8); a.tick_params(labelsize=6, axis="x", labelrotation=30)
    h_, l_ = ax[0].get_legend_handles_labels()
    fig.legend(h_, l_, loc="lower center", ncol=4, fontsize=7, bbox_to_anchor=(0.5, -0.06))
    fig.tight_layout(rect=(0, 0.06, 1, 1)); fig._keep_layout = True
    savefig(fig, ST, "s05_global_examples.png")
    fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.8))
    ax[0].barh([MODEL_LABEL[m] for m in summ.model], summ.WAPE, color=[PAL[0] if "Global" in m else (PAL[1] if "Local" in m else GREY) for m in summ.model])
    for i, v in enumerate(summ.WAPE):
        ax[0].text(v, i, " " + vn(v), va="center", fontsize=7)
    ax[0].set_title("(a) WAPE (%) trung bình 3 gốc"); ax[0].tick_params(labelsize=7)
    ii = imp100.sort_values()
    ax[1].barh(ii.index, ii.values, color=PAL[2]); ax[1].set_title("(b) Tầm quan trọng gain – toàn cục"); ax[1].tick_params(labelsize=7)
    savefig(fig, ST, "s05_global_vs_local.png")

# ================================================================ E5.4
with Timer("E5.4 15 SKU"):
    ms = io.gv("multi_sku")
    W15 = ms.pivot_table(index="OrderDate", columns="SKU", values="QuantitySold", aggfunc="sum").sort_index()
    st15 = ms.groupby("SKU").Category.first().reset_index().rename(columns={"SKU": "sid", "Category": "cat"})
    st15["cat_code"] = st15.cat.astype("category").cat.codes; st15["log_price"] = 0.0; st15["margin"] = 0.0
    n15 = len(W15); o15 = [n15 - 1 - k * H for k in range(4, 0, -1)]
    res15, P15, imp15 = run_suite(W15, st15, o15, H, "15SKU")
    s15 = res15.groupby("model")[["WAPE", "MAE", "RMSE", "MASE", "Bias"]].mean().reset_index().sort_values("WAPE")
    write_csv(res15, ST, "global_vs_local_15.csv")
    lp15 = long_predictions(P15, o15, list(MODEL_LABEL))
    RES["E5_4"] = dict(summary=s15.to_dict("records"), dm_global_vs_hw=dm_between(lp15, "Global_LGBM_scaled", "Local_HW", H),
                       importance=imp15.round(5).to_dict(), n_series=W15.shape[1], n_days=n15)

# ================================================================ E5.5
with Timer("E5.5 Cold-start SKU mới"):
    rng = np.random.default_rng(SEED)
    hold = sorted(rng.choice(W.columns, CFG["global_models"]["coldstart_holdout"], replace=False).tolist())
    keep = [c for c in W.columns if c not in hold]
    T0 = origins[-1]
    ftr = make_frame(W[keep].iloc[: T0 + 1], static, list(range(35, T0 - H + 1)), H)
    # (a) chỉ đặc trưng tĩnh + lịch: mục tiêu là mức tuyệt đối
    SF = ["h", "dow", "cat_code", "log_price", "margin", "double_day", "payday", "mid_month"]
    mS = lgb.train({**PARAMS}, lgb.Dataset(ftr[SF], ftr["y"], categorical_feature=["cat_code"]), num_boost_round=400)
    fte = make_frame(W[hold], static, [T0], H)
    pa = mS.predict(fte[SF])
    # (b) trung bình ngành × thứ
    lp_k = W[keep].iloc[: T0 + 1].stack().rename("y").reset_index().rename(columns={"unique_id": "sid"})
    lp_k["cat"] = lp_k.sid.str.rsplit("_", n=1).str[0]; lp_k["dow"] = lp_k.ds.dt.dayofweek
    cm = lp_k.groupby(["cat", "dow"]).y.mean()
    fte["cat"] = fte.sid.str.rsplit("_", n=1).str[0]
    pb = np.array([cm[(c, d)] for c, d in zip(fte.cat, fte.dow)])
    # (c) warm-start 7 ngày: m28 thay bằng trung bình 7 ngày quan sát, đặc trưng tỷ lệ tính trên 7 ngày
    mG = fit_global(ftr, True)
    f7 = fte.copy()
    m7 = W[hold].iloc[T0 - 6: T0 + 1].mean().reindex(f7.sid).values
    last = W[hold].iloc[T0].reindex(f7.sid).values
    f7["m28"] = m7; f7["last_r"] = last / m7; f7["m7_r"] = 1.0
    sd = []
    for s, h in zip(f7.sid, f7.h):
        i = T0 - ((7 - h % 7) % 7)
        sd.append(W[s].iloc[i])
    f7["same_dow4_r"] = np.array(sd) / m7; f7["slope_r"] = 0.0; f7["s28_r"] = W[hold].iloc[T0 - 6: T0 + 1].std().reindex(f7.sid).values / m7
    pc = mG.predict(f7[FEATS]) * f7["m28"].values
    fd = make_frame(W, static, [T0], H); fd = fd[fd.sid.isin(hold)].reset_index(drop=True)
    pd_ = mG.predict(fd[FEATS]) * fd["m28"].values
    y = fte.y.values
    cold = {k: point_metrics(y, p) for k, p in {"ColdStart_static": pa, "Category_x_dow": pb, "WarmStart_7d": pc, "Full_history": pd_}.items()}
    RES["E5_5"] = dict(holdout=hold, results=cold)
    fig, ax = plt.subplots(figsize=(6.4, 2.6))
    ks = list(cold); ax.bar(range(4), [cold[k]["WAPE"] for k in ks], color=[GREY, PAL[2], PAL[1], PAL[0]])
    ax.set_xticks(range(4)); ax.set_xticklabels(["Chỉ đặc trưng tĩnh", "TB ngành × thứ", "Warm-start 7 ngày", "Đủ lịch sử"], fontsize=7)
    for i, k in enumerate(ks):
        ax.text(i, cold[k]["WAPE"], vn(cold[k]['WAPE']), ha="center", va="bottom", fontsize=7)
    ax.set_ylabel("WAPE (%)"); ax.set_title("Dự báo cho 10 SKU mới bị giữ lại khỏi huấn luyện (H = 14)")
    savefig(fig, ST, "s05_coldstart.png")

# ================================================================ E5.6
with Timer("E5.6 Ngày đôi trong dữ liệu 100 SKU"):
    import statsmodels.formula.api as smf
    L = W.stack().rename("y").reset_index().rename(columns={"unique_id": "sid"})
    L["ly"] = np.log(L.y); L["dow"] = L.ds.dt.dayofweek; L["t"] = (L.ds - L.ds.min()).dt.days
    L["dd"] = (L.ds.dt.day == L.ds.dt.month).astype(int); L["pay"] = (L.ds.dt.day == 25).astype(int); L["mid"] = (L.ds.dt.day == 15).astype(int)
    L["cat"] = L.sid.str.rsplit("_", n=1).str[0]
    L["rel"] = L.y / L.groupby("sid").y.transform(lambda s_: s_.rolling(7, center=True, min_periods=4).mean())
    naive = stats.ttest_ind(L.loc[L.dd == 1, "rel"].dropna(), L.loc[L.dd == 0, "rel"].dropna(), equal_var=False)
    groups = L.ds.dt.strftime("%Y%m%d").astype(int)
    fe = smf.ols("ly ~ C(sid) + C(dow) + t:C(sid) + dd + pay + mid", L).fit(cov_type="cluster", cov_kwds={"groups": groups})
    bycat = {}
    for c, g in L.groupby("cat"):
        r = smf.ols("ly ~ C(sid) + C(dow) + t:C(sid) + dd + pay + mid", g).fit(cov_type="cluster", cov_kwds={"groups": g.ds.dt.strftime("%Y%m%d").astype(int)})
        bycat[c] = {k: dict(coef=float(r.params[k]), p=float(r.pvalues[k])) for k in ["dd", "pay", "mid"]}
    dates = L.loc[L.dd == 1].drop_duplicates("ds")
    RES["E5_6"] = dict(naive_rel=L.groupby("dd").rel.mean().to_dict(), naive_t=float(naive.statistic), naive_p=float(naive.pvalue),
                       double_dates=[dict(date=str(r.ds.date()), dow=int(r.dow)) for r in dates.itertuples()],
                       fe={k: dict(coef=float(fe.params[k]), se=float(fe.bse[k]), p=float(fe.pvalues[k]), pct=float(np.exp(fe.params[k]) - 1)) for k in ["dd", "pay", "mid"]},
                       fe_by_cat=bycat, weekend_share_double=float((dates.dow >= 5).mean()))

write_json(RES, ST, "results.json")
log_run(ST, {})
print(summ.round(3).to_string()); print(RES["E5_3"]["dm_global_vs_hw"]); print(s15.round(3).to_string()); print({k: round(v["WAPE"], 3) for k, v in cold.items()})
print(upl.round(3).to_string()); print(RES["E5_6"]["fe"], RES["E5_6"]["naive_p"])
