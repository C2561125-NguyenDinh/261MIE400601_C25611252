"""Bảng số liệu cho báo cáo – mọi giá trị đọc trực tiếp từ outputs/ của pipeline (không gõ tay)."""
import json
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "outputs"
GSO = ROOT / "data" / "raw" / "gso"
SRC_GV = "Nguồn: Tác giả tính toán từ dữ liệu học phần (tranduythanh.com/forecasting-models – dữ liệu mô phỏng, slide Ch1 tr.11); đầu ra pipeline"
SRC_GSO = "Nguồn: Tác giả tổng hợp, tính toán từ báo cáo tình hình kinh tế – xã hội hằng tháng của Cục Thống kê (nso.gov.vn)"


def J(st, f="results.json"):
    return json.load(open(OUT / st / f, encoding="utf-8"))


def C(st, f):
    return pd.read_csv(OUT / st / f)


def vn(x, d=2):
    if x is None or (isinstance(x, float) and not np.isfinite(x)) or (not isinstance(x, str) and pd.isna(x)):
        return "–"
    s = f"{float(x):,.{d}f}"
    return s.replace(",", "§").replace(".", ",").replace("§", ".").replace("-", "−")


def pc(x, d=1):
    return "–" if x is None or pd.isna(x) else vn(100 * x, d) + "%"


def pv(x):
    return "< 0,001" if x < 0.001 else vn(x, 3)


def fmt(v, f):
    if f == "s":
        return str(v)
    if f == "%":
        return pc(v)
    if f == "%2":
        return pc(v, 2)
    if f == "p":
        return pv(v)
    if f == "b":
        return "Có" if bool(v) else "Không"
    if f.startswith("d"):
        return vn(v, int(f[1:]))
    return str(v)


def frame(df, spec, cap, src, font=9, widths=None):
    rows = [[fmt(r[c], f) for c, _, f in spec] for _, r in df.iterrows()]
    return dict(cap=cap, header=[h for _, h, _ in spec], rows=rows, src=src, font=font, widths=widths)


T = {}


def reg(f):
    T[f.__name__] = f
    return f


def get(k):
    return T[k]()


# ------------------------------------------------------------------ Dữ liệu
@reg
def data_inventory():
    d = C("01_data", "data_inventory.csv"); d["sha"] = d.sha256.str[:12]
    return frame(d, [("file", "Tệp", "s"), ("rows", "Số dòng", "d0"), ("cols", "Số cột", "d0"), ("slide", "Slide", "s"), ("description", "Nội dung", "s"), ("sha", "SHA-256 (12 ký tự)", "s")],
                 "Mười hai bộ dữ liệu của học phần: quy mô, vị trí trong slide, nội dung và mã băm", SRC_GV + ".", 8, [4.2, 1.3, 1.1, 2.6, 4.6, 2.4])


@reg
def quality_checks():
    d = C("01_data", "quality_checks.csv").fillna("")
    for c in ["duplicate_keys", "n_series", "min_dates_per_series", "expected_dates", "missing_dates_total"]:
        d[c] = d[c].apply(lambda x: "" if x == "" else vn(x, 0))
    return frame(d, [("key", "Bộ dữ liệu", "s"), ("missing_cells", "Ô khuyết", "d0"), ("duplicate_rows", "Dòng trùng", "d0"), ("negative_values", "Giá trị âm", "d0"),
                     ("zero_values", "Giá trị 0", "d0"), ("start", "Từ", "s"), ("end", "Đến", "s"), ("n_series", "Số chuỗi", "s"), ("missing_dates_total", "Ngày thiếu", "s")],
                 "Kiểm tra chất lượng dữ liệu đầu vào (Stage 01)", SRC_GV + ". Giá trị âm ở biên lợi nhuận và chuỗi chuẩn hóa là hợp lệ theo định nghĩa biến.", 8)


@reg
def gso_annual():
    a = pd.read_csv(GSO / "tmbl_annual_2019_2025.csv"); c = C("01_data", "gso_check.csv").set_index("year")
    rows = []
    for _, r in a.iterrows():
        cc = c.loc[r.year] if r.year in c.index else None
        rows.append([str(int(r.year)), vn(r.value, 1), vn(r.yoy_nominal, 1), vn(r.yoy_real, 1), vn(cc["sum"], 1) if cc is not None else "–", vn(cc.gap_pct, 2) if cc is not None else "–"])
    return dict(cap="Tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng theo năm và đối chiếu với tổng 12 tháng ước tính lần đầu",
                header=["Năm", "TMBL năm (nghìn tỷ đồng)", "Tăng danh nghĩa (%)", "Tăng thực (%)", "Tổng 12 tháng", "Chênh lệch (%)"], rows=rows, src=SRC_GSO + ". 2019 chỉ có tháng 12.")


@reg
def dirty():
    d = C("01_data", "dirty_cleaning.csv")
    return frame(d, [("Date", "Ngày", "s"), ("GMV_raw", "GMV gốc", "d1"), ("after_interp", "Sau nội suy", "d2"), ("robust_z", "Z vững", "d2"),
                     ("iqr_outlier", "Ngoài hàng rào", "b"), ("treated_as_error", "Xử lý như lỗi", "b"), ("GMV_clean", "GMV sạch", "d2"), ("Note", "Ghi chú", "s")],
                 "Làm sạch tệp ecommerce_dirty_data: nội suy, hàng rào Tukey, Z vững (MAD), phân loại lỗi và sự kiện", SRC_GV + ".", 8, [1.9, 1.4, 1.6, 1.3, 1.5, 1.5, 1.5, 5.3])


# ------------------------------------------------------------------ Stage 02
@reg
def eda_desc():
    d = C("02_marketing", "eda_descriptive.csv")
    return frame(d, [("var", "Biến", "s"), ("mean", "TB", "d2"), ("median", "Trung vị", "d2"), ("std", "Độ lệch chuẩn", "d2"), ("min", "Min", "d2"), ("max", "Max", "d2"),
                     ("pearson_skew", "Skew Pearson", "d3"), ("fisher_skew", "Skew Fisher", "d3"), ("kurt", "Độ nhọn dư", "d2"), ("jb_p", "p JB", "p")],
                 "Thống kê mô tả 90 ngày (01/07–28/09/2026) – GMV, quảng cáo (triệu VNĐ), đơn, chiết khấu, AOV", SRC_GV + ".")


@reg
def corr():
    a = C("02_marketing", "corr_pearson.csv").set_index("var"); b = C("02_marketing", "corr_spearman.csv").set_index("var")
    rows = [[i] + [vn(a.loc[i, j], 3) + " / " + vn(b.loc[i, j], 3) for j in a.columns] for i in a.index]
    return dict(cap="Ma trận tương quan Pearson / Spearman", header=["Biến"] + list(a.columns), rows=rows, src=SRC_GV + ".", font=8)


