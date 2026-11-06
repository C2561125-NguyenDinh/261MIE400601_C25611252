"""Stage 10 – Kiểm tra đầu ra và các ràng buộc phương pháp của pipeline (dừng với mã lỗi nếu có kiểm tra thất bại)."""
import sys

import numpy as np
import pandas as pd

from src.common import OUT, Timer, log_run, read_csv, read_json, write_csv
from src.genai.agent import validate_payloads

ST = "10_smoke"
checks = []


def ok(name, cond, detail=""):
    checks.append(dict(check=name, passed=bool(cond), detail=str(detail)))


with Timer("Kiểm tra đầu ra"):
    for st, f in [("01_data", "summary.json"), ("02_marketing", "results.json"), ("03_decomposition", "results.json"), ("04_features", "leakage_test.json"),
                  ("05_models", "results.json"), ("06_probabilistic", "results.json"), ("07_budget", "results.json"), ("08_genai", "results.json"),
                  ("09_summary", "research_summary.json")]:
        ok(f"Tồn tại {st}/{f}", (OUT / st / f).exists())
    ok("Không rò rỉ thông tin trong đặc trưng", read_json("04_features", "leakage_test.json")["passed"])
    s1 = read_json("01_data", "summary.json")
    ok("Đối chiếu tổng tháng – số năm Cục Thống kê |chênh| < 5%", s1["gso"]["max_abs_gap_pct"] < 5, s1["gso"]["max_abs_gap_pct"])
    s2 = read_json("02_marketing", "results.json")
    ok("Unit economics khớp slide: FMCG lỗ lũy kế −78,44", abs([r for r in s2["E2_4"]["by_cat"] if r["Category"].startswith("FMCG")][0]["Total_Margin"] + 78.44) < 0.01)
    ok("Đồng nhất thức OVB: b_simple = b_full + b_disc·δ", abs(s2["E2_2"]["ovb"]["ovb_identity"]["implied"] - s2["E2_2"]["ovb"]["ovb_identity"]["b_simple"]) < 1e-6)
    s3 = read_json("03_decomposition", "results.json")
    ok("Ví dụ tay Chương 2: T3 kháng nhiễu = 11,5706", abs(s3["E3_0"]["T3_robust_odd"] - 11.5706) < 1e-3)
    ok("Ví dụ tay GAM2: Ŷ9 = 61", abs(s3["E3_0"]["gam2"]["y9"] - 61) < 1e-9)
    s6 = read_json("06_probabilistic", "results.json")
    q = read_csv("06_probabilistic", "quantile_forecasts_last_origin.csv")
    ok("Phân vị QLGBM đơn điệu sau sắp xếp", (q.QLGBM_P10 <= q.QLGBM_P50 + 1e-9).all() and (q.QLGBM_P50 <= q.QLGBM_P90 + 1e-9).all())
    ok("Ví dụ tay Chương 4: q* = 0,5 / 0,8 / 0,3", np.allclose([r["q"] for r in s6["E6_0"]["newsvendor3"]], [.5, .8, .3]))
    nv = pd.DataFrame(s6["E6_2"]["table"]); nv = nv[nv.cat == "ALL"]
    ok("Oracle là cận trên lợi nhuận", nv.profit.max() == nv[nv.policy.str.startswith("Oracle")].profit.iloc[0])
    s7 = read_json("07_budget", "results.json")
    pol = pd.DataFrame(s7["E7_2"]); cols = [c for c in pol.columns if c.startswith("ads_")]
    ok("Mọi chính sách phân bổ dùng đúng tổng ngân sách", np.allclose(pol[cols].sum(1), s7["E7_1"]["budget_now"], atol=1e-4))
    s8 = read_json("08_genai", "results.json")
    plans = pd.DataFrame(s8["E8_3"]["plans"])
    ok("Mọi đề xuất chiết khấu > 50% (không thuộc KM tập trung) bị từ chối",
       (plans[(plans.discount > .5) & (plans.status != "REJECTED")].request_id.isin(["R08"])).all())
    ok("Không tự động duyệt đề xuất có biên đóng góp P50 âm", not ((plans.cm_p50 < 0) & (plans.status == "AUTO_APPROVED")).any())
    ok("Không tự động duyệt đề xuất ngoại suy", not (plans.extrapolation & (plans.status == "AUTO_APPROVED")).any())
    ok("Payload sai kiểu bị chặn", validate_payloads([dict(request_id="Z", campaign="Mega Sale", ads_per_day=-1, discount=.2)])[0].startswith("bị chặn"))
    ok("RAG tái lập điểm slide 0,3979", abs(s8["E8_1"]["scores"][2] - 0.3979) < 1e-4)

res = pd.DataFrame(checks)
write_csv(res, ST, "smoke_test.csv")
log_run(ST, dict(passed=int(res.passed.sum()), total=len(res)))
print(res.to_string())
if not res.passed.all():
    sys.exit(1)
