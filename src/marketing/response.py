"""Mô hình phản hồi marketing: hồi quy OLS (thiên lệch bỏ sót biến), độ co giãn, adstock, đường cong bão hòa,
panel hiệu ứng cố định và bootstrap phân phối lợi nhuận tăng thêm của quảng cáo."""
from __future__ import annotations

import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
from scipy import optimize, stats
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor


def ols(formula: str, data: pd.DataFrame, cov: str = "HC3"):
    return smf.ols(formula, data).fit(cov_type=cov)


def ovb_table(d: pd.DataFrame) -> dict:
    """Ba đặc tả của slide Ch1 (tr.69–70) + mở rộng: kiểm chứng thiên lệch bỏ sót biến của Ad_Spend."""
    m1 = smf.ols("Orders ~ Ad_Spend", d).fit()
    m2 = smf.ols("Orders ~ Ad_Spend + Discount", d).fit()
    m3 = smf.ols("np.log(Orders) ~ np.log(Ad_Spend) + Discount", d).fit()
    m4 = smf.ols("Orders ~ Ad_Spend + Discount + Mega + C(dow)", d).fit()
    m5 = smf.ols("GMV ~ Ad_Spend + Discount + Mega", d).fit()
    bp = het_breuschpagan(m1.resid, m1.model.exog)
    X = sm.add_constant(d[["Ad_Spend", "Discount"]])
    vif = {c: float(variance_inflation_factor(X.values, i)) for i, c in enumerate(X.columns) if c != "const"}
    # công thức thiên lệch: b1_simple = b1_full + b2_full × cov(Ads,Disc)/var(Ads)
    delta = np.cov(d.Ad_Spend, d.Discount)[0, 1] / d.Ad_Spend.var()
    out = {
        "m1": dict(b_ads=m1.params["Ad_Spend"], se=m1.bse["Ad_Spend"], r2=m1.rsquared, n=int(m1.nobs)),
        "m2": dict(b_ads=m2.params["Ad_Spend"], se=m2.bse["Ad_Spend"], b_disc=m2.params["Discount"], se_disc=m2.bse["Discount"], r2=m2.rsquared),
        "m3": dict(elast_ads=m3.params["np.log(Ad_Spend)"], se=m3.bse["np.log(Ad_Spend)"], semi_disc=m3.params["Discount"], r2=m3.rsquared),
        "m4": dict(b_ads=m4.params["Ad_Spend"], se=m4.bse["Ad_Spend"], b_disc=m4.params["Discount"], b_mega=m4.params["Mega"],
                   p_mega=m4.pvalues["Mega"], r2=m4.rsquared),
        "m5_gmv": dict(b_ads=m5.params["Ad_Spend"], se=m5.bse["Ad_Spend"], b_disc=m5.params["Discount"], b_mega=m5.params["Mega"],
                       p_mega=m5.pvalues["Mega"], r2=m5.rsquared),
        "ovb_identity": dict(b_simple=m1.params["Ad_Spend"], b_full=m2.params["Ad_Spend"], b_disc=m2.params["Discount"], delta=delta,
                             implied=m2.params["Ad_Spend"] + m2.params["Discount"] * delta),
        "bias_pct": (m1.params["Ad_Spend"] - m2.params["Ad_Spend"]) / m2.params["Ad_Spend"] * 100,
        "hc3": dict(m1_ads=float(m1.get_robustcov_results("HC3").bse[1]), m2_ads=float(m2.get_robustcov_results("HC3").bse[1]),
                    m2_disc=float(m2.get_robustcov_results("HC3").bse[2])),
        "bp_lm": bp[0], "bp_p": bp[1], "vif": vif, "corr_ads_disc": float(d.Ad_Spend.corr(d.Discount)),
    }
    return out, dict(m1=m1, m2=m2, m3=m3, m4=m4, m5=m5)


def contribution_decomposition(d: pd.DataFrame, model) -> pd.DataFrame:
    """Phân rã số đơn mỗi ngày thành nền + quảng cáo + chiết khấu theo mô hình tuyến tính (đóng góp so với mức 0)."""
    p = model.params
    out = pd.DataFrame({"Date": d.Date, "Orders": d.Orders})
    out["base"] = p["Intercept"]
    out["ads"] = p["Ad_Spend"] * d.Ad_Spend
    out["discount"] = p["Discount"] * d.Discount
    out["residual"] = d.Orders - out[["base", "ads", "discount"]].sum(1)
    return out


def adstock(x: np.ndarray, decay: float) -> np.ndarray:
    """Adstock hình học (Broadbent, 1979): A_t = x_t + λ·A_{t−1}."""
    a = np.zeros(len(x))
    for t, v in enumerate(x):
        a[t] = v + (decay * a[t - 1] if t else 0.0)
    return a


def adstock_scan(y: np.ndarray, x: np.ndarray, grid, controls: np.ndarray | None = None) -> pd.DataFrame:
    rows = []
    for lam in grid:
        a = adstock(x, lam)
        X = a[:, None] if controls is None else np.column_stack([a, controls])
        res = sm.OLS(y, sm.add_constant(X)).fit()
        rows.append(dict(decay=lam, beta=res.params[1], se=res.bse[1], p=res.pvalues[1], r2=res.rsquared, aic=res.aic))
    return pd.DataFrame(rows)


