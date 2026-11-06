"""Stage 06 – Dự báo xác suất cho chiến dịch (slide Chương 4).

E6.0 Kiểm chứng ví dụ tính tay (Z-score tr.10–20; Quantile loss tr.36–41; Newsvendor tr.56–65)
E6.1 Năm họ dự báo phân vị cầu 100 SKU (3 gốc × H = 14): Z-chuẩn, Heuristic GV (script ai_train_reorder_point.py),
     Quantile LightGBM toàn cục, DeepAR, phân vị phần dư thực nghiệm
E6.2 Chuẩn bị hàng cho chiến dịch theo Newsvendor: lợi nhuận, fill-rate, vốn hàng đặt
E6.3 Reorder point với lead time L ∈ {3, 7, 14}
E6.4 Rủi ro tài chính của việc tăng ngân sách quảng cáo (bootstrap): xác suất lỗ theo ngành
E6.5 Dự báo phân phối GMV ngày Mega Sale (kiểm tra bỏ-một-ngày) và lưới kịch bản quảng cáo × chiết khấu
E6.6 Tổng mức bán lẻ Việt Nam: walk-forward 2 gốc × 12 tháng và dự báo kịch bản 10/2026–9/2027 có khoảng 80%
"""
import logging
import time
import warnings

import numpy as np
import pandas as pd
from scipy import stats

from src.common import CFG, GREY, INTERIM, PAL, SEED, Timer, log_run, plt, savefig, write_csv, write_json
from src.data import io
from src.evaluation.metrics import dm_test, pinball, point_metrics, winkler
from src.features.build import FEATS, make_frame, static_100
from src.inventory.policy import QS, interp_quantile, profit, strategy_label
from src.marketing import response as MR
from src.models import macro
from src.models.train import fit_global, quantile_lgbm
from src.scenarios.megasale import CampaignModel

warnings.filterwarnings("ignore")
for lg in ("pytorch_lightning", "lightning.pytorch", "lightning_fabric"):
    logging.getLogger(lg).setLevel(logging.ERROR)
ST = "06_probabilistic"
H = CFG["global_models"]["horizon"]
RES = {}
CACHE = INTERIM / "cache"; CACHE.mkdir(parents=True, exist_ok=True)

# ================================================================ E6.0
with Timer("E6.0 Ví dụ tính tay Chương 4"):
    y = np.array([100, 110, 120, 130, 110, 150, 100, 170.])
    yh = np.array([y[i - 3:i].mean() for i in range(3, 8)]); err = y[3:] - yh
    bias, sd = err.mean(), err.std(ddof=1)
    ya = np.array([170, 130, 200, 180, 150.])
    fin3 = pd.DataFrame({"SKU": ["SKU_1_Phone", "SKU_2_Cable", "SKU_3_Food"], "p": [30000, 200, 60], "c": [25000, 40, 45], "s": [20000, 0, 10]})
    fin3["q"] = (fin3.p - fin3.c) / ((fin3.p - fin3.c) + (fin3.c - fin3.s))
    RES["E6_0"] = dict(errors=err.tolist(), bias=bias, var=err.var(ddof=1), sd=sd, y9=y[-3:].mean(),
                       p90=y[-3:].mean() + bias + stats.norm.ppf(.9) * sd, p90_rounded_z=y[-3:].mean() + bias + 1.28 * sd,
                       pinball_q09=pinball(ya, np.full(5, 150.), .9).tolist(), pinball_q09_mean=float(pinball(ya, np.full(5, 150.), .9).mean()),
                       newsvendor3=fin3.to_dict("records"))