@reg
def ovb():
    o = J("02_marketing")["E2_2"]["ovb"]
    rows = [["(1) Orders ~ Ad_Spend", f"{vn(o['m1']['b_ads'], 3)} ({vn(o['m1']['se'], 3)})", "–", "–", vn(o["m1"]["r2"], 3)],
            ["(2) + Discount", f"{vn(o['m2']['b_ads'], 3)} ({vn(o['m2']['se'], 3)})", f"{vn(o['m2']['b_disc'], 2)} ({vn(o['m2']['se_disc'], 2)})", "–", vn(o["m2"]["r2"], 3)],
            ["(3) log–log", f"{vn(o['m3']['elast_ads'], 3)} ({vn(o['m3']['se'], 3)})", vn(o["m3"]["semi_disc"], 3), "–", vn(o["m3"]["r2"], 3)],
            ["(4) + Mega + thứ", f"{vn(o['m4']['b_ads'], 3)} ({vn(o['m4']['se'], 3)})", vn(o["m4"]["b_disc"], 2), f"{vn(o['m4']['b_mega'], 2)} (p {pv(o['m4']['p_mega'])})", vn(o["m4"]["r2"], 3)],
            ["(5) GMV ~ Ads + Discount + Mega", f"{vn(o['m5_gmv']['b_ads'], 3)} ({vn(o['m5_gmv']['se'], 3)})", vn(o["m5_gmv"]["b_disc"], 2), f"{vn(o['m5_gmv']['b_mega'], 2)} (p {pv(o['m5_gmv']['p_mega'])})", vn(o["m5_gmv"]["r2"], 3)]]
    return dict(cap="Hồi quy kiểm chứng thiên lệch bỏ sót biến giữa quảng cáo, chiết khấu và ngày Mega Sale (sai số chuẩn OLS trong ngoặc)",
                header=["Mô hình", "Hệ số Ad_Spend", "Hệ số Discount", "Hệ số Mega", "R²"], rows=rows,
                src=SRC_GV + f". Tương quan Ads–Discount = {vn(o['corr_ads_disc'], 3)}; δ = {vn(o['ovb_identity']['delta'], 5)}; Breusch–Pagan p = {pv(o['bp_p'])}; VIF = {vn(o['vif']['Ad_Spend'], 3)}; SE HC3 của Ad_Spend ở (1)/(2): {vn(o['hc3']['m1_ads'], 3)}/{vn(o['hc3']['m2_ads'], 3)}, của Discount ở (2): {vn(o['hc3']['m2_disc'], 2)}.", font=8)


@reg
def mega_cmp():
    e = J("02_marketing")["E2_1"]["mega_cmp"]
    rows = [[k, vn(v["mega_mean"], 3), vn(v["normal_mean"], 3), vn(v["ratio"], 3)] for k, v in e.items()]
    return dict(cap="Hai ngày Mega Sale so với 88 ngày thường (trung bình)", header=["Biến", "Mega Sale", "Ngày thường", "Tỷ số"], rows=rows, src=SRC_GV + ".")


@reg
def contrib():
    s = J("02_marketing")["E2_2"]["contribution_share"]
    rows = [["Hằng số (nền)", pc(s["base"])], ["Quảng cáo", pc(s["ads"])], ["Chiết khấu", pc(s["discount"])], ["Phần dư", pc(s["residual"])]]
    return dict(cap="Tỷ trọng đóng góp vào tổng số đơn 90 ngày theo mô hình (2)", header=["Thành phần", "Tỷ trọng"], rows=rows,
                src=SRC_GV + ". Đóng góp tính so với mức 0 của từng biến; hằng số âm phản ánh ngoại suy về mức chi tiêu 0.")


@reg
def panel():
    d = C("02_marketing", "panel_by_category.csv"); m = J("02_marketing")["E2_3"]["models"]
    d["b"] = d.Category.map(lambda c: m["slopes"][c]["b"]); d["p"] = d.Category.map(lambda c: m["slopes"][c]["p"]); d["r2"] = d.Category.map(lambda c: m["slopes"][c]["r2"])
    return frame(d, [("Category", "Ngành", "s"), ("Orders", "Đơn", "d0"), ("GMV", "GMV", "d1"), ("Ad", "Quảng cáo", "d2"), ("AOV", "AOV", "d3"), ("CAC", "CAC", "d4"),
                     ("ROAS", "ROAS", "d2"), ("CV", "CV GMV", "d3"), ("b", "β Ads→Đơn", "d3"), ("p", "p", "p"), ("r2", "R²", "d3")],
                 "Panel 3 ngành × 30 ngày: lượng, chỉ số đơn vị và độ dốc quảng cáo → đơn",
                 SRC_GV + f". Gộp: β = {vn(m['pooled']['b'], 3)} (R² = {vn(m['pooled']['r2'], 3)}); hiệu ứng cố định: β = {vn(m['fe']['b'], 3)} (R² = {vn(m['fe']['r2'], 3)}); F khác biệt độ dốc p = {pv(m['F_heterog_p'])}.", 8)


@reg
def response_forms():
    f = J("02_marketing")["E2_3"]["fits"]
    rows = []
    for c, v in f.items():
        h = v["hill"]
        rows.append([c, vn(v["linear"]["r2"], 3), vn(v["linear"]["aic"], 1), vn(v["log"]["r2"], 3), vn(v["log"]["aic"], 1), vn(h.get("r2"), 3) if "r2" in h else "không hội tụ", vn(h.get("aic"), 1) if "aic" in h else "–"])
    return dict(cap="So sánh ba dạng đường phản hồi đơn theo quảng cáo theo ngành", header=["Ngành", "R² tuyến tính", "AIC", "R² log", "AIC", "R² Hill", "AIC"], rows=rows, src=SRC_GV + ".")


@reg
def elasticity():
    d = C("02_marketing", "panel_elasticity.csv")
    return frame(d, [("Category", "Ngành", "s"), ("elasticity", "Độ co giãn", "d3"), ("se", "SE", "d3"), ("p", "p", "p"), ("r2", "R²", "d3")],
                 "Độ co giãn của số đơn theo chi phí quảng cáo (log–log) theo ngành", SRC_GV + ".")


@reg
def agg_fallacy():
    d = C("02_marketing", "aggregation_fallacy.csv"); tg = J("02_marketing")["E2_3"]["total_growth"]
    rows = [[r.Category, vn(r.H1, 1), vn(r.H2, 1), pc(r.growth, 2)] for r in d.itertuples()]
    rows.append(["Tổng gộp", vn(d.H1.sum(), 1), vn(d.H2.sum(), 1), pc(tg, 2)])
    return dict(cap="Ngụy biện tổng gộp: GMV 15 ngày đầu và 15 ngày sau", header=["Ngành", "Nửa đầu", "Nửa sau", "Tăng trưởng"], rows=rows, src=SRC_GV + ".")


@reg
def unit_econ():
    d = C("02_marketing", "unit_economics.csv")
    return frame(d, [("Category", "Ngành", "s"), ("Orders", "Đơn", "d0"), ("GMV", "GMV", "d2"), ("Ad", "QC", "d2"), ("AOV", "AOV", "d4"), ("CAC", "CAC", "d4"),
                     ("COGS_per_Order", "COGS/đơn", "d2"), ("CM", "CM/đơn", "d4"), ("ROAS", "ROAS", "d2"), ("ROAS_breakeven", "ROAS hòa vốn", "d2"),
                     ("CAC_max", "CAC tối đa", "d3"), ("Total_Margin", "Lãi/lỗ lũy kế", "d2"), ("loss_day_share", "Ngày lỗ", "%")],
                 "Unit Economics theo ngành (triệu VNĐ)", SRC_GV + ". CM = AOV − (CAC + COGS) (slide Ch1 tr.111).", 7)


@reg
def marginal_ad():
    d = C("02_marketing", "marginal_ad_profit.csv")
    return frame(d, [("Category", "Ngành", "s"), ("orders_per_ad", "Đơn / 1 triệu QC", "d3"), ("p", "p", "p"), ("gross_margin_per_order", "Biên gộp/đơn", "d3"),
                     ("marginal_profit_per_ad", "LN tăng thêm / 1 triệu QC", "d3")],
                 "Lợi nhuận biên của 1 triệu VNĐ quảng cáo theo ngành", SRC_GV + ". Lợi nhuận biên = β × biên gộp/đơn − 1.")


@reg
def ue_sens():
    s = C("02_marketing", "unit_econ_sensitivity.csv"); s = s[s.Category.str.startswith("FMCG")]
    pvt = s.pivot(index="dAOV", columns="dCOGS", values="CM")
    rows = [[f"+{int(i * 100)}%"] + [vn(pvt.loc[i, c], 4) for c in sorted(pvt.columns, reverse=True)] for i in pvt.index]
    return dict(cap="Độ nhạy biên đóng góp/đơn của FMCG theo tăng AOV (bán combo) và giảm giá vốn (triệu VNĐ)", header=["Tăng AOV", "COGS giữ nguyên", "COGS −10%", "COGS −20%"],
                rows=rows, src="Nguồn: Tác giả mô phỏng trên Unit Economics (CAC giữ nguyên).")