def distributed_lag(y: np.ndarray, x: np.ndarray, max_lag: int) -> pd.DataFrame:
    X = np.column_stack([np.r_[np.full(k, np.nan), x[: len(x) - k]] for k in range(max_lag + 1)])
    ok = ~np.isnan(X).any(1)
    res = sm.OLS(y[ok], sm.add_constant(X[ok])).fit(cov_type="HAC", cov_kwds={"maxlags": 7})
    joint = res.f_test(np.eye(max_lag + 2)[1:])
    df = pd.DataFrame({"lag": range(max_lag + 1), "beta": res.params[1:], "se": res.bse[1:], "p": res.pvalues[1:]})
    df.attrs["joint_F"] = float(np.squeeze(joint.fvalue))
    df.attrs["joint_p"] = float(np.squeeze(joint.pvalue))
    df.attrs["r2"] = float(res.rsquared)
    return df


def hill(x, vmax, k, s):
    x = np.maximum(np.asarray(x, float), 1e-9)
    return vmax * x ** s / (k ** s + x ** s)


def fit_response(x: np.ndarray, y: np.ndarray) -> dict:
    """So sánh 3 dạng phản hồi Orders theo Ads cho một ngành: tuyến tính, log (lợi suất giảm dần), Hill."""
    out = {}
    lin = sm.OLS(y, sm.add_constant(x)).fit()
    out["linear"] = dict(a=lin.params[0], b=lin.params[1], p=lin.pvalues[1], r2=lin.rsquared, aic=lin.aic)
    lg = sm.OLS(y, sm.add_constant(np.log(x))).fit()
    out["log"] = dict(a=lg.params[0], b=lg.params[1], p=lg.pvalues[1], r2=lg.rsquared, aic=lg.aic)
    try:
        p0 = [y.max() * 2, np.median(x), 1.0]
        popt, _ = optimize.curve_fit(lambda xx, c, vmax, k, s: c + hill(xx, vmax, k, s), x, y, p0=[y.min()] + p0,
                                     bounds=([-np.inf, 0, 1e-3, 0.3], [np.inf, 1e6, 1e4, 5]), maxfev=20000)
        yh = popt[0] + hill(x, *popt[1:])
        rss = ((y - yh) ** 2).sum(); n = len(y)
        out["hill"] = dict(c=popt[0], vmax=popt[1], k=popt[2], s=popt[3], r2=1 - rss / ((y - y.mean()) ** 2).sum(),
                           aic=n * np.log(rss / n) + 2 * 5)
    except Exception as e:  # noqa: BLE001
        out["hill"] = dict(error=str(e))
    return out


def panel_models(p: pd.DataFrame) -> dict:
    pooled = smf.ols("Orders ~ Ad_Spend", p).fit()
    fe = smf.ols("Orders ~ Ad_Spend + C(Category)", p).fit()
    het = smf.ols("Orders ~ Ad_Spend * C(Category)", p).fit()
    f = het.compare_f_test(fe)
    slopes = {}
    for c, g in p.groupby("Category"):
        r = smf.ols("Orders ~ Ad_Spend", g).fit()
        rg = smf.ols("GMV ~ Ad_Spend", g).fit()
        slopes[c] = dict(b=r.params["Ad_Spend"], se=r.bse["Ad_Spend"], p=r.pvalues["Ad_Spend"], r2=r.rsquared,
                         b_gmv=rg.params["Ad_Spend"], p_gmv=rg.pvalues["Ad_Spend"], n=int(r.nobs))
    return dict(pooled=dict(b=pooled.params["Ad_Spend"], r2=pooled.rsquared, p=pooled.pvalues["Ad_Spend"]),
                fe=dict(b=fe.params["Ad_Spend"], r2=fe.rsquared, p=fe.pvalues["Ad_Spend"]),
                F_heterog=float(f[0]), F_heterog_p=float(f[1]), slopes=slopes)


def bootstrap_campaign(d: pd.DataFrame, extra_ads: float, cm_per_order: float, B: int = 2000, seed: int = 42) -> dict:
    """Phân phối lợi nhuận tăng thêm khi tăng quảng cáo thêm extra_ads (triệu VNĐ/ngày), bootstrap theo cặp (case resampling).
    Lợi nhuận tăng thêm = b_ads × extra × CM trước quảng cáo/đơn − extra."""
    rng = np.random.default_rng(seed)
    n = len(d)
    bs = np.empty(B)
    X = np.column_stack([np.ones(n), d.Ad_Spend.values, d.Discount.values])
    y = d.Orders.values
    for b in range(B):
        i = rng.integers(0, n, n)
        bs[b] = np.linalg.lstsq(X[i], y[i], rcond=None)[0][1]
    inc_orders = bs * extra_ads
    profit = inc_orders * cm_per_order - extra_ads
    return dict(b_mean=float(bs.mean()), b_p05=float(np.quantile(bs, .05)), b_p95=float(np.quantile(bs, .95)),
                profit_mean=float(profit.mean()), profit_p05=float(np.quantile(profit, .05)), profit_p50=float(np.quantile(profit, .5)),
                profit_p95=float(np.quantile(profit, .95)), p_loss=float((profit < 0).mean()), samples=profit)


def elasticity_by_category(p: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for c, g in p.groupby("Category"):
        r = smf.ols("np.log(Orders) ~ np.log(Ad_Spend)", g).fit()
        rows.append(dict(Category=c, elasticity=r.params["np.log(Ad_Spend)"], se=r.bse["np.log(Ad_Spend)"],
                         p=r.pvalues["np.log(Ad_Spend)"], r2=r.rsquared))
    return pd.DataFrame(rows)


def ttest_mega(d: pd.DataFrame, col: str) -> dict:
    a, b = d.loc[d.Mega == 1, col], d.loc[d.Mega == 0, col]
    return dict(mega_mean=float(a.mean()), normal_mean=float(b.mean()), ratio=float(a.mean() / b.mean()),
                n_mega=int(len(a)), n_normal=int(len(b)), welch_p=float(stats.ttest_ind(a, b, equal_var=False).pvalue) if len(a) > 1 else None)
