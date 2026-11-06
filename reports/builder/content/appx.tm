# PHỤ LỤC A. ĐỐI CHIẾU NỘI DUNG SLIDE VỚI THỰC NGHIỆM

Phụ lục này đối chiếu từng khối nội dung của bộ slide học phần với phần thực nghiệm tương ứng trong project mã nguồn của tiểu luận. Mục đích của việc đối chiếu là hai mặt. Thứ nhất, nó cho phép người đọc kiểm tra rằng mọi ví dụ tính tay và mọi đoạn mã minh họa trên slide đều đã được tái lập bằng mã nguồn và cho cùng kết quả, trừ một số điểm khác biệt nhỏ được ghi nhận rõ. Thứ hai, nó tách bạch phần nội dung kế thừa từ học phần (Trần Duy Thanh, 2026a) với phần mở rộng do tác giả thực hiện để phục vụ đề tài đo lường hiệu quả quảng cáo – khuyến mãi và dự báo GMV mùa Mega Sale. Cột "Trang" ghi số trang slide đã được xác minh bằng cách tìm kiếm nội dung trong bản trích văn bản của từng chương; cột "Stage/tệp" chỉ tệp mã nguồn thực hiện; cột "Mục" chỉ mục kết quả trong Chương 4 hoặc các phụ lục.

Một số quy ước khi đọc bảng: "Tái lập" nghĩa là tính lại đúng ví dụ hoặc đoạn mã trên slide và so sánh số; "Mở rộng" nghĩa là áp dụng phương pháp của slide vào bài toán marketing của tiểu luận, hoặc bổ sung kiểm định, đối chứng mà slide chưa trình bày. Toàn bộ dữ liệu doanh nghiệp được dùng là dữ liệu mô phỏng của học phần (Trần Duy Thanh, 2026a, Ch1 tr.11; Trần Duy Thanh, 2026c), do đó cột "Mở rộng" phản ánh khả năng vận dụng phương pháp chứ không phải bằng chứng về một doanh nghiệp cụ thể.

[[T:@pl_a_map Đối chiếu nội dung slide học phần với thực nghiệm của tiểu luận
Chương | Trang | Nội dung slide | Tái lập / mở rộng | Stage / tệp | Mục
Ch1 | tr.11 | Nguồn dữ liệu minh họa "Synthetic Data" | Ghi nhận giới hạn dữ liệu mô phỏng trong mọi kết luận | 01_data_validation.py | 3.2
Ch1 | tr.27–37 | Trung bình trượt SMA, độ trễ của SMA | Tái lập SMA 7 ngày; đo độ trễ sau ngày Mega Sale | 02_marketing_diagnostics.py | 4.1
Ch1 | tr.39–46 | Độ lệch Pearson và Fisher, phân phối | Tính cả hai độ lệch; Jarque–Bera | 02_marketing_diagnostics.py | 4.1
Ch1 | tr.55–74 | EDA ba phương diện trên chuỗi 90 ngày | Tái lập; bổ sung so sánh ngày Mega Sale với ngày thường | 02_marketing_diagnostics.py | 4.1
Ch1 | tr.70 | Thiên lệch bỏ sót biến (quảng cáo – chiết khấu) | Tái lập hồi quy; kiểm chứng đồng nhất thức OVB; thêm HC3, VIF, Breusch–Pagan | src/marketing/response.py | 4.1
Ch1 | tr.76–77 | Dữ liệu khuyết, cơ chế MCAR/MAR/MNAR | Xử lý 0 do lỗi hệ thống thành khuyết trước khi nội suy | 01_data_validation.py | 3.2
Ch1 | tr.82–97 | Hàng rào IQR, phân loại lỗi và Flash Sale | Tái lập Q1, Q3, ngưỡng; bổ sung Z vững (MAD) | 01_data_validation.py | 3.4
Ch1 | tr.91–92 | Nội suy tuyến tính ngày khuyết | Tái lập đúng các giá trị nội suy | 01_data_validation.py | 3.4
Ch1 | tr.102–108 | Dữ liệu bảng (panel) 3 ngành | Tái lập; so sánh gộp với hiệu ứng cố định; F-test khác biệt độ dốc | src/marketing/response.py | 4.1
Ch1 | tr.110–111 | CAC, biên đóng góp CM = AOV − (CAC + COGS) | Tái lập; thêm ROAS hòa vốn, CAC tối đa | 02_marketing_diagnostics.py | 4.1
Ch1 | tr.117–129 | Unit Economics theo ngành | Tái lập đúng lỗ FMCG −78,44 triệu; mở rộng lợi nhuận biên của quảng cáo | 02_marketing_diagnostics.py | 4.1
Ch2 | tr.8 | Phần dư mô hình cộng (= 5) | Tái lập | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.11 | Phần dư mô hình nhân (≈ 1,0101) | Tái lập | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.18 | Trung bình trượt cổ điển cửa sổ lẻ (29,2) | Tái lập | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.19–42 | Trọng số bisquare, STL kháng nhiễu (11,57; 33,625; 11,5511) | Tái lập cả cửa sổ lẻ và chẵn | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.43–47 | STL + bộ lọc HP (λ = 14.400) | Áp dụng cho biên lợi nhuận 72 tháng và GMV 48 tháng | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.47–55 | Backfitting nhiều mùa vụ | Tái lập sóng S₁, S₂ | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.60–61 | MSTL (7, 365) | Áp dụng cho chuỗi ngày 2021–2023; đo độ mạnh mùa vụ | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.64–89 | GAM và hai ví dụ tính tay | Tái lập đúng β và dự báo Ŷ₆–Ŷ₉ | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.70–79 | Prophet với biến ngày lễ Mega Sale | Tái lập ví dụ 5 ngày; kiểm định chéo Prophet có/không biến marketing | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.91–102 | Khử mùa vụ, tăng trưởng lõi | Tái lập ví dụ khử mùa vụ nhân; áp dụng cho GMV 48 tháng và TMBL | 03_decomposition_seasonality.py | 4.2
Ch2 | tr.103 | Bài toán dòng tiền mùa Mega Sale | Mô phỏng dòng tiền theo độ trễ đối soát sàn Việt Nam | src/cashflow/sim.py | 4.6
Ch2 | tr.105 | Câu hỏi ôn tập: phân rã GMV 48 tháng | Thực hiện; bổ sung bảng độ nhạy STL thường/kháng nhiễu | 03_decomposition_seasonality.py | 4.2
Ch3 | tr.5–23 | Tabular hóa chuỗi, đặc trưng trễ, hồi quy tuyến tính | Tái lập dự báo ngày 4 và đệ quy 7 ngày | 05_uplift_global_models.py | 4.3
Ch3 | tr.30–43 | Mô hình toàn cục so với cục bộ | Mở rộng: 100 SKU, 3 gốc, H = 14, Diebold–Mariano | src/models/train.py | 4.3
Ch3 | tr.44–50 | Gradient Boosting cho sản phẩm mới (F₀ = 103, ngưỡng 35°C) | Tái lập; cây chọn ngưỡng 34°C, cùng phân hoạch | 05_uplift_global_models.py | 4.3
Ch3 | tr.56–72 | Cold-start, đặc trưng tĩnh, chuẩn hóa quy mô | Mở rộng: giữ lại 10 SKU, warm-start 7 ngày | 05_uplift_global_models.py | 4.3
Ch3 | tr.70–71 | Uplift khuyến mãi | Mở rộng: S-learner toàn cục, T-learner cục bộ, uplift gộp | 05_uplift_global_models.py | 4.3
Ch3 | tr.74–75 | Sản phẩm mới có khuyến mãi (giá 150.000) | Tái lập mô hình thô; đề xuất mô hình uplift chuẩn hóa | 05_uplift_global_models.py | 4.3
Ch3 | tr.82–88 | Walk-forward so với K-Fold xáo trộn | Tái lập trên complex_retail_sales | 05_uplift_global_models.py | 4.3
Ch3 | tr.87 | Cơ chế sinh dữ liệu 5 sản phẩm (cuối tuần, khuyến mãi) | Đối chiếu hệ số nhân quan sát với mô hình học được | 05_uplift_global_models.py | 4.3
Ch4 | tr.9–20 | Dự báo điểm và Z-score, P90 ≈ 193 | Tái lập sai số, bias, σ, P90 | 06_probabilistic_campaign.py | 4.4
Ch4 | tr.22–34 | DeepAR | Mở rộng: DeepAR Student-t trên 100 SKU, so sánh 5 họ mô hình | 06_probabilistic_campaign.py | 4.4
Ch4 | tr.35–50 | Quantile loss (pinball) | Tái lập ví dụ q = 0,9; đánh giá 9 phân vị, hiệu chỉnh, Winkler | src/evaluation/metrics.py | 4.4
Ch4 | tr.56–63 | Newsvendor, q^*^ = 0,5 / 0,8 / 0,3 | Tái lập; mở rộng chuẩn bị hàng 100 SKU cho chiến dịch | src/inventory/policy.py | 4.4
Ch4 | tr.67–75 | Reorder point và script dải heuristic | Tái lập heuristic; so sánh CSL thực đạt theo lead time | 06_probabilistic_campaign.py | 4.4
Ch5 | tr.6 | Khung ReAct (Quan sát – Suy luận – Hành động) | Hiện thực bằng đồ thị bốn nút có nhật ký | src/genai/agent.py | 4.5
Ch5 | tr.15–16 | Kết quả tác tử cho TECH_PHONE_001 (luật 80%) | Dùng làm phản ví dụ về hệ số do mô hình ngôn ngữ tự chọn | src/genai/agent.py | 4.5
Ch5 | tr.17–30 | RAG TF-IDF + cosine | Tái lập điểm 0,1711 / 0 / 0,3979 / 0; mở rộng kho tri thức pháp lý – thị trường | src/genai/rag.py | 4.5
Ch5 | tr.26 | Điểm tương đồng của 4 tài liệu ví dụ | Tái lập chính xác | 08_genai_decision_support.py | 4.5
Ch5 | tr.32–35 | Kiến trúc đa tác tử, Tác tử Điều phối | Mở rộng: phân bổ ngân sách quảng cáo giữa ba ngành | src/budget/allocate.py | 4.5
Ch5 | tr.42–44 | Hàm mục tiêu có trọng số w₁, w₂ | Quét w₂; ràng buộc ngân sách; giá bóng λ | 07_budget_allocation.py | 4.5
Ch5 | tr.52 | Đầu ra định chuẩn (Pydantic) và LangGraph | Lược đồ CampaignRequest/CampaignPlan; chặn payload sai | src/genai/agent.py | 4.5
Ch5 | tr.60 | Hồ sơ kiểm toán, nguyên tắc hộp kính | Nhật ký audit_log.jsonl cho 12 đề xuất | 08_genai_decision_support.py | Phụ lục D
Ch5 | tr.61–63 | Human-in-the-loop, hàm ngắt rủi ro | Ngưỡng ngân sách P95, chiết khấu, biên đóng góp âm, ngoại suy | src/genai/agent.py | 4.5
Nguồn: Tác giả tổng hợp từ slide học phần (Trần Duy Thanh, 2026a) và project mã nguồn của tiểu luận.
]]