# ================================================================ E6.1
W = io.hist100_wide()
fin = io.fin100()
static = static_100(fin)
n = len(W); origins = [n - 1 - k * H for k in range(CFG["global_models"]["n_origins"], 0, -1)]
store = {}
with Timer("E6.1a Z-chuẩn, phân vị phần dư, Quantile LightGBM"):
    for T0 in origins:
        fte = make_frame(W, static, [T0], H)
        ftr = make_frame(W.iloc[: T0 + 1], static, list(range(35, T0 - H + 1)), H)
        m28 = fte.m28.values
        p_point = fit_global(ftr).predict(fte[FEATS]) * m28
        inner = []
        for k in [1, 2, 3]:                                   # sai số kiểm định nội bộ ở 3 gốc trước đó (không rò rỉ)
            Ti = T0 - k * H
            mi = fit_global(make_frame(W.iloc[: Ti + 1], static, list(range(35, Ti - H + 1)), H))
            fi = make_frame(W.iloc[: Ti + H + 1], static, [Ti], H)
            fi["pred"] = mi.predict(fi[FEATS]) * fi.m28.values; fi["err"] = fi.y - fi.pred; fi["err_r"] = fi.err / fi.m28
            inner.append(fi)
        inner = pd.concat(inner)
        bs = inner.groupby("sid").err.agg(["mean", "std"])
        b_ = fte.sid.map(bs["mean"]).values; s_ = fte.sid.map(bs["std"]).values
        Pz = {q: p_point + b_ + stats.norm.ppf(q) * s_ for q in QS}
        Pe = {q: p_point + fte.h.map(inner.groupby("h").err_r.quantile(q)).values * m28 for q in QS}
        raw = quantile_lgbm(ftr, fte, QS, rounds=400)
        cross = float((np.diff(raw, axis=1) < 0).any(1).mean())
        srt = np.sort(raw, 1)
        store[T0] = dict(frame=fte[["sid", "h", "dow", "m28", "date"]].assign(y=fte.y.values), point=p_point, Z=Pz, EMP=Pe,
                         QLGBM={q: srt[:, i] for i, q in enumerate(QS)}, qlgbm_cross=cross, inner=inner)

with Timer("E6.1b DeepAR và LSTM-MQ (neuralforecast)"):
    dfn = io.gv("hist100")[["unique_id", "ds", "y"]]
    fd, fl = CACHE / "cv_deepar.parquet", CACHE / "cv_lstm_mq.parquet"
    neural_ok = True
    if not (fd.exists() and fl.exists()):
        try:
            from neuralforecast import NeuralForecast
            from neuralforecast.losses.pytorch import DistributionLoss, MQLoss
            from neuralforecast.models import LSTM, DeepAR
            nf = NeuralForecast(models=[DeepAR(h=H, input_size=28, lstm_hidden_size=64, scaler_type="robust", max_steps=CFG["probabilistic"]["deepar_max_steps"],
                                               loss=DistributionLoss(distribution="StudentT", level=[20, 40, 60, 80]), enable_progress_bar=False,
                                               random_seed=SEED, alias="DeepAR")], freq="D")
            nf.cross_validation(df=dfn, n_windows=3, step_size=H, level=[20, 40, 60, 80]).to_parquet(fd)
            nf2 = NeuralForecast(models=[LSTM(h=H, input_size=28, encoder_hidden_size=64, decoder_hidden_size=64, loss=MQLoss(quantiles=[0.1, 0.5, 0.9]),
                                              max_steps=150, scaler_type="standard", enable_progress_bar=False, random_seed=SEED, alias="LSTMMQ")], freq="D")
            nf2.cross_validation(df=dfn, n_windows=3, step_size=H).to_parquet(fl)
        except Exception as ex:  # noqa: BLE001
            print("Bỏ qua DeepAR/LSTM:", ex); neural_ok = False
    if neural_ok:
        cvd, cvl = pd.read_parquet(fd), pd.read_parquet(fl)
        cutoffs = sorted(cvd.cutoff.unique())
        for T0, cut in zip(origins, cutoffs):
            assert W.index[T0] == pd.Timestamp(cut)
            fr = store[T0]["frame"]
            key = list(zip(fr.sid, fr.date))
            d = cvd[cvd.cutoff == cut].set_index(["unique_id", "ds"])
            Pd = {0.5: d.loc[key, "DeepAR-median"].values}
            for lv in [20, 40, 60, 80]:
                Pd[round(.5 - lv / 200, 2)] = d.loc[key, f"DeepAR-lo-{lv}"].values
                Pd[round(.5 + lv / 200, 2)] = d.loc[key, f"DeepAR-hi-{lv}"].values
            store[T0]["DeepAR"] = {q: Pd[q] for q in QS}
            lq = cvl[cvl.cutoff == cut].set_index(["unique_id", "ds"])
            lmed = lq.loc[key, [c for c in lq.columns if "median" in c][0]].values
            # Heuristic GV – tái lập ai_train_reorder_point.py: P50 = LSTM, kẹp ±20% TB lịch sử, ×1,3 cuối tuần, σ = 15%·TB(P50)·√t
            hist_mean = fr.sid.map(W.iloc[: T0 + 1].mean()).values
            p50 = np.clip(lmed, .8 * hist_mean, 1.2 * hist_mean) * np.where(fr.dow.values >= 5, 1.3, 1.0)
            unc = pd.Series(p50).groupby(fr.sid.values).transform("mean").values * .15 * np.sqrt(fr.h.values)
            store[T0]["HeurGV"] = {q: np.maximum(0, p50 + stats.norm.ppf(q) * unc) for q in QS}
            store[T0]["lstm_cross"] = float((lq.loc[key, [c for c in lq.columns if "hi-80" in c][0]].values < lq.loc[key, [c for c in lq.columns if "lo-80" in c][0]].values).mean())
    MODELS = ["Z", "HeurGV", "QLGBM", "DeepAR", "EMP"] if neural_ok else ["Z", "QLGBM", "EMP"]