# ------------------------------------------------------------------ Stage 03
@reg
def handcheck2():
    e = J("03_decomposition")["E3_0"]
    rows = [["Phần dư cộng (tr.8)", "5", vn(e["add_R"], 2)], ["Phần dư nhân (tr.10–11)", "1,0101", vn(e["mul_R"], 4)],
            ["T₃ cổ điển n=5 (tr.18)", "29,2", vn(e["T3_classic_odd"], 4)], ["T₃ kháng nhiễu n=5 (tr.27)", "11,57", vn(e["T3_robust_odd"], 4)],
            ["T₃ cổ điển n=4 (tr.31–32)", "33,625", vn(e["T3_classic_even"], 4)], ["T₃ kháng nhiễu n=4 (tr.38)", "11,5511", vn(e["T3_robust_even"], 4)],
            ["GAM 1: β₀; β₁; β₂ (tr.67–68)", "11,55; 1,4; 34,25", "; ".join(vn(e["gam1"][k], 2) for k in ["b0", "b1", "b2"])],
            ["GAM 1: Ŷ₆; Ŷ₇ (tr.70)", "19,95; 55,60", vn(e["gam1"]["y6"], 2) + "; " + vn(e["gam1"]["y7"], 2)],
            ["GAM 2: Ŷ₆…Ŷ₉ (tr.87–89)", "30; 78; 13; 61", "; ".join(vn(e["gam2"][k], 0) for k in ["y6", "y7", "y8", "y9"])],
            ["Prophet: Ŷ ngày 6; 7 (tr.79)", "≈19,95; ≈55,60", vn(e["prophet_toy"][5]["yhat"], 3) + "; " + vn(e["prophet_toy"][6]["yhat"], 3)],
            ["Khử mùa vụ nhân (tr.96–97)", "100; 97,40; 112,50", "; ".join(vn(x, 2) for x in e["deseason_mul"])]]
    return dict(cap="Kiểm chứng bằng mã nguồn các ví dụ tính tay của slide Chương 2", header=["Ví dụ", "Slide", "Tái lập"], rows=rows,
                src="Nguồn: Slide Chương 2 và tác giả tái lập (Stage 03).", widths=[7.0, 4.2, 4.8])


@reg
def mstl():
    e = J("03_decomposition")["E3_1"]
    rows = [["Y", vn(e["var_Y"], 2), "100%"], ["Xu hướng", vn(e["var_T"], 2), pc(e["var_T"] / e["var_Y"])], ["Mùa vụ năm", vn(e["var_S365"], 2), pc(e["var_S365"] / e["var_Y"])],
            ["Mùa vụ tuần", vn(e["var_S7"], 2), pc(e["var_S7"] / e["var_Y"])], ["Phần dư", vn(e["var_R"], 2), pc(e["var_R"] / e["var_Y"])]]
    return dict(cap="Phương sai các thành phần MSTL (7, 365) của chuỗi doanh thu ngày 2021–2023", header=["Thành phần", "Phương sai", "Tỷ trọng"], rows=rows,
                src=SRC_GV + f". F_S7 = {vn(e['F_S7'], 3)}; F_S365 = {vn(e['F_S365'], 3)}.")


@reg
def mkt_effect():
    e = J("03_decomposition")["E3_2"]; pcv = e["prophet_cv"]
    rows = [["Tương quan thô (doanh thu, chi marketing)", vn(e["corr_raw"], 4)], ["Tương quan với phần dư MSTL", vn(e["corr_resid"], 4)],
            ["Tương quan với chuỗi khử mùa vụ", vn(e["corr_deseason"], 4)], ["Adstock tốt nhất theo AIC: λ", vn(e["adstock_best"]["decay"], 1)],
            ["β adstock tại λ đó (p)", f"{vn(e['adstock_best']['beta'], 4)} ({vn(e['adstock_best']['p'], 3)})"], ["p nhỏ nhất trên lưới λ", vn(e["adstock_min_p"], 3)],
            ["Độ trễ 0–14: F chung (p)", f"{vn(e['dl_joint_F'], 3)} ({vn(e['dl_joint_p'], 4)})"],
            ["Prophet cơ sở: MAE / phủ 80%", f"{vn(pcv['base']['mae'], 3)} / {pc(pcv['base']['coverage'])}"],
            ["Prophet + marketing: MAE / phủ 80%", f"{vn(pcv['mkt']['mae'], 3)} / {pc(pcv['mkt']['coverage'])}"], ["Hệ số Prophet của marketing", vn(pcv["mkt"]["coef"], 4)]]
    return dict(cap="Kiểm định hiệu ứng chi phí marketing trên chuỗi doanh thu ngày đa mùa vụ", header=["Chỉ tiêu", "Giá trị"], rows=rows, src=SRC_GV + ".")


@reg
def power():
    e = J("03_decomposition")["E3_2"]["power_check"]
    rows = [[vn(r["beta_true"], 2), vn(r["beta_hat"], 4), vn(r["se"], 4), pv(r["p"])] for r in e]
    return dict(cap="Kiểm tra khả năng phát hiện: cấy hiệu ứng adstock (λ = 0,5) giả định vào chuỗi thật đã khử mùa vụ", header=["β cấy vào", "β ước lượng", "SE", "p"], rows=rows,
                src="Nguồn: Tác giả mô phỏng (Stage 03).")


@reg
def m48_sens():
    d = C("03_decomposition", "m48_stl_sensitivity.csv")
    return frame(d, [("robust", "Kháng nhiễu", "b"), ("seasonal", "Cửa sổ mùa vụ", "d0"), ("resid_sd", "SD phần dư", "d2"), ("seas_amp", "Biên độ S", "d2"),
                     ("C_min", "C min", "d2"), ("C_max", "C max", "d2"), ("Fs", "F_S", "d3")], "Độ nhạy STL + HP của chuỗi GMV 48 tháng", SRC_GV + ".")


@reg
def margin_decomp():
    e = J("03_decomposition")["E3_4"]
    rows = []
    for k, lab in [("plain", "STL thường"), ("robust", "STL kháng nhiễu")]:
        x = e[k]; rows.append([lab, vn(x["Fs"], 3), vn(x["Ft"], 3), vn(x["resid_sd"], 3), vn(x["T_start"], 2), vn(x["T_end"], 2), f"{vn(x['C_min'], 2)} ({x['C_argmin']})", f"{vn(x['C_max'], 2)} ({x['C_argmax']})"])
    return dict(cap="Phân rã STL + HP biên lợi nhuận ròng 72 tháng", header=["Phương án", "F_S", "F_T", "SD phần dư", "T đầu", "T cuối", "C min", "C max"], rows=rows, src=SRC_GV + ".", font=8)


@reg
def gso_season():
    e = J("03_decomposition")["E3_5"]
    rows = [[f"Tháng {m}", vn(e["S_by_month"][str(m)], 4), vn(np.exp(e["month_dummies_vs_jan"][str(m)]) - 1, 4) if str(m) in e["month_dummies_vs_jan"] else "gốc"] for m in range(1, 13)]
    return dict(cap="Hệ số mùa vụ nhân của Tổng mức bán lẻ Việt Nam (STL log) và chênh lệch tháng so với tháng 1 trong hồi quy", header=["Tháng", "S (STL)", "Hồi quy: so với tháng 1"], rows=rows, src=SRC_GSO + ".")


@reg
def gso_ols():
    o = J("03_decomposition")["E3_5"]["ols"]
    rows = [["Cửa sổ 21 ngày trước Tết", vn(o["tet"], 4), pc(o["tet_pct"]), pv(o["tet_p"])], ["Tháng giãn cách COVID-19", vn(o["covid"], 4), pc(o["covid_pct"]), pv(o["covid_p"])]]
    return dict(cap="Hồi quy log TMBL: xu hướng gãy khúc, 11 biến giả tháng, Tết và giãn cách (HAC)", header=["Biến", "Hệ số log", "Tác động (%)", "p"], rows=rows,
                src=SRC_GSO + f". n = {o['n']}, R² = {vn(o['r2'], 3)}.")


