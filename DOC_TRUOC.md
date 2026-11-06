# Tiểu luận cuối kỳ – Các mô hình dự báo trong kinh doanh (MIE4006, UEL)

**Đề tài:** Đo lường hiệu quả quảng cáo – khuyến mãi và dự báo GMV mùa Mega Sale cho doanh nghiệp TMĐT Việt Nam: từ chẩn đoán dữ liệu, phân rã chuỗi thời gian, học máy toàn cục, dự báo xác suất đến tác tử AI phân bổ ngân sách marketing.

Giảng viên: TS. Trần Duy Thanh · Học viên: Đinh Nguyễn Tấn Nguyên – C25611252

## Nội dung thư mục
| Mục | Mô tả |
|---|---|
| `BaoCao_MegaSale_Marketing_VN.pdf` / `.docx` | Báo cáo tiểu luận |
| Thư mục gốc | Mã nguồn đầy đủ: 14 stage Python, gói `src/`, dashboard Streamlit `app.py`, dữ liệu, kho tri thức, kiểm thử, kết quả lần chạy chính thức |
| `outputs/` | Kết quả của từng stage (JSON, CSV, hình) – mọi số trong báo cáo đọc từ đây |
| `REPORT_READY/` | Toàn bộ hình, bảng và `tables_all.xlsx` dùng trong báo cáo |
| `reports/builder/` | Bộ dựng báo cáo Word/PDF từ kết quả |

## Cách chạy (Windows, Python 3.11/3.12)
1. **Chỉ xem dashboard:** mở `OPEN_DASHBOARD.bat` → trình duyệt mở `http://localhost:8501`.
2. **Chạy lại toàn bộ pipeline:** `START_WINDOWS.bat` (tạo môi trường ảo, cài thư viện, chạy Stage 01 → 14, 24 kiểm tra tự động, 11 kiểm thử đơn vị, mở dashboard; khoảng 5 phút).
3. Linux/macOS: `pip install -r requirements.txt && ./run_all.sh && streamlit run app.py`.

Chi tiết từng stage, dữ liệu và cách diễn giải: `README.md`.

## Lưu ý về dữ liệu
12 bộ dữ liệu của học phần là dữ liệu mô phỏng (slide Ch1 tr.11); số liệu thật duy nhất là Tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng của Cục Thống kê (12/2019 – 9/2026, kèm nguồn từng kỳ). Quy chế marketing trong kho tri thức là mẫu do tác giả soạn cho mô phỏng.