with Timer("E6.1c Đánh giá dự báo xác suất"):
    rows, calib, cone, bycat = [], [], [], []
    for T0 in origins:
        fr = store[T0]["frame"]; yv = fr.y.values; cat = fr.sid.str.rsplit("_", n=1).str[0].values
        for m in MODELS:
            P = store[T0][m]
            pin = {q: float(pinball(yv, P[q], q).mean()) for q in QS}
            rows.append(dict(origin=str(W.index[T0].date()), model=m, mean_pinball=np.mean(list(pin.values())), pin10=pin[.1], pin50=pin[.5], pin90=pin[.9],
                             cov80=float(np.mean((yv >= P[.1]) & (yv <= P[.9]))), width80=float(np.mean(P[.9] - P[.1])),
                             rel_width=float(np.mean(P[.9] - P[.1]) / yv.mean()), winkler80=float(winkler(yv, P[.1], P[.9], .2).mean()),
                             mae_p50=float(np.mean(np.abs(yv - P[.5])))))
            for q in QS:
                calib.append(dict(model=m, q=q, hit=float(np.mean(yv <= P[q]))))
            tmp = pd.DataFrame({"h": fr.h, "w": (P[.9] - P[.1]) / fr.m28, "cov": (yv >= P[.1]) & (yv <= P[.9])})
            for hh, g in tmp.groupby("h"):
                cone.append(dict(model=m, h=hh, rel_w=g.w.mean(), cov=g["cov"].mean()))
            for c in np.unique(cat):
                k = cat == c
                bycat.append(dict(model=m, cat=c, cov80=np.mean((yv[k] >= P[.1][k]) & (yv[k] <= P[.9][k])),
                                  rel_width=np.mean(P[.9][k] - P[.1][k]) / yv[k].mean(),
                                  pinball_rel=np.mean([pinball(yv[k], P[q][k], q).mean() for q in QS]) / yv[k].mean()))
    ev = pd.DataFrame(rows)
    summ = ev.groupby("model")[["mean_pinball", "pin10", "pin50", "pin90", "cov80", "width80", "rel_width", "winkler80", "mae_p50"]].mean().reset_index().sort_values("mean_pinball")
    cal = pd.DataFrame(calib).groupby(["model", "q"]).hit.mean().unstack(0)
    cone = pd.DataFrame(cone).groupby(["model", "h"]).mean().reset_index()
    bycat = pd.DataFrame(bycat).groupby(["cat", "model"]).mean().reset_index()

    def loss_vec(m):
        return np.concatenate([np.mean([pinball(store[T]["frame"].y.values, store[T][m][q], q) for q in QS], 0) for T in origins])

    pairs = [("QLGBM", "Z"), ("QLGBM", "EMP"), ("EMP", "Z")] + ([("QLGBM", "HeurGV"), ("QLGBM", "DeepAR"), ("DeepAR", "HeurGV")] if neural_ok else [])
    dm = {f"{a}-{b}": dm_test(loss_vec(a), loss_vec(b)) for a, b in pairs}
    write_csv(ev, ST, "prob_eval_by_origin.csv"); write_csv(summ, ST, "prob_eval_summary.csv")
    write_csv(cal.reset_index(), ST, "calibration.csv"); write_csv(cone, ST, "uncertainty_cone.csv"); write_csv(bycat, ST, "prob_eval_bycat.csv")
    RES["E6_1"] = dict(summary=summ.to_dict("records"), dm=dm, qlgbm_crossing_before_sort=[store[T]["qlgbm_cross"] for T in origins],
                       lstm_crossing=[store[T].get("lstm_cross") for T in origins], models=MODELS, neural=neural_ok)
    # lưu dự báo phân vị gốc cuối cho dashboard
    T0 = origins[-1]; fr = store[T0]["frame"].copy()
    for m in MODELS:
        for q in (.1, .5, .9):
            fr[f"{m}_P{int(q * 100)}"] = store[T0][m][q]
    write_csv(fr.round(3), ST, "quantile_forecasts_last_origin.csv")

