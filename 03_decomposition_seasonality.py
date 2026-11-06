"""Stage 03 – Phân rã chuỗi thời gian, mùa vụ mua sắm và hiệu ứng marketing (slide Chương 2).

E3.0 Kiểm chứng các ví dụ tính tay của slide (phần dư cộng/nhân, trung bình trượt cổ điển/kháng nhiễu, backfitting, GAM, Prophet, khử mùa vụ)
E3.1 MSTL (7, 365) chuỗi doanh thu ngày 2021–2023: mùa vụ tuần, mùa vụ năm
E3.2 Kiểm định hiệu ứng chi phí marketing: tương quan, độ trễ phân phối, adstock, Prophet có/không biến hồi quy
E3.3 GMV 48 tháng: STL + HP, khử mùa vụ, tăng trưởng thô vs lõi (độ nhạy STL)
E3.4 Biên lợi nhuận 72 tháng: STL kháng nhiễu + HP
E3.5 Tổng mức bán lẻ Việt Nam (Cục Thống kê): STL log, Tết, COVID, độ trôi hệ số mùa vụ tháng 11–12 (mùa ngày đôi)
"""
import logging
import warnings

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from statsmodels.stats.diagnostic import acorr_ljungbox
from statsmodels.tsa.filters.hp_filter import hpfilter
from statsmodels.tsa.seasonal import MSTL, STL, seasonal_decompose

from src.common import CFG, GREY, PAL, Timer, log_run, plt, savefig, write_csv, write_json
from src.data import io
from src.marketing import response as MR

warnings.filterwarnings("ignore")
logging.getLogger("cmdstanpy").setLevel(logging.ERROR)
logging.getLogger("prophet").setLevel(logging.ERROR)
ST = "03_decomposition"
RES = {}


def strength(seasonal, resid):
    return float(max(0.0, 1 - np.var(resid) / np.var(np.asarray(seasonal) + np.asarray(resid))))


# ================================================================ E3.0
with Timer("E3.0 Kiểm chứng ví dụ tính tay Chương 2"):
    e = {}
    Y0, T0, S0, C0 = 150, 100, 35, 10
    e["add_R"] = Y0 - (T0 + S0 + C0)
    e["mul_R"] = Y0 / (T0 * (T0 + S0) / T0 * (T0 + C0) / T0)
    y = np.array([10, 12, 100, 11, 13.])
    r = y - np.median(y); M = np.median(np.abs(r)); u = np.abs(r) / (6 * M); w = np.where(u < 1, (1 - u ** 2) ** 2, 0)
    for nm, dvec in {"odd": np.ones(5), "even": np.array([.5, 1, 1, 1, .5])}.items():
        e[f"T3_classic_{nm}"] = float((dvec * y).sum() / dvec.sum())
        e[f"T3_robust_{nm}"] = float((dvec * w * y).sum() / (dvec * w).sum())
    e["bisquare_w"] = w.round(4).tolist()

    def phase(s, p):
        pat = np.array([s[i::p].mean() for i in range(p)])
        return np.tile(pat, int(np.ceil(len(s) / p)))[:len(s)]

    Yb = np.array([26, 16, 20, 22, 20, 13, 26.]); S1 = phase(Yb - 20, 2); S2 = phase(Yb - 20 - S1, 3)
    e["backfit"] = dict(S1=S1.round(2).tolist(), S2=S2.round(2).tolist(), R=(Yb - 20 - S1 - S2).round(2).tolist())
    t = np.array([1, 2, 3, 4, 5.]); Yg = np.array([15, 12, 50, 16, 20.]); Hh = np.array([0, 0, 1, 0, 0])
    tn, yn = t[Hh == 0], Yg[Hh == 0]
    b1 = ((tn - tn.mean()) * (yn - yn.mean())).sum() / ((tn - tn.mean()) ** 2).sum(); b0 = yn.mean() - b1 * tn.mean()
    e["gam1"] = dict(b0=b0, b1=b1, b2=50 - (b0 + 3 * b1), y6=b0 + 6 * b1, y7=b0 + 7 * b1 + 50 - (b0 + 3 * b1))
    Yg2 = np.array([20, 22, 70, 5, 28.]); clean = np.array([1, 1, 0, 0, 1], bool)
    tn, yn = t[clean], Yg2[clean]
    c1 = ((tn - tn.mean()) * (yn - yn.mean())).sum() / ((tn - tn.mean()) ** 2).sum(); c0 = yn.mean() - c1 * tn.mean()
    bs, bb = 70 - (c0 + 3 * c1), 5 - (c0 + 4 * c1)
    e["gam2"] = dict(b0=c0, b1=c1, b_sale=bs, b_bad=bb, y6=c0 + 6 * c1, y7=c0 + 7 * c1 + bs, y8=c0 + 8 * c1 + bb, y9=c0 + 9 * c1 + bs + bb)
    e["deseason_mul"] = [100 / 1, 150 / (1.4 * 1.1), 90 / .8]
    from prophet import Prophet
    dfp = pd.DataFrame({"ds": pd.date_range("2026-08-01", periods=5), "y": Yg})
    hol = pd.DataFrame({"holiday": "mega_sale", "ds": pd.to_datetime(["2026-08-03", "2026-08-07"]), "lower_window": 0, "upper_window": 0})
    m = Prophet(growth="linear", yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False, holidays=hol, changepoint_prior_scale=0.01)
    m.fit(dfp)
    fc = m.predict(pd.DataFrame({"ds": pd.date_range("2026-08-01", periods=7)}))
    e["prophet_toy"] = fc[["ds", "yhat", "trend", "mega_sale"]].assign(ds=lambda x: x.ds.dt.strftime("%Y-%m-%d")).round(3).to_dict("records")
    RES["E3_0"] = e

