"""Đặc trưng cho mô hình toàn cục (direct multi-horizon, chuẩn hóa quy mô – slide Ch3 tr.69–72) và đặc trưng khuyến mãi."""
from __future__ import annotations

import numpy as np
import pandas as pd

from src.data.io import calendar_features

FEATS = ["h", "dow", "last_r", "m7_r", "same_dow4_r", "slope_r", "s28_r", "cat_code", "log_price", "margin", "double_day", "payday", "mid_month"]
FEATS_RAW = ["h", "dow", "last", "m7", "m28", "same_dow4", "slope", "s28", "cat_code", "log_price", "margin", "double_day", "payday", "mid_month"]
LOCAL_FEATS = ["h", "dow", "last_r", "m7_r", "same_dow4_r", "slope_r", "s28_r", "double_day", "payday", "mid_month"]


def make_frame(wide: pd.DataFrame, static: pd.DataFrame, origins, H: int, need_target: bool = True) -> pd.DataFrame:
    """Mỗi dòng = (chuỗi, gốc T, chân trời h). Chỉ dùng thông tin đến T (không rò rỉ)."""
    rows = []
    vals = wide.values
    dates = wide.index
    x = np.arange(28)
    for T in origins:
        hist = vals[: T + 1]
        last = hist[-1]; m7 = hist[-7:].mean(0); m28 = hist[-28:].mean(0); s28 = hist[-28:].std(0)
        slope = ((x - x.mean())[:, None] * (hist[-28:] - m28)).sum(0) / ((x - x.mean()) ** 2).sum()
        for h in range(1, H + 1):
            d = T + h
            if need_target and d >= len(vals):
                continue
            idx = [T - ((7 - h % 7) % 7) - 7 * k for k in range(4)]
            sd = np.stack([vals[i] for i in idx if i >= 0]).mean(0)
            tgt = dates[T] + pd.Timedelta(days=h)
            rows.append(pd.DataFrame({"sid": wide.columns, "T": T, "h": h, "date": tgt, "dow": tgt.dayofweek,
                                      "double_day": int(tgt.day == tgt.month), "payday": int(tgt.day == 25), "mid_month": int(tgt.day == 15),
                                      "last": last, "m7": m7, "m28": m28, "s28": s28, "slope": slope, "same_dow4": sd,
                                      "y": vals[d] if (need_target and d < len(vals)) else np.nan}))
    f = pd.concat(rows, ignore_index=True).merge(static, on="sid", how="left")
    for c in ["last", "m7", "same_dow4", "slope", "s28"]:
        f[c + "_r"] = f[c] / f["m28"]
    f["y_r"] = f["y"] / f["m28"]
    return f


def static_100(fin: pd.DataFrame) -> pd.DataFrame:
    s = fin.rename(columns={"SKU": "sid"}).copy()
    s["cat_code"] = s["cat"].astype("category").cat.codes
    s["log_price"] = np.log(s["Price"])
    s["margin"] = (s["Price"] - s["Cost"]) / s["Price"]
    return s[["sid", "cat", "cat_code", "log_price", "margin"]]


def promo_frame(cr: pd.DataFrame) -> pd.DataFrame:
    """Đặc trưng cho bài toán uplift khuyến mãi (complex_retail_sales)."""
    f = cr.copy().sort_values(["Product_ID", "Date"]).reset_index(drop=True)
    cal = calendar_features(f["Date"])
    for c in ["dow", "double_day", "payday", "mid_month"]:
        f[c] = cal[c].values
    f["log_base"] = np.log(f["Baseline_Sales"])
    f["prod_code"] = f["Product_ID"].astype("category").cat.codes
    f["ratio"] = f["Sales"] / f["Baseline_Sales"]
    return f