Bảng {T:@pl_a_map} cho thấy cả năm chương của học phần đều được tái lập hoặc vận dụng. Những điểm khác biệt có ý nghĩa giữa slide và kết quả tái lập được ghi nhận như sau. Ở Chương 3, ví dụ Gradient Boosting cho sản phẩm mới trên slide nêu ngưỡng chia 35°C; thuật toán cây quyết định của scikit-learn chọn ngưỡng 34°C, tức điểm giữa của hai giá trị nhiệt độ liền kề 32°C và 36°C trong dữ liệu. Hai ngưỡng tạo ra cùng một phân hoạch dữ liệu nên giá trị γ và dự báo Ŷ_C = 190 không đổi; khác biệt chỉ nằm ở quy ước chọn điểm cắt. Ở Chương 4, script reorder point của học phần tạo dải bất định theo công thức σ = 15% × trung bình P50 × √t, nên độ rộng khoảng tăng theo chân trời bất kể dữ liệu; tiểu luận giữ nguyên công thức này làm chuẩn đối chiếu "Heuristic GV" thay vì hiệu chỉnh nó. Ở Chương 5, luật "đặt 80% nhu cầu trung bình bảy ngày" là đầu ra của mô hình ngôn ngữ trên slide chứ không phải quy tắc của giảng viên; tiểu luận dùng luật này như một phản ví dụ minh họa rủi ro khi hệ số quyết định do mô hình ngôn ngữ tự chọn.

Đối với các mở rộng, nguyên tắc chung là mỗi phương pháp của slide được đặt vào đúng câu hỏi quản trị của đề tài: EDA và hồi quy bỏ sót biến của Chương 1 trở thành công cụ đo lường hiệu quả quảng cáo – chiết khấu; phân rã của Chương 2 trở thành phép kiểm định xem chi phí marketing có để lại dấu vết trong chuỗi doanh thu đã khử mùa vụ hay không; mô hình toàn cục của Chương 3 phục vụ dự báo cầu nhiều SKU trước chiến dịch và ước lượng uplift theo sản phẩm; dự báo xác suất của Chương 4 phục vụ chuẩn bị hàng và đánh giá rủi ro tài chính của chiến dịch; kiến trúc tác tử của Chương 5 phục vụ phân bổ ngân sách và kiểm soát pháp lý cho đề xuất khuyến mãi.

# PHỤ LỤC B. SỐ LIỆU TỔNG MỨC BÁN LẺ CỦA CỤC THỐNG KÊ

Phụ lục này công bố đầy đủ chuỗi số liệu thật duy nhất ở cấp vĩ mô được sử dụng trong tiểu luận: tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng (TMBL) theo tháng, từ tháng 12/2019 đến tháng 9/2026, tổng cộng 82 tháng (Cục Thống kê, 2019–2026). Chuỗi được thu thập từ các báo cáo và thông cáo báo chí tình hình kinh tế – xã hội hằng tháng, hằng quý trên cổng thông tin của Cục Thống kê. Mục đích công bố là để mọi phép phân rã mùa vụ, hồi quy hiệu ứng Tết và giãn cách, cũng như các dự báo kịch bản ở Chương 4 đều có thể được kiểm tra lại tới từng giá trị tháng.

