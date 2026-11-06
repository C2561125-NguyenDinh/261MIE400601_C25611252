# Thẻ mô hình

| Thành phần | Mô hình | Dữ liệu huấn luyện | Đánh giá | Giới hạn |
|---|---|---|---|---|
| Phản hồi quảng cáo (Stage 02) | OLS: Orders ~ Ad_Spend + Discount (+ Mega, thứ) | ecommerce_90days | R², HC3, Breusch–Pagan, VIF, đồng nhất thức OVB | Tương quan, không nhân quả; dữ liệu mô phỏng |
| Phản hồi theo ngành (Stage 02, 07) | Orders = α + β·ln(Ads) | panel 3 ngành × 30 ngày | AIC tuyến tính/log/Hill; bootstrap | 30 điểm/ngành; FMCG không có ý nghĩa thống kê |
| Phân rã (Stage 03) | STL/MSTL, HP (λ = 14.400; 10⁸), Prophet | dữ liệu ngày/tháng | độ mạnh F_S, kiểm định chéo Prophet | HP bị phê phán (Hamilton, 2018) |
| Dự báo nhiều chuỗi (Stage 05) | LightGBM toàn cục, mục tiêu y/m28, direct H = 14 | 100 SKU (114 gốc huấn luyện) | walk-forward 3 gốc; WAPE, MASE; DM | Lợi thế phụ thuộc số chuỗi |
| Dự báo phân vị (Stage 06) | Quantile LightGBM, phân vị phần dư, Z-chuẩn, DeepAR, heuristic GV | 100 SKU | pinball, phủ 80%, Winkler, hiệu chỉnh | DeepAR thiếu phủ; heuristic quá rộng |
| Mô hình chiến dịch (Stage 06, 08) | OLS đơn + OLS AOV; mô phỏng nhiễu | ecommerce_90days | bỏ-một-ngày trên 2 ngày Mega Sale | Mega và chiết khấu 50% trùng nhau; khoảng quá hẹp cho sự kiện |
| Tác tử (Stage 08) | Quy tắc + công cụ; LangGraph; pydantic | kho tri thức 21 đoạn | P@1, MRR, từ chối ngoài miền | Không gọi LLM thật mặc định |