@reg
def gso_drift():
    e = J("03_decomposition")["E3_5"]
    rows = [[str(r["year"]), vn(r.get("1"), 4), vn(r.get("11"), 4), vn(r.get("12"), 4)] for r in e["S_drift"]]
    q = {r["year"]: r for r in e["q4_share"]}
    for r in rows:
        y = int(r[0]); r.append(pc(q[y]["q4_share"], 2) if y in q else "–")
    return dict(cap="Độ trôi hệ số mùa vụ tháng 1, 11, 12 và tỷ trọng quý IV trong TMBL năm", header=["Năm", "S tháng 1", "S tháng 11", "S tháng 12", "Tỷ trọng quý IV"], rows=rows, src=SRC_GSO + ".")


# ------------------------------------------------------------------ Stage 05
LAB = {"SNaive7": "Naive mùa vụ 7 ngày", "MA_dow4": "TB cùng thứ 4 tuần", "Local_HW": "Holt-Winters cục bộ", "Local_LGBM": "LightGBM cục bộ",
       "Global_LGBM_raw": "LightGBM toàn cục (thô)", "Global_LGBM_scaled": "LightGBM toàn cục (chuẩn hóa)"}


@reg
def handcheck3():
    e = J("05_models")["E5_0"]; e1 = J("05_models")["E5_1"]
    rows = [["Hồi quy Lag-1 (tr.18–21)", f"Ŷ₄(A) = {vn(e['toy_lr']['pred_day4'][0], 3)}; Ŷ₄(B) = {vn(e['toy_lr']['pred_day4'][1], 3)}"],
            ["Đệ quy 7 ngày SKU A (tr.22–28)", "; ".join(vn(x[0], 1) for x in e["toy_recursive7"])],
            ["Gradient Boosting cold-start (tr.45–50)", f"F₀ = {vn(e['gb_toy']['F0'], 0)}; γ = {vn(e['gb_toy']['gamma'][0], 0)}/{vn(e['gb_toy']['gamma'][1], 0)}; Ŷ_C = {vn(e['gb_toy']['yhat_C'], 0)}; ngưỡng {vn(e['gb_toy']['split'], 1)}°C"],
            ["Sản phẩm mới – GB trên số thô (tr.75)", vn(e1["pred_new_raw"], 1)], ["Sản phẩm mới – uplift chuẩn hóa", vn(e1["pred_new_scaled"], 1)]]
    return dict(cap="Tái lập ví dụ Chương 3 và phương án chuẩn hóa quy mô cho sản phẩm mới có khuyến mãi", header=["Ví dụ", "Kết quả"], rows=rows,
                src="Nguồn: Slide Chương 3 và tác giả tái lập (Stage 05).", widths=[6.0, 10.0])


@reg
def cv_leak():
    e = J("05_models")["E5_2"]
    rows = [[f"Walk-forward {r['fold']}", r["train"], r["test"], vn(r["r2"], 4), vn(r["MAE"], 3), vn(r["WAPE"], 3)] for r in e["walk_forward"]]
    rows += [[f"K-Fold xáo trộn {r['fold']}", "ngẫu nhiên", "ngẫu nhiên", vn(r["r2"], 4), vn(r["MAE"], 3), vn(r["WAPE"], 3)] for r in e["kfold_shuffled"]]
    return dict(cap="Walk-forward so với K-Fold xáo trộn trên complex_retail_sales (Gradient Boosting)", header=["Lần chia", "Huấn luyện", "Kiểm tra", "R²", "MAE", "WAPE (%)"], rows=rows, src=SRC_GV + ".", font=8)


@reg
def uplift():
    d = C("05_models", "promo_uplift_by_product.csv")
    d["ci"] = [f"{vn(a, 3)}–{vn(b, 3)}" if pd.notna(a) else "–" for a, b in zip(d.promo_obs_ci_lo, d.promo_obs_ci_hi)]
    return frame(d, [("product", "Sản phẩm", "s"), ("baseline", "Baseline", "d0"), ("n_promo", "Ngày KM", "d0"), ("weekend_obs", "Cuối tuần QS", "d3"), ("weekend_S", "Cuối tuần MH", "d3"),
                     ("promo_obs", "KM quan sát", "d3"), ("ci", "KTC 95%", "s"), ("promo_S", "KM S-learner", "d3"), ("promo_T", "KM T-learner", "d3")],
                 "Hệ số nhân cuối tuần và khuyến mãi theo sản phẩm: quan sát, S-learner toàn cục và T-learner cục bộ",
                 SRC_GV + f". Uplift gộp một con số cho mọi sản phẩm = {vn(d.promo_pooled_naive.iloc[0], 3)}; cơ chế sinh dữ liệu theo slide Ch3 tr.87.", 8)


@reg
def global100():
    s = pd.DataFrame(J("05_models")["E5_3"]["summary"]).sort_values("WAPE"); s["m"] = s.model.map(LAB)
    dm = J("05_models")["E5_3"]["dm_global_vs_hw"]
    return frame(s, [("m", "Mô hình", "s"), ("WAPE", "WAPE (%)", "d3"), ("MAE", "MAE", "d3"), ("RMSE", "RMSE", "d3"), ("MASE", "MASE", "d4"), ("Bias", "Bias (%)", "d3")],
                 "Toàn cục so với cục bộ trên 100 SKU: trung bình 3 gốc walk-forward, H = 14",
                 SRC_GV + f". Diebold–Mariano (|e|) toàn cục chuẩn hóa vs Holt-Winters: gộp điểm t = {vn(dm['pooled']['t'], 3)}, p = {pv(dm['pooled']['p'])} (n = {dm['pooled']['n']}); gộp chéo theo (gốc, h) với HAC độ trễ 13: t = {vn(dm['aggregated']['t'], 3)}, p = {pv(dm['aggregated']['p'])} (n = {dm['aggregated']['n']}).")


@reg
def global_origin():
    d = C("05_models", "global_vs_local_100.csv"); pvt = d.pivot(index="model", columns="origin", values="WAPE")
    rows = [[LAB[m]] + [vn(pvt.loc[m, c], 3) for c in pvt.columns] for m in pvt.index]
    return dict(cap="WAPE (%) theo gốc dự báo – 100 SKU", header=["Mô hình"] + [f"Gốc {c}" for c in pvt.columns], rows=rows, src=SRC_GV + ".")


@reg
def global_cat():
    d = C("05_models", "global_vs_local_100_bycat.csv"); pvt = d.pivot(index="cat", columns="model", values="WAPE")
    cols = ["SNaive7", "Local_HW", "Local_LGBM", "Global_LGBM_scaled"]
    return dict(cap="WAPE (%) theo ngành – 100 SKU", header=["Ngành"] + [LAB[c] for c in cols], rows=[[i] + [vn(pvt.loc[i, c], 3) for c in cols] for i in pvt.index], src=SRC_GV + ".")


@reg
def importance():
    a = J("05_models")["E5_3"]["importance"]; b = J("05_models")["E5_4"]["importance"]
    rows = [[k, pc(v, 2), pc(b.get(k, 0), 2)] for k, v in sorted(a.items(), key=lambda x: -x[1])]
    return dict(cap="Tầm quan trọng gain của đặc trưng trong LightGBM toàn cục (gốc cuối)", header=["Đặc trưng", "100 SKU", "15 SKU"], rows=rows,
                src=SRC_GV + ". Bộ 15 SKU không có giá nên log_price, margin là hằng số.")


