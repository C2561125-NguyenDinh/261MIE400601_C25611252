"""Stage 09 – Tổng hợp kết quả nghiên cứu theo câu hỏi nghiên cứu (RQ1–RQ5) từ đầu ra Stage 01–08."""
import pandas as pd

from src.common import Timer, log_run, read_json, write_csv, write_json

ST = "09_summary"
with Timer("Tổng hợp kết quả"):
    s1 = read_json("01_data", "summary.json"); s2 = read_json("02_marketing", "results.json"); s3 = read_json("03_decomposition", "results.json")
    s5 = read_json("05_models", "results.json"); s6 = read_json("06_probabilistic", "results.json"); s7 = read_json("07_budget", "results.json")
    s8 = read_json("08_genai", "results.json")
    ue = {r["Category"]: r for r in s2["E2_4"]["by_cat"]}
    m5 = {r["model"]: r for r in s5["E5_3"]["summary"]}
    m15 = {r["model"]: r for r in s5["E5_4"]["summary"]}
    pr = {r["model"]: r for r in s6["E6_1"]["summary"]}
    nv = {r["policy"]: r for r in s6["E6_2"]["table"] if r["cat"] == "ALL"}
    pol = {r["policy"]: r for r in s7["E7_2"]}
    risk = {r["Category"]: r for r in s6["E6_4"]["category"]}
    K = dict(
        RQ1=dict(
            ovb_ads_simple=s2["E2_2"]["ovb"]["m1"]["b_ads"], ovb_ads_full=s2["E2_2"]["ovb"]["m2"]["b_ads"], ovb_bias_pct=s2["E2_2"]["ovb"]["bias_pct"],
            mega_share_gmv=s2["E2_1"]["mega_share_gmv"], roas_avg=s2["E2_2"]["roas_avg"], roas_marginal=s2["E2_2"]["roas_marginal"],
            pooled_b=s2["E2_3"]["models"]["pooled"]["b"], fe_b=s2["E2_3"]["models"]["fe"]["b"], total_growth=s2["E2_3"]["total_growth"],
            fmcg_cm=ue["FMCG (Tiêu dùng)"]["CM"], fmcg_roas=ue["FMCG (Tiêu dùng)"]["ROAS"], fmcg_roas_be=ue["FMCG (Tiêu dùng)"]["ROAS_breakeven"],
            fmcg_total=ue["FMCG (Tiêu dùng)"]["Total_Margin"]),
        RQ2=dict(F_S365=s3["E3_1"]["F_S365"], F_S7=s3["E3_1"]["F_S7"], mkt_corr_resid=s3["E3_2"]["corr_resid"], mkt_dl_p=s3["E3_2"]["dl_joint_p"],
                 prophet_mae_base=s3["E3_2"]["prophet_cv"]["base"]["mae"], prophet_mae_mkt=s3["E3_2"]["prophet_cv"]["mkt"]["mae"],
                 gso_S_nov=s3["E3_5"]["S_by_month"]["11"], gso_S_may=s3["E3_5"]["S_by_month"]["5"], gso_tet_pct=s3["E3_5"]["ols"]["tet_pct"],
                 gso_tet_p=s3["E3_5"]["ols"]["tet_p"], gso_covid_pct=s3["E3_5"]["ols"]["covid_pct"], m48_cagr=s3["E3_3"]["cagr"]),
        RQ3=dict(global_wape=m5["Global_LGBM_scaled"]["WAPE"], hw_wape=m5["Local_HW"]["WAPE"], dm_p_pooled=s5["E5_3"]["dm_global_vs_hw"]["pooled"]["p"],
                 dm_p_agg=s5["E5_3"]["dm_global_vs_hw"]["aggregated"]["p"], hw15=m15["Local_HW"]["WAPE"], global15=m15["Global_LGBM_scaled"]["WAPE"],
                 cold_static=s5["E5_5"]["results"]["ColdStart_static"]["WAPE"], cold_warm7=s5["E5_5"]["results"]["WarmStart_7d"]["WAPE"],
                 double_day_naive_rel=s5["E5_6"]["naive_rel"]["1"], double_day_fe_pct=s5["E5_6"]["fe"]["dd"]["pct"], double_day_fe_p=s5["E5_6"]["fe"]["dd"]["p"],
                 wf_wape=s5["E5_2"]["wf_mean_wape"], kf_wape=s5["E5_2"]["kf_mean_wape"]),
        RQ4=dict(pinball=dict((k, v["mean_pinball"]) for k, v in pr.items()), cov80=dict((k, v["cov80"]) for k, v in pr.items()),
                 nv_q_qlgbm=nv["q* – Quantile LGBM"]["profit"], nv_p50=nv["Đặt P50 (dự báo điểm)"]["profit"], nv_p90=nv["Đặt P90 cho mọi SKU"]["profit"],
                 nv_oracle_pct=nv["q* – Quantile LGBM"]["profit_pct_oracle"], fmcg_ad_p_loss=risk["FMCG (Tiêu dùng)"]["p_loss"],
                 mega_loo_covered=[r["covered_gmv"] for r in s6["E6_5"]["loo"]], gso_sarima_mape=[r["MAPE"] for r in s6["E6_6"]["summary"] if r["model"].startswith("SARIMA")][0],
                 gso_q4_growth=s6["E6_6"]["q4_growth"]),
        RQ5=dict(profit_now=pol["Hiện trạng (TB 30 ngày)"]["profit"], profit_opt=pol["Tối ưu lợi nhuận (w1 = w2 = 1)"]["profit"],
                 profit_opt_in=pol["Tối ưu lợi nhuận trong vùng dữ liệu"]["profit"], p_opt_beats=s7["E7_5"]["p_opt_beats_current"],
                 plan_status=s8["E8_3"]["status_counts"], rag_p1_char=s8["E8_2"]["eval"]["char"]["P1"], rag_tau=s8["E8_2"]["tau"]),
        data=dict(gv_rows=s1["gv_rows_total"], gso_months=s1["gso"]["n_months"]))
    write_json(K, ST, "research_summary.json")
    rows = [("RQ1", "Hệ số quảng cáo lên số đơn: chỉ Ads → có Discount", f"{K['RQ1']['ovb_ads_simple']:.2f} → {K['RQ1']['ovb_ads_full']:.2f}"),
            ("RQ1", "FMCG: ROAS thực tế / ROAS hòa vốn", f"{K['RQ1']['fmcg_roas']:.2f} / {K['RQ1']['fmcg_roas_be']:.2f}"),
            ("RQ2", "Độ mạnh mùa vụ năm F_S365", f"{K['RQ2']['F_S365']:.3f}"),
            ("RQ2", "Hệ số mùa vụ TMBL tháng 11 / tháng 5", f"{K['RQ2']['gso_S_nov']:.4f} / {K['RQ2']['gso_S_may']:.4f}"),
            ("RQ3", "WAPE toàn cục vs Holt-Winters (100 SKU)", f"{K['RQ3']['global_wape']:.3f}% vs {K['RQ3']['hw_wape']:.3f}%"),
            ("RQ3", "Hiệu ứng ngày đôi sau kiểm soát thứ (100 SKU)", f"{K['RQ3']['double_day_fe_pct'] * 100:.2f}% (p = {K['RQ3']['double_day_fe_p']:.3f})"),
            ("RQ4", "Lợi nhuận q*–QLGBM / P50 / P90 (triệu VNĐ)", f"{K['RQ4']['nv_q_qlgbm']:,.1f} / {K['RQ4']['nv_p50']:,.1f} / {K['RQ4']['nv_p90']:,.1f}"),
            ("RQ5", "Lợi nhuận/ngày: hiện trạng → tối ưu trong vùng dữ liệu", f"{K['RQ5']['profit_now']:.2f} → {K['RQ5']['profit_opt_in']:.2f}")]
    write_csv(pd.DataFrame(rows, columns=["RQ", "Chỉ tiêu", "Giá trị"]), ST, "key_findings.csv")
log_run(ST, {})
print(pd.DataFrame(rows).to_string())
