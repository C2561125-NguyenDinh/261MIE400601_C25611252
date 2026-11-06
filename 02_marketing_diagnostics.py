"""Stage 02 – Chẩn đoán dữ liệu marketing và mô hình kinh doanh (slide Chương 1).

E2.1 EDA 3 phương diện của chuỗi 90 ngày (động thái, phân phối, quan hệ) + so sánh ngày Mega Sale với ngày thường
E2.2 Thiên lệch bỏ sót biến (OVB) giữa quảng cáo và chiết khấu; phân rã đóng góp số đơn theo ngày
E2.3 Panel 3 ngành: pooled vs hiệu ứng cố định, độ dốc riêng, độ co giãn, dạng đường phản hồi, ngụy biện tổng gộp
E2.4 Unit Economics: CM = AOV − (CAC + COGS), ROAS hòa vốn, CAC tối đa, độ nhạy combo/giá vốn
"""
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from scipy import stats

from src.common import CFG, GREY, PAL, Timer, log_run, plt, savefig, write_csv, write_json
from src.data import io
from src.marketing import response as R

ST = "02_marketing"
RES = {}

# ================================================================ E2.1
with Timer("E2.1 EDA chuỗi 90 ngày"):
    d = io.ecommerce_90days()
    desc = []
    for c in ["GMV", "Orders", "Ad_Spend", "Discount", "AOV"]:
        x = d[c]
        desc.append(dict(var=c, mean=x.mean(), median=x.median(), std=x.std(ddof=0), min=x.min(), max=x.max(),
                         pearson_skew=3 * (x.mean() - x.median()) / x.std(ddof=0), fisher_skew=stats.skew(x), kurt=stats.kurtosis(x),
                         jb_p=stats.jarque_bera(x).pvalue))
    desc = pd.DataFrame(desc)
    write_csv(desc, ST, "eda_descriptive.csv")
    cols = ["GMV", "Orders", "Ad_Spend", "Discount", "AOV"]
    corr = d[cols].corr().round(4)
    spear = d[cols].corr("spearman").round(4)
    write_csv(corr.reset_index().rename(columns={"index": "var"}), ST, "corr_pearson.csv")
    write_csv(spear.reset_index().rename(columns={"index": "var"}), ST, "corr_spearman.csv")
    mega = d[d.Mega == 1]
    mega_cmp = {c: R.ttest_mega(d, c) for c in ["GMV", "Orders", "Ad_Spend", "AOV"]}
    # cửa sổ quanh ngày Mega Sale: 7 ngày trước / sau so với trung bình ngày thường
    normal_mean = d.loc[d.Mega == 0, "GMV"].mean()
    win = []
    for md in mega.Date:
        for k in range(-7, 8):
            t = md + pd.Timedelta(days=k)
            r = d[d.Date == t]
            if len(r):
                win.append(dict(mega_day=str(md.date()), k=k, GMV=float(r.GMV.iloc[0]), Orders=int(r.Orders.iloc[0]),
                                rel=float(r.GMV.iloc[0] / normal_mean)))
    win = pd.DataFrame(win)
    write_csv(win, ST, "mega_window.csv")
    pre = win[win.k.between(-7, -1)].groupby("mega_day").rel.mean()
    post = win[win.k.between(1, 7)].groupby("mega_day").rel.mean()
    dow = d.groupby("dow").GMV.agg(["mean", "std", "count"]).reset_index()
    an = stats.f_oneway(*[g.GMV.values for _, g in d.groupby("dow")])
    an_ex = stats.f_oneway(*[g.GMV.values for _, g in d[d.Mega == 0].groupby("dow")])
    sma7 = d.GMV.rolling(7).mean()
    RES["E2_1"] = dict(n=len(d), start=str(d.Date.min().date()), end=str(d.Date.max().date()),
                       totals=dict(GMV=d.GMV.sum(), Orders=int(d.Orders.sum()), Ad_Spend=d.Ad_Spend.sum()),
                       roas_total=d.GMV.sum() / d.Ad_Spend.sum(),
                       mega_days=[dict(date=str(r.Date.date()), GMV=r.GMV, Orders=int(r.Orders), Ad=r.Ad_Spend, Discount=r.Discount, AOV=r.AOV) for r in mega.itertuples()],
                       mega_share_gmv=mega.GMV.sum() / d.GMV.sum(), mega_cmp=mega_cmp,
                       pre_mean_rel=pre.to_dict(), post_mean_rel=post.to_dict(), normal_mean_gmv=normal_mean,
                       dow_anova_p=an.pvalue, dow_anova_p_ex_mega=an_ex.pvalue, dow=dow.to_dict("records"),
                       share_50_90=float(d.GMV.between(50, 90).mean()),
                       sma7_after_peak=sma7[d.Date.between(mega.Date.max(), mega.Date.max() + pd.Timedelta(days=7))].round(2).tolist())
    fig, ax = plt.subplots(2, 2, figsize=(7.8, 5.6))
    a = ax[0, 0]
    a.plot(d.Date, d.GMV, color=GREY, lw=.9, label="GMV ngày")
    a.plot(d.Date, sma7, color=PAL[0], label="SMA 7 ngày (trễ)")
    a.scatter(mega.Date, mega.GMV, color=PAL[3], zorder=3, s=18, label="Mega Sale (Discount ≥ 50%)")
    a.set_title("(a) Động thái GMV (triệu VNĐ)"); a.legend(fontsize=6); a.tick_params(axis="x", labelsize=6, labelrotation=30)
    a = ax[0, 1]
    a.hist(d.GMV, bins=25, color=PAL[0], alpha=.8); a.axvline(d.GMV.mean(), color=PAL[1], ls="--", label=f"Mean {d.GMV.mean():.1f}")
    a.axvline(d.GMV.median(), color=PAL[2], label=f"Median {d.GMV.median():.1f}"); a.legend(fontsize=6); a.set_title("(b) Phân phối GMV")
    a = ax[1, 0]
    sc = a.scatter(d.Ad_Spend, d.Orders, c=d.Discount, cmap="viridis", s=14)
    plt.colorbar(sc, ax=a, label="Discount"); a.set_xlabel("Ad_Spend (triệu VNĐ)"); a.set_ylabel("Orders"); a.set_title("(c) Quảng cáo – đơn hàng, màu = chiết khấu")
    a = ax[1, 1]
    im = a.imshow(corr.values, cmap="RdBu_r", vmin=-1, vmax=1)
    a.set_xticks(range(len(cols))); a.set_xticklabels(cols, rotation=45, fontsize=6.5); a.set_yticks(range(len(cols))); a.set_yticklabels(cols, fontsize=6.5)
    for i in range(len(cols)):
        for j in range(len(cols)):
            a.text(j, i, f"{corr.values[i, j]:.2f}".replace(".", ","), ha="center", va="center", fontsize=6.5, color="white" if abs(corr.values[i, j]) > 0.6 else "#1F2D33")
    a.grid(False); a.set_title("(d) Tương quan Pearson")
    savefig(fig, ST, "s02_eda90.png")