@reg
def global15():
    s = pd.DataFrame(J("05_models")["E5_4"]["summary"]).sort_values("WAPE"); s["m"] = s.model.map(LAB)
    dm = J("05_models")["E5_4"]["dm_global_vs_hw"]
    return frame(s, [("m", "Mô hình", "s"), ("WAPE", "WAPE (%)", "d3"), ("MAE", "MAE", "d3"), ("RMSE", "RMSE", "d3"), ("MASE", "MASE", "d4"), ("Bias", "Bias (%)", "d3")],
                 "Toàn cục so với cục bộ trên 15 SKU (4 gốc, H = 14)", SRC_GV + f". DM toàn cục vs HW: gộp điểm p = {pv(dm['pooled']['p'])}; gộp chéo p = {pv(dm['aggregated']['p'])}.")


@reg
def coldstart():
    e = J("05_models")["E5_5"]
    lab = {"ColdStart_static": "Chỉ đặc trưng tĩnh + lịch", "Category_x_dow": "Trung bình ngành × thứ", "WarmStart_7d": "Warm-start 7 ngày + toàn cục", "Full_history": "Đủ lịch sử + toàn cục"}
    rows = [[lab[k], vn(v["WAPE"], 3), vn(v["MAE"], 3), vn(v["Bias"], 3)] for k, v in e["results"].items()]
    return dict(cap="Dự báo cho 10 SKU mới bị giữ lại khỏi huấn luyện (gốc cuối, H = 14)", header=["Phương án", "WAPE (%)", "MAE", "Bias (%)"], rows=rows,
                src=SRC_GV + ". SKU giữ lại: " + ", ".join(e["holdout"]) + ".")


@reg
def doubleday():
    e = J("05_models")["E5_6"]
    rows = [["So sánh thô (y / TB trượt 7 ngày)", pc(e["naive_rel"]["1"] - 1, 2), "–", pv(e["naive_p"])]]
    for k, lab in [("dd", "Ngày đôi (d = m)"), ("pay", "Ngày 25"), ("mid", "Ngày 15")]:
        rows.append([lab + " – hiệu ứng cố định SKU + thứ + xu hướng", pc(e["fe"][k]["pct"], 2), vn(e["fe"][k]["se"], 4), pv(e["fe"][k]["p"])])
    return dict(cap="Hiệu ứng ngày đôi, ngày 15, ngày 25 trên cầu 100 SKU: so sánh thô và hồi quy có kiểm soát", header=["Đặc tả", "Tác động", "SE (log)", "p"], rows=rows,
                src=SRC_GV + ". Ngày đôi: " + ", ".join(f"{r['date']} (thứ {r['dow'] + 2 if r['dow'] < 6 else 'CN'})" for r in e["double_dates"]) + "; sai số chuẩn cụm theo ngày.")


# ------------------------------------------------------------------ Stage 06
L4 = {"Z": "Z-chuẩn", "HeurGV": "Heuristic GV", "QLGBM": "Quantile LightGBM", "DeepAR": "DeepAR", "EMP": "Phân vị phần dư"}


@reg
def handcheck4():
    e = J("06_probabilistic")["E6_0"]
    rows = [["Sai số ngày 4–8 (tr.12)", "+20; −10; +30; −30; +50", "; ".join(vn(x, 0) for x in e["errors"])], ["Bias (tr.13)", "12", vn(e["bias"], 2)], ["σ (tr.16)", "31,94", vn(e["sd"], 4)],
            ["P90 với Z = 1,28 (tr.17)", "193", vn(e["p90_rounded_z"], 2)], ["Pinball q=0,9 (tr.40)", "18; 2; 45; 27; 0", "; ".join(vn(abs(x), 0) for x in e["pinball_q09"])]]
    rows += [[f"q* {r['SKU']} (tr.61)", "", vn(r["q"], 2)] for r in e["newsvendor3"]]
    for r, sv in zip(rows[-3:], ["0,50", "0,80", "0,30"]):
        r[1] = sv
    return dict(cap="Kiểm chứng ví dụ tính tay của slide Chương 4", header=["Ví dụ", "Slide", "Tái lập"], rows=rows, src="Nguồn: Slide Chương 4 và tác giả tái lập (Stage 06).", widths=[6.5, 4.8, 4.7])


@reg
def prob_eval():
    s = C("06_probabilistic", "prob_eval_summary.csv"); s["m"] = s.model.map(L4)
    return frame(s, [("m", "Mô hình", "s"), ("mean_pinball", "Pinball TB", "d3"), ("pin10", "q=0,1", "d3"), ("pin50", "q=0,5", "d3"), ("pin90", "q=0,9", "d3"), ("cov80", "Phủ 80%", "%"),
                     ("rel_width", "Rộng/cầu", "%"), ("winkler80", "Winkler", "d2"), ("mae_p50", "MAE P50", "d3")],
                 "Đánh giá dự báo phân vị: 100 SKU × 14 ngày × 3 gốc (4.200 điểm)", SRC_GV + ".", 8)


@reg
def prob_dm():
    d = J("06_probabilistic")["E6_1"]["dm"]
    rows = [[k.replace("QLGBM", "Quantile LGBM").replace("EMP", "Phân vị phần dư").replace("HeurGV", "Heuristic GV").replace("-", " – "), vn(v["mean_diff"], 4), vn(v["t"], 3), pv(v["p"])] for k, v in d.items()]
    return dict(cap="Kiểm định Diebold–Mariano trên pinball trung bình 9 phân vị (âm: mô hình thứ nhất tốt hơn)", header=["Cặp", "Chênh lệch TB", "t", "p"], rows=rows, src=SRC_GV + ".")


@reg
def calib():
    c = C("06_probabilistic", "calibration.csv").set_index("q")
    rows = [[vn(q, 1)] + [pc(c.loc[q, m]) for m in ["Z", "HeurGV", "QLGBM", "DeepAR", "EMP"]] for q in c.index]
    return dict(cap="Hiệu chỉnh: tỷ lệ cầu thực tế ≤ P_q (lý tưởng = q)", header=["q"] + [L4[m] for m in ["Z", "HeurGV", "QLGBM", "DeepAR", "EMP"]], rows=rows, src=SRC_GV + ".")


@reg
def newsvendor():
    d = C("06_probabilistic", "newsvendor_policies.csv"); d = d[d.cat == "ALL"].sort_values("profit", ascending=False)
    return frame(d, [("policy", "Chính sách", "s"), ("profit", "Lợi nhuận", "d1"), ("profit_pct_oracle", "% Oracle", "d2"), ("fill", "Fill-rate", "%2"), ("inv_capital", "Vốn hàng đặt", "d1"),
                     ("salvage_loss", "Lỗ thanh lý", "d1"), ("lost_margin", "Lãi bị mất", "d1")],
                 "Chuẩn bị hàng cho chiến dịch theo các chính sách đặt hàng ngày (100 SKU, 3 gốc × 14 ngày, triệu VNĐ)",
                 SRC_GV + ". Lợi nhuận = p·min(Q,D) − c·Q + s·(Q − D)⁺ (giá/vốn/thanh lý: nghìn VNĐ/đơn vị).", 8)


@reg
def newsvendor_cat():
    d = C("06_probabilistic", "newsvendor_policies.csv"); d = d[d.cat != "ALL"]
    keep = ["Đặt P50 (dự báo điểm)", "Đặt P90 cho mọi SKU", "q* – Quantile LGBM", "Oracle (biết trước cầu)"]
    d = d[d.policy.isin(keep)].sort_values(["cat", "profit"])
    return frame(d, [("cat", "Ngành", "s"), ("policy", "Chính sách", "s"), ("profit", "Lợi nhuận", "d1"), ("profit_pct_oracle", "% Oracle", "d2"), ("fill", "Fill-rate", "%2"), ("inv_capital", "Vốn", "d1")],
                 "Chính sách đặt hàng theo ngành (triệu VNĐ)", SRC_GV + ".", 8)