Ba quy tắc chọn số liệu được áp dụng nhất quán. Thứ nhất, mỗi giá trị tháng là ước tính lần đầu được công bố trong báo cáo của chính tháng đó (giá hiện hành, đơn vị nghìn tỷ đồng); tiểu luận không thay bằng số điều chỉnh của các kỳ sau để tránh trộn lẫn các "phiên bản" số liệu. Thứ hai, 80 tháng được lấy trực tiếp từ báo cáo tháng; hai tháng không có số liệu tháng riêng được suy ra từ tổng quý: tháng 12/2020 bằng tổng quý IV/2020 (1.387,6) trừ tháng 10 (450,8) và tháng 11 (464,4), cho 472,4; tháng 6/2021 bằng tổng quý II/2021 (1.177,6) trừ tháng 4 (409,4) và tháng 5 (393,6), cho 374,6. Thứ ba, các cột tăng trưởng so với tháng trước và so với cùng kỳ là số do Cục Thống kê công bố trong cùng bài, không phải số do tác giả tự tính.

Giá trị thấp nhất của chuỗi là 279,8 nghìn tỷ đồng vào tháng 8/2021, thời kỳ giãn cách xã hội; giá trị cao nhất là 690,6 nghìn tỷ đồng vào tháng 9/2026, tăng 14,1% so với cùng kỳ theo công bố. Để kiểm tra tính nhất quán, Stage 01 đối chiếu tổng 12 tháng ước tính lần đầu với số năm chính thức cho các năm 2020–2025; chênh lệch lớn nhất về trị tuyệt đối là 3,04% (năm 2021), các năm còn lại nằm trong khoảng ±0,62% (xem bảng đối chiếu ở Chương 3). Chênh lệch năm 2021 phản ánh việc các ước tính tháng trong giai đoạn giãn cách được điều chỉnh ở các kỳ báo cáo sau, và là lý do chuỗi được mô hình hóa kèm biến giả giãn cách.

[[TAB:gso_monthly]]

Bảng {T:gso_monthly} liệt kê giá trị, tăng trưởng công bố, ngày đăng bài và loại nguồn của từng tháng. Bảng {T:gso_links} cho đường dẫn đến bài viết gốc của từng giá trị; phần tên miền https://www.nso.gov.vn được lược bỏ để bảng gọn. Người đọc có thể ghép tên miền với đường dẫn để mở bài gốc và đối chiếu. Tệp dữ liệu tương ứng trong project là data/raw/gso/tmbl_monthly_2019_12_2026_09.csv; ngoài ra, các tệp tmbl_all_mentions.csv và tmbl_monthly_first_estimate.csv lưu toàn bộ các câu có nhắc tới TMBL đã trích từ các bài, phục vụ kiểm tra quy trình trích xuất.

[[TAB:gso_links]]

# PHỤ LỤC C. CHUẨN BỊ HÀNG 100 SKU

Phụ lục này trình bày chi tiết cấu trúc chi phí và phân vị tới hạn của 100 SKU trong bộ dữ liệu financial_metadata_100 (Trần Duy Thanh, 2026c), là đầu vào của bài toán chuẩn bị hàng cho chiến dịch ở mục 4.4. Với mỗi SKU, chi phí thiếu hàng trên một đơn vị là C~u~ = giá bán − giá vốn và chi phí thừa hàng là C~o~ = giá vốn − giá thanh lý; phân vị tới hạn của mô hình Newsvendor là q^*^ = C~u~/(C~u~ + C~o~) (Trần Duy Thanh, 2026a, Ch4 tr.56–63; Khouja, 1999). Nhãn chiến lược được gán theo đúng ngưỡng của script trong case study của học phần: q^*^ từ 0,75 trở lên là "tấn công", q^*^ từ 0,35 trở xuống là "phòng thủ", còn lại là "cân bằng". Đơn vị giá trong bảng là nghìn VNĐ trên một đơn vị sản phẩm.

[[TAB:qstar_all]]

Bảng {T:qstar_all} cho thấy ba nhóm ngành có hồ sơ rủi ro khác biệt rõ rệt. Nhóm cáp sạc phụ kiện (ACC_CABLE, 40 SKU) có giá thanh lý bằng 0 nhưng biên gộp rất cao, nên q^*^ trung bình 0,791 (thấp nhất 0,667, cao nhất 0,857): thiếu hàng tốn kém hơn nhiều so với thừa hàng. Nhóm thực phẩm (FMCG_FOOD, 30 SKU) có biên gộp mỏng và chi phí thừa hàng lớn, nên q^*^ trung bình chỉ 0,182 (0,097–0,280). Nhóm điện thoại (TECH_PHONE, 30 SKU) nằm giữa với q^*^ trung bình 0,433 (0,256–0,596). Theo ngưỡng của script, danh mục gồm 34 SKU phòng thủ, 34 SKU cân bằng và 32 SKU tấn công.

[[TAB:newsvendor_cat]]

Bảng {T:newsvendor_cat} phân rã kết quả kinh tế của bốn chính sách đặt hàng theo ngành, cộng dồn qua ba gốc dự báo × 14 ngày. Ở nhóm cáp sạc, đặt theo P90 cho mọi SKU đạt 97,08% lợi nhuận Oracle, gần bằng chính sách q^*^ (97,22%), vì q^*^ của nhóm này vốn cao. Ở nhóm thực phẩm, cùng chính sách P90 chỉ đạt 55,38% lợi nhuận Oracle, thấp hơn rõ so với đặt theo P50 (82,27%) và theo q^*^ (88,90%): đặt dư cho hàng có chi phí thừa cao làm mất gần một nửa lợi nhuận khả dĩ. Ở nhóm điện thoại, q^*^ đạt 94,21% so với 93,83% của P50 và 87,88% của P90, đồng thời dùng ít vốn hàng nhất trong ba chính sách (2.401.750,4 triệu VNĐ so với 2.434.475,2 của P50 và 2.627.497,5 của P90). Hàm ý quản trị là không có một mức phân vị "an toàn" chung cho mọi ngành khi chuẩn bị hàng cho Mega Sale; mức đặt phải suy ra từ cấu trúc chi phí của từng SKU.

# PHỤ LỤC D. BẢNG KẾT QUẢ BỔ SUNG

Phụ lục này gom các bảng kết quả chi tiết mà Chương 4 chỉ trích dẫn tóm tắt: bảng phân rã đầy đủ của chuỗi GMV 48 tháng, danh mục kho tri thức của tác tử và trích đoạn nhật ký kiểm toán.

[[TAB:m48_table]]

Bảng {T:m48_table} là đầu ra outputs/03_decomposition/m48_decomposition.csv của Stage 03, tương ứng câu hỏi ôn tập phân rã chuỗi GMV 48 tháng của học phần (Trần Duy Thanh, 2026a, Ch2 tr.105). Cột S là hệ số mùa vụ nhân ước lượng bằng STL trên logarit (cửa sổ mùa vụ 13, không kháng nhiễu); cột "Khử mùa vụ" bằng GMV chia cho S; cột T và C là xu hướng và chu kỳ thu được khi áp bộ lọc HP (λ = 14.400) lên khối xu hướng – chu kỳ của STL. Hai cột cuối so sánh tăng trưởng tháng của chuỗi thô và chuỗi lõi đã khử mùa vụ. Lý do chọn STL không kháng nhiễu cho chuỗi này được trình bày ở mục 4.2 cùng bảng độ nhạy.

[[TAB:kb]]

Bảng {T:kb} liệt kê 20 đoạn của kho tri thức được tác tử truy xuất (Stage 08 chia mỗi tệp Markdown thành các đoạn theo tiêu đề cấp hai). Nội dung đầy đủ của các đoạn được trình bày ở Phụ lục F. Mỗi đoạn mang một mã định danh dạng tệp#số thứ tự; mã này xuất hiện trong trường "citations" của mọi kế hoạch chiến dịch và của nhật ký kiểm toán, cho phép truy vết căn cứ của từng quyết định.