# ================================================================ E3.1
with Timer("E3.1 MSTL chuỗi ngày đa mùa vụ"):
    dm = io.gv("multiseasonal").set_index("date")
    yd = dm.revenue_zscore
    ms = MSTL(yd, periods=(7, 365)).fit()
    S7, S365 = ms.seasonal["seasonal_7"], ms.seasonal["seasonal_365"]
    trd = hpfilter(ms.trend, lamb=1e8)[1]
    RES["E3_1"] = dict(n=len(yd), var_Y=float(yd.var(ddof=0)), var_T=float(np.var(ms.trend)), var_S7=float(np.var(S7)), var_S365=float(np.var(S365)),
                       var_R=float(np.var(ms.resid)), F_S7=strength(S7, ms.resid), F_S365=strength(S365, ms.resid),
                       S7_by_dow=S7.groupby(S7.index.dayofweek).mean().round(3).to_dict(),
                       S365_by_m=S365.groupby(S365.index.month).mean().round(3).to_dict(),
                       S365_peak=str(S365.idxmax().date()), S365_trough=str(S365.idxmin().date()), T_first=float(trd.iloc[0]), T_last=float(trd.iloc[-1]))
    comp = pd.DataFrame({"date": yd.index, "Y": yd.values, "T": ms.trend.values, "S7": S7.values, "S365": S365.values, "R": ms.resid.values,
                         "marketing_spend": dm.marketing_spend.values, "dau": dm.daily_active_users.values})
    write_csv(comp.round(4), ST, "mstl_components.csv")
    fig, ax = plt.subplots(5, 1, figsize=(7.6, 7.6))
    ax[0].plot(yd.index, yd, color="k", lw=.5); ax[0].set_title("Y – revenue_zscore (ngày, 2021–2023)")
    ax[1].plot(ms.trend.index, ms.trend, color=PAL[0]); ax[1].set_title("T – xu hướng")
    ax[2].plot(S365.index, S365, color=PAL[2]); ax[2].set_title("S₃₆₅ – mùa vụ năm")
    ax[3].plot(S7.index[:84], S7[:84], color=PAL[6], marker=".", ms=3); ax[3].set_title("S₇ – mùa vụ tuần (12 tuần đầu, trục thời gian phóng to)"); ax[3].tick_params(axis="x", labelsize=6)
    ax[4].plot(ms.resid.index, ms.resid, color=GREY, lw=.4); ax[4].set_title("R – phần dư")
    savefig(fig, ST, "s03_mstl.png")