@reg
def qstar_cat():
    q = J("06_probabilistic")["E6_2"]
    rows = [[r["cat"], vn(r["mean"], 3), vn(r["min"], 3), vn(r["max"], 3), vn(r["count"], 0)] for r in q["q_by_cat"]]
    return dict(cap="Phân vị tới hạn q* theo ngành (100 SKU)", header=["Ngành", "q* TB", "q* min", "q* max", "Số SKU"], rows=rows,
                src=SRC_GV + ". Nhãn chiến lược theo script của học phần: " + "; ".join(f"{k}: {v}" for k, v in q["strategy_counts"].items()) + ".")


@reg
def rop():
    d = C("06_probabilistic", "reorder_point.csv")
    return frame(d, [("L", "L (ngày)", "d0"), ("target", "Mục tiêu", "%"), ("method", "Phương pháp", "s"), ("CSL", "CSL thực đạt", "%"), ("mean_SS", "SS TB", "d1"), ("mean_SS_rel", "SS/cầu L ngày", "%")],
                 "Reorder Point theo lead time và mức phục vụ mục tiêu", SRC_GV + f". Tự tương quan bậc 1 TB của sai số ngày = {vn(J('06_probabilistic')['E6_3']['acf1_mean'], 3)}.", 8)


@reg
def ad_risk():
    d = C("06_probabilistic", "ad_risk_category.csv")
    s = C("06_probabilistic", "ad_risk_shop.csv").iloc[0]
    t = frame(d, [("Category", "Ngành", "s"), ("slope_mean", "β TB", "d3"), ("slope_p05", "β P5", "d3"), ("slope_p95", "β P95", "d3"), ("gross_margin_order", "Biên gộp/đơn", "d3"),
                  ("profit_per_ad_p05", "LN/1tr QC P5", "d3"), ("profit_per_ad_p50", "P50", "d3"), ("profit_per_ad_p95", "P95", "d3"), ("p_loss", "P(lỗ)", "%")],
              "Phân phối bootstrap lợi nhuận tăng thêm trên 1 triệu VNĐ quảng cáo theo ngành (2.000 lần lấy mẫu)",
              SRC_GV + f". Toàn shop (90 ngày, biên gộp/đơn {vn(J('06_probabilistic')['E6_4']['gm_order_90'], 4)}): P(lỗ) = {pc(s.p_loss)}, LN/1 triệu P50 = {vn(s.profit_p50, 3)}.", 8)
    return t


@reg
def mega_model():
    e = J("06_probabilistic")["E6_5"]["model"]
    rows = [[k, vn(e["params"][k], 3), vn(e["bse"][k], 3), pv(e["pvalues"][k])] for k in ["Intercept", "Ad_Spend", "Discount", "Mega"]]
    rows += [["AOV ~ Discount: hệ số", vn(e["aov_params"]["Discount"], 4), "–", pv(e["aov_p"]["Discount"])]]
    return dict(cap="Mô hình chiến dịch: Orders ~ Ad_Spend + Discount + Mega và AOV ~ Discount (90 ngày)", header=["Hệ số", "Ước lượng", "SE", "p"], rows=rows,
                src=SRC_GV + f". R² = {vn(e['r2'], 3)}; độ lệch chuẩn phần dư = {vn(e['resid_sd'], 2)} đơn.")


@reg
def mega_loo():
    d = C("06_probabilistic", "megasale_loo.csv")
    return frame(d, [("date", "Ngày bỏ ra", "s"), ("actual_orders", "Đơn thực", "d0"), ("orders_p10", "Đơn P10", "d1"), ("orders_p50", "P50", "d1"), ("orders_p90", "P90", "d1"),
                     ("actual_gmv", "GMV thực", "d2"), ("gmv_p10", "GMV P10", "d2"), ("gmv_p50", "P50", "d2"), ("gmv_p90", "P90", "d2"), ("covered_gmv", "Phủ", "b")],
                 "Kiểm tra bỏ-một-ngày: dự báo ngày Mega Sale khi mô hình chỉ thấy ngày Mega Sale còn lại", SRC_GV + ".", 8)


@reg
def mega_grid():
    g = C("06_probabilistic", "megasale_scenarios.csv"); g = g[g.cost_basis == "list"]
    pvt = g.pivot(index="ads", columns="disc", values="cm_p50")
    rows = [[vn(a, 0)] + [vn(pvt.loc[a, d], 1) for d in pvt.columns] for a in pvt.index]
    return dict(cap="Biên đóng góp P50 ngày Mega Sale theo quảng cáo × chiết khấu (giá vốn theo giá niêm yết, triệu VNĐ)",
                header=["QC/ngày"] + [f"Chiết khấu {int(d * 100)}%" for d in pvt.columns], rows=rows,
                src=SRC_GV + ". Mọi ô có chiết khấu ≠ 50% hoặc QC > 33,54 là ngoại suy (dữ liệu chỉ có Mega Sale ở mức 50%).")


@reg
def gso_backtest():
    d = C("06_probabilistic", "gso_backtest.csv")
    return frame(d, [("origin", "Gốc", "s"), ("model", "Mô hình", "s"), ("MAPE", "MAPE (%)", "d2"), ("WAPE", "WAPE (%)", "d2"), ("RMSE", "RMSE", "d2"), ("Bias", "Bias (%)", "d2"),
                     ("cov80", "Phủ 80%", "%"), ("sum_err_pct", "Sai số tổng (%)", "d2")], "Dự báo TMBL 12 tháng: walk-forward hai gốc (9/2024, 9/2025)", SRC_GSO + ".", 8)


@reg
def gso_forecast():
    d = C("06_probabilistic", "gso_forecast.csv")
    d["ci"] = [f"{vn(a, 1)} – {vn(b, 1)}" for a, b in zip(d.SARIMA_lo, d.SARIMA_hi)]
    return frame(d, [("ds", "Tháng", "s"), ("SARIMA", "SARIMA", "d1"), ("ci", "Khoảng 80% SARIMA", "s"), ("Prophet", "Prophet", "d1"), ("ETS", "ETS", "d1"), ("Ensemble", "Tổ hợp", "d1")],
                 "Dự báo kịch bản TMBL 10/2026 – 9/2027 (nghìn tỷ đồng) – đầu ra mô hình, không phải số liệu công bố", "Nguồn: Tác giả dự báo từ chuỗi Cục Thống kê (Stage 06).")


# ------------------------------------------------------------------ Stage 07
@reg
def budget_resp():
    e = J("07_budget")["E7_1"]
    rows = [[c, vn(v["alpha"], 2), vn(v["beta"], 3), vn(v["aov"], 3), vn(v["cogs"], 3), vn(v["gm"], 3), f"{vn(v['a_range'][0], 2)}–{vn(v['a_range'][1], 2)}",
             vn(e["current"][c], 3), vn(v["marginal_profit_at_current"], 3)] for c, v in e["response"].items()]
    return dict(cap="Đường phản hồi Orders = α + β·ln(QC) theo ngành và lợi nhuận biên tại mức chi hiện tại",
                header=["Ngành", "α", "β", "AOV", "COGS/đơn", "Biên gộp", "Vùng QC quan sát", "QC hiện tại", "LN biên/1tr"], rows=rows,
                src=SRC_GV + ". AOV, COGS từ unit economics; đường phản hồi từ panel.", font=8)


@reg
def budget_policy():
    d = C("07_budget", "policy_comparison.csv")
    return frame(d, [("policy", "Chính sách", "s"), ("ads_FMCG (Tiêu dùng)", "FMCG", "d2"), ("ads_Thời trang", "Thời trang", "d2"), ("ads_Điện tử", "Điện tử", "d2"),
                     ("gmv", "GMV/ngày", "d2"), ("profit", "LN gộp sau QC/ngày", "d2"), ("all_in_range", "Trong vùng dữ liệu", "b")],
                 "Phân bổ ngân sách quảng cáo/ngày giữa ba ngành ở mức ngân sách hiện tại (triệu VNĐ)", SRC_GV + f". Ngân sách = {vn(J('07_budget')['E7_1']['budget_now'], 3)} triệu VNĐ/ngày.", 8)


