# Khả năng tái lập
- Hạt giống ngẫu nhiên: 42 (config/default.yaml); LightGBM `deterministic=True`, `num_threads=2`.
- Lần chạy chính thức: Python 3.13, pandas 3.0.5, numpy 2.5.3, scikit-learn 1.9.1, lightgbm 4.7.0, statsmodels 0.15.0, prophet 1.5.0, neuralforecast 3.3.0, langgraph 1.2.16, pydantic 2.13.5, streamlit 1.66.1, plotly 7.1.0 (Linux, 2 CPU, ~5 phút).
- Trên Windows, `requirements.txt` cho phép pandas 2.x; khác biệt phiên bản có thể làm thay đổi chữ số thập phân cuối của các mô hình học máy.
- SHA-256 của mọi tệp đầu vào: `outputs/01_data/sha256.json`.
- DeepAR/LSTM: kết quả kiểm định chéo đã lưu trong `data/interim/cache/`; xóa để huấn luyện lại (cần `requirements-neural.txt`).
- Stage 10 dừng pipeline nếu một trong 24 kiểm tra thất bại.