# ================================================================ E6.2
with Timer("E6.2 Chuẩn bị hàng theo Newsvendor"):
    fm = fin.rename(columns={"SKU": "sid"})
    pol_rows = []
    for T0 in origins:
        fr = store[T0]["frame"].merge(fm[["sid", "Price", "Cost", "Salvage", "q_star", "cat"]], on="sid", how="left")
        D = fr.y.values; p, c, s, qs_ = fr.Price.values, fr.Cost.values, fr.Salvage.values, fr.q_star.values
        pols = {"Đặt P50 (dự báo điểm)": store[T0]["QLGBM"][.5], "Đặt P90 cho mọi SKU": store[T0]["QLGBM"][.9],
                "q* – Z chuẩn": interp_quantile(store[T0]["Z"], qs_), "q* – Quantile LGBM": interp_quantile(store[T0]["QLGBM"], qs_),
                "q* – Phân vị phần dư": interp_quantile(store[T0]["EMP"], qs_), "Oracle (biết trước cầu)": D}
        if neural_ok:
            avail = np.array([.1, .3, .5, .7, .9]); closest = avail[np.abs(avail[None, :] - qs_[:, None]).argmin(1)]
            pols["GV: phân vị gần q* (dải heuristic)"] = np.select([closest == a for a in avail], [store[T0]["HeurGV"][a] for a in avail])
            pols["q* – DeepAR"] = interp_quantile(store[T0]["DeepAR"], qs_)
        for name, Q in pols.items():
            Q = np.round(np.maximum(Q, 0)); pr = profit(Q, D, p, c, s)
            for cc in ["ALL"] + sorted(fr.cat.unique()):
                k = np.ones(len(D), bool) if cc == "ALL" else (fr.cat.values == cc)
                pol_rows.append(dict(origin=T0, policy=name, cat=cc, profit=pr[k].sum() / 1000, fill=np.minimum(Q, D)[k].sum() / D[k].sum(),
                                     inv_capital=(c * Q)[k].sum() / 1000, salvage_loss=((c - s) * np.maximum(Q - D, 0))[k].sum() / 1000,
                                     lost_margin=((p - c) * np.maximum(D - Q, 0))[k].sum() / 1000))
    pol = pd.DataFrame(pol_rows)
    agg = pol.groupby(["policy", "cat"])[["profit", "inv_capital", "salvage_loss", "lost_margin"]].sum()
    agg["fill"] = pol.groupby(["policy", "cat"]).fill.mean()
    orc = agg.xs("Oracle (biết trước cầu)", level=0).profit
    agg["profit_pct_oracle"] = agg.profit / agg.index.get_level_values(1).map(orc).values * 100
    agg = agg.reset_index()
    write_csv(agg, ST, "newsvendor_policies.csv")
    fs = fm.assign(strategy=strategy_label(fm.q_star))
    write_csv(fs[["sid", "cat", "Price", "Cost", "Salvage", "Cu", "Co", "q_star", "strategy"]], ST, "sku_critical_ratio.csv")
    RES["E6_2"] = dict(table=agg.to_dict("records"), strategy_counts=fs.strategy.value_counts().to_dict(),
                       q_by_cat=fs.groupby("cat").q_star.describe().reset_index().to_dict("records"),
                       unit="triệu VNĐ (giá/vốn trong financial_metadata là nghìn VNĐ/đơn vị, slide Ch4 tr.60)")