@reg
def budget_sweep():
    d = C("07_budget", "weight_sweep.csv")
    return frame(d, [("w2", "w₂", "d2"), ("ads_FMCG (Tiêu dùng)", "FMCG", "d2"), ("ads_Thời trang", "Thời trang", "d2"), ("ads_Điện tử", "Điện tử", "d2"), ("gmv", "GMV", "d2"), ("profit", "LN", "d2")],
                 "Quét trọng số chi phí w₂ (w₁ = 1) của hàm mục tiêu w₁·GMV − w₂·(giá vốn + QC)", SRC_GV + ".")


@reg
def budget_levels():
    d = C("07_budget", "budget_levels.csv")
    return frame(d, [("level", "Ngân sách", "%"), ("budget", "Triệu/ngày", "d2"), ("profit", "LN tối ưu", "d2"), ("shadow_price", "λ", "d3"), ("profit_within_data", "LN trong vùng DL", "d2"),
                     ("shadow_within_data", "λ trong vùng DL", "d3"), ("all_in_range", "Tối ưu tự do trong vùng DL", "b")],
                 "Lợi nhuận tối ưu và giá bóng λ theo mức ngân sách", SRC_GV + ".", 8)


@reg
def budget_boot():
    d = C("07_budget", "bootstrap_policy_profit.csv"); e = J("07_budget")["E7_5"]
    return frame(d, [("policy", "Chính sách", "s"), ("profit_mean", "LN TB", "d2"), ("profit_p05", "P5", "d2"), ("profit_p95", "P95", "d2")],
                 "Lợi nhuận/ngày của các chính sách dưới bất định tham số (bootstrap 1.000 lần)",
                 SRC_GV + f". P(tối ưu lợi nhuận > hiện trạng) = {pc(e['p_opt_beats_current'])}; chênh lệch TB = {vn(e['mean_gain_vs_current'], 2)} triệu VNĐ/ngày.")


# ------------------------------------------------------------------ Stage 08
@reg
def rag_eval():
    e = J("08_genai"); r1, r2 = e["E8_1"], e["E8_2"]
    rows = [[f"Ví dụ slide – tài liệu {i + 1}", vn(s, 4)] for i, s in enumerate(r1["scores"])]
    rows += [["Kho tri thức: số đoạn", str(r2["n_chunks"])], ["TF-IDF từ: P@1 / MRR", f"{vn(r2['eval']['word']['P1'], 3)} / {vn(r2['eval']['word']['MRR'], 3)}"],
             ["TF-IDF n-gram ký tự: P@1 / MRR", f"{vn(r2['eval']['char']['P1'], 3)} / {vn(r2['eval']['char']['MRR'], 3)}"], ["Ngưỡng từ chối τ (P5 trong miền)", vn(r2["tau"], 4)]]
    rows += [[f"Ngoài miền: {o['q']}", f"{vn(o['score'], 4)} → {'từ chối' if o['abstain'] else 'không từ chối'}"] for o in r2["ood"]]
    return dict(cap="RAG: tái lập ví dụ slide (tr.22–26) và đánh giá trên kho tri thức chiến dịch", header=["Chỉ tiêu", "Giá trị"], rows=rows, src="Nguồn: Tác giả (Stage 08).", widths=[10.0, 6.0])


@reg
def kb():
    d = C("08_genai", "knowledge_chunks.csv")
    return frame(d, [("doc_id", "Mã đoạn", "s"), ("title", "Tiêu đề", "s"), ("source", "Nguồn", "s")], f"Kho tri thức của tác tử ({len(d)} đoạn)",
                 "Nguồn: knowledge_base/ – tệp 04 là quy chế mẫu do tác giả soạn cho mô phỏng.", 7, [4.0, 6.5, 5.5])


@reg
def plans():
    d = C("08_genai", "campaign_plans.csv")
    d["st"] = d.status.map({"AUTO_APPROVED": "Tự duyệt", "NEEDS_HUMAN_REVIEW": "Người duyệt", "REJECTED": "Từ chối"})
    return frame(d, [("request_id", "ID", "s"), ("campaign", "Chiến dịch", "s"), ("ads_per_day", "QC/ngày", "d1"), ("discount", "CK", "%"), ("gmv_p50", "GMV P50", "d1"),
                     ("cm_p50", "CM P50", "d1"), ("p_cm_negative", "P(CM<0)", "%"), ("extrapolation", "Ngoại suy", "b"), ("st", "Trạng thái", "s")],
                 "Mười hai đề xuất chiến dịch qua tác tử: dự báo, kiểm tra và trạng thái phê duyệt (triệu VNĐ)",
                 SRC_GV + f". Ngưỡng ngân sách P95 = {vn(J('08_genai')['E8_3']['ads_p95'], 2)} triệu VNĐ/ngày.", 8, [1.0, 4.6, 1.4, 1.1, 1.6, 1.5, 1.5, 1.5, 1.8])


@reg
def plan_reasons():
    d = C("08_genai", "campaign_plans.csv")
    return frame(d, [("request_id", "ID", "s"), ("reasons", "Lý do do tác tử ghi nhận", "s")], "Lý do phê duyệt/chuyển người duyệt/từ chối của từng đề xuất", "Nguồn: outputs/08_genai/campaign_plans.csv.", 8, [1.2, 14.8])


@reg
def agent_cmp():
    d = C("08_genai", "agent_comparison.csv").fillna("")
    return frame(d, [("day", "Loại ngày", "s"), ("agent", "Tác tử", "s"), ("ads", "QC", "d1"), ("disc", "CK", "%"), ("gmv_p50", "GMV P50", "d1"), ("cm_p50", "CM P50", "d1"), ("p_cm_negative", "P(CM<0)", "%")],
                 "Tác tử tối đa GMV so với tác tử tối đa biên đóng góp có rào chắn (triệu VNĐ)", SRC_GV + ". Ô trống: không có phương án khả thi trong vùng dữ liệu.", 8)


# ------------------------------------------------------------------ Stage 11–13
@reg
def diag_h():
    d = C("11_diagnostics", "wape_by_h.csv")
    return frame(d, [("h", "h", "d0"), ("Global_LGBM_scaled", "Toàn cục", "d3"), ("Local_HW", "Holt-Winters", "d3"), ("SNaive7", "Naive mùa vụ", "d3")], "WAPE (%) theo chân trời dự báo – 100 SKU", SRC_GV + ".")