# ================================================================ E2.2
with Timer("E2.2 Thiên lệch bỏ sót biến và phân rã đóng góp"):
    ovb, models = R.ovb_table(d)
    contrib = R.contribution_decomposition(d, models["m2"])
    write_csv(contrib.round({"base": 3, "ads": 3, "discount": 3, "residual": 3}), ST, "orders_contribution.csv")
    share = {k: float(contrib[k].sum() / contrib.Orders.sum()) for k in ["base", "ads", "discount", "residual"]}
    # ROAS biên (GMV tăng thêm trên 1 triệu VNĐ quảng cáo) từ mô hình GMV có kiểm soát chiết khấu và Mega
    m5 = models["m5"]
    roas_marginal = float(m5.params["Ad_Spend"])
    # kiểm tra độ vững: bỏ hai ngày Mega Sale (88 ngày thường)
    dn = d[d.Mega == 0]
    n1 = smf.ols("Orders ~ Ad_Spend", dn).fit(); n2 = smf.ols("Orders ~ Ad_Spend + Discount", dn).fit(); n5 = smf.ols("GMV ~ Ad_Spend + Discount", dn).fit()
    robust_normal = dict(n=int(n1.nobs), b_simple=float(n1.params["Ad_Spend"]), r2_simple=float(n1.rsquared), b_full=float(n2.params["Ad_Spend"]),
                         b_disc=float(n2.params["Discount"]), r2_full=float(n2.rsquared), corr_ads_disc=float(dn.Ad_Spend.corr(dn.Discount)),
                         roas_marginal=float(n5.params["Ad_Spend"]))
    RES["E2_2"] = dict(ovb=ovb, robust_normal_days=robust_normal, contribution_share=share, roas_marginal=roas_marginal, roas_marginal_ci=m5.conf_int().loc["Ad_Spend"].tolist(),
                       roas_avg=float(d.GMV.sum() / d.Ad_Spend.sum()))
    fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.9))
    xs = np.linspace(d.Ad_Spend.min(), d.Ad_Spend.max(), 50)
    a = ax[0]
    a.scatter(d.Ad_Spend, d.Orders, s=10, color=GREY)
    a.plot(xs, models["m1"].params["Intercept"] + models["m1"].params["Ad_Spend"] * xs, color=PAL[3], label=f"(1) chỉ Ads: β = {models['m1'].params['Ad_Spend']:.2f}")
    a.plot(xs, models["m2"].params["Intercept"] + models["m2"].params["Ad_Spend"] * xs + models["m2"].params["Discount"] * d.Discount.mean(),
           color=PAL[0], label=f"(2) + Discount: β = {models['m2'].params['Ad_Spend']:.2f}")
    a.legend(fontsize=6.5); a.set_xlabel("Ad_Spend"); a.set_ylabel("Orders"); a.set_title("(a) Hệ số quảng cáo trước/sau kiểm soát chiết khấu")
    a = ax[1]
    c2 = contrib.set_index("Date")
    a.stackplot(c2.index, c2.base, c2.ads, c2.discount, colors=[GREY, PAL[0], PAL[1]], labels=["Nền", "Quảng cáo", "Chiết khấu"], alpha=.85)
    a.plot(c2.index, c2.Orders, color="k", lw=.8, label="Thực tế")
    a.legend(fontsize=6, ncol=2); a.set_title("(b) Phân rã số đơn theo mô hình (2)"); a.tick_params(axis="x", labelsize=6, labelrotation=30)
    savefig(fig, ST, "s02_ovb_contribution.png")

