# Mega Sale Marketing Intelligence: hiệu quả quảng cáo – khuyến mãi và dự báo GMV mùa Mega Sale

Đề tài học phần *Các mô hình dự báo trong kinh doanh* (MIE4006, UEL): **Đo lường hiệu quả quảng cáo – khuyến mãi và dự báo GMV mùa Mega Sale cho doanh nghiệp thương mại điện tử Việt Nam: từ chẩn đoán dữ liệu, phân rã chuỗi thời gian, học máy toàn cục, dự báo xác suất đến tác tử AI phân bổ ngân sách marketing**.
Học viên: Đinh Nguyễn Tấn Nguyên · Giảng viên: TS. Trần Duy Thanh.

## Chạy nhanh (Windows)
1. Cài Python 3.11 hoặc 3.12.
2. **Chỉ xem kết quả:** double-click `OPEN_DASHBOARD.bat` (kết quả lần chạy chính thức có sẵn trong `outputs/` và `REPORT_READY/`).
3. **Chạy lại toàn bộ:** double-click `START_WINDOWS.bat` (tạo `.venv`, cài `requirements.txt`, chạy Stage 01 → 14, kiểm thử, mở dashboard). Lần chạy chính thức mất khoảng 5 phút trên máy 2 CPU.

Linux/macOS: `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt && ./run_all.sh && streamlit run app.py`.

DeepAR/LSTM (Stage 06) cần `requirements-neural.txt` (PyTorch). Nếu chưa cài, Stage 06 dùng kết quả kiểm định chéo đã lưu trong `data/interim/cache/` của lần chạy chính thức; xóa thư mục này để buộc huấn luyện lại.

## Dữ liệu
- 12 bộ dữ liệu của học phần (`data/raw/gv/`, tranduythanh.com/forecasting-models) – **dữ liệu mô phỏng** (slide Ch1 tr.11: *src: Synthetic Data*). Kết quả trên các bộ này minh chứng phương pháp, không phải bằng chứng về thị trường thật.
- Số liệu thật: Tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng theo tháng 12/2019 – 9/2026 (82 tháng) từ báo cáo tình hình kinh tế – xã hội của Cục Thống kê (`data/raw/gso/`, kèm đường dẫn từng kỳ).
- Kho tri thức (`knowledge_base/`): tóm tắt quy định khuyến mại (NĐ 81/2018, sửa đổi bởi NĐ 128/2024), chính sách đối soát sàn, bối cảnh thị trường (có nguồn), và **quy chế marketing mẫu do tác giả soạn** cho mô phỏng.

## Kết quả chính (lần chạy chính thức)
| Chỉ tiêu | Giá trị |
|---|---|
| Hệ số quảng cáo lên số đơn: chỉ Ads → có kiểm soát chiết khấu | 9,08 → 7,31 |
| FMCG: ROAS thực tế / ROAS hòa vốn / lỗ lũy kế (triệu VNĐ) | 2,03 / 3,00 / -78,44 |
| Panel: độ dốc gộp vs hiệu ứng cố định | 1,054 vs 2,699 |
| Hệ số mùa vụ TMBL Việt Nam tháng 11 / tháng 5 | 1,0415 / 0,9526 |
| Chi phí marketing ↔ phần dư MSTL (chuỗi ngày 3 năm) | r = -0,026 |
| WAPE toàn cục vs Holt-Winters (100 SKU, H = 14) | 6,548% vs 6,631% |
| Ngày đôi: so sánh thô → sau kiểm soát thứ | +15,3% → +0,79% (p = 0,273) |
| Pinball TB: phân vị phần dư / Quantile LGBM / heuristic GV | 5,410 / 5,414 / 13,100 |
| Lợi nhuận chuẩn bị hàng q*–QLGBM / P50 / P90 (triệu VNĐ) | 663.207,1 / 659.032,6 / 626.277,9 |
| Lợi nhuận/ngày: hiện trạng → tối ưu ngân sách trong vùng dữ liệu (triệu VNĐ) | 61,93 → 71,73 |

Chi tiết: `outputs/09_summary/research_summary.json`, `outputs/09_summary/key_findings.csv`.