# ================================================================ E3.2
with Timer("E3.2 Kiểm định hiệu ứng chi phí marketing trên chuỗi đa mùa vụ"):
    mk = dm.marketing_spend.values
    resid = ms.resid.values
    deseason = (yd - S7 - S365).values
    e = dict(corr_raw=float(np.corrcoef(yd, mk)[0, 1]), corr_resid=float(np.corrcoef(resid, mk)[0, 1]),
             corr_deseason=float(np.corrcoef(deseason, mk)[0, 1]))
    scan = MR.adstock_scan(deseason, mk, CFG["marketing"]["adstock_grid"])
    write_csv(scan, ST, "adstock_scan.csv")
    dl = MR.distributed_lag(deseason, mk, CFG["marketing"]["max_lag"])
    write_csv(dl, ST, "distributed_lag.csv")
    e.update(adstock_best=scan.loc[scan.aic.idxmin()].to_dict(), adstock_min_p=float(scan.p.min()),
             dl_joint_F=dl.attrs["joint_F"], dl_joint_p=dl.attrs["joint_p"], dl_r2=dl.attrs["r2"],
             dl_sig_lags=dl.loc[dl.p < .05, "lag"].tolist())
    # tương quan chéo theo độ trễ của phần dư MSTL và chi phí marketing
    xc = {k: float(pd.Series(resid).corr(pd.Series(mk).shift(k))) for k in range(0, 15)}
    e["xcorr_resid"] = xc
    # mô phỏng kiểm tra công suất: nếu có hiệu ứng thật β = 0,1 trên adstock 0,5 thì quy trình có phát hiện không?
    # cấy hiệu ứng giả định vào chính chuỗi thật đã khử mùa vụ (nhiễu thật của dữ liệu), kiểm tra quy trình có phát hiện và ước lượng lại đúng không
    det = []
    for beta in [0.02, 0.05, 0.1, 0.2, 0.5]:
        ysim = deseason + beta * MR.adstock(mk, 0.5)
        sc = MR.adstock_scan(ysim, mk, [0.5])
        det.append(dict(beta_true=beta, beta_hat=float(sc.beta.iloc[0]), se=float(sc.se.iloc[0]), p=float(sc.p.iloc[0])))
    e["power_check"] = det
    # Prophet có/không có biến hồi quy marketing (kiểm định chéo)
    from prophet import Prophet
    from prophet.diagnostics import cross_validation, performance_metrics
    dfp = yd.reset_index().rename(columns={"date": "ds", "revenue_zscore": "y"})
    dfp["mkt"] = mk
    pcv = {}
    for name in ["base", "mkt"]:
        m = Prophet(yearly_seasonality=True, weekly_seasonality=True, daily_seasonality=False, changepoint_prior_scale=0.05)
        if name == "mkt":
            m.add_regressor("mkt")
        m.fit(dfp)
        cv = cross_validation(m, initial="730 days", period="60 days", horizon="30 days", parallel=None, disable_tqdm=True)
        pmx = performance_metrics(cv, rolling_window=1)
        pcv[name] = dict(mae=float(pmx.mae.iloc[0]), rmse=float(pmx.rmse.iloc[0]), coverage=float(pmx.coverage.iloc[0]), n_cut=int(cv.cutoff.nunique()))
        if name == "mkt":
            from prophet.utilities import regressor_coefficients
            rc = regressor_coefficients(m)
            pcv[name]["coef"] = float(rc.coef.iloc[0]); pcv[name]["coef_lower"] = float(rc.coef_lower.iloc[0]); pcv[name]["coef_upper"] = float(rc.coef_upper.iloc[0])
        else:
            fc = m.predict(dfp)
            fig = m.plot_components(fc); fig.set_size_inches(7.4, 6.0)
            for a_ in fig.axes:                       # đồng bộ màu với bộ hình của báo cáo
                for ln in a_.lines:
                    ln.set_color(PAL[0]); ln.set_linewidth(1.7)
                for c_ in a_.collections:
                    c_.set_facecolor(PAL[5]); c_.set_alpha(.35)
                a_.grid(True, axis="y", color="#E9EEF0"); a_.grid(False, axis="x")
                for sp in ("top", "right"):
                    a_.spines[sp].set_visible(False)
                a_.set_ylabel(a_.get_ylabel(), fontsize=8.5)
            savefig(fig, ST, "s03_prophet_components.png")
    e["prophet_cv"] = pcv
    RES["E3_2"] = e
    fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.6))
    ax[0].scatter(mk, resid, s=3, color=GREY); ax[0].set_xlabel("marketing_spend"); ax[0].set_ylabel("phần dư MSTL"); ax[0].set_title(f"(a) r = {e['corr_resid']:.3f}")
    ax[1].bar(scan.decay, scan.beta, width=.07, color=PAL[0], yerr=1.96 * scan.se, capsize=2); ax[1].axhline(0, color="k", lw=.6)
    ax[1].set_title("(b) β adstock theo độ suy giảm λ"); ax[1].set_xlabel("λ")
    ax[2].bar(dl.lag, dl.beta, color=PAL[2], yerr=1.96 * dl.se, capsize=2); ax[2].axhline(0, color="k", lw=.6); ax[2].set_title("(c) Độ trễ phân phối 0–14 ngày"); ax[2].set_xlabel("độ trễ")
    savefig(fig, ST, "s03_marketing_effect.png")