Nhật ký kiểm toán outputs/08_genai/audit_log.jsonl ghi 12 bản ghi, mỗi bản ghi tương ứng một đề xuất chiến dịch đã qua tác tử. Bảng {T:@pl_d_audit} trích nguyên văn sáu bản ghi đại diện cho ba trạng thái phê duyệt; các trường được giữ đúng giá trị trong tệp, chỉ đổi dấu thập phân sang dấu phẩy. Mọi bản ghi đều có cùng chuỗi công cụ rag.search → campaign_model.predict → policy_check → emit_plan và cùng động cơ thực thi langgraph, cho thấy tác tử đã đi qua đầy đủ các bước của đồ thị trạng thái.

[[T:@pl_d_audit Trích sáu bản ghi thật từ nhật ký kiểm toán của tác tử (outputs/08_genai/audit_log.jsonl)
ID | Chiến dịch | QC/ngày | Chiết khấu | GMV P10–P50–P90 | CM P50 | P(CM<0) | Trạng thái | Lý do ghi nhận
R01 | Ngày thường – duy trì | 12,0 | 0,15 | 58,27 – 64,441 – 70,29 | 16,305 | 0,0 | AUTO_APPROVED | Mọi kiểm tra đạt: hợp pháp, trong vùng dữ liệu, biên đóng góp dương
R02 | Ngày thường – tăng quảng cáo | 20,0 | 0,15 | 78,773 – 84,811 – 91,035 | 17,252 | 0,0 | NEEDS_HUMAN_REVIEW | Ngân sách 20.0 triệu/ngày vượt P95 lịch sử (19.3)
R05 | Mega Sale 11.11 – chiết khấu 40% | 25,0 | 0,4 | 188,532 – 195,378 – 202,109 | 15,165 | 0,0 | NEEDS_HUMAN_REVIEW | Chiết khấu ≥ 40% cần Giám đốc Tài chính duyệt; ngân sách vượt P95; ngoài vùng dữ liệu (ngoại suy)
R06 | Mega Sale 11.11 – chiết khấu 50% | 30,0 | 0,5 | 198,269 – 204,42 – 210,671 | −20,455 | 1,0 | NEEDS_HUMAN_REVIEW | Chiết khấu ≥ 40%; ngân sách vượt P95; biên đóng góp P50 âm; xác suất biên âm > 20%
R07 | Mega Sale 12.12 – chiết khấu 60% | 30,0 | 0,6 | 195,601 – 201,742 – 207,833 | −68,66 | 1,0 | REJECTED | Chiết khấu 60% vượt mức tối đa 50% (NĐ 81/2018, sửa đổi bởi NĐ 128/2024)
R08 | Khuyến mại tập trung – 70% | 30,0 | 0,7 | 192,104 – 198,039 – 203,836 | −146,614 | 1,0 | NEEDS_HUMAN_REVIEW | Chiết khấu ≥ 40%; ngân sách vượt P95; biên P50 âm; xác suất biên âm > 20%; ngoại suy
Nguồn: outputs/08_genai/audit_log.jsonl (lần chạy chính thức ngày 22/10/2026); đơn vị triệu VNĐ. Trường lý do của R02 giữ nguyên định dạng số do mã nguồn ghi.
]]

Ba quan sát rút ra từ trích đoạn nhật ký. Thứ nhất, đề xuất R07 với chiết khấu 60% bị từ chối ngay ở bước kiểm tra pháp lý, độc lập với dự báo kinh tế; trong khi đề xuất R08 với chiết khấu 70% không bị từ chối vì được khai báo thuộc chương trình khuyến mại tập trung, nơi mức giảm tối đa được phép tới 100% (Chính phủ, 2024), nhưng vẫn phải chuyển người duyệt vì biên đóng góp kỳ vọng âm sâu. Thứ hai, các đề xuất Mega Sale với chiết khấu khác 50% (như R05) bị gắn cờ ngoại suy: dữ liệu lịch sử chỉ có ngày Mega Sale ở mức chiết khấu 50%, nên mô hình không có căn cứ để tách hiệu ứng sự kiện khỏi hiệu ứng chiết khấu. Thứ ba, mọi bản ghi đều kèm cùng bộ ba căn cứ truy xuất (quy chế biên đóng góp, mức giảm giá tối đa, ngưỡng ngân sách), vì truy vấn RAG được dựng từ cùng mẫu câu; đây là một giới hạn của thiết kế truy vấn đơn giản được bàn ở Chương 5.

# PHỤ LỤC E. MÃ NGUỒN, DASHBOARD VÀ HƯỚNG DẪN TÁI LẬP

## E.1. Cấu trúc thư mục project

Sản phẩm phần mềm của tiểu luận là một project Python hoàn chỉnh, được tổ chức theo cùng chuẩn với project dự báo bán lẻ trước đó của học viên: các bước xử lý được đánh số từ 01 đến 14 ở thư mục gốc, thư viện dùng chung nằm trong gói src/, mọi kết quả ghi vào outputs/ theo từng stage, và một dashboard Streamlit đọc lại các kết quả đó. Tổng số dòng mã của 14 stage, gói src/ và dashboard là khoảng 4.250 dòng. Bảng {T:@pl_e_tree} liệt kê các tệp và thư mục chính theo đúng cấu trúc thực tế của project (không tính các thư mục kết quả sinh tự động và bộ dựng báo cáo).

