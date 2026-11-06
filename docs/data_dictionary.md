# Từ điển dữ liệu

## Dữ liệu học phần (data/raw/gv/) – dữ liệu mô phỏng (slide Ch1 tr.11)
| Tệp | Cột | Ý nghĩa | Đơn vị |
|---|---|---|---|
| ecommerce_90days.csv | Date, GMV, Orders, Ad_Spend, Discount | GMV, số đơn, chi phí quảng cáo, tỷ lệ chiết khấu theo ngày (01/07–28/09/2026) | triệu VNĐ; đơn; triệu VNĐ; tỷ lệ |
| ecommerce_dirty_data.csv | Date, GMV, Orders, Note | 20 ngày có giá trị 0 do lỗi hệ thống, khuyết do lỗi API, ngoại lai sai giá trị, Flash Sale | triệu VNĐ |
| ecommerce_panel_data_raw.csv | Date, Category, Orders, GMV, Ad_Spend | Panel 3 ngành × 30 ngày | triệu VNĐ |
| ecommerce_unit_economics.csv | Date, Category, Orders, GMV, Ad_Spend, COGS_per_Order | Unit Economics theo ngành | triệu VNĐ |
| ecommerce_profit_margin_2020_2025.csv | report_month, total_orders, gross_revenue, net_profit_margin_pct, active_sellers | Biên lợi nhuận ròng 72 tháng | % |
| ecommerce_daily_multiseasonal.csv | date, daily_active_users, revenue_zscore, marketing_spend | Doanh thu chuẩn hóa ngày 2021–2023 | điểm z; đơn vị chi phí |
| ecommerce_48months.csv | Month, GMV | GMV 48 tháng (chỉ số tháng 1..48) | – |
| raw_sales_data.csv | Date, Product_ID, Category, Price, Discount, Sales | Sản phẩm mới, khuyến mãi | VNĐ; 0/1; đơn vị |
| complex_retail_sales.csv | Date, Product_ID, Is_Weekend, Discount, Baseline_Sales, Sales | 5 sản phẩm × 60 ngày | đơn vị |
| ecommerce_sales_multi_sku.csv | OrderDate, SKU, Category, QuantitySold | 15 SKU × 240 ngày | đơn vị |
| historical_sales_100_r2.csv | unique_id, ds, y | 100 SKU × 150 ngày (làm tròn 2 chữ số) | đơn vị |
| financial_metadata_100.csv | SKU, Price, Cost, Salvage | Giá bán, giá vốn, giá thanh lý | nghìn VNĐ/đơn vị |

## Số liệu thật (data/raw/gso/)
| Tệp | Nội dung |
|---|---|
| tmbl_monthly_2019_12_2026_09.csv | 82 tháng TMBL (nghìn tỷ đồng, giá hiện hành, ước tính lần đầu), so tháng trước, so cùng kỳ, ngày đăng, đường dẫn bài, loại nguồn (2 tháng suy ra từ tổng quý) |
| tmbl_annual_2019_2025.csv | Số năm chính thức, tăng danh nghĩa, tăng thực |
| tmbl_check_monthly_vs_annual.csv | Đối chiếu tổng tháng với số năm |
| tmbl_all_mentions.csv, tmbl_monthly_first_estimate.csv | Toàn bộ câu nhắc TMBL đã trích từ các bài và bảng ước tính lần đầu |

## Biến dẫn xuất
| Biến | Định nghĩa |
|---|---|
| AOV | GMV / Orders |
| CAC | Ad_Spend / Orders |
| CM (biên đóng góp/đơn) | AOV − (CAC + COGS/đơn) – slide Ch1 tr.111 |
| ROAS hòa vốn | AOV / (AOV − COGS/đơn) |
| Mega | 1 nếu Discount ≥ 0,5 (hai ngày 15/08 và 19/09/2026) |
| q* | (Giá − Vốn) / (Giá − Thanh lý) |
| Giá vốn theo giá niêm yết | κ × GMV / (1 − chiết khấu), κ hiệu chỉnh để tổng giá vốn 90 ngày = tỷ lệ giá vốn/GMV của unit economics |