# ================================================================ E3.3
with Timer("E3.3 GMV 48 tháng"):
    g = io.gv("m48"); g["ds"] = pd.date_range("2022-01-01", periods=48, freq="MS")   # nhãn tháng quy ước (tệp chỉ có số thứ tự tháng 1..48)
    yg = g.set_index("ds").GMV
    sens = []
    for rob in [False, True]:
        for sw in [7, 13, 25]:
            s_ = STL(yg, period=12, seasonal=sw, robust=rob).fit(); c_ = hpfilter(s_.trend, lamb=14400)[0]
            sens.append(dict(robust=rob, seasonal=sw, resid_sd=float(s_.resid.std()), seas_amp=float(s_.seasonal.max() - s_.seasonal.min()),
                             C_min=float(c_.min()), C_max=float(c_.max()), Fs=strength(s_.seasonal, s_.resid)))
    write_csv(pd.DataFrame(sens), ST, "m48_stl_sensitivity.csv")
    st = STL(yg, period=12, seasonal=13, robust=False).fit()
    stl_log = STL(np.log(yg), period=12, seasonal=13, robust=False).fit()
    cyc, trd = hpfilter(st.trend, lamb=14400)
    S_mul = np.exp(stl_log.seasonal); des = yg / S_mul
    mom_raw, mom_des = yg.pct_change(), des.pct_change()
    tbl = pd.DataFrame({"Month": range(1, 49), "GMV": yg.values, "S_mul": S_mul.values, "GMV_deseason": des.values,
                        "T_hp": trd.values, "C_hp": cyc.values, "mom_raw": mom_raw.values, "mom_core": mom_des.values})
    write_csv(tbl.round(5), ST, "m48_decomposition.csv")
    add = seasonal_decompose(yg, model="additive", period=12)
    RES["E3_3"] = dict(cagr=float((yg[-12:].sum() / yg[:12].sum()) ** (1 / 3) - 1), S_mul_by_m=S_mul.groupby(S_mul.index.month).mean().round(4).to_dict(),
                       Fs=strength(st.seasonal, st.resid), C_min=float(cyc.min()), C_argmin=int(np.argmin(cyc.values)) + 1,
                       C_max=float(cyc.max()), C_argmax=int(np.argmax(cyc.values)) + 1,
                       sign_disagree=int(((np.sign(mom_raw) != np.sign(mom_des)) & mom_raw.notna()).sum()),
                       mom_corr=float(mom_raw.corr(mom_des)), nan_ends_classic=int(add.trend.isna().sum()),
                       lb_stl_p=float(acorr_ljungbox(st.resid, lags=[6]).lb_pvalue.iloc[0]))
    fig, ax = plt.subplots(2, 2, figsize=(7.8, 4.8))
    x = np.arange(1, 49)
    ax[0, 0].plot(x, yg, color="k", lw=1, label="GMV"); ax[0, 0].plot(x, trd, color=PAL[0], label="T (HP)"); ax[0, 0].plot(x, add.trend, color=PAL[1], ls="--", label="MA 2×12")
    ax[0, 0].legend(fontsize=6.5); ax[0, 0].set_title("(a) GMV 48 tháng và xu hướng")
    ax[0, 1].plot(x, cyc, color=PAL[3]); ax[0, 1].axhline(0, color="k", lw=.5); ax[0, 1].set_title("(b) Chu kỳ C (HP trên khối TC)")
    ax[1, 0].plot(x, yg, color=GREY, label="Thô"); ax[1, 0].plot(x, des, color=PAL[6], label="Khử mùa vụ"); ax[1, 0].legend(fontsize=6.5); ax[1, 0].set_title("(c) Thô vs khử mùa vụ (nhân)")
    ax[1, 1].bar(x[1:] - .2, mom_raw[1:] * 100, .4, color=GREY, label="MoM thô"); ax[1, 1].bar(x[1:] + .2, mom_des[1:] * 100, .4, color=PAL[6], label="MoM lõi")
    ax[1, 1].legend(fontsize=6.5); ax[1, 1].set_title("(d) Tăng trưởng tháng (%)")
    savefig(fig, ST, "s03_m48.png")