# ================================================================ E6.3
with Timer("E6.3 Reorder point"):
    rop_rows = []
    for L in [3, 7, 14]:
        for T0 in origins:
            fr = store[T0]["frame"]; inner = store[T0]["inner"]
            k = (fr.h <= L).values
            sumY = fr[k].groupby("sid").y.sum()
            sumP = pd.Series(store[T0]["point"][k], index=fr[k].sid.values).groupby(level=0).sum()
            m28 = fr.groupby("sid").m28.first()
            ie = inner[inner.h <= L].groupby(["T", "sid"]).agg(e=("err", "sum"), m=("m28", "first")); ie["er"] = ie.e / ie.m
            sd1 = inner.groupby("sid").err.std()
            for sl in [0.8, 0.9, 0.95]:
                cands = [("Chuẩn √L", sumP + stats.norm.ppf(sl) * sd1.reindex(sumP.index) * np.sqrt(L)),
                         ("Thực nghiệm", sumP + ie.er.quantile(sl) * m28.reindex(sumP.index))]
                if neural_ok:
                    qd = 0.9 if sl > .85 else min(QS, key=lambda x: abs(x - sl))
                    cands.append(("Tổng phân vị DeepAR", pd.Series(store[T0]["DeepAR"][qd][k], index=fr[k].sid.values).groupby(level=0).sum()))
                for nm, rop in cands:
                    ss = (rop - sumP).reindex(sumY.index)
                    rop_rows.append(dict(L=L, target=sl, method=nm, origin=T0, CSL=float((sumY <= rop.reindex(sumY.index)).mean()),
                                         mean_SS=float(ss.mean()), mean_SS_rel=float((ss / sumP.reindex(sumY.index)).mean())))
    rop = pd.DataFrame(rop_rows).groupby(["L", "target", "method"])[["CSL", "mean_SS", "mean_SS_rel"]].mean().reset_index()
    write_csv(rop, ST, "reorder_point.csv")
    ac = []
    for T0 in origins:
        for _, g in store[T0]["inner"].sort_values(["T", "sid", "h"]).groupby(["T", "sid"]):
            e_ = g.err_r.values
            if len(e_) > 3:
                ac.append(np.corrcoef(e_[:-1], e_[1:])[0, 1])
    RES["E6_3"] = dict(table=rop.to_dict("records"), acf1_mean=float(np.nanmean(ac)))

# ================================================================ E6.4
with Timer("E6.4 Rủi ro tài chính khi tăng ngân sách quảng cáo"):
    d90 = io.ecommerce_90days()
    u = io.unit_econ()
    cogs_ratio = float(u.COGS.sum() / u.GMV.sum())
    gm_order_90 = float(d90.AOV.mean() * (1 - cogs_ratio))               # biên gộp trước quảng cáo của một đơn (toàn shop)
    B = CFG["marketing"]["bootstrap"]
    shop = []
    for extra in [1, 2, 5, 10]:
        r = MR.bootstrap_campaign(d90, extra, gm_order_90, B=B, seed=SEED)
        r.pop("samples"); shop.append(dict(level="Toàn shop (90 ngày)", extra_ads=extra, **r))
    # theo ngành (panel): bootstrap theo cặp trong từng ngành, biên gộp/đơn từ unit economics
    p = io.panel()
    ue = pd.DataFrame(MR.__dict__.get("dummy", [])) if False else None
    gm_cat = (u.groupby("Category").apply(lambda x: (x.GMV.sum() - x.COGS.sum()) / x.Orders.sum())).to_dict()
    rng = np.random.default_rng(SEED)
    cat_rows, samples = [], {}
    for c, g in p.groupby("Category"):
        X = np.column_stack([np.ones(len(g)), g.Ad_Spend.values]); yv = g.Orders.values
        bs = np.empty(B)
        for b in range(B):
            i = rng.integers(0, len(g), len(g)); bs[b] = np.linalg.lstsq(X[i], yv[i], rcond=None)[0][1]
        prof = bs * gm_cat[c] - 1.0                                       # lợi nhuận tăng thêm trên 1 triệu VNĐ quảng cáo
        samples[c] = prof
        cat_rows.append(dict(Category=c, slope_mean=bs.mean(), slope_p05=np.quantile(bs, .05), slope_p95=np.quantile(bs, .95), gross_margin_order=gm_cat[c],
                             profit_per_ad_mean=prof.mean(), profit_per_ad_p05=np.quantile(prof, .05), profit_per_ad_p50=np.quantile(prof, .5),
                             profit_per_ad_p95=np.quantile(prof, .95), p_loss=float((prof < 0).mean())))
    cat_rows = pd.DataFrame(cat_rows)
    write_csv(pd.DataFrame(shop), ST, "ad_risk_shop.csv"); write_csv(cat_rows, ST, "ad_risk_category.csv")
    RES["E6_4"] = dict(cogs_ratio=cogs_ratio, gm_order_90=gm_order_90, shop=shop, category=cat_rows.to_dict("records"), B=B)