[[T:@pl_e_tree Cấu trúc thư mục và vai trò các tệp của project MegaSale_Marketing_VN
Đường dẫn | Vai trò
01_data_validation.py | Kiểm tra 12 bộ dữ liệu, làm sạch dữ liệu bẩn, đối chiếu số liệu Cục Thống kê, tính SHA-256
02_marketing_diagnostics.py | EDA ba phương diện, thiên lệch bỏ sót biến, panel, Unit Economics (Ch1)
03_decomposition_seasonality.py | Ví dụ tay Ch2, MSTL, kiểm định hiệu ứng marketing, STL + HP, phân rã TMBL (Ch2)
04_feature_engineering.py | Khung đặc trưng toàn cục, kiểm tra rò rỉ, lịch sự kiện 2026 (Ch3)
05_uplift_global_models.py | Ví dụ tay Ch3, uplift khuyến mãi, toàn cục vs cục bộ, cold-start, ngày đôi (Ch3)
06_probabilistic_campaign.py | Năm họ dự báo phân vị, Newsvendor, ROP, rủi ro quảng cáo, GMV Mega Sale, dự báo TMBL (Ch4)
07_budget_allocation.py | Phân bổ ngân sách quảng cáo giữa ba ngành, quét trọng số, giá bóng, bootstrap (Ch5)
08_genai_decision_support.py | RAG, tác tử lập kế hoạch chiến dịch, HITL, nhật ký kiểm toán (Ch5)
09_build_research_summary.py | Tổng hợp chỉ tiêu theo RQ1–RQ5
10_pipeline_smoke_test.py | 24 kiểm tra đầu ra và ràng buộc phương pháp
11_forecast_diagnostics.py | Sai số theo chân trời, thứ, ngành, SKU, ngày đôi; phần dư mô hình chiến dịch
12_case_studies.py | Hai ngày Mega Sale, FMCG lỗ, bẫy vốn lưu động, kế hoạch hàng một SKU
13_sensitivity_experiments.py | Độ nhạy giá vốn, tỷ trọng tối thiểu, ngưỡng HITL, siêu tham số, biên gộp
14_build_report_ready.py | Gom hình và bảng vào REPORT_READY/, tạo tables_all.xlsx
app.py | Dashboard Streamlit 12 trang
config/default.yaml | Toàn bộ tham số: hạt giống, lịch Tết, ngưỡng pháp lý, lưới adstock, ngân sách, HITL
src/common.py | Đường dẫn, cấu hình, hạt giống, ghi/đọc kết quả, định dạng số kiểu Việt
src/data/io.py | Đọc dữ liệu, biến lịch (Tết, ngày đôi, ngày lương, COVID)
src/features/build.py | Đặc trưng direct multi-horizon chuẩn hóa quy mô; đặc trưng khuyến mãi
src/models/train.py | Bộ so sánh toàn cục/cục bộ, Diebold–Mariano, Quantile LightGBM
src/models/macro.py | Năm mô hình dự báo TMBL tháng
src/evaluation/metrics.py | WAPE, MASE, pinball, độ phủ, Winkler, Diebold–Mariano HAC
src/marketing/response.py | Hồi quy OVB, phân rã đóng góp, adstock, độ trễ phân phối, Hill, panel, bootstrap
src/scenarios/megasale.py | Mô hình chiến dịch: quảng cáo × chiết khấu → đơn, GMV, biên đóng góp
src/inventory/policy.py | Phân vị tới hạn, nội suy phân vị, lợi nhuận Newsvendor, nhãn chiến lược
src/budget/allocate.py | Đường phản hồi log, tối ưu SLSQP có ràng buộc, giá bóng
src/cashflow/sim.py | Mô phỏng dòng tiền ngày theo độ trễ đối soát và lead time
src/genai/rag.py | Chia kho tri thức, truy xuất TF-IDF, ngưỡng từ chối
src/genai/agent.py | Lược đồ Pydantic, tác tử bốn nút, LangGraph, nhật ký kiểm toán
src/genai/assistant.py | Diễn giải bằng quy tắc; LLM tùy chọn (mặc định tắt)
src/export/report.py | Báo cáo 1 trang HTML, mẫu quyết định Excel
tests/test_core.py | 11 kiểm thử đơn vị
tools/capture_dashboard.py | Chụp ảnh 12 trang dashboard (Playwright) vào outputs/15_dashboard/figures cho báo cáo
knowledge_base/ (5 tệp .md) | 5 tệp kho tri thức (Phụ lục F)
data/raw/gv/, data/raw/gso/ | 12 tệp dữ liệu học phần; 5 tệp số liệu Cục Thống kê
data/interim/cache/ | Kết quả kiểm định chéo DeepAR và LSTM-MQ của lần chạy chính thức
docs/ | Từ điển dữ liệu, thẻ mô hình, hướng dẫn tái lập
START_WINDOWS.bat, OPEN_DASHBOARD.bat, run_all.sh | Tệp khởi chạy
requirements.txt, requirements-neural.txt | Thư viện bắt buộc và thư viện tùy chọn (PyTorch)
Nguồn: Tác giả (project MegaSale_Marketing_VN).
]]

Thiết kế theo stage có ba lợi ích cho một nghiên cứu cần kiểm chứng. Mỗi stage đọc dữ liệu gốc hoặc đầu ra của stage trước và ghi kết quả của mình vào một thư mục riêng (outputs/01_data, outputs/02_marketing, …, outputs/14_report_ready), kèm tệp run_info.json ghi thời điểm chạy và hạt giống; nhờ vậy người đọc có thể chạy lại riêng một stage mà không phải chạy toàn bộ. Mọi tham số mô hình và ngưỡng nghiệp vụ được tập trung trong config/default.yaml chứ không rải rác trong mã, nên một thí nghiệm độ nhạy chỉ cần đổi cấu hình. Cuối cùng, dashboard và bộ dựng báo cáo chỉ đọc lại các tệp kết quả, nên mọi con số hiển thị hoặc in ra đều truy được về một tệp cụ thể.

## E.2. Hướng dẫn chạy

Trên Windows, người dùng cài Python 3.11 hoặc 3.12, giải nén project và chọn một trong hai tệp khởi chạy. Tệp OPEN_DASHBOARD.bat dành cho người chỉ muốn xem kết quả: tệp tạo môi trường ảo .venv nếu chưa có, cài thư viện trong requirements.txt rồi mở dashboard bằng lệnh streamlit run app.py; kết quả của lần chạy chính thức đã có sẵn trong outputs/ và REPORT_READY/. Tệp START_WINDOWS.bat chạy lại toàn bộ quy trình: tạo môi trường ảo, cài thư viện, chạy lần lượt 14 stage, dừng ngay khi một stage báo lỗi, chạy kiểm thử đơn vị bằng pytest và cuối cùng mở dashboard. Trên Linux hoặc macOS, tệp run_all.sh thực hiện cùng chuỗi lệnh. Lần chạy chính thức trên máy hai nhân xử lý mất khoảng năm phút, trong đó phần lớn thời gian thuộc Stage 05 và Stage 06.

Hai mô hình học sâu DeepAR và LSTM-MQ ở Stage 06 cần PyTorch, được tách sang requirements-neural.txt để không làm nặng cài đặt mặc định. Khi thư viện này chưa được cài, Stage 06 đọc kết quả kiểm định chéo đã lưu trong data/interim/cache/ của lần chạy chính thức; khi người dùng xóa thư mục cache và đã cài neuralforecast, Stage 06 tự huấn luyện lại. Lớp diễn giải bằng mô hình ngôn ngữ mặc định tắt; muốn bật, người dùng sao chép .env.example thành .env, điền khóa API và đặt genai.enabled: true trong cấu hình. Ngay cả khi bật, mô hình ngôn ngữ chỉ được phép diễn giải kế hoạch đã do công cụ tính, không được thay đổi con số.

## E.3. Dashboard

Dashboard (app.py) gồm 12 trang, dùng chung một hệ thiết kế với dashboard của project dự báo bán lẻ trước đó. Các trang phân tích chỉ đọc kết quả trong outputs/; bốn trang mô phỏng gọi lại đúng các mô hình trong src/ trên dữ liệu gốc khi người dùng thay đổi tham số. Bảng {T:@pl_e_dash} mô tả nội dung từng trang. Tất cả 12 trang đã được kiểm tra tự động bằng công cụ kiểm thử ứng dụng của Streamlit (AppTest) và chạy không phát sinh lỗi.