# ================================================================ E3.4
with Timer("E3.4 Biên lợi nhuận 72 tháng"):
    pm = io.gv("margin"); pm["ds"] = pd.to_datetime(pm.report_month)
    ym = pm.set_index("ds").net_profit_margin_pct
    out = {}
    for rob in [False, True]:
        s_ = STL(ym, period=12, robust=rob).fit(); c_, t_ = hpfilter(s_.trend, lamb=14400)
        out["robust" if rob else "plain"] = dict(Fs=strength(s_.seasonal, s_.resid), Ft=strength(s_.trend, s_.resid), resid_sd=float(s_.resid.std()),
                                                 seas_by_month=s_.seasonal.groupby(s_.seasonal.index.month).mean().round(3).to_dict(),
                                                 C_min=float(c_.min()), C_argmin=str(c_.idxmin().date())[:7], C_max=float(c_.max()), C_argmax=str(c_.idxmax().date())[:7],
                                                 T_start=float(t_.iloc[0]), T_end=float(t_.iloc[-1]))
        if rob:
            out["robust"]["low_weight_months"] = [str(i.date())[:7] for i in s_.weights[s_.weights < .5].index]
            st_r, c_r, t_r = s_, c_, t_
    out["yearly_mean"] = ym.groupby(ym.index.year).mean().round(3).to_dict()
    out["corr_orders_margin"] = float(pm.total_orders.corr(pm.net_profit_margin_pct))
    RES["E3_4"] = out
    fig, ax = plt.subplots(4, 1, figsize=(7.6, 6.4), sharex=True)
    ax[0].plot(ym.index, ym, color="k"); ax[0].plot(t_r.index, t_r, color=PAL[0]); ax[0].set_title("Biên lợi nhuận ròng (%) và xu hướng lõi HP")
    ax[1].plot(c_r.index, c_r, color=PAL[3]); ax[1].axhline(0, color="k", lw=.5); ax[1].set_title("Chu kỳ C")
    ax[2].plot(st_r.seasonal.index, st_r.seasonal, color=PAL[2]); ax[2].set_title("Mùa vụ S (STL kháng nhiễu)")
    ax[3].bar(st_r.resid.index, st_r.resid, width=20, color=[PAL[3] if w_ < .5 else GREY for w_ in st_r.weights]); ax[3].set_title("Phần dư (đỏ: trọng số bisquare < 0,5)")
    savefig(fig, ST, "s03_margin.png")

