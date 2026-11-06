"""Mô phỏng dòng tiền ngày của chiến dịch: nhập hàng trả trước (lead time), quảng cáo trả ngay, tiền bán về sau độ trễ đối soát.
Phiên bản Việt Nam của case 'dòng tiền Mega Sale' (slide Ch2 tr.103) với chính sách đối soát sàn (knowledge_base/02)."""
from __future__ import annotations

import pandas as pd


def simulate(d: pd.DataFrame, cogs_ratio: float, lag: int, lead: int = 30, fee: float = 0.0) -> dict:
    """d: DataFrame chỉ mục ngày, cột GMV, Ad_Spend (triệu VNĐ)."""
    idx = pd.date_range(d.index[0] - pd.Timedelta(days=lead), d.index[-1] + pd.Timedelta(days=lag + 1))
    out_ = pd.Series(0.0, index=idx)
    inn = pd.Series(0.0, index=idx)
    for dte, r in d.iterrows():
        out_[dte - pd.Timedelta(days=lead)] += cogs_ratio * r.GMV
        out_[dte] += r.Ad_Spend
        inn[dte + pd.Timedelta(days=lag)] += r.GMV * (1 - fee)
    net = (inn - out_).cumsum()
    return dict(cash_need=float(max(0.0, -net.min())), date_min=str(net.idxmin().date()), end=float(net.iloc[-1]), series=net)


def mega_increment(d: pd.DataFrame, mega_days, cogs_ratio: float, lag: int, lead: int) -> dict:
    """Phần tiền mặt bị khóa thêm do các ngày Mega Sale so với kịch bản thay GMV/Ads ngày đó bằng trung vị."""
    base = simulate(d, cogs_ratio, lag, lead)["series"]
    alt = d.copy()
    alt.loc[mega_days, "GMV"] = d.GMV.median()
    alt.loc[mega_days, "Ad_Spend"] = d.Ad_Spend.median()
    gap = simulate(alt, cogs_ratio, lag, lead)["series"] - base
    return dict(peak_extra_cash=float(gap.max()), peak_date=str(gap.idxmax().date()), days_locked=int((gap > 0.01).sum()),
                extra_cash_end=float(-gap.iloc[-1]))
