"""Phân bổ ngân sách quảng cáo giữa các ngành (bài toán của Tác tử Điều phối – slide Ch5 tr.31–35).

Đường phản hồi mỗi ngành: Orders_c(a) = α_c + β_c·ln(a) (lợi suất giảm dần), ước lượng trên panel 30 ngày.
Mục tiêu có trọng số: max Σ_c [ w1·GMV_c(a_c) − w2·(COGS_c(a_c) + a_c) ]  s.t. Σ a_c = B, a_c ≥ m·B.
Với w1 = w2 = 1 đây là tối đa lợi nhuận gộp sau quảng cáo; w2 = 0 là tối đa GMV.
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from scipy import optimize


class Response:
    def __init__(self, name: str, alpha: float, beta: float, aov: float, cogs: float, a_range: tuple[float, float]):
        self.name, self.alpha, self.beta, self.aov, self.cogs, self.a_range = name, alpha, beta, aov, cogs, a_range

    def orders(self, a):
        return np.maximum(0.0, self.alpha + self.beta * np.log(np.maximum(a, 1e-6)))

    def gmv(self, a):
        return self.aov * self.orders(a)

    def profit(self, a):
        return (self.aov - self.cogs) * self.orders(a) - a


def fit_log_response(p: pd.DataFrame, unit: pd.DataFrame) -> dict[str, Response]:
    out = {}
    for c, g in p.groupby("Category"):
        X = np.column_stack([np.ones(len(g)), np.log(g.Ad_Spend.values)])
        a_, b_ = np.linalg.lstsq(X, g.Orders.values.astype(float), rcond=None)[0]
        u = unit[unit.Category == c]
        out[c] = Response(c, a_, b_, aov=float(u.GMV.sum() / u.Orders.sum()), cogs=float(u.COGS.sum() / u.Orders.sum()),
                          a_range=(float(g.Ad_Spend.min()), float(g.Ad_Spend.max())))
    return out


def objective(alloc, resp: list[Response], w1: float, w2: float) -> float:
    tot = 0.0
    for a, r in zip(alloc, resp):
        o = r.orders(a)
        tot += w1 * r.aov * o - w2 * (r.cogs * o + a)
    return tot


def optimize_allocation(resp: list[Response], budget: float, w1: float = 1.0, w2: float = 1.0, min_share: float = 0.1,
                        within_data: bool = False) -> np.ndarray:
    """within_data=True: giới hạn mỗi ngành trong khoảng chi quảng cáo đã quan sát (tránh ngoại suy đường phản hồi)."""
    k = len(resp)
    lo = min_share * budget
    if within_data:
        bounds = [(max(lo, r.a_range[0]), r.a_range[1]) for r in resp]
        if sum(b[0] for b in bounds) > budget or sum(b[1] for b in bounds) < budget:
            return np.full(k, np.nan)
    else:
        bounds = [(lo, budget)] * k
    cons = [{"type": "eq", "fun": lambda x: x.sum() - budget}]
    best = None
    starts = [np.clip(np.full(k, budget / k), [b[0] for b in bounds], [b[1] for b in bounds])]
    starts += [np.array([b[0] for b in bounds]) + (budget - sum(b[0] for b in bounds)) * np.eye(k)[i] for i in range(k)]
    for x0 in starts:
        r = optimize.minimize(lambda x: -objective(x, resp, w1, w2), x0, bounds=bounds, constraints=cons, method="SLSQP",
                              options=dict(ftol=1e-10, maxiter=500))
        if not r.success and best is not None:
            continue
        if best is None or r.fun < best.fun:
            best = r
    return best.x


def shadow_price(resp: list[Response], budget: float, w1=1.0, w2=1.0, min_share=0.1, eps=0.01, within_data=False) -> float:
    a1 = optimize_allocation(resp, budget, w1, w2, min_share, within_data)
    a2 = optimize_allocation(resp, budget + eps, w1, w2, min_share, within_data)
    if np.isnan(a1).any() or np.isnan(a2).any():
        return float("nan")
    return (objective(a2, resp, w1, w2) - objective(a1, resp, w1, w2)) / eps


def evaluate(alloc, resp: list[Response]) -> dict:
    rows = {r.name: dict(ads=float(a), orders=float(r.orders(a)), gmv=float(r.gmv(a)), profit=float(r.profit(a)),
                         in_range=bool(r.a_range[0] <= a <= r.a_range[1])) for a, r in zip(alloc, resp)}
    return dict(by_cat=rows, ads=float(np.sum(alloc)), gmv=float(sum(v["gmv"] for v in rows.values())),
                profit=float(sum(v["profit"] for v in rows.values())), all_in_range=all(v["in_range"] for v in rows.values()))