# ================================================================ E3.5
with Timer("E3.5 Tổng mức bán lẻ Việt Nam"):
    s = io.gso_monthly().set_index("ds")
    y = s.value.asfreq("MS")
    ly = np.log(y)
    st = STL(ly, period=12, seasonal=13, robust=True).fit()
    S_mul = np.exp(st.seasonal)
    cyc, trd = hpfilter(st.trend, lamb=14400)
    df = pd.DataFrame({"ly": ly, "t": np.arange(len(ly)), "m": ly.index.month, "tet": io.tet_window_share(ly.index), "covid": io.covid_dummy(ly.index)})
    df["post21"] = np.maximum(0, df.t - df.index.get_loc(pd.Timestamp("2021-10-01")))
    ols = smf.ols("ly ~ t + post21 + C(m) + tet + covid", df).fit(cov_type="HAC", cov_kwds={"maxlags": 3})
    mcoef = {int(k.split("T.")[1].rstrip("]")): float(ols.params[k]) for k in ols.params.index if k.startswith("C(m)")}
    # độ trôi của hệ số mùa vụ tháng 11, 12 qua các năm (STL cho phép mùa vụ thay đổi chậm)
    drift = pd.DataFrame({"year": S_mul.index.year, "month": S_mul.index.month, "S": S_mul.values})
    drift_q4 = drift[drift.month.isin([1, 11, 12])].pivot(index="year", columns="month", values="S").round(4)
    yoy = s.yoy.reindex(y.index)
    q4 = []
    for yr in range(2020, 2026):
        v = y[f"{yr}-10":f"{yr}-12"].sum(); a9 = y[f"{yr}-01":f"{yr}-09"].sum()
        q4.append(dict(year=yr, q4=float(v), first9=float(a9), q4_share=float(v / (v + a9))))
    RES["E3_5"] = dict(n=len(y), S_by_month=S_mul.groupby(S_mul.index.month).mean().round(4).to_dict(),
                       month_dummies_vs_jan=mcoef, ols=dict(tet=float(ols.params["tet"]), tet_p=float(ols.pvalues["tet"]), covid=float(ols.params["covid"]),
                                                             covid_p=float(ols.pvalues["covid"]), r2=float(ols.rsquared), n=int(ols.nobs),
                                                             tet_pct=float(np.exp(ols.params["tet"]) - 1), covid_pct=float(np.exp(ols.params["covid"]) - 1)),
                       low_weight=[str(i.date())[:7] for i in st.weights[st.weights < .5].index], C_min=float(cyc.min()), C_argmin=str(cyc.idxmin().date())[:7],
                       S_drift=drift_q4.reset_index().to_dict("records"), q4_share=q4,
                       ytd2026=float(y["2026-01":"2026-09"].sum()), ytd2025=float(y["2025-01":"2025-09"].sum()), last=float(y.iloc[-1]),
                       yoy_last=float(yoy.iloc[-1]))
    RES["E3_5"]["ytd_growth"] = RES["E3_5"]["ytd2026"] / RES["E3_5"]["ytd2025"] - 1
    write_csv(pd.DataFrame({"ds": y.index, "value": y.values, "T_hp": np.exp(trd.values), "C_hp": cyc.values, "S_mul": S_mul.values,
                            "R_mul": np.exp(st.resid.values), "weight": st.weights.values}).round(5), ST, "gso_decomposition.csv")
    write_csv(pd.DataFrame(q4), ST, "gso_q4_share.csv")
    fig, ax = plt.subplots(3, 1, figsize=(7.6, 6.2), sharex=False)
    ax[0].plot(y.index, y, color="k", marker=".", ms=3); ax[0].plot(y.index, np.exp(trd), color=PAL[0])
    for k in CFG["calendar"]["covid_months"]:
        ax[0].axvspan(pd.Timestamp(k + "-01"), pd.Timestamp(k + "-01") + pd.offsets.MonthEnd(1), color=PAL[3], alpha=.15, lw=0)
    ax[0].set_title("(a) TMBL hàng hóa & dịch vụ tiêu dùng (nghìn tỷ đồng/tháng) và xu hướng lõi")
    ax[1].bar(y.index, (S_mul - 1) * 100, width=20, color=[PAL[1] if m_ in (11, 12) else PAL[2] for m_ in y.index.month])
    ax[1].set_title("(b) Hệ số mùa vụ nhân (% so với 1) – cam: tháng 11–12 (mùa ngày đôi/cuối năm)")
    for mo, col in [(1, PAL[2]), (11, PAL[1]), (12, PAL[3])]:
        if mo in drift_q4.columns:
            ax[2].plot(drift_q4.index, drift_q4[mo], marker="o", color=col, label=f"Tháng {mo}")
    ax[2].legend(fontsize=7); ax[2].set_title("(c) Độ trôi hệ số mùa vụ theo năm")
    savefig(fig, ST, "s03_gso.png")

write_json(RES, ST, "results.json")
log_run(ST, {})
print({k: {kk: vv for kk, vv in list(v.items())[:6]} for k, v in RES.items()})
print(RES["E3_2"]["power_check"], RES["E3_2"]["prophet_cv"])
print(RES["E3_5"]["S_drift"], RES["E3_5"]["q4_share"])