# ================================================================ E6.5
with Timer("E6.5 Phân phối GMV ngày Mega Sale"):
    cmod = CampaignModel(d90, cogs_ratio, seed=SEED)
    loo = []
    for md in d90.loc[d90.Mega == 1, "Date"]:
        tr = d90[d90.Date != md]
        cm_ = CampaignModel(tr, cogs_ratio, seed=SEED)
        row = d90[d90.Date == md].iloc[0]
        pr = cm_.predict(row.Ad_Spend, row.Discount, 1)
        loo.append(dict(date=str(md.date()), actual_orders=int(row.Orders), actual_gmv=float(row.GMV), **{k: pr[k] for k in ["orders_p10", "orders_p50", "orders_p90", "gmv_p10", "gmv_p50", "gmv_p90"]},
                        covered_gmv=bool(pr["gmv_p10"] <= row.GMV <= pr["gmv_p90"])))
    normal = d90[d90.Mega == 0]
    ADS, DISC = [5, 10, 15, 20, 25, 30, 35, 40], [0.1, 0.2, 0.3, 0.4, 0.5]
    grid = pd.concat([cmod.grid(ADS, DISC, mega=1, cost_basis="list"), cmod.grid(ADS, DISC, mega=1, cost_basis="gmv")], ignore_index=True)
    grid_fee = cmod.grid(ADS, DISC, mega=1, platform_fee=0.1, cost_basis="list")
    base = cmod.predict(float(normal.Ad_Spend.mean()), float(normal.Discount.mean()), 0)
    write_csv(grid, ST, "megasale_scenarios.csv"); write_csv(grid_fee, ST, "megasale_scenarios_fee10.csv"); write_csv(pd.DataFrame(loo), ST, "megasale_loo.csv")
    RES["E6_5"] = dict(model=dict(params=cmod.m_orders.params.to_dict(), bse=cmod.m_orders.bse.to_dict(), pvalues=cmod.m_orders.pvalues.to_dict(), r2=cmod.m_orders.rsquared,
                                  aov_params=cmod.m_aov.params.to_dict(), aov_p=cmod.m_aov.pvalues.to_dict(), resid_sd=cmod.resid_sd, range=cmod.range),
                       loo=loo, base_day=base, kappa=cmod.kappa, cogs_ratio=cogs_ratio,
                       best_cm_list=grid[(grid.cost_basis == "list") & ~grid.extrapolation].sort_values("cm_p50").iloc[-1].to_dict(),
                       best_cm_gmv=grid[(grid.cost_basis == "gmv") & ~grid.extrapolation].sort_values("cm_p50").iloc[-1].to_dict(),
                       observed_mega=[cmod.predict(float(r.Ad_Spend), float(r.Discount), 1) for r in d90[d90.Mega == 1].itertuples()])