[[T:@pl_e_dash Mười hai trang của dashboard Mega Sale Marketing Intelligence
Trang | Nội dung chính | Tương tác
Tổng quan điều hành | 6 chỉ số KPI, quy trình 14 bước, ROAS thực tế so với ROAS hòa vốn, phát hiện chính, bảng phát hiện theo RQ | Chỉ đọc
01 · Dữ liệu & chẩn đoán | Danh mục dữ liệu, kiểm tra chất lượng, làm sạch dữ liệu bẩn, đối chiếu Cục Thống kê | Chuyển tab
02 · Hiệu quả quảng cáo & khuyến mãi | EDA 90 ngày, ngày Mega Sale, OVB, phân rã đóng góp, panel, Unit Economics, nhiệt đồ độ nhạy CM | Chọn ngành
03 · Chuỗi thời gian & mùa vụ | Thành phần MSTL, kiểm định marketing, GMV 48 tháng, biên lợi nhuận, TMBL và độ trôi mùa vụ | Chuyển tab
04 · Mô hình toàn cục & uplift | WAPE các mô hình, Diebold–Mariano, uplift theo sản phẩm, cold-start, ngày đôi | Chuyển tab
05 · Dự báo xác suất & rủi ro | Pinball, hiệu chỉnh, phễu bất định, fan chart từng SKU, Newsvendor, ROP, rủi ro quảng cáo | Chọn SKU, mô hình, ngành
06 · Mô phỏng Mega Sale | GMV và biên đóng góp P10–P90 theo quảng cáo, chiết khấu, giả định giá vốn, phí sàn; cảnh báo ngoại suy và vượt mức pháp lý | Thanh trượt
07 · Phân bổ ngân sách | Phân bổ tối ưu theo mức ngân sách, trọng số w₂, tỷ trọng tối thiểu, ràng buộc vùng dữ liệu | Thanh trượt
08 · Trung tâm quyết định AI | Hàng đợi phê duyệt, phiếu khuyến nghị, gửi đề xuất mới cho tác tử, hỏi kho tri thức, nhật ký kiểm toán | Phê duyệt/từ chối, biểu mẫu
09 · Dòng tiền chiến dịch | Tiền mặt lũy kế và tiền mặt tối thiểu theo độ trễ đối soát, lead time, phí sàn | Thanh trượt
10 · Kết quả nghiên cứu | Tóm tắt nghiên cứu, kiểm thử pipeline, chẩn đoán sai số, độ nhạy | Chuyển tab
11 · Xuất báo cáo | Tải Excel toàn bộ bảng, báo cáo 1 trang HTML, mẫu quyết định chiến dịch; thư viện hình | Tải tệp
Nguồn: Tác giả (app.py).
]]

Trang 08 là nơi khép vòng Human-in-the-loop. Với mỗi đề xuất ở trạng thái "cần người duyệt", người dùng đọc phiếu khuyến nghị (dự báo GMV, biên đóng góp, lý do và căn cứ truy xuất), ghi chú rồi bấm phê duyệt hoặc từ chối; quyết định được ghi kèm thời điểm vào outputs/08_genai/hitl_decisions.csv và hiển thị lại trong tab nhật ký. Trang này cũng cho phép gửi một đề xuất mới: tác tử chạy lại toàn bộ chuỗi quan sát – mô phỏng – kiểm tra – quyết định và trả về trạng thái cùng dấu vết từng bước. Trang 11 xuất mẫu ra quyết định dưới dạng Excel gồm ba sheet (hướng dẫn, đề xuất, ngân sách) để người duyệt điền quyết định ngoài hệ thống.

Các ảnh chụp màn hình dưới đây được lấy từ lần chạy chính thức bằng tệp tools/capture_dashboard.py (trình duyệt Chromium không giao diện, khung nhìn 1.600 × 1.000 điểm ảnh). Tám trang đã được trình bày cạnh kết quả tương ứng ở Chương 3 và Chương 4 (Tổng quan điều hành, 02, 03, 05, 06, 07, 08, 09); bốn trang còn lại được trình bày ở {F:dash01_du_lieu_chan_doan.png}, {F:dash04_mo_hinh_toan_cuc_uplift.png}, {F:dash10_ket_qua_nghien_cuu.png} và {F:dash11_xuat_bao_cao.png}. Trang 01 liệt kê danh mục mười hai bộ dữ liệu cùng số dòng, số cột, khoảng thời gian, mô tả và mã băm SHA-256, kèm bảng kiểm tra chất lượng; trang 04 hiển thị WAPE của các mô hình trên 100 SKU, kết quả kiểm định Diebold–Mariano và tầm quan trọng đặc trưng của mô hình toàn cục; trang 10 hiển thị trạng thái 24 kiểm tra của Stage 10 và các bảng chẩn đoán sai số; trang 11 cung cấp các nút tải workbook Excel, báo cáo một trang HTML, mẫu quyết định chiến dịch và thư viện hình của báo cáo.

[[FIG:dash01_du_lieu_chan_doan.png|Trang "01 · Dữ liệu & chẩn đoán": danh mục dữ liệu và kiểm tra chất lượng|Nguồn: Ảnh chụp màn hình dashboard của tác giả (app.py) đọc từ outputs/01_data.]]

[[FIG:dash04_mo_hinh_toan_cuc_uplift.png|Trang "04 · Mô hình toàn cục & uplift": WAPE của các mô hình trên 100 SKU và tầm quan trọng đặc trưng|Nguồn: Ảnh chụp màn hình dashboard của tác giả (app.py) đọc từ outputs/05_models.]]

[[FIG:dash10_ket_qua_nghien_cuu.png|Trang "10 · Kết quả nghiên cứu": 24 kiểm tra tự động của pipeline|Nguồn: Ảnh chụp màn hình dashboard của tác giả (app.py) đọc từ outputs/10_smoke và outputs/11_diagnostics.]]

[[FIG:dash11_xuat_bao_cao.png|Trang "11 · Xuất báo cáo": các tệp tải xuống và thư viện hình của báo cáo|Nguồn: Ảnh chụp màn hình dashboard của tác giả (app.py) đọc từ REPORT_READY/ và outputs/14_report_ready.]]


## E.4. Kiểm thử và toàn vẹn dữ liệu

Tính đúng của pipeline được bảo đảm bằng ba lớp kiểm tra. Lớp thứ nhất là 11 kiểm thử đơn vị trong tests/test_core.py, kiểm tra các hàm lõi trên những trường hợp có đáp án biết trước: hàm pinball cho đúng ví dụ q = 0,9 của slide (18; 2; 45; 27; 0), phân vị tới hạn cho đúng 0,5 / 0,8 / 0,3, adstock hình học, lợi nhuận Newsvendor, nội suy phân vị có kẹp biên, điểm Winkler, tối ưu ngân sách giữ đúng tổng và cận dưới, mô phỏng dòng tiền (độ trễ dài hơn phải cần nhiều tiền mặt hơn), và chặn payload sai kiểu. Lần chạy chính thức cho kết quả 11 kiểm thử đạt (11 passed).

Lớp thứ hai là Stage 10 với 24 kiểm tra trên đầu ra thật của pipeline ({T:smoke}); pipeline dừng với mã lỗi nếu một kiểm tra thất bại. Các kiểm tra bao gồm sự tồn tại của mọi tệp kết quả, kiểm tra rò rỉ thông tin của đặc trưng, đối chiếu số liệu Cục Thống kê, tái lập số trên slide (lỗ FMCG −78,44 triệu VNĐ, T₃ kháng nhiễu 11,5706, Ŷ₉ = 61 của ví dụ GAM, q^*^ của ví dụ Newsvendor, điểm RAG 0,3979), tính đơn điệu của phân vị, tính cận trên của Oracle, việc mọi phân bổ dùng đúng tổng ngân sách, và các ràng buộc của tác tử (từ chối chiết khấu vượt 50% khi không thuộc khuyến mại tập trung, không tự duyệt đề xuất có biên đóng góp âm hoặc ngoại suy).

[[TAB:smoke]]

Lớp thứ ba là toàn vẹn dữ liệu đầu vào. Stage 01 tính mã băm SHA-256 của mọi tệp dữ liệu và lưu vào outputs/01_data/sha256.json ({T:sha_all}). Người đọc có thể tính lại mã băm của tệp mình có (ví dụ bằng lệnh certutil -hashfile trên Windows hoặc sha256sum trên Linux) để xác nhận đang dùng đúng dữ liệu của lần chạy chính thức.

[[TAB:sha_all]]

## E.5. Các hàm then chốt

