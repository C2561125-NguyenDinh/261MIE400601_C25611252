"""Kiểm thử đơn vị cho các hàm lõi (chạy: python -m pytest -q tests/test_core.py)."""
import numpy as np
import pandas as pd
import pytest

from src.budget.allocate import Response, evaluate, optimize_allocation
from src.cashflow.sim import simulate
from src.evaluation.metrics import dm_test, pinball, point_metrics, winkler
from src.genai.agent import validate_payloads
from src.inventory.policy import critical_ratio, interp_quantile, profit
from src.marketing.response import adstock


def test_pinball_slide_example():
    # slide Ch4 tr.40: q = 0,9; dự báo 150; thực tế 170,130,200,180,150 → 18; 2; 45; 27; 0
    assert np.allclose(pinball([170, 130, 200, 180, 150], np.full(5, 150.), .9), [18, 2, 45, 27, 0])


def test_critical_ratio_slide():
    assert np.allclose(critical_ratio([30000, 200, 60], [25000, 40, 45], [20000, 0, 10]), [.5, .8, .3])


def test_point_metrics_perfect():
    m = point_metrics([1, 2, 3], [1, 2, 3])
    assert m["MAE"] == 0 and m["WAPE"] == 0


def test_winkler_inside_equals_width():
    assert np.allclose(winkler([5], [4], [6], .2), [2])


def test_dm_identical_losses():
    r = dm_test(np.ones(10), np.ones(10))
    assert np.isnan(r["t"]) or r["t"] == 0


def test_adstock_geometric():
    assert np.allclose(adstock(np.array([1., 0, 0]), .5), [1, .5, .25])


def test_newsvendor_profit():
    assert profit([10], [8], 5, 3, 1)[0] == 5 * 8 - 3 * 10 + 1 * 2


def test_interp_quantile_clip():
    P = {q: np.array([q * 100]) for q in [.1, .2, .3, .4, .5, .6, .7, .8, .9]}
    assert interp_quantile(P, [0.05])[0] == pytest.approx(10)
    assert interp_quantile(P, [0.55])[0] == pytest.approx(55)


def test_budget_sum_and_bounds():
    R = [Response("A", 10, 5, 1.0, .5, (1, 10)), Response("B", 5, 2, 1.0, .5, (1, 10))]
    a = optimize_allocation(R, 8.0, 1, 1, .1)
    assert a.sum() == pytest.approx(8.0, abs=1e-6) and (a >= .8 - 1e-9).all()
    assert evaluate(a, R)["profit"] >= evaluate(np.array([4.0, 4.0]), R)["profit"] - 1e-9


def test_cash_lag_increases_need():
    d = pd.DataFrame({"GMV": [10.0] * 30, "Ad_Spend": [1.0] * 30}, index=pd.date_range("2026-01-01", periods=30))
    assert simulate(d, .6, 14, 7)["cash_need"] > simulate(d, .6, 0, 7)["cash_need"]


def test_payload_validation():
    r = validate_payloads([dict(request_id="a", campaign="Mega Sale", ads_per_day=-1, discount=.2),
                           dict(request_id="b", campaign="Mega Sale", ads_per_day=1, discount=.2)])
    assert r[0].startswith("bị chặn") and r[1] == "hợp lệ"