# ================================================================ E6.6
with Timer("E6.6 Tổng mức bán lẻ Việt Nam: walk-forward và kịch bản"):
    yg = io.gso_monthly().set_index("ds").value.asfreq("MS")
    rows, paths = [], []
    for T in [pd.Timestamp("2024-09-01"), pd.Timestamp("2025-09-01")]:
        tr = yg[:T]; idx_f = pd.date_range(T + pd.offsets.MonthBegin(1), periods=12, freq="MS"); act = yg.reindex(idx_f)
        for name, fn in macro.MODELS.items():
            p_, lo, hi = fn(tr, 12)
            mk = act.notna().values
            mm = point_metrics(act.values[mk], p_[mk])
            cov = float(np.mean((act.values[mk] >= lo[mk]) & (act.values[mk] <= hi[mk]))) if not np.isnan(lo).all() else np.nan
            rows.append(dict(origin=str(T.date())[:7], model=name, n=int(mk.sum()), cov80=cov, sum_err_pct=float((p_[mk].sum() / act.values[mk].sum() - 1) * 100), **mm))
            paths.append(pd.DataFrame({"origin": str(T.date())[:7], "model": name, "ds": idx_f, "f": p_, "lo": lo, "hi": hi, "y": act.values}))
    bt = pd.DataFrame(rows); paths = pd.concat(paths)
    write_csv(bt, ST, "gso_backtest.csv"); write_csv(paths, ST, "gso_backtest_paths.csv")
    idx_f = pd.date_range("2026-10-01", periods=12, freq="MS")
    p1, l1, h1 = macro.fc_sarima(yg, 12); p2, l2, h2 = macro.fc_prophet(yg, 12); p3, l3, h3 = macro.fc_ets(yg, 12)
    ens = (p1 + p2 + p3) / 3
    fut = pd.DataFrame({"ds": idx_f.strftime("%Y-%m"), "SARIMA": p1, "SARIMA_lo": l1, "SARIMA_hi": h1, "Prophet": p2, "Prophet_lo": l2, "Prophet_hi": h2,
                        "ETS": p3, "ETS_lo": l3, "ETS_hi": h3, "Ensemble": ens})
    write_csv(fut, ST, "gso_forecast.csv")
    ann = io.gso_annual()
    q4_2025 = float(yg["2025-10":"2025-12"].sum())
    RES["E6_6"] = dict(backtest=bt.to_dict("records"), summary=bt.groupby("model")[["MAPE", "WAPE", "Bias", "cov80"]].mean().reset_index().to_dict("records"),
                       forecast=fut.to_dict("records"), q4_2026_ens=float(ens[:3].sum()), q4_2025=q4_2025, q4_growth=float(ens[:3].sum() / q4_2025 - 1),
                       nov_dec_2026=float(ens[1:3].sum()), implied_2026_total=float(yg["2026-01":"2026-09"].sum() + ens[:3].sum()),
                       implied_2026_growth=float((yg["2026-01":"2026-09"].sum() + ens[:3].sum()) / ann.value.iloc[-1] - 1),
                       note="Dự báo là đầu ra mô hình, không phải số liệu công bố.")

# ================================================================ Hình
lab = {"Z": "Z-chuẩn", "HeurGV": "Heuristic GV", "QLGBM": "Quantile LGBM", "DeepAR": "DeepAR", "EMP": "Phân vị phần dư"}
fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.7))
o = summ.set_index("model")
ax[0].barh([lab[i] for i in o.index], o.mean_pinball, color=PAL[0]); ax[0].set_title("(a) Pinball TB (9 phân vị)")
ax[1].barh([lab[i] for i in o.index], o.cov80 * 100, color=PAL[2]); ax[1].axvline(80, color=PAL[3], ls="--"); ax[1].set_title("(b) Độ phủ PI 80% (%)")
ax[2].barh([lab[i] for i in o.index], o.rel_width * 100, color=PAL[1]); ax[2].set_title("(c) Độ rộng PI / cầu TB (%)")
for a in ax:
    a.tick_params(labelsize=7)
savefig(fig, ST, "s06_prob_eval.png")
fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.9))
for i, m in enumerate(MODELS):
    ax[0].plot(cal.index, cal[m], marker="o", ms=3, label=lab[m], color=PAL[i])
    g = cone[cone.model == m]; ax[1].plot(g.h, g.rel_w, marker=".", label=lab[m], color=PAL[i])
ax[0].plot([0, 1], [0, 1], color="k", lw=.6, ls="--"); ax[0].set_xlabel("q danh nghĩa"); ax[0].set_ylabel("Tỷ lệ y ≤ P_q"); ax[0].legend(fontsize=6); ax[0].set_title("(a) Hiệu chỉnh")
ax[1].set_xlabel("Chân trời h"); ax[1].set_title("(b) Phễu bất định (P90 − P10)/m28")
savefig(fig, ST, "s06_calibration_cone.png")
tb = agg[agg.cat == "ALL"].set_index("policy").sort_values("profit")
fig, ax = plt.subplots(1, 2, figsize=(7.8, 3.0))
ax[0].barh(tb.index, tb.profit_pct_oracle, color=[PAL[0] if "q*" in i else (GREY if "Oracle" in i else PAL[1]) for i in tb.index]); ax[0].set_title("(a) Lợi nhuận (% Oracle)"); ax[0].tick_params(labelsize=6)
ax[0].set_xlim(80, 101)
ax[1].scatter(tb.inv_capital, tb.profit, color=PAL[0])
for i, r in tb.iterrows():
    if not i.startswith("q*"):
        ax[1].annotate(i.split(" (")[0], (r.inv_capital, r.profit), fontsize=5.5)