Phần này mô tả bằng lời các hàm quyết định kết quả chính, để người đọc có thể đối chiếu với mã nguồn mà không cần đọc toàn bộ project.

Hàm ovb_table trong src/marketing/response.py ước lượng năm đặc tả hồi quy của số đơn và GMV theo quảng cáo, chiết khấu và biến Mega Sale, rồi kiểm chứng đồng nhất thức thiên lệch bỏ sót biến: hệ số quảng cáo của mô hình chỉ có quảng cáo bằng hệ số trong mô hình đầy đủ cộng hệ số chiết khấu nhân với hệ số hồi quy của chiết khấu theo quảng cáo. Đồng nhất thức này là một kiểm tra đại số chứ không phải ước lượng, nên Stage 10 yêu cầu hai vế bằng nhau tới sai số làm tròn. Hàm adstock_scan và distributed_lag trong cùng tệp kiểm định hiệu ứng chi phí marketing trên chuỗi doanh thu đã khử mùa vụ, lần lượt với dạng lưu dư hình học trên lưới độ suy giảm từ 0 đến 0,9 và với độ trễ phân phối 0–14 ngày dùng sai số chuẩn HAC.

Hàm make_frame trong src/features/build.py dựng khung dữ liệu dự báo trực tiếp nhiều chân trời: mỗi dòng là một cặp (chuỗi, gốc dự báo, chân trời h), mọi đặc trưng chỉ dùng thông tin đến gốc dự báo và được chia cho trung bình 28 ngày của chuỗi để mô hình toàn cục học trên thang tương đối. Stage 04 kiểm tra tính không rò rỉ bằng cách phá hủy toàn bộ giá trị tương lai rồi dựng lại khung: chênh lệch lớn nhất của đặc trưng bằng 0 tới sai số máy. Hàm run_suite trong src/models/train.py chạy sáu mô hình trên cùng các gốc walk-forward và lưu dự báo để tính Diebold–Mariano bằng hàm dm_test có phương sai dài hạn Newey–West.

Lớp CampaignModel trong src/scenarios/megasale.py là lõi của bài toán Mega Sale. Lớp này ước lượng số đơn theo quảng cáo, chiết khấu và biến Mega Sale, ước lượng AOV theo chiết khấu, rồi mô phỏng 4.000 kịch bản số đơn kết hợp bất định tham số và nhiễu ngày để suy ra phân vị P10–P50–P90 của GMV và biên đóng góp. Hai giả định giá vốn được cài đặt tường minh: giá vốn tỷ lệ cố định theo GMV, hoặc giá vốn tỷ lệ với giá trị trước chiết khấu với hệ số κ hiệu chỉnh sao cho tổng giá vốn 90 ngày khớp tỷ lệ giá vốn/GMV của dữ liệu Unit Economics. Lớp cũng gắn cờ ngoại suy khi quảng cáo hoặc chiết khấu nằm ngoài vùng đã quan sát, hoặc khi kịch bản Mega Sale dùng mức chiết khấu chưa từng xuất hiện trong ngày Mega Sale.

Hàm optimize_allocation trong src/budget/allocate.py giải bài toán phân bổ ngân sách quảng cáo giữa ba ngành bằng phương pháp SLSQP, với hàm mục tiêu w₁ × GMV − w₂ × (giá vốn + quảng cáo), ràng buộc tổng ngân sách và cận dưới tỷ trọng tối thiểu; tùy chọn within_data giới hạn mỗi ngành trong khoảng chi đã quan sát. Hàm shadow_price tính giá bóng bằng sai phân hữu hạn của lợi nhuận tối ưu theo ngân sách. Lớp CampaignAgent trong src/genai/agent.py hiện thực tác tử bốn nút (observe, simulate, check, decide) trên LangGraph, với lược đồ Pydantic CampaignRequest kiểm tra kiểu và miền giá trị của đầu vào, và CampaignPlan định chuẩn đầu ra; hàm audit_record chuyển kết quả thành một bản ghi kiểm toán JSON. Hàm simulate trong src/cashflow/sim.py tính tiền mặt lũy kế theo ngày với giả định nhập hàng trả trước theo lead time, quảng cáo trả ngay và tiền bán hàng về sau độ trễ đối soát.

## E.6. Môi trường của lần chạy chính thức

Lần chạy chính thức được thực hiện ngày 22/10/2026 trên Linux, hai nhân xử lý, với Python 3.13 và các thư viện: pandas 3.0.5, numpy 2.5.3, scipy 1.18.1, scikit-learn 1.9.1, lightgbm 4.7.0, statsmodels 0.15.0, prophet 1.5.0, neuralforecast 3.3.0, langgraph 1.2.16, pydantic 2.13.5, matplotlib 3.11.2, plotly 7.1.0 và streamlit 1.66.1. Hạt giống ngẫu nhiên là 42; LightGBM chạy ở chế độ tất định với hai luồng. Tệp requirements.txt cho phép pandas 2.x để tương thích với môi trường Windows phổ biến; khác biệt phiên bản thư viện có thể làm thay đổi các chữ số thập phân cuối của mô hình học máy nhưng không làm thay đổi các kết luận định tính.

# PHỤ LỤC F. KHO TRI THỨC VÀ QUY CHẾ MẪU

Kho tri thức của tác tử (thư mục knowledge_base/) gồm năm tệp Markdown, được Stage 08 chia thành 20 đoạn theo tiêu đề cấp hai. Bốn tệp đầu là tóm tắt có dẫn nguồn của các văn bản và số liệu công khai, hoặc là quy chế mẫu; tệp thứ năm chép lại bốn tài liệu ví dụ của slide RAG. Cần nhấn mạnh rằng **tệp 04_quy_che_marketing_mau.md là quy chế MẪU do tác giả soạn để mô phỏng**, không phải quy chế của một doanh nghiệp có thật; các ngưỡng trong tệp này (phân vị 95% ngân sách, chiết khấu 40%, xác suất biên âm 20%) là tham số thiết kế của nghiên cứu và được kiểm tra độ nhạy ở mục 4.6. Phần dưới đây trình bày nội dung từng tệp đúng như tác tử truy xuất.

## F.1. Tệp 01 – Quy định pháp lý về khuyến mại

Nguồn của tệp là Luật Thương mại 2005 (Quốc hội, 2005), Nghị định 81/2018/NĐ-CP (Chính phủ, 2018) và Nghị định 128/2024/NĐ-CP ban hành ngày 10/10/2024, có hiệu lực từ 01/12/2024 (Chính phủ, 2024), theo bản tóm tắt của Luật Việt An. Tệp gồm bốn đoạn. Đoạn "Mức giảm giá tối đa" ghi: mức giảm giá tối đa đối với hàng hóa, dịch vụ được khuyến mại không được vượt quá 50% giá của hàng hóa, dịch vụ đó ngay trước thời gian khuyến mại (Điều 7 Nghị định 81/2018/NĐ-CP, được sửa đổi bởi Nghị định 128/2024/NĐ-CP). Đoạn "Ngoại lệ chương trình khuyến mại tập trung" ghi: đối với chương trình khuyến mại tập trung và các chương trình, hoạt động xúc tiến thương mại do Thủ tướng Chính phủ quyết định, mức giảm giá tối đa có thể lên tới 100%. Đoạn "Giá trị vật chất dùng để khuyến mại" ghi: giá trị vật chất dùng để khuyến mại cho một đơn vị hàng hóa, dịch vụ không được vượt quá 50% giá bán ngay trước thời gian khuyến mại; tổng giá trị hàng hóa, dịch vụ dùng để khuyến mại trong một chương trình không được vượt quá 50% tổng giá trị hàng hóa, dịch vụ được khuyến mại (Điều 6). Đoạn "Lưu ý áp dụng" ghi nguyên tắc thiết kế: tác tử phải từ chối tự động mọi đề xuất chiết khấu vượt 50% nếu chương trình không thuộc diện khuyến mại tập trung; tài liệu là bản tóm tắt phục vụ nghiên cứu, không thay thế tư vấn pháp lý.

