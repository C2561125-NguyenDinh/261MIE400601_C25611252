"""Thước đo dự báo điểm, dự báo xác suất và kiểm định so sánh (Diebold–Mariano có hiệu chỉnh HAC)."""
from __future__ import annotations

import numpy as np
from scipy import stats


def point_metrics(y, f) -> dict:
    y, f = np.asarray(y, float), np.asarray(f, float)
    e = y - f
    nz = y != 0
    return dict(
        MAE=float(np.mean(np.abs(e))),
        RMSE=float(np.sqrt(np.mean(e ** 2))),
        MAPE=float(np.mean(np.abs(e[nz] / y[nz])) * 100) if nz.any() else np.nan,
        WAPE=float(np.sum(np.abs(e)) / np.sum(np.abs(y)) * 100),
        Bias=float(np.sum(f - y) / np.sum(y) * 100),
    )


def mase(y, f, scale) -> float:
    return float(np.mean(np.abs(np.asarray(y) - np.asarray(f)) / np.asarray(scale)))


def pinball(y, q_pred, q: float) -> np.ndarray:
    """Quantile (pinball) loss từng điểm: q·(y−ŷ) nếu y ≥ ŷ, (1−q)·(ŷ−y) nếu ngược lại (slide Ch4 tr.36–40)."""
    y, p = np.asarray(y, float), np.asarray(q_pred, float)
    d = y - p
    return np.where(d >= 0, q * d, (q - 1) * d)


def coverage(y, lo, hi) -> float:
    y = np.asarray(y)
    return float(np.mean((y >= lo) & (y <= hi)))


def winkler(y, lo, hi, alpha: float) -> np.ndarray:
    """Điểm Winkler (1972) cho khoảng (1−α): độ rộng + phạt 2/α × khoảng vượt ra ngoài."""
    y, lo, hi = map(lambda a: np.asarray(a, float), (y, lo, hi))
    w = hi - lo
    w = w + (2 / alpha) * (lo - y) * (y < lo) + (2 / alpha) * (y - hi) * (y > hi)
    return w


def dm_test(loss_a, loss_b, h: int = 1) -> dict:
    """Diebold–Mariano (1995) với phương sai dài hạn Newey–West (độ trễ h−1, tối thiểu 0).
    Âm: mô hình A tốt hơn."""
    d = np.asarray(loss_a, float) - np.asarray(loss_b, float)
    n = len(d)
    dbar = d.mean()
    dc = d - dbar
    lag = max(h - 1, 0)
    gamma0 = np.dot(dc, dc) / n
    lrv = gamma0
    for k in range(1, lag + 1):
        g = np.dot(dc[k:], dc[:-k]) / n
        lrv += 2 * (1 - k / (lag + 1)) * g
    se = np.sqrt(lrv / n)
    t = dbar / se if se > 0 else np.nan
    p = 2 * stats.t.sf(abs(t), n - 1) if np.isfinite(t) else np.nan
    return dict(mean_diff=float(dbar), t=float(t), p=float(p), n=int(n), hac_lag=int(lag))