ax[1].annotate("Các chính sách q*", (tb[tb.index.str.startswith("q*")].inv_capital.mean(), tb[tb.index.str.startswith("q*")].profit.max()), fontsize=5.5, xytext=(5, 6), textcoords="offset points")
ax[1].set_xlabel("Vốn hàng đặt (triệu VNĐ)"); ax[1].set_ylabel("Lợi nhuận (triệu VNĐ)"); ax[1].set_title("(b) Lợi nhuận – vốn")
savefig(fig, ST, "s06_newsvendor.png")
fig, ax = plt.subplots(1, 2, figsize=(8.4, 3.1))
for i, (c, s_) in enumerate(samples.items()):
    ax[0].hist(s_, bins=60, alpha=.55, color=PAL[i], label=f"{c}: P(lỗ) = {np.mean(s_ < 0):.2f}")
ax[0].axvline(0, color="k", lw=.7); ax[0].legend(fontsize=6); ax[0].set_title("(a) LN tăng thêm / 1 triệu VNĐ QC (bootstrap)")
gl = grid[grid.cost_basis == "list"]
g5 = gl[gl.disc == 0.5].sort_values("ads")
ax[1].fill_between(g5.ads, g5.cm_p10, g5.cm_p90, color=PAL[0], alpha=.2, label="CM P10–P90 (chiết khấu 50%)")
ax[1].plot(g5.ads, g5.cm_p50, color=PAL[0])
for dsc, col in [(0.3, PAL[1]), (0.2, PAL[2])]:
    g3 = gl[gl.disc == dsc].sort_values("ads"); ax[1].plot(g3.ads, g3.cm_p50, color=col, ls="--", label=f"CM P50 (chiết khấu {int(dsc * 100)}% – ngoại suy)")
ax[1].axhline(0, color="k", lw=.6); ax[1].axvspan(cmod.range["ads"][1], 40, color=GREY, alpha=.15, label="Ngoài vùng dữ liệu")
ax[1].set_xlabel("Quảng cáo ngày Mega Sale (triệu VNĐ)"); ax[1].legend(fontsize=6); ax[1].set_title("(b) CM ngày Mega Sale (triệu VNĐ)")
savefig(fig, ST, "s06_campaign_risk.png")
fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.9), gridspec_kw=dict(width_ratios=[1.3, 1]))
ax[0].plot(yg["2023":].index, yg["2023":], color="k", label="Thực tế (Cục Thống kê)")
ax[0].plot(idx_f, ens, color=PAL[0], label="Tổ hợp SARIMA–Prophet–ETS"); ax[0].fill_between(idx_f, l1, h1, color=PAL[1], alpha=.2, label="Khoảng 80% SARIMA")
ax[0].legend(fontsize=6); ax[0].set_title("(a) TMBL 10/2026–9/2027 (nghìn tỷ đồng) – đầu ra mô hình")
sb = bt.groupby("model").MAPE.mean().sort_values()
ax[1].barh(sb.index, sb.values, color=PAL[2]); ax[1].set_title("(b) MAPE (%) walk-forward 2 gốc"); ax[1].tick_params(labelsize=6.5)
savefig(fig, ST, "s06_gso_forecast.png")

write_json(RES, ST, "results.json")
log_run(ST, dict(neural=neural_ok))
print(summ.round(3).to_string()); print(RES["E6_1"]["dm"])
print(agg[agg.cat == "ALL"].sort_values("profit", ascending=False).round(2).to_string())
print(cat_rows.round(3).to_string()); print(pd.DataFrame(shop).round(3).to_string()); print(pd.DataFrame(loo)); print(RES["E6_5"]["best_cm_list"], RES["E6_5"]["best_cm_gmv"], RES["E6_5"]["kappa"])
print(bt.groupby("model")[["MAPE", "Bias", "cov80"]].mean()); print(RES["E6_6"]["q4_growth"], RES["E6_6"]["implied_2026_growth"])
