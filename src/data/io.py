"""Đọc dữ liệu đầu vào và lịch sự kiện (Tết, ngày đôi, COVID)."""
from __future__ import annotations

import numpy as np
import pandas as pd

from src.common import CFG, RAW_GV, RAW_GSO

GV_FILES = {
    "ecommerce_90days": ("ecommerce_90days.csv", "Ch1 tr.55–74", "GMV, đơn, quảng cáo, chiết khấu 90 ngày (có 2 ngày Mega Sale)"),
    "dirty": ("ecommerce_dirty_data.csv", "Ch1 tr.76–101", "GMV 20 ngày có khuyết, lỗi, ngoại lai và Flash Sale"),
    "panel": ("ecommerce_panel_data_raw.csv", "Ch1 tr.104–108", "Panel 3 ngành × 30 ngày: đơn, GMV, quảng cáo"),
    "unit_econ": ("ecommerce_unit_economics.csv", "Ch1 tr.118–129", "Unit Economics: quảng cáo, giá vốn theo ngành"),
    "margin": ("ecommerce_profit_margin_2020_2025.csv", "Ch2 tr.43–45", "Biên lợi nhuận ròng 72 tháng"),
    "multiseasonal": ("ecommerce_daily_multiseasonal.csv", "Ch2 tr.59–63", "Doanh thu chuẩn hóa ngày 2021–2023 và chi phí marketing"),
    "m48": ("ecommerce_48months.csv", "Ch2 tr.105", "GMV 48 tháng"),
    "raw_sales": ("raw_sales_data.csv", "Ch3 tr.73–76", "Giá, khuyến mãi, doanh số – sản phẩm mới"),
    "complex_retail": ("complex_retail_sales.csv", "Ch3 tr.87–92", "5 sản phẩm × 60 ngày: cuối tuần, khuyến mãi"),
    "multi_sku": ("ecommerce_sales_multi_sku.csv", "Ch4 tr.27–34", "15 SKU × 240 ngày"),
    "hist100": ("historical_sales_100_r2.csv", "Ch4 tr.67–75; Ch5", "100 SKU × 150 ngày"),
    "fin100": ("financial_metadata_100.csv", "Ch4 tr.67–75; Ch5", "Giá, giá vốn, giá thanh lý 100 SKU"),
}


def gv(key: str, **kw) -> pd.DataFrame:
    fn = GV_FILES[key][0]
    df = pd.read_csv(RAW_GV / fn, **kw)
    for c in ("Date", "date", "ds", "OrderDate"):
        if c in df.columns:
            df[c] = pd.to_datetime(df[c])
    return df


def ecommerce_90days() -> pd.DataFrame:
    d = gv("ecommerce_90days").sort_values("Date").reset_index(drop=True)
    thr = CFG["marketing"]["mega_discount_threshold"]
    d["Mega"] = (d["Discount"] >= thr).astype(int)
    d["AOV"] = d["GMV"] / d["Orders"]
    d["dow"] = d["Date"].dt.dayofweek
    return d


def panel() -> pd.DataFrame:
    p = gv("panel").sort_values(["Category", "Date"]).reset_index(drop=True)
    p["AOV"] = p["GMV"] / p["Orders"]
    return p


def unit_econ() -> pd.DataFrame:
    u = gv("unit_econ").sort_values(["Category", "Date"]).reset_index(drop=True)
    u["AOV"] = u["GMV"] / u["Orders"]
    u["COGS"] = u["COGS_per_Order"] * u["Orders"]
    u["CM_total"] = u["GMV"] - u["COGS"] - u["Ad_Spend"]
    return u


def hist100_wide() -> pd.DataFrame:
    h = gv("hist100")
    return h.pivot(index="ds", columns="unique_id", values="y").sort_index()


def fin100() -> pd.DataFrame:
    f = gv("fin100").copy()
    f["cat"] = f["SKU"].str.rsplit("_", n=1).str[0]
    f["Cu"] = f["Price"] - f["Cost"]
    f["Co"] = f["Cost"] - f["Salvage"]
    f["q_star"] = f["Cu"] / (f["Cu"] + f["Co"])
    return f


def gso_monthly() -> pd.DataFrame:
    s = pd.read_csv(RAW_GSO / "tmbl_monthly_2019_12_2026_09.csv", parse_dates=["ds"])
    return s.sort_values("ds").reset_index(drop=True)


def gso_annual() -> pd.DataFrame:
    return pd.read_csv(RAW_GSO / "tmbl_annual_2019_2025.csv")


# ------------------------------------------------------------------ lịch sự kiện
TET = pd.to_datetime(CFG["calendar"]["tet"])


def tet_window_share(month_index: pd.DatetimeIndex, days: int | None = None) -> pd.Series:
    """Tỷ lệ số ngày của cửa sổ mua sắm trước Tết (days ngày trước mùng 1) rơi vào từng tháng."""
    days = days or CFG["calendar"]["tet_window_days"]
    out = pd.Series(0.0, index=month_index)
    for t in TET:
        for d in pd.date_range(t - pd.Timedelta(days=days), t - pd.Timedelta(days=1)):
            m = d.to_period("M").to_timestamp()
            if m in out.index:
                out[m] += 1 / days
    return out


def covid_dummy(month_index: pd.DatetimeIndex) -> pd.Series:
    months = set(CFG["calendar"]["covid_months"])
    return pd.Series([1.0 if str(i)[:7] in months else 0.0 for i in month_index], index=month_index)


def calendar_features(dates: pd.Series | pd.DatetimeIndex) -> pd.DataFrame:
    """Đặc trưng lịch cho dữ liệu ngày: thứ, cuối tuần, ngày đôi (d = m), giữa tháng, ngày lương, khoảng cách tới Tết."""
    d = pd.DatetimeIndex(pd.to_datetime(dates))
    f = pd.DataFrame(index=range(len(d)))
    f["dow"] = d.dayofweek
    f["weekend"] = (d.dayofweek >= 5).astype(int)
    f["dom"] = d.day
    f["month"] = d.month
    f["double_day"] = (d.day == d.month).astype(int)
    f["mid_month"] = (d.day == CFG["calendar"]["mid_month"]).astype(int)
    f["payday"] = (d.day == CFG["calendar"]["payday"]).astype(int)
    days_to_tet = []
    for x in d:
        fut = TET[TET >= x]
        days_to_tet.append(int((fut[0] - x).days) if len(fut) else 999)
    f["days_to_tet"] = np.minimum(days_to_tet, 120)
    f["pre_tet"] = (f["days_to_tet"].between(1, CFG["calendar"]["tet_window_days"])).astype(int)
    return f