## Các stage
| Stage | Tệp | Nội dung (chương slide) |
|---|---|---|
| 01 | `01_data_validation.py` | Kiểm tra dữ liệu, làm sạch dữ liệu bẩn, đối chiếu số liệu Cục Thống kê, SHA-256 (Ch1) |
| 02 | `02_marketing_diagnostics.py` | EDA 3 phương diện, thiên lệch bỏ sót biến, panel hiệu ứng cố định, Unit Economics (Ch1) |
| 03 | `03_decomposition_seasonality.py` | Ví dụ tay Ch2, MSTL, kiểm định hiệu ứng marketing (adstock, độ trễ, Prophet), STL+HP, TMBL Việt Nam (Ch2) |
| 04 | `04_feature_engineering.py` | Đặc trưng direct multi-horizon chuẩn hóa quy mô, ngày đôi/ngày lương, kiểm tra rò rỉ (Ch3) |
| 05 | `05_uplift_global_models.py` | Uplift khuyến mãi (S/T-learner), walk-forward vs K-Fold, toàn cục vs cục bộ, cold-start, ngày đôi (Ch3) |
| 06 | `06_probabilistic_campaign.py` | 5 họ dự báo phân vị, Newsvendor, ROP, rủi ro quảng cáo (bootstrap), GMV ngày Mega Sale, dự báo TMBL (Ch4) |
| 07 | `07_budget_allocation.py` | Phân bổ ngân sách quảng cáo giữa ngành: hàm mục tiêu có trọng số, giá bóng, bootstrap (Ch5) |
| 08 | `08_genai_decision_support.py` | RAG, tác tử ReAct + LangGraph + pydantic, kiểm tra pháp lý, HITL, nhật ký kiểm toán (Ch5) |
| 09 | `09_build_research_summary.py` | Tổng hợp theo RQ1–RQ5 |
| 10 | `10_pipeline_smoke_test.py` | 24 kiểm tra đầu ra và ràng buộc phương pháp |
| 11 | `11_forecast_diagnostics.py` | Sai số theo chân trời, thứ, ngành, SKU, ngày đôi |
| 12 | `12_case_studies.py` | Hai ngày Mega Sale, FMCG lỗ, bẫy vốn lưu động, kế hoạch hàng SKU |
| 13 | `13_sensitivity_experiments.py` | Độ nhạy giá vốn, tỷ trọng tối thiểu, ngưỡng HITL, siêu tham số, biên gộp |
| 14 | `14_build_report_ready.py` | `REPORT_READY/figures`, `REPORT_READY/tables`, `tables_all.xlsx` |

Kiểm thử: `python -m pytest -q tests/test_core.py`.

## Dashboard (`app.py`, 12 trang)
Tổng quan điều hành · 01 Dữ liệu & chẩn đoán · 02 Hiệu quả quảng cáo & khuyến mãi · 03 Chuỗi thời gian & mùa vụ · 04 Mô hình toàn cục & uplift · 05 Dự báo xác suất & rủi ro · 06 Mô phỏng Mega Sale (tương tác) · 07 Phân bổ ngân sách (tương tác) · 08 Trung tâm quyết định AI (gửi đề xuất, RAG, phê duyệt HITL ghi vào `outputs/08_genai/hitl_decisions.csv`) · 09 Dòng tiền chiến dịch (tương tác) · 10 Kết quả nghiên cứu · 11 Xuất báo cáo (Excel, HTML 1 trang, mẫu quyết định).

## Ảnh dashboard cho báo cáo
Sau khi chạy pipeline: mở dashboard ở cổng 8599 (`streamlit run app.py --server.headless true --server.port 8599`), rồi chạy `python tools/capture_dashboard.py` (cần `pip install playwright && playwright install chromium`). Ảnh 12 trang được ghi vào `outputs/15_dashboard/figures/`; chạy lại `python 14_build_report_ready.py` để gom vào `REPORT_READY/figures/`.

## Báo cáo tiểu luận
`reports/builder/build.py` dựng `reports/BaoCao_MegaSale_Marketing_VN.docx` từ nội dung `reports/builder/content/*.tm`, bảng sinh từ `outputs/` (`tables.py`) và hình trong `REPORT_READY/figures/`; `python reports/builder/topdf.py <docx> <pdf>` xuất PDF bằng LibreOffice; `reports/builder/check/numcheck.py` đối chiếu số trong văn bản với tệp kết quả.

## Diễn giải đúng
- Mô hình chiến dịch là **dự báo có điều kiện**, không phải ước lượng nhân quả. Trong dữ liệu, cả hai ngày Mega Sale đều có chiết khấu 50%, nên hiệu ứng "sự kiện" và hiệu ứng "chiết khấu sâu" không tách được; mọi kịch bản Mega Sale với chiết khấu khác 50% bị gắn cờ ngoại suy.
- Biên đóng góp phụ thuộc giả định giá vốn: *theo giá niêm yết* (thận trọng, mặc định) hoặc *tỷ lệ cố định theo GMV* (lạc quan). Hai giả định cho kết luận trái dấu về lợi nhuận ngày Mega Sale (xem Stage 12–13).
- Lớp tác tử chạy bằng quy tắc và công cụ tất định; khi bật LLM (`.env` + `genai.enabled: true`), LLM chỉ diễn giải, không được thay đổi con số.