# ================================================================ E2.3
with Timer("E2.3 Panel 3 ngành"):
    p = io.panel()
    pm = R.panel_models(p)
    el = R.elasticity_by_category(p)
    write_csv(el, ST, "panel_elasticity.csv")
    byc = p.groupby("Category").agg(Orders=("Orders", "sum"), GMV=("GMV", "sum"), Ad=("Ad_Spend", "sum"), GMV_mean=("GMV", "mean"), GMV_sd=("GMV", "std")).reset_index()
    byc["AOV"] = byc.GMV / byc.Orders; byc["CAC"] = byc.Ad / byc.Orders; byc["ROAS"] = byc.GMV / byc.Ad; byc["CV"] = byc.GMV_sd / byc.GMV_mean
    write_csv(byc, ST, "panel_by_category.csv")
    fits = {c: R.fit_response(g.Ad_Spend.values, g.Orders.values.astype(float)) for c, g in p.groupby("Category")}
    # ngụy biện tổng gộp: nửa đầu vs nửa sau
    p["half"] = np.where(p.Date < p.Date.min() + pd.Timedelta(days=15), "H1", "H2")
    hg = p.pivot_table(index="Category", columns="half", values="GMV", aggfunc="sum").reset_index()
    hg["growth"] = hg.H2 / hg.H1 - 1
    tot = hg[["H1", "H2"]].sum()
    write_csv(hg, ST, "aggregation_fallacy.csv")
    RES["E2_3"] = dict(models=pm, fits=fits, by_cat=byc.to_dict("records"), half_growth=hg.to_dict("records"), total_growth=float(tot.H2 / tot.H1 - 1),
                       elasticity=el.to_dict("records"))
    fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.6))
    for a, (c, g) in zip(ax, p.groupby("Category")):
        a.scatter(g.Ad_Spend, g.Orders, s=12, color=PAL[0])
        xs = np.linspace(g.Ad_Spend.min(), g.Ad_Spend.max(), 50)
        s_ = pm["slopes"][c]
        lin = fits[c]["linear"]; lg = fits[c]["log"]
        a.plot(xs, lin["a"] + lin["b"] * xs, color=PAL[3], label=f"tuyến tính β={s_['b']:.2f} (p={s_['p']:.3f})")
        a.plot(xs, lg["a"] + lg["b"] * np.log(xs), color=PAL[1], ls="--", label="log")
        a.set_title(c, fontsize=8); a.legend(fontsize=5.5); a.set_xlabel("Ad_Spend", fontsize=7)
    ax[0].set_ylabel("Orders")
    savefig(fig, ST, "s02_panel_response.png")