@reg
def diag_dow():
    d = C("11_diagnostics", "wape_by_dow.csv"); d["t"] = d.dow.map(lambda x: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"][x])
    return frame(d, [("t", "Thứ", "s"), ("Global_LGBM_scaled", "Toàn cục", "d3"), ("Local_HW", "Holt-Winters", "d3"), ("SNaive7", "Naive mùa vụ", "d3"), ("n", "Số điểm", "d0")], "WAPE (%) theo thứ – 100 SKU", SRC_GV + ".")


@reg
def mega_days():
    d = C("12_cases", "c1_mega_days.csv"); d["b"] = d.basis.map({"gmv": "Theo GMV", "list": "Theo giá niêm yết"})
    return frame(d, [("date", "Ngày", "s"), ("b", "Giả định giá vốn", "s"), ("GMV", "GMV", "d2"), ("Orders", "Đơn", "d0"), ("AOV", "AOV", "d3"), ("Ads", "QC", "d2"), ("cost_share", "Giá vốn/GMV", "%"), ("CM", "Biên đóng góp", "d2")],
                 "Giải phẫu hai ngày Mega Sale theo hai giả định giá vốn (triệu VNĐ)", SRC_GV + f". Ngày thường: biên đóng góp TB {vn(J('12_cases')['C1']['normal_mean']['CM_list'], 2)} (giá niêm yết) / {vn(J('12_cases')['C1']['normal_mean']['CM_gmv'], 2)} (theo GMV).", 8)


@reg
def cash_grid():
    d = C("12_cases", "c3_cash_grid.csv")
    return frame(d, [("lag", "Trễ đối soát", "d0"), ("lead", "Lead time", "d0"), ("fee", "Phí sàn", "%"), ("cash_need", "Tiền mặt tối thiểu", "d1"), ("date_min", "Ngày đáy", "s"), ("end", "Tiền cuối kỳ", "d1")],
                 "Tiền mặt tối thiểu cần chuẩn bị cho 90 ngày chiến dịch theo độ trễ đối soát, lead time và phí sàn (triệu VNĐ)", SRC_GV + f" (giá vốn/GMV = {vn(J('12_cases')['C1']['cogs_ratio'], 4)}). Độ trễ và phí là tham số kịch bản.", 8)


@reg
def mega_inc():
    d = C("12_cases", "c3_mega_increment.csv")
    return frame(d, [("lag", "Trễ đối soát", "d0"), ("lead", "Lead time", "d0"), ("peak_extra_cash", "Vốn khóa thêm tối đa", "d2"), ("peak_date", "Ngày đỉnh", "s"), ("days_locked", "Số ngày bị khóa", "d0"), ("extra_cash_end", "Tiền ròng thêm cuối kỳ", "d2")],
                 "Vốn bị khóa thêm do hai ngày Mega Sale so với kịch bản thay bằng trung vị (triệu VNĐ)", SRC_GV + ".")


@reg
def sens_cost():
    d = C("13_sensitivity", "s1_cost_basis.csv"); d["b"] = d.basis.map({"gmv": "Theo GMV", "list": "Theo giá niêm yết"})
    return frame(d, [("cogs_mult", "Hệ số giá vốn", "d1"), ("b", "Giả định", "s"), ("date", "Ngày Mega Sale", "s"), ("cost_share", "Giá vốn/GMV", "%"), ("cm_p50", "CM P50", "d2")],
                 "Độ nhạy biên đóng góp ngày Mega Sale theo giả định giá vốn và mức giá vốn ±10%", SRC_GV + ".")


@reg
def sens_minshare():
    d = C("13_sensitivity", "s2_min_share.csv")
    return frame(d, [("min_share", "Tỷ trọng tối thiểu", "%"), ("ads_FMCG (Tiêu dùng)", "FMCG", "d2"), ("ads_Thời trang", "Thời trang", "d2"), ("ads_Điện tử", "Điện tử", "d2"), ("profit", "LN", "d2"), ("gmv", "GMV", "d2")],
                 "Độ nhạy phân bổ tối ưu theo tỷ trọng tối thiểu mỗi ngành", SRC_GV + ".")


@reg
def sens_hitl():
    d = C("13_sensitivity", "s3_hitl_thresholds.csv")
    return frame(d, [("budget_q", "Phân vị NS", "%"), ("budget_thr", "Ngưỡng NS", "d2"), ("discount_review", "Ngưỡng CK", "%"), ("auto", "Tự duyệt", "d0"), ("review", "Người duyệt", "d0"), ("rejected", "Từ chối", "d0")],
                 "Độ nhạy số đề xuất chuyển người duyệt theo ngưỡng HITL", SRC_GV + ".")


@reg
def sens_hyper():
    d = C("13_sensitivity", "s4_hyperparams.csv")
    return frame(d, [("num_leaves", "num_leaves", "d0"), ("min_data_in_leaf", "min_data_in_leaf", "d0"), ("WAPE", "WAPE (%)", "d3"), ("MAE", "MAE", "d3"), ("RMSE", "RMSE", "d3"), ("Bias", "Bias (%)", "d3")],
                 "Độ nhạy LightGBM toàn cục theo siêu tham số (gốc cuối)", SRC_GV + ".")


@reg
def sens_margin():
    d = C("13_sensitivity", "s5_margin_allocation.csv")
    return frame(d, [("category_changed", "Ngành thay đổi", "s"), ("gm_factor", "Hệ số biên gộp", "d1"), ("ads_FMCG (Tiêu dùng)", "FMCG", "d2"), ("ads_Thời trang", "Thời trang", "d2"), ("ads_Điện tử", "Điện tử", "d2"), ("profit", "LN", "d2")],
                 "Độ nhạy phân bổ tối ưu khi biên gộp của một ngành thay đổi ±20%", SRC_GV + ".", 8)


@reg
def smoke():
    d = C("10_smoke", "smoke_test.csv")
    return frame(d, [("check", "Kiểm tra", "s"), ("passed", "Đạt", "b")], "Hai mươi bốn kiểm tra tự động của Stage 10", "Nguồn: outputs/10_smoke/smoke_test.csv.", 8, [13.5, 2.5])


# ------------------------------------------------------------------ Phụ lục
@reg
def gso_monthly():
    s = pd.read_csv(GSO / "tmbl_monthly_2019_12_2026_09.csv")
    rows = [[r.ym, vn(r.value, 1), "–" if pd.isna(r.mom) else vn(r.mom, 1), "–" if pd.isna(r.yoy) else vn(r.yoy, 1), r.post_date, "Suy ra từ tổng quý" if str(r.source_type).startswith("suy") else "Báo cáo tháng"] for r in s.itertuples()]
    return dict(cap="Chuỗi TMBL theo tháng 12/2019 – 9/2026 (nghìn tỷ đồng, ước tính lần đầu)", header=["Tháng", "TMBL", "So tháng trước (%)", "So cùng kỳ (%)", "Ngày đăng", "Nguồn"], rows=rows, src=SRC_GSO + ".", font=8)


@reg
def gso_links():
    s = pd.read_csv(GSO / "tmbl_monthly_2019_12_2026_09.csv")
    return dict(cap="Đường dẫn nguồn (sau https://www.nso.gov.vn) của từng giá trị tháng", header=["Tháng", "Đường dẫn"], rows=[[r.ym, r.link.replace("https://www.nso.gov.vn", "")] for r in s.itertuples()],
                src=SRC_GSO + ".", font=7, widths=[1.8, 14.2])


@reg
def qstar_all():
    d = C("06_probabilistic", "sku_critical_ratio.csv")
    return frame(d, [("sid", "SKU", "s"), ("Price", "Giá", "d0"), ("Cost", "Vốn", "d0"), ("Salvage", "Thanh lý", "d0"), ("q_star", "q*", "d3"), ("strategy", "Chiến lược", "s")],
                 "Cấu trúc chi phí và q* của 100 SKU (nghìn VNĐ/đơn vị)", SRC_GV + ".", 8)


@reg
def m48_table():
    d = C("03_decomposition", "m48_decomposition.csv")
    return frame(d, [("Month", "Tháng", "d0"), ("GMV", "GMV", "d2"), ("S_mul", "S (nhân)", "d4"), ("GMV_deseason", "Khử mùa vụ", "d2"), ("T_hp", "T (HP)", "d2"), ("C_hp", "C (HP)", "d2"), ("mom_raw", "MoM thô", "%"), ("mom_core", "MoM lõi", "%")],
                 "Phân rã chuỗi GMV 48 tháng", SRC_GV + ".", 8)


@reg
def sha_all():
    h = J("01_data", "sha256.json")
    return dict(cap="Mã băm SHA-256 của các tệp dữ liệu đầu vào", header=["Tệp", "SHA-256"], rows=[[k, v] for k, v in h.items()], src="Nguồn: outputs/01_data/sha256.json.", font=7, widths=[5.5, 10.5])


@reg
def feat_dict():
    d = C("04_features", "feature_dictionary.csv")
    return frame(d, [("feature", "Đặc trưng", "s"), ("definition", "Định nghĩa", "s"), ("role", "Vai trò", "s")], "Từ điển đặc trưng của mô hình toàn cục", "Nguồn: outputs/04_features/feature_dictionary.csv.", 8, [3.0, 8.0, 5.0])
