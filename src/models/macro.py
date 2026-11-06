"""Mô hình dự báo chuỗi tháng Tổng mức bán lẻ Việt Nam (Cục Thống kê): SNaive tăng trưởng, ETS log, SARIMA + Tết + COVID,
Prophet + Tết + COVID, LightGBM trên tăng trưởng cùng kỳ."""
from __future__ import annotations

import logging
import warnings

import lightgbm as lgb
import numpy as np
import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from statsmodels.tsa.statespace.sarimax import SARIMAX

from src.common import SEED
from src.data.io import covid_dummy, tet_window_share

warnings.filterwarnings("ignore")
logging.getLogger("cmdstanpy").setLevel(logging.ERROR)
logging.getLogger("prophet").setLevel(logging.ERROR)
Z80 = 1.2816


def _future_index(tr: pd.Series, h: int) -> pd.DatetimeIndex:
    return pd.date_range(tr.index[-1] + pd.offsets.MonthBegin(1), periods=h, freq="MS")


def fc_snaive(tr: pd.Series, h: int):
    base = tr.values[-12:][:h] * (tr.values[-12:].sum() / tr.values[-24:-12].sum())
    return base, np.full(h, np.nan), np.full(h, np.nan)


def fc_ets(tr: pd.Series, h: int):
    m = ExponentialSmoothing(np.log(tr.values), trend="add", damped_trend=True, seasonal="add", seasonal_periods=12).fit()
    f = m.forecast(h)
    sd = (np.log(tr.values) - m.fittedvalues)[12:].std()
    k = np.sqrt(np.arange(1, h + 1))
    return np.exp(f), np.exp(f - Z80 * sd * k), np.exp(f + Z80 * sd * k)


def fc_sarima(tr: pd.Series, h: int):
    ex = pd.DataFrame({"tet": tet_window_share(tr.index), "covid": covid_dummy(tr.index)})
    idx_f = _future_index(tr, h)
    exf = pd.DataFrame({"tet": tet_window_share(idx_f), "covid": 0.0}, index=idx_f)
    m = SARIMAX(np.log(tr), exog=ex, order=(1, 1, 1), seasonal_order=(0, 1, 1, 12)).fit(disp=False)
    p = m.get_forecast(h, exog=exf)
    ci = p.conf_int(alpha=.2)
    return np.exp(p.predicted_mean.values), np.exp(ci.iloc[:, 0].values), np.exp(ci.iloc[:, 1].values)


def fc_prophet(tr: pd.Series, h: int):
    from prophet import Prophet
    idx_f = _future_index(tr, h)
    dfp = pd.DataFrame({"ds": tr.index, "y": np.log(tr.values), "tet": tet_window_share(tr.index).values, "covid": covid_dummy(tr.index).values})
    m = Prophet(yearly_seasonality=True, weekly_seasonality=False, daily_seasonality=False, interval_width=.8, changepoint_prior_scale=0.1,
                uncertainty_samples=1000)
    m.add_regressor("tet"); m.add_regressor("covid")
    m.fit(dfp)
    p = m.predict(pd.DataFrame({"ds": idx_f, "tet": tet_window_share(idx_f).values, "covid": 0.0}))
    return np.exp(p.yhat.values), np.exp(p.yhat_lower.values), np.exp(p.yhat_upper.values)


def fc_lgbm(tr: pd.Series, h: int):
    idx_f = _future_index(tr, h)
    d = pd.DataFrame({"y": np.log(tr)})
    d["m"] = d.index.month; d["tet"] = tet_window_share(d.index); d["covid"] = covid_dummy(d.index)
    d["d12"] = d.y - d.y.shift(12); d["t"] = np.arange(len(d))
    tr_ = d.dropna(); X = ["m", "tet", "covid", "t"]
    mdl = lgb.train(dict(objective="l2", learning_rate=.05, num_leaves=4, min_data_in_leaf=5, verbose=-1, seed=SEED, deterministic=True),
                    lgb.Dataset(tr_[X], tr_.d12), 300)
    hist = d.y.copy(); out = []
    tw = tet_window_share(idx_f)
    for i, ds in enumerate(idx_f):
        g = mdl.predict(pd.DataFrame({"m": [ds.month], "tet": [tw[ds]], "covid": [0.0], "t": [len(d) + i]}))[0]
        val = hist.get(ds - pd.DateOffset(months=12), np.nan) + g
        hist[ds] = val; out.append(np.exp(val))
    return np.array(out), np.full(h, np.nan), np.full(h, np.nan)


MODELS = {"SNaive tăng trưởng": fc_snaive, "ETS (log)": fc_ets, "SARIMA + Tết + COVID": fc_sarima,
          "Prophet + Tết + COVID": fc_prophet, "LightGBM (tăng trưởng cùng kỳ)": fc_lgbm}
