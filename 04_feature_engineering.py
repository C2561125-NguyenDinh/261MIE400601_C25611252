"""Stage 04 – Kỹ thuật đặc trưng (slide Chương 3: tabular hóa chuỗi, đặc trưng trễ/cửa sổ/lịch, chuẩn hóa quy mô).

Đầu ra: data/interim/global_frame_100.parquet, promo_frame.parquet; outputs/04_features/feature_dictionary.csv,
leakage_test.json (đổi giá trị tương lai không làm đổi đặc trưng), calendar_2026.csv (ngày đôi, ngày lương, cửa sổ Tết)
"""
import numpy as np
import pandas as pd

from src.common import CFG, INTERIM, Timer, log_run, write_csv, write_json
from src.data import io
from src.features.build import FEATS, make_frame, promo_frame, static_100

ST = "04_features"
H = CFG["global_models"]["horizon"]

with Timer("Khung đặc trưng toàn cục 100 SKU"):
    W = io.hist100_wide()
    static = static_100(io.fin100())
    n = len(W)
    origins = list(range(CFG["global_models"]["min_train_origin"], n - 1))
    fr = make_frame(W, static, origins, H)
    fr.to_parquet(INTERIM / "global_frame_100.parquet", index=False)

with Timer("Kiểm tra rò rỉ thông tin"):
    T = n - 1 - 2 * H
    a = make_frame(W, static, [T], H, need_target=False)
    W2 = W.copy(); W2.iloc[T + 1:] = W2.iloc[T + 1:] * 10 + 999          # phá hủy toàn bộ tương lai
    b = make_frame(W2, static, [T], H, need_target=False)
    cols = [c for c in FEATS if c in a.columns]
    leak = dict(origin=str(W.index[T].date()), n_rows=len(a), max_abs_diff=float(np.abs(a[cols].values - b[cols].values).max()),
                passed=bool(np.allclose(a[cols].values, b[cols].values)))
    write_json(leak, ST, "leakage_test.json")

with Timer("Đặc trưng khuyến mãi và lịch"):
    pf = promo_frame(io.gv("complex_retail"))
    pf.to_parquet(INTERIM / "promo_frame.parquet", index=False)
    cal = io.calendar_features(pd.date_range("2026-01-01", "2026-12-31"))
    cal.insert(0, "date", pd.date_range("2026-01-01", "2026-12-31").date)
    write_csv(cal[(cal.double_day == 1) | (cal.payday == 1) | (cal.mid_month == 1) | (cal.pre_tet == 1)], ST, "calendar_2026_events.csv")

dic = pd.DataFrame([
    ("h", "Chân trời dự báo (1–14 ngày)", "Thiết kế direct multi-horizon"),
    ("dow", "Thứ trong tuần của ngày đích", "Mùa vụ tuần"),
    ("double_day", "Ngày đôi (ngày = tháng, ví dụ 9.9, 11.11)", "Lịch Mega Sale của sàn"),
    ("payday", "Ngày 25 (ngày lương phổ biến)", "Lịch khuyến mãi"),
    ("mid_month", "Ngày 15", "Lịch khuyến mãi giữa tháng"),
    ("last_r", "Giá trị ngày gốc / m28", "Đặc trưng trễ, chuẩn hóa quy mô"),
    ("m7_r", "TB 7 ngày / m28", "Cửa sổ trượt"),
    ("same_dow4_r", "TB cùng thứ của 4 tuần gần nhất / m28", "Trễ mùa vụ"),
    ("slope_r", "Độ dốc OLS 28 ngày / m28", "Xu hướng ngắn hạn"),
    ("s28_r", "Độ lệch chuẩn 28 ngày / m28", "Biến động"),
    ("cat_code", "Ngành hàng (TECH_PHONE, FMCG_FOOD, ACC_CABLE)", "Đặc trưng tĩnh"),
    ("log_price", "log giá bán", "Đặc trưng tĩnh – cold-start"),
    ("margin", "Biên gộp (giá − vốn)/giá", "Đặc trưng tĩnh – cold-start"),
    ("y_r", "Mục tiêu: y / m28", "Mục tiêu chuẩn hóa (dự báo = ŷ_r × m28)"),
], columns=["feature", "definition", "role"])
write_csv(dic, ST, "feature_dictionary.csv")
summary = dict(global_frame_rows=len(fr), n_origins=len(origins), n_series=W.shape[1], promo_rows=len(pf), leakage=leak,
               double_days_in_100sku=int(fr.drop_duplicates("date").double_day.sum()))
write_json(summary, ST, "summary.json")
log_run(ST, summary)
print(summary)