# ================================================================ E2.4
with Timer("E2.4 Unit Economics"):
    u = io.unit_econ()
    g = u.groupby("Category").agg(Days_Active=("Date", "nunique"), Orders=("Orders", "sum"), GMV=("GMV", "sum"), Ad=("Ad_Spend", "sum"),
                                  COGS=("COGS", "sum"), COGS_per_Order=("COGS_per_Order", "mean")).reset_index()
    g["AOV"] = g.GMV / g.Orders; g["CAC"] = g.Ad / g.Orders
    g["CM"] = g.AOV - (g.CAC + g.COGS_per_Order)
    g["ROAS"] = g.GMV / g.Ad
    g["ROAS_breakeven"] = g.AOV / (g.AOV - g.COGS_per_Order)
    g["CAC_max"] = g.AOV - g.COGS_per_Order
    g["Total_Margin"] = g.GMV - g.COGS - g.Ad
    u["CM_per_order"] = u.AOV - u.Ad_Spend / u.Orders - u.COGS_per_Order
    loss = u.groupby("Category").apply(lambda x: float((x.CM_total < 0).mean())).rename("loss_day_share").reset_index()
    g = g.merge(loss, on="Category")
    write_csv(g, ST, "unit_economics.csv")
    sens = []
    for _, r in g.iterrows():
        for da in [0, .1, .2, .3, .5]:
            for dc in [0, -.1, -.2]:
                aov = r.AOV * (1 + da); cogs = r.COGS_per_Order * (1 + dc)
                sens.append(dict(Category=r.Category, dAOV=da, dCOGS=dc, CM=aov - r.CAC - cogs, ROAS_breakeven=aov / (aov - cogs)))
    sens = pd.DataFrame(sens)
    write_csv(sens, ST, "unit_econ_sensitivity.csv")
    # lợi nhuận tăng thêm của quảng cáo ở mức biên (ROAS biên của panel × biên gộp trước quảng cáo)
    marg = []
    for _, r in g.iterrows():
        s_ = pm["slopes"].get(r.Category)
        if s_ is None:
            continue
        gm = r.AOV - r.COGS_per_Order
        marg.append(dict(Category=r.Category, orders_per_ad=s_["b"], p=s_["p"], gross_margin_per_order=gm,
                         marginal_profit_per_ad=s_["b"] * gm - 1))
    marg = pd.DataFrame(marg)
    write_csv(marg, ST, "marginal_ad_profit.csv")
    RES["E2_4"] = dict(by_cat=g.to_dict("records"), marginal=marg.to_dict("records"))
    fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.8))
    a = ax[0]
    xx = np.arange(len(g)); w = .38
    a.bar(xx - w / 2, g.ROAS, w, color=PAL[0], label="ROAS thực tế")
    a.bar(xx + w / 2, g.ROAS_breakeven, w, color=PAL[1], label="ROAS hòa vốn")
    a.set_xticks(xx); a.set_xticklabels(g.Category, fontsize=7); a.legend(fontsize=6.5); a.set_title("(a) ROAS thực tế so với ROAS hòa vốn")
    a = ax[1]
    for i, (c, x) in enumerate(u.groupby("Category")):
        a.plot(x.Date, x.CM_total.cumsum(), color=PAL[i], label=c)
    a.axhline(0, color="k", lw=.6); a.legend(fontsize=6.5); a.set_title("(b) Lãi/lỗ lũy kế sau quảng cáo (triệu VNĐ)")
    a.tick_params(axis="x", labelsize=6, labelrotation=30)
    savefig(fig, ST, "s02_unit_economics.png")

write_json(RES, ST, "results.json")
log_run(ST, {})
print(pd.DataFrame(RES["E2_4"]["by_cat"]).round(3).to_string())
print(RES["E2_2"]["ovb"]["m1"], RES["E2_2"]["ovb"]["m2"], RES["E2_2"]["contribution_share"], RES["E2_2"]["roas_marginal"])
print(pd.DataFrame(RES["E2_4"]["marginal"]).round(3))
