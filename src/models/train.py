"""Bộ so sánh mô hình toàn cục và cục bộ (walk-forward, chân trời H) và mô hình phân vị."""
from __future__ import annotations

import time
import warnings

import lightgbm as lgb
import numpy as np
import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

from src.common import CFG, SEED
from src.evaluation.metrics import dm_test, point_metrics
from src.features.build import FEATS, FEATS_RAW, LOCAL_FEATS, make_frame

warnings.filterwarnings("ignore")
G = CFG["global_models"]
PARAMS = dict(objective="l2", learning_rate=G["lgbm"]["learning_rate"], num_leaves=G["lgbm"]["num_leaves"],
              min_data_in_leaf=G["lgbm"]["min_data_in_leaf"], feature_fraction=G["lgbm"]["feature_fraction"],
              bagging_fraction=G["lgbm"]["bagging_fraction"], bagging_freq=G["lgbm"]["bagging_freq"], lambda_l2=G["lgbm"]["lambda_l2"],
              verbose=-1, seed=SEED, num_threads=2, deterministic=True, force_row_wise=True)
NB = G["lgbm"]["num_boost_round"]

MODEL_LABEL = {"SNaive7": "Naive mùa vụ 7 ngày", "MA_dow4": "TB cùng thứ 4 tuần", "Local_HW": "Holt-Winters cục bộ",
               "Local_LGBM": "LightGBM cục bộ", "Global_LGBM_raw": "LightGBM toàn cục (thô)", "Global_LGBM_scaled": "LightGBM toàn cục (chuẩn hóa)"}


def fit_global(ftr: pd.DataFrame, scaled: bool = True, params: dict | None = None, rounds: int = NB):
    p = {**PARAMS, **(params or {})}
    if scaled:
        return lgb.train(p, lgb.Dataset(ftr[FEATS], ftr["y_r"], categorical_feature=["cat_code"]), num_boost_round=rounds)
    return lgb.train(p, lgb.Dataset(ftr[FEATS_RAW], ftr["y"], categorical_feature=["cat_code"]), num_boost_round=rounds)


def holt_winters(series: np.ndarray, H: int) -> np.ndarray:
    try:
        hw = ExponentialSmoothing(series, trend="add", seasonal="add", seasonal_periods=7, damped_trend=True).fit(optimized=True)
        return np.asarray(hw.forecast(H))
    except Exception:  # noqa: BLE001
        return np.repeat(series[-7:].mean(), H)


def run_suite(wide: pd.DataFrame, static: pd.DataFrame, test_origins, H: int, tag: str):
    out, preds = [], {}
    imp = None
    for T0 in test_origins:
        tr_orig = list(range(G["min_train_origin"], T0 - H + 1))
        ftr = make_frame(wide.iloc[: T0 + 1], static, tr_orig, H)
        fte = make_frame(wide, static, [T0], H)
        y = fte["y"].values
        col = {s: i for i, s in enumerate(wide.columns)}
        p_snaive = np.array([wide.values[T0 - ((7 - h % 7) % 7), col[s]] for s, h in zip(fte["sid"], fte["h"])])
        p_ma = fte["same_dow4"].values
        t0 = time.time(); mdl = fit_global(ftr, True); p_glob = mdl.predict(fte[FEATS]) * fte["m28"].values; tg = time.time() - t0
        mdl_raw = fit_global(ftr, False); p_raw = mdl_raw.predict(fte[FEATS_RAW])
        t0 = time.time(); p_loc = np.zeros(len(fte))
        for s in wide.columns:
            a = ftr[ftr["sid"] == s]; b = (fte["sid"] == s).values
            ml = lgb.train({**PARAMS, "min_data_in_leaf": 10, "num_leaves": 7}, lgb.Dataset(a[LOCAL_FEATS], a["y_r"]), num_boost_round=150)
            p_loc[b] = ml.predict(fte.loc[b, LOCAL_FEATS]) * fte.loc[b, "m28"].values
        tl = time.time() - t0
        t0 = time.time(); p_hw = np.zeros(len(fte))
        for s in wide.columns:
            fc = holt_winters(wide[s].iloc[: T0 + 1].values, H)
            b = (fte["sid"] == s).values; p_hw[b] = fc[fte.loc[b, "h"].values - 1]
        th = time.time() - t0
        scale = {s: np.mean(np.abs(wide[s].iloc[7: T0 + 1].values - wide[s].iloc[: T0 + 1 - 7].values)) for s in wide.columns}
        sc = fte["sid"].map(scale).values
        for name, p in {"SNaive7": p_snaive, "MA_dow4": p_ma, "Local_HW": p_hw, "Local_LGBM": p_loc,
                        "Global_LGBM_raw": p_raw, "Global_LGBM_scaled": p_glob}.items():
            mm = point_metrics(y, p)
            mm["MASE"] = float(np.mean(np.abs(y - p) / sc))
            out.append(dict(tag=tag, origin=str(wide.index[T0].date()), model=name, **mm))
            preds[(T0, name)] = p
        out[-1].update(train_rows=len(ftr), t_global_s=tg, t_local_s=tl, t_hw_s=th)
        preds[(T0, "y")] = y
        preds[(T0, "frame")] = fte[["sid", "h", "date", "m28"]].copy()
        if T0 == test_origins[-1]:
            imp = pd.Series(mdl.feature_importance("gain"), index=FEATS)
            imp = imp / imp.sum()
    return pd.DataFrame(out), preds, imp


def long_predictions(preds: dict, origins, models) -> pd.DataFrame:
    rows = []
    for T0 in origins:
        fr = preds[(T0, "frame")].copy(); fr["origin"] = T0; fr["y"] = preds[(T0, "y")]
        for m in models:
            fr[m] = preds[(T0, m)]
        rows.append(fr)
    return pd.concat(rows, ignore_index=True)


def dm_between(lp: pd.DataFrame, a: str, b: str, H: int) -> dict:
    """DM trên tổn thất |e|: (i) gộp mọi điểm (SKU × ngày); (ii) gộp chéo – lấy trung bình chéo theo SKU cho từng (gốc, h),
    sắp theo thời gian và dùng phương sai HAC độ trễ H − 1 (sai số của các chân trời từ cùng một gốc tương quan với nhau)."""
    d = lp.assign(la=np.abs(lp["y"] - lp[a]), lb=np.abs(lp["y"] - lp[b]))
    pooled = dm_test(d["la"].values, d["lb"].values, h=1)
    agg = d.groupby(["origin", "h"])[["la", "lb"]].mean().sort_index()
    cons = dm_test(agg["la"].values, agg["lb"].values, h=H)
    return dict(pooled=pooled, aggregated=cons)


def quantile_lgbm(ftr: pd.DataFrame, fte: pd.DataFrame, qs, rounds: int = 300) -> np.ndarray:
    P = np.zeros((len(fte), len(qs)))
    for j, q in enumerate(qs):
        m = lgb.train({**PARAMS, "objective": "quantile", "alpha": q}, lgb.Dataset(ftr[FEATS], ftr["y_r"], categorical_feature=["cat_code"]),
                      num_boost_round=rounds)
        P[:, j] = m.predict(fte[FEATS]) * fte["m28"].values
    return P