Trong mã nguồn, hai ngưỡng 50% và 100% được khai báo trong config/default.yaml (legal_max_discount, legal_max_discount_central) và được nút kiểm tra của tác tử dùng trực tiếp; nhờ vậy quy định pháp lý được thực thi bằng mã, không phụ thuộc vào việc mô hình ngôn ngữ có "nhớ" quy định hay không.

## F.2. Tệp 02 – Chính sách đối soát của sàn

Nguồn của tệp là bài viết của MISA eShop về cách sàn Shopee trả tiền cho người bán (MISA eShop, không ghi năm). Đoạn "Thời điểm ghi nhận tiền đơn hàng" ghi: tiền đơn hàng được ghi nhận vào số dư người bán khi người mua xác nhận "Đã nhận được hàng"; nếu người mua không xác nhận, tiền được ghi nhận sau 4 ngày kể từ khi giao hàng thành công (áp dụng từ 29/03/2024), với điều kiện không có yêu cầu trả hàng/hoàn tiền. Đoạn "Thời gian rút tiền về ngân hàng" ghi: theo bài viết, tiền về trong vòng 24 giờ làm việc với một số ngân hàng lớn và có thể kéo dài đến 4 ngày làm việc với ngân hàng khác, kể từ khi sàn xác nhận yêu cầu rút tiền. Đoạn "Hàm ý cho dòng tiền chiến dịch" giải thích vì sao nghiên cứu dùng các mức trễ đối soát 0, 7, 10 và 14 ngày như tham số kịch bản: độ trễ từ ngày bán đến ngày tiền về tài khoản gồm thời gian giao hàng, thời gian chờ xác nhận và thời gian rút tiền, và các thành phần này thay đổi theo ngành hàng, đơn vị vận chuyển và hành vi người mua.

## F.3. Tệp 03 – Bối cảnh thị trường

Tệp tổng hợp bốn nhóm số liệu công bố. Đoạn "Quy mô thương mại điện tử 2024": theo Bộ Công Thương (Báo Công Thương, 2025), thị trường thương mại điện tử Việt Nam năm 2024 vượt 25 tỷ USD, tăng khoảng 20% so với 2023, chiếm khoảng 9% tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng cả nước. Đoạn "Doanh thu bốn sàn lớn năm 2025": theo báo cáo của YouNet ECI được Báo Pháp luật Việt Nam đưa tin (Nam Linh, 2026), tổng giá trị giao dịch trên bốn sàn Shopee, TikTok Shop, Lazada và Tiki năm 2025 đạt 458.160 tỷ đồng, tăng 26%. Đoạn "Mùa cao điểm cuối năm": Metric.vn (VnEconomy, 2025) dự báo doanh thu thương mại điện tử quý IV/2025 khoảng 105 nghìn tỷ đồng với sản lượng khoảng 1,069 tỷ sản phẩm, trong đó các chiến dịch 11.11 và 12.12 là động lực tăng trưởng của các tháng cuối năm. Đoạn "Tổng mức bán lẻ (Cục Thống kê)": TMBL năm 2025 đạt 7.008,9 nghìn tỷ đồng, tăng 9,2% danh nghĩa và 6,7% nếu loại trừ yếu tố giá; tháng 9/2026 ước đạt 690,6 nghìn tỷ đồng, tăng 14,1% so với cùng kỳ (Cục Thống kê, 2019–2026).

## F.4. Tệp 04 – Quy chế ra quyết định marketing (MẪU do tác giả soạn)

Tiêu đề của tệp ghi rõ đây là quy chế mẫu cho mô phỏng, không phải quy chế của doanh nghiệp thật. Tệp gồm sáu đoạn, mỗi đoạn tương ứng một quy tắc mà tác tử và dashboard thực thi:

- Ngưỡng phê duyệt ngân sách: đề xuất ngân sách quảng cáo ngày vượt phân vị 95% của chi tiêu quảng cáo ngày trong lịch sử phải chuyển Trưởng phòng Marketing phê duyệt. Với dữ liệu 90 ngày, ngưỡng này bằng 19,27 triệu VNĐ/ngày.
- Ngưỡng chiết khấu: mọi chiết khấu từ 40% trở lên phải được Giám đốc Tài chính phê duyệt; chiết khấu vượt 50% bị từ chối trừ khi chương trình thuộc diện khuyến mại tập trung.
- Điều kiện biên đóng góp: không tự động phê duyệt chiến dịch có biên đóng góp kỳ vọng (P50) âm hoặc xác suất biên đóng góp âm lớn hơn 20%.
- Quy tắc ROAS hòa vốn: ROAS hòa vốn của một ngành bằng AOV chia cho (AOV − giá vốn mỗi đơn); ngành có ROAS thực tế thấp hơn ROAS hòa vốn phải giảm quảng cáo hoặc tăng giá trị đơn (bán combo) trước khi tăng ngân sách.
- Quy tắc vùng dữ liệu: khi đề xuất ngân sách hoặc chiết khấu nằm ngoài khoảng đã quan sát trong dữ liệu lịch sử, dự báo được gắn cờ ngoại suy và phải có người duyệt.
- Dự trữ tiền mặt cho Mega Sale: trước Mega Sale, bộ phận tài chính phải dự trữ tiền mặt tối thiểu bằng nhu cầu vốn mô phỏng với độ trễ đối soát 14 ngày.

Các quy tắc này được chọn để phản ánh những phát hiện của chính tiểu luận: quy tắc ROAS hòa vốn xuất phát từ kết quả Unit Economics của ngành FMCG; quy tắc vùng dữ liệu xuất phát từ việc dữ liệu chỉ có ngày Mega Sale ở mức chiết khấu 50%; quy tắc dự trữ tiền mặt xuất phát từ mô phỏng bẫy vốn lưu động. Doanh nghiệp áp dụng khung này cần thay các ngưỡng bằng quy chế tài chính thật của mình.

## F.5. Tệp 05 – Bốn tài liệu ví dụ của slide

Tệp chép nguyên văn bốn tài liệu dùng trong ví dụ RAG của slide Chương 5 (Trần Duy Thanh, 2026a, Ch5 tr.22): quy chế kho về hệ số dự trữ an toàn 15% cho linh kiện điện tử; báo cáo tài chính về chi phí lưu kho quý 3/2026 tăng 5% do giá thuê bến bãi tăng; email khẩn về tàu hàng chở mã linh kiện TECH_001 gặp bão tại cảng Cát Lái, dự kiến trễ 5 ngày; và chính sách giá kích hoạt giảm giá 10% khi tồn kho vượt 200% định mức. Bốn tài liệu này được giữ trong kho vì hai lý do: chúng cho phép Stage 08 tái lập chính xác điểm tương đồng trên slide (0,1711; 0; 0,3979; 0 – Ch5 tr.26), và chúng đóng vai trò "nhiễu trong miền" khi đánh giá khả năng truy xuất đúng tài liệu pháp lý, thị trường của các câu hỏi về chiến dịch.

