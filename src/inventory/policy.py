"""Chính sách tồn kho cho chiến dịch: Newsvendor (phân vị tới hạn q* = Cu/(Cu + Co)) – slide Ch4 tr.56–65."""
from __future__ import annotations

import numpy as np

QS = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]


def critical_ratio(price, cost, salvage):
    cu = np.asarray(price, float) - np.asarray(cost, float)
    co = np.asarray(cost, float) - np.asarray(salvage, float)
    return cu / (cu + co)


def interp_quantile(P: dict, qstar) -> np.ndarray:
    """Nội suy tuyến tính trên lưới phân vị P10..P90 (kẹp q* vào [0,1; 0,9])."""
    grid = np.array(QS)
    M = np.stack([P[q] for q in QS], 1)
    qc = np.clip(np.asarray(qstar, float), grid[0], grid[-1])
    return np.array([np.interp(qc[i], grid, M[i]) for i in range(len(qc))])


def profit(Q, D, p, c, s):
    Q = np.maximum(np.asarray(Q, float), 0)
    D = np.asarray(D, float)
    return p * np.minimum(Q, D) - c * Q + s * np.maximum(Q - D, 0)


def strategy_label(q):
    """Ngưỡng của script strategy_reorder_point.py (case study GV): ≥ 0,75 tấn công; ≤ 0,35 phòng thủ."""
    q = np.asarray(q, float)
    return np.where(q >= .75, "TẤN CÔNG", np.where(q <= .35, "PHÒNG THỦ", "CÂN BẰNG"))
