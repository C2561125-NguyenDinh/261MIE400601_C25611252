# CHƯƠNG 3. DỮ LIỆU VÀ PHƯƠNG PHÁP NGHIÊN CỨU

Chương này trình bày cách tiểu luận biến năm câu hỏi nghiên cứu thành một hệ thống tính toán có thể kiểm tra và tái lập. Khác với một bài tập phân tích riêng lẻ, sản phẩm của tiểu luận là một project phần mềm hoàn chỉnh gồm mười bốn bước xử lý (stage), một thư viện mã nguồn dùng chung, bộ kiểm thử tự động và một dashboard tương tác mười hai trang. Mọi con số được báo cáo ở Chương 4 đều do pipeline này sinh ra và lưu trong thư mục outputs/. Mọi bảng số liệu trong báo cáo được dựng tự động từ các tệp đó, không gõ tay. Vì vậy, chương này vừa mô tả phương pháp thống kê và học máy, vừa mô tả kiến trúc phần mềm, cấu hình và quy trình kiểm soát chất lượng, bởi hai phần này gắn liền với nhau trong việc bảo đảm rằng kết quả không bị bịa đặt hay chỉnh sửa thủ công.

Chương được tổ chức như sau. Mục 3.1 trình bày thiết kế nghiên cứu tổng thể và cách mỗi câu hỏi nghiên cứu được ánh xạ vào dữ liệu, phương pháp và stage cụ thể. Mục 3.2 mô tả ba nguồn dữ liệu: mười hai bộ dữ liệu của học phần, chuỗi Tổng mức bán lẻ của Cục Thống kê và kho tri thức của tác tử AI. Mục 3.3 trình bày kiến trúc phần mềm. Các mục 3.4 đến 3.9 lần lượt trình bày phương pháp của từng nhóm stage, bám theo trình tự năm chương của học phần: chẩn đoán dữ liệu (Chương 1 của slide), phân rã chuỗi thời gian (Chương 2), học máy toàn cục và uplift (Chương 3), dự báo xác suất (Chương 4), phân bổ ngân sách và tác tử AI (Chương 5), cùng các phân tích trường hợp, dòng tiền và độ nhạy. Mục 3.10 tổng hợp các thước đo và kiểm định thống kê. Mục 3.11 trình bày các biện pháp bảo đảm khả năng tái lập và các cân nhắc đạo đức nghiên cứu.

## 3.1. Thiết kế nghiên cứu

### 3.1.1. Cách tiếp cận tổng thể

Quy trình nghiên cứu gồm bảy bước được tóm tắt ở {F:d02_quy_trinh_nghien_cuu.png}: xác định vấn đề và câu hỏi nghiên cứu từ nội dung học phần và bối cảnh thương mại điện tử Việt Nam; thu thập và kiểm tra dữ liệu (Stage 01); chẩn đoán và phân rã (Stage 02–03); xây dựng mô hình dự báo (Stage 04–06); tối ưu hóa và tác tử (Stage 07–08); kiểm định, chẩn đoán sai số và phân tích độ nhạy (Stage 09–13); cuối cùng là tổng hợp hình, bảng cho báo cáo và dashboard (Stage 14). Mũi tên nét đứt thể hiện vòng lặp hiệu chỉnh: khi kiểm định hoặc phân tích độ nhạy phát hiện vấn đề, quy trình quay lại bước mô hình hóa, như trường hợp chuyển sang STL không kháng nhiễu cho chuỗi 48 tháng, bổ sung giả định giá vốn theo giá niêm yết và gắn cờ ngoại suy cho kịch bản Mega Sale có chiết khấu khác 50%.

[[FIG:d02_quy_trinh_nghien_cuu.png|Quy trình nghiên cứu bảy bước và các stage tương ứng của pipeline|Nguồn: Tác giả]]

Tiểu luận sử dụng thiết kế nghiên cứu định lượng theo hướng khoa học thiết kế (design science): xây dựng một hệ thống hỗ trợ quyết định, rồi đánh giá từng thành phần của hệ thống bằng các thí nghiệm có kiểm soát trên dữ liệu có sẵn. Đối tượng quyết định là bài toán mà một doanh nghiệp thương mại điện tử (TMĐT) Việt Nam phải giải trước mỗi mùa Mega Sale: chi bao nhiêu cho quảng cáo, chiết khấu sâu đến đâu, phân bổ ngân sách giữa các ngành hàng thế nào, chuẩn bị bao nhiêu hàng và cần dự trữ bao nhiêu tiền mặt. Mỗi quyết định này dựa trên một loại dự báo khác nhau. Quyết định quảng cáo cần ước lượng hiệu quả biên của quảng cáo. Quyết định chiết khấu cần hiểu chiết khấu ảnh hưởng đến số đơn và giá trị đơn ra sao. Quyết định hàng hóa cần dự báo phân phối nhu cầu theo SKU. Quyết định tiền mặt cần dự báo dòng tiền theo thời gian.

Thiết kế nghiên cứu vì vậy được tổ chức thành năm tầng tương ứng với năm chương của học phần (Trần Duy Thanh, 2026b). Tầng thứ nhất chẩn đoán dữ liệu và mô hình kinh doanh để trả lời câu hỏi "quảng cáo và chiết khấu đóng góp gì" trước khi dự báo bất cứ điều gì. Tầng thứ hai phân rã chuỗi thời gian để tách mùa vụ khỏi tín hiệu marketing. Tầng thứ ba dùng học máy toàn cục để dự báo nhiều chuỗi và ước lượng uplift khuyến mãi theo sản phẩm. Tầng thứ tư chuyển dự báo điểm thành dự báo xác suất và dùng phân phối đó để ra quyết định hàng hóa và đánh giá rủi ro tài chính. Tầng thứ năm tích hợp các kết quả trên vào một tác tử AI lập kế hoạch chiến dịch, có kiểm tra pháp lý, quy chế nội bộ và người phê duyệt. Mỗi tầng dùng đầu ra của tầng trước làm đầu vào hoặc ràng buộc, ví dụ tỷ lệ giá vốn ước lượng ở tầng một được dùng lại trong mô hình chiến dịch ở tầng bốn và mô phỏng dòng tiền ở tầng năm.

Một nguyên tắc xuyên suốt của thiết kế là tách bạch giữa *dự báo có điều kiện* và *ước lượng nhân quả*. Các bộ dữ liệu sẵn có là dữ liệu quan sát, không có thí nghiệm ngẫu nhiên hóa, nên hệ số của quảng cáo hay chiết khấu trong các mô hình hồi quy chỉ được diễn giải là mối liên hệ có điều kiện trong vùng dữ liệu đã quan sát. Tiểu luận không tuyên bố tác động nhân quả và gắn cờ ngoại suy mỗi khi một kịch bản nằm ngoài vùng dữ liệu. Nguyên tắc này đặc biệt quan trọng với Mega Sale. Trong bộ dữ liệu 90 ngày, cả hai ngày Mega Sale (15/08/2026 và 19/09/2026) đều có mức chiết khấu đúng 50%, và không có ngày thường nào có chiết khấu 50%. Do đó, biến chỉ báo "ngày Mega Sale" và mức "chiết khấu sâu" trùng nhau hoàn toàn trên dữ liệu. Không mô hình nào có thể tách được phần tăng đơn do *sự kiện sàn* với phần tăng đơn do *chiết khấu sâu*. Giới hạn nhận dạng này được mã hóa trực tiếp vào mô hình chiến dịch (mục 3.7.4) và vào tác tử (mục 3.8.3).

### 3.1.2. Ánh xạ câu hỏi nghiên cứu vào dữ liệu, phương pháp và stage

{T:@rqmap} tóm tắt cách năm câu hỏi nghiên cứu được trả lời. Mỗi câu hỏi gắn với một chương của slide, một hoặc vài bộ dữ liệu, một nhóm phương pháp, một hoặc vài stage của pipeline và nhóm thước đo đánh giá. Cách ánh xạ này cho phép người đọc lần theo một kết luận ở Chương 4 về tệp mã nguồn đã sinh ra nó.

[[T:@rqmap Ánh xạ câu hỏi nghiên cứu vào chương slide, dữ liệu, phương pháp, stage và thước đo
RQ | Chương slide | Dữ liệu chính | Phương pháp | Stage | Thước đo
RQ1 | Ch1: chẩn đoán dữ liệu, mô hình kinh doanh | ecommerce_90days; dirty; panel; unit_economics | EDA 3 phương diện; IQR, Z vững; OLS và OVB; panel FE; Unit Economics | 01, 02 | Hệ số, R², kiểm định F, Breusch–Pagan; CM, ROAS hòa vốn
RQ2 | Ch2: phân rã chuỗi thời gian | multiseasonal; 48 tháng; profit_margin; TMBL Cục Thống kê | STL, HP, MSTL, GAM, Prophet; adstock; độ trễ phân phối; hồi quy lịch | 03 | Độ mạnh F_S, phương sai thành phần; p; MAE kiểm định chéo
RQ3 | Ch3: học máy cho dự báo quy mô lớn | complex_retail; raw_sales; 100 SKU; 15 SKU | LightGBM toàn cục, cục bộ, Holt-Winters; S/T-learner; cold-start; hồi quy hiệu ứng cố định | 04, 05, 11 | WAPE, MASE, Bias; Diebold–Mariano
RQ4 | Ch4: dự báo xác suất, tồn kho | 100 SKU + financial_metadata; 90 ngày; TMBL | Z, Quantile LightGBM, phân vị phần dư, DeepAR; Newsvendor; ROP; bootstrap | 06, 12 | Pinball, độ phủ, Winkler; lợi nhuận, fill-rate, CSL; P(lỗ)
RQ5 | Ch5: tác tử AI | panel + unit_economics; 90 ngày; kho tri thức | Tối ưu ngân sách có trọng số, Lagrange; RAG; ReAct; pydantic; LangGraph; HITL; mô phỏng dòng tiền | 07, 08, 12, 13 | Lợi nhuận, giá bóng; P@1, MRR; trạng thái phê duyệt; tiền mặt tối thiểu
Nguồn: Tác giả thiết kế; tên stage theo project MegaSale_Marketing_VN.
]]

### 3.1.3. Đơn vị phân tích và chân trời quyết định

Tiểu luận làm việc trên ba đơn vị phân tích. Đơn vị thứ nhất là *ngày giao dịch của toàn cửa hàng* (90 ngày, 01/07–28/09/2026), dùng để đo hiệu quả quảng cáo, chiết khấu và mô phỏng ngày Mega Sale. Đơn vị thứ hai là *ngày – ngành hàng* (panel ba ngành × 30 ngày), dùng để so sánh hiệu quả quảng cáo giữa ngành và phân bổ ngân sách. Đơn vị thứ ba là *ngày – SKU* (100 SKU × 150 ngày và 15 SKU × 240 ngày), dùng để dự báo cầu nhiều chuỗi và ra quyết định chuẩn bị hàng. Ngoài ra, chuỗi tháng Tổng mức bán lẻ (TMBL) của Việt Nam là đơn vị phân tích vĩ mô, dùng để đặt mùa vụ của doanh nghiệp vào bối cảnh tiêu dùng cả nước.

Chân trời quyết định được chọn theo tính chất của từng quyết định. Quyết định quảng cáo và chiết khấu là quyết định ngày (đơn vị ngân sách trong mô hình là triệu VNĐ/ngày). Quyết định chuẩn bị hàng dùng chân trời 14 ngày, phù hợp với chu kỳ đặt hàng hai tuần và với thiết kế trong slide Chương 4 (Trần Duy Thanh, 2026a, Ch4 tr.67–75). Quyết định tiền mặt dùng toàn bộ cửa sổ 90 ngày cộng thêm thời gian nhập hàng trước (lead time) và độ trễ đối soát. Dự báo vĩ mô dùng chân trời 12 tháng.

## 3.2. Dữ liệu

### 3.2.1. Mười hai bộ dữ liệu của học phần

Nguồn dữ liệu cấp doanh nghiệp của tiểu luận là mười hai tệp CSV do giảng viên cung cấp kèm bài giảng và mã minh họa (Trần Duy Thanh, 2026c). Cần nói rõ ngay từ đầu: đây là **dữ liệu mô phỏng**. Slide Chương 1 ghi rõ nguồn của các bộ dữ liệu minh họa là "src: Synthetic Data" (Trần Duy Thanh, 2026a, Ch1 tr.11, tr.20). Dữ liệu mô phỏng có ưu điểm là cấu trúc sạch, cơ chế sinh dữ liệu đôi khi được mô tả trên slide (ví dụ hệ số nhân cuối tuần và khuyến mãi của năm sản phẩm trong tệp complex_retail_sales, Ch3 tr.87), nhờ đó có thể kiểm tra xem phương pháp có khôi phục đúng tham số đã biết hay không. Nhược điểm là các kết quả trên dữ liệu này chỉ có giá trị *minh chứng phương pháp*, không phải bằng chứng về hành vi thị trường TMĐT Việt Nam. Tiểu luận giữ nguyên tắc này trong toàn bộ phần diễn giải: mỗi kết luận về hiệu quả quảng cáo hay lợi nhuận Mega Sale đều được hiểu là "trên dữ liệu học phần" và đi kèm điều kiện cần kiểm chứng lại bằng dữ liệu giao dịch thật.

{T:data_inventory} liệt kê mười hai tệp, quy mô, vị trí sử dụng trên slide, nội dung và mười hai ký tự đầu của mã băm SHA-256. Mã băm đầy đủ được lưu trong outputs/01_data/sha256.json và trình bày ở Phụ lục. Việc công bố mã băm cho phép bất kỳ ai tải lại dữ liệu từ trang của giảng viên kiểm tra xem tệp mình dùng có giống hệt tệp của tiểu luận hay không.

[[TAB:data_inventory]]

Với đề tài hiệu quả quảng cáo – khuyến mãi, bốn tệp có vai trò trung tâm. Tệp **ecommerce_90days** ghi nhận GMV (triệu VNĐ), số đơn, chi phí quảng cáo (triệu VNĐ) và tỷ lệ chiết khấu của 90 ngày liên tục từ 01/07/2026 đến 28/09/2026. Đây là tệp duy nhất có đồng thời quảng cáo, chiết khấu và hai ngày Mega Sale, nên được dùng để đo hiệu quả quảng cáo, kiểm chứng thiên lệch bỏ sót biến và xây dựng mô hình chiến dịch. Tệp **ecommerce_panel_data_raw** ghi nhận số đơn, GMV và quảng cáo của ba ngành (FMCG, Thời trang, Điện tử) trong 30 ngày tháng 8/2026; đây là cơ sở để so sánh hiệu quả quảng cáo giữa ngành và giải bài toán phân bổ ngân sách. Tệp **ecommerce_unit_economics** bổ sung giá vốn mỗi đơn theo ngành, cho phép tính biên đóng góp và ROAS hòa vốn. Tệp **ecommerce_daily_multiseasonal** có chi phí marketing hằng ngày trong ba năm 2021–2023 cùng doanh thu chuẩn hóa và số người dùng hoạt động, cho phép kiểm định hiệu ứng marketing sau khi đã khử mùa vụ tuần và năm.

Các tệp còn lại phục vụ những câu hỏi bổ trợ. Tệp ecommerce_dirty_data (20 ngày) chứa đủ bốn loại bất thường điển hình mà slide Chương 1 phân tích: giá trị 0 do lỗi hệ thống, giá trị khuyết do lỗi API, ngoại lai do sai giá trị và ngoại lai hợp lệ do Flash Sale. Tệp ecommerce_profit_margin_2020_2025 (72 tháng) và ecommerce_48months (48 tháng) phục vụ phân rã chuỗi tháng. Tệp raw_sales_data và complex_retail_sales phục vụ bài toán khuyến mãi và sản phẩm mới. Tệp historical_sales_100_r2 (100 SKU × 150 ngày) cùng financial_metadata_100 (giá bán, giá vốn, giá thanh lý của 100 SKU, đơn vị nghìn VNĐ/đơn vị) phục vụ dự báo cầu nhiều chuỗi và quyết định chuẩn bị hàng cho chiến dịch. Tệp ecommerce_sales_multi_sku (15 SKU × 240 ngày) dùng để kiểm tra lại kết luận về mô hình toàn cục trên một bộ dữ liệu nhỏ hơn.

Về đơn vị, tiểu luận tuân theo cách slide sử dụng. Mọi giá trị tiền tệ trong các tệp cấp cửa hàng và ngành (GMV, quảng cáo, AOV, giá vốn mỗi đơn) được hiểu là triệu VNĐ. Riêng giá trong financial_metadata_100 được hiểu là nghìn VNĐ cho một đơn vị sản phẩm, phù hợp với ví dụ tính tay về Newsvendor trên slide Chương 4. Lợi nhuận Newsvendor vì vậy được quy về triệu VNĐ bằng cách chia cho 1.000.

### 3.2.2. Kiểm tra chất lượng dữ liệu

Stage 01 kiểm tra tự động từng tệp theo cùng một bộ tiêu chí: số ô khuyết, số dòng trùng hoàn toàn, số giá trị âm, số giá trị bằng 0, khoảng thời gian, số dòng trùng khóa (ngày cùng mã chuỗi), số chuỗi và số ngày thiếu so với lịch liên tục. Kết quả được ghi vào outputs/01_data/quality_checks.csv và trình bày ở {T:quality_checks}.

[[TAB:quality_checks]]

Kết quả cho thấy dữ liệu nhìn chung sạch, với ba nhóm bất thường có chủ đích. Nhóm thứ nhất nằm trong ecommerce_dirty_data: bốn ô khuyết và bốn giá trị 0, đúng với mô tả trên slide. Nhóm thứ hai là các ngày thiếu trong ecommerce_unit_economics: ba ngành lẽ ra có 3 × 30 = 90 bản ghi nhưng tệp chỉ có 76 dòng, tức thiếu 14 ngày–ngành (FMCG hoạt động 25 ngày, Thời trang 24 ngày, Điện tử 27 ngày). Tiểu luận không lấp các ngày thiếu này, vì Unit Economics được tính trên tổng lượng của những ngày có hoạt động; điền giá trị giả cho những ngày không có giao dịch sẽ làm sai lệch AOV và CAC. Nhóm thứ ba là các giá trị âm ở biên lợi nhuận ròng (29 tháng) và ở doanh thu chuẩn hóa của chuỗi đa mùa vụ (485 ngày). Đây không phải lỗi mà là bản chất của biến: biên lợi nhuận có thể âm, còn doanh thu chuẩn hóa theo điểm z dao động quanh 0. Các giá trị 0 trong complex_retail_sales (470 ô) và financial_metadata_100 (40 ô) là biến nhị phân cuối tuần/khuyến mãi và giá thanh lý bằng 0 của nhóm cáp sạc, cũng hợp lệ.

### 3.2.3. Làm sạch dữ liệu bẩn theo quy trình của slide

Tệp ecommerce_dirty_data được làm sạch theo đúng trình tự mà slide Chương 1 đề xuất (Trần Duy Thanh, 2026a, Ch1 tr.76–101), sau đó bổ sung một phương pháp phát hiện ngoại lai vững hơn để kiểm tra độ tin cậy. Trình tự gồm bốn bước, đều được hiện thực trong Stage 01.

Bước thứ nhất là *chuyển giá trị 0 do lỗi hệ thống thành giá trị khuyết*. Hai ngày 04/08 và 05/08 có GMV bằng 0 với ghi chú "Lỗi hệ thống (Stock-out ảo)". Nếu giữ nguyên 0, mọi thống kê và mô hình sẽ hiểu đó là hai ngày không có nhu cầu. Vì ghi chú cho biết đây là lỗi ghi nhận chứ không phải hết hàng thật, hai giá trị này được coi là khuyết. Bước thứ hai là *nội suy tuyến tính* cho cả bốn ngày khuyết (04/08, 05/08, 09/08, 10/08), theo công thức nội suy trên slide:

$ x̂~t~ = x~a~ + (x~b~ − x~a~) · (t − a)/(b − a)

trong đó a và b là hai ngày quan sát gần nhất trước và sau khoảng khuyết. Bước thứ ba là *phát hiện ngoại lai bằng hàng rào Tukey*:

$ Q~1~ − 1,5 · IQR ≤ x ≤ Q~3~ + 1,5 · IQR,  IQR = Q~3~ − Q~1~

Trên chuỗi sau nội suy, Q~1~ = 14,95, Q~3~ = 17,85, IQR = 2,90, hàng rào dưới 10,60 và hàng rào trên 22,20 triệu VNĐ. Hai ngày vượt hàng rào trên là 15/08 (150,0) và 19/08 (85,0). Bước thứ tư là *phân loại ngoại lai theo bối cảnh nghiệp vụ*. Ngày 19/08 được ghi chú "Sự kiện Flash Sale (Outlier hợp lệ)", nên được giữ nguyên và gắn cờ sự kiện. Ngày 15/08 được ghi chú "Ngoại lai (Sai giá trị)", nên bị coi là lỗi, chuyển thành khuyết và nội suy lại từ hai ngày lân cận.

Để kiểm tra độ vững của bước ba, Stage 01 tính thêm điểm Z vững dựa trên trung vị và độ lệch tuyệt đối trung vị (MAD), theo Rousseeuw và Croux (1993):

$ z~i~^vững^ = 0,6745 · (x~i~ − median(x)) / MAD

Trung vị của chuỗi sau nội suy là 16,27 và MAD là 1,467. Khác với Z-score thông thường, trung vị và MAD không bị chính các ngoại lai kéo lệch, nên phương pháp này không mắc hiệu ứng che lấp (masking). Kết quả từng ngày được trình bày ở {T:dirty} và minh họa ở {F:s01_dirty_cleaning.png}. Sau làm sạch, GMV trung bình của 20 ngày giảm từ 25,73 xuống 19,57 triệu VNĐ, cho thấy một giá trị sai duy nhất có thể làm sai lệch trung bình hơn 30%.

[[TAB:dirty]]

[[FIG:s01_dirty_cleaning.png|GMV 20 ngày trước và sau làm sạch: giá trị 0 do lỗi được coi là khuyết và nội suy, ngoại lai sai giá trị được thay, sự kiện Flash Sale được giữ và gắn cờ; vùng tô là khoảng nằm trong hàng rào Tukey|Nguồn: Tác giả tính toán từ dữ liệu học phần (Stage 01, outputs/01_data/dirty_cleaning.csv).]]

Quy trình làm sạch này có hàm ý trực tiếp cho đề tài. Trong dữ liệu TMĐT, ngày khuyến mãi và ngày lỗi hệ thống đều tạo ra các điểm cực trị. Nếu xử lý ngoại lai một cách máy móc, chẳng hạn cắt bỏ mọi điểm ngoài hàng rào, tiểu luận sẽ xóa luôn những ngày chứa thông tin quan trọng nhất về hiệu quả khuyến mãi. Ngược lại, nếu giữ mọi điểm, lỗi ghi nhận sẽ bị hiểu nhầm thành hiệu ứng khuyến mãi. Vì vậy, trong toàn bộ pipeline, ngày Mega Sale luôn được giữ và mô hình hóa bằng biến chỉ báo riêng thay vì bị loại bỏ.

### 3.2.4. Số liệu Tổng mức bán lẻ của Cục Thống kê

Nguồn dữ liệu thật của tiểu luận là chỉ tiêu "Tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng" (TMBL) do Cục Thống kê (trước đây là Tổng cục Thống kê) công bố hằng tháng trong báo cáo và thông cáo báo chí về tình hình kinh tế – xã hội (Cục Thống kê, 2019–2026). TMBL đo tổng doanh thu bán lẻ hàng hóa và các dịch vụ tiêu dùng của toàn nền kinh tế theo giá hiện hành, đơn vị nghìn tỷ đồng. Chỉ tiêu này có ý nghĩa với đề tài Mega Sale vì hai lý do. Thứ nhất, TMĐT bán lẻ là một bộ phận ngày càng lớn của TMBL: theo Bộ Công Thương, thị trường TMĐT Việt Nam năm 2024 vượt 25 tỷ USD, tăng khoảng 20% và chiếm khoảng 9% tổng mức bán lẻ (Báo Công Thương, 2025). Mùa vụ, chu kỳ và cú sốc của TMBL vì vậy là môi trường vĩ mô của mọi chiến dịch TMĐT. Thứ hai, chuỗi TMBL có những đặc điểm mà dữ liệu mô phỏng không có: mùa vụ gắn với Tết Nguyên đán là ngày lễ âm lịch di động, cú sốc ngoại sinh lớn trong giai đoạn giãn cách xã hội 2020–2021, và độ vênh giữa ước tính lần đầu với số chính thức. Đặc biệt, chuỗi này cho phép kiểm tra một giả thuyết mà dữ liệu học phần không thể kiểm tra: liệu sự bùng nổ của các chiến dịch "ngày đôi" cuối năm (11.11, 12.12) có để lại dấu vết trong mùa vụ tiêu dùng của cả nước hay không.

Chuỗi phân tích gồm 82 tháng liên tục từ 12/2019 đến 9/2026. Mỗi giá trị là *ước tính lần đầu*, tức con số công bố trong báo cáo của chính tháng đó. Lựa chọn này mô phỏng đúng điều kiện thông tin của nhà quản trị tại thời điểm ra quyết định và tránh rò rỉ từ các lần điều chỉnh số liệu về sau. Mỗi giá trị đi kèm tốc độ tăng so với tháng trước và so với cùng kỳ (khi báo cáo có nêu), ngày đăng và đường dẫn bài gốc. Danh sách đủ 82 giá trị và đường dẫn được trình bày ở Phụ lục.

Ngoài chuỗi tháng, tiểu luận thu thập số TMBL cả năm 2019–2025 cùng tốc độ tăng danh nghĩa và tốc độ tăng thực đã loại trừ yếu tố giá. {T:gso_annual} trình bày các giá trị này và kết quả đối chiếu với tổng 12 tháng ước tính lần đầu do Stage 01 tính lại. Với các năm 2020, 2022, 2023, 2024 và 2025, chênh lệch nằm trong khoảng ±0,62%, cho thấy chuỗi tháng nhất quán với số năm và không có lỗi bóc tách hệ thống. Năm 2021 có chênh lệch lớn nhất (−3,04%): đây là năm có bốn tháng giãn cách và các ước tính lần đầu của giai đoạn này được điều chỉnh tăng đáng kể ở những kỳ báo cáo sau. Stage 10 kiểm tra tự động điều kiện chênh lệch tuyệt đối dưới 5% ở mọi năm đủ 12 tháng.

[[TAB:gso_annual]]

Hai đặc điểm lịch được mã hóa thành biến ngoại sinh trong mã nguồn (src/data/io.py và mục calendar của config/default.yaml). Thứ nhất là Tết Nguyên đán. Cấu hình lưu ngày mùng 1 Tết từ 2020 đến 2027 (25/01/2020, 12/02/2021, 01/02/2022, 22/01/2023, 10/02/2024, 29/01/2025, 17/02/2026, 06/02/2027). Hàm tet_window_share tính, cho từng tháng, tỷ lệ số ngày trong cửa sổ 21 ngày trước mùng 1 rơi vào tháng đó:

$ Tết~m~ = (1/21) · Σ~Tết~ Σ~d ∈ [Tết − 21; Tết − 1]~ 1[d thuộc tháng m]

Cách mã hóa này phân bổ hiệu ứng mua sắm trước Tết hợp lý giữa tháng 1 và tháng 2 tùy năm, thay vì gán cứng cho một tháng dương lịch. Thứ hai là các tháng giãn cách xã hội do COVID-19: tháng 4/2020 và các tháng 7, 8, 9/2021. Biến giả COVID bằng 1 ở bốn tháng này và bằng 0 ở các tháng khác; các đợt giãn cách cục bộ ngắn hơn không được mã hóa và được coi là nằm trong phần dư.

### 3.2.5. Quy trình thu thập và kiểm tra toàn vẹn số liệu Cục Thống kê

Trang nso.gov.vn được xây dựng trên nền tảng WordPress và có giao diện lập trình REST công khai (đường dẫn /wp-json/wp/v2/posts) cho phép truy vấn bài viết theo chuyên mục và mã bài. Tiểu luận truy vấn các bài thuộc chuyên mục báo cáo, thông cáo kinh tế – xã hội, lọc các bài có câu chứa cụm "tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng" và lưu ngày đăng, tiêu đề, đường dẫn cùng câu trích chứa số liệu của 265 bài. Truy vấn được thực hiện qua trình duyệt theo cơ chế truy cập công khai của trang, không vượt bất kỳ rào cản kỹ thuật nào.

Việc bóc tách giá trị từ văn bản gặp ba khó khăn thực tế, và mỗi khó khăn được xử lý tường minh. Khó khăn thứ nhất là chuẩn hóa Unicode: văn bản tiếng Việt trên trang tồn tại ở cả dạng dựng sẵn (NFC) và dạng tổ hợp (NFD), khiến cùng một chữ "tháng" có số mã ký tự khác nhau và biểu thức chính quy không khớp. Toàn bộ tiêu đề và câu trích được chuẩn hóa về NFC trước khi so khớp. Khó khăn thứ hai là biến thể chính tả "hóa"/"hoá", được xử lý bằng lớp ký tự chấp nhận cả hai dạng. Khó khăn thứ ba là cách diễn đạt tháng không thống nhất: "tháng 9/2026", "tháng Chín năm 2026", hay câu bắt đầu bằng ký hiệu liệt kê "a)". Bộ phân tích chấp nhận cả số và chữ, chỉ lấy câu mô tả tháng hiện hành của báo cáo và loại các cụm chỉ lũy kế ("9 tháng", "đầu năm") để tránh nhầm số lũy kế với số tháng.

Kết quả bóc tách gồm 143 lần nhắc tới giá trị TMBL tháng, tương ứng 123 tháng khác nhau. Với mỗi tháng, tiểu luận giữ một giá trị duy nhất theo thứ tự ưu tiên: bài loại "Báo cáo" trước bài loại "Thông cáo", và bài đăng sớm hơn trước bài đăng muộn hơn (để giữ ước tính lần đầu). Chuỗi sau đó được cắt từ 12/2019 và kiểm tra tính liên tục. Hai tháng không có câu trích trực tiếp được **suy ra từ tổng quý chính thức** trừ đi hai tháng còn lại của quý, và được đánh dấu rõ là giá trị suy ra:

$ TMBL~12/2020~ = TMBL~quý IV/2020~ − TMBL~10/2020~ − TMBL~11/2020~ = 1.387,6 − 450,8 − 464,4 = 472,4

$ TMBL~6/2021~ = TMBL~quý II/2021~ − TMBL~4/2021~ − TMBL~5/2021~ = 1.177,6 − 409,4 − 393,6 = 374,6

Tiểu luận không nội suy bất kỳ giá trị tháng nào khác. Ngoài đối chiếu tổng tháng với số năm, tốc độ tăng so với cùng kỳ do Cục Thống kê công bố được so với tốc độ tự tính từ chuỗi ước tính lần đầu: hệ số tương quan giữa hai chuỗi là 0,941 và chênh lệch tuyệt đối trung bình là 3,63 điểm phần trăm. Chênh lệch này không phải lỗi bóc tách: tốc độ công bố so với số đã điều chỉnh của cùng kỳ năm trước, còn tốc độ tự tính so với ước tính lần đầu của năm trước. Vì vậy, trong toàn bộ tiểu luận, tốc độ tăng so với cùng kỳ được trích theo số công bố, còn mô hình được ước lượng trên chuỗi mức ước tính lần đầu.

### 3.2.6. Truyền tải và kiểm tra toàn vẹn dữ liệu học phần

Môi trường tính toán của tiểu luận tách biệt với máy tính cá nhân nơi tải dữ liệu. Để chuyển các tệp CSV mà không làm sai lệch nội dung, tiểu luận dùng quy trình bốn bước: nén tệp bằng gzip ngay trong trình duyệt; mã hóa nhị phân thành chuỗi base64; chuyển chuỗi theo từng khối tối đa 18.000 ký tự, sao chép nguyên văn từ kết quả hiển thị; giải mã, giải nén và so khớp mã băm SHA-256 tính ở hai đầu. Một sai lệch dù chỉ một ký tự cũng làm hai mã băm khác nhau và làm hỏng kiểm tra CRC của gzip. Trong quá trình thực hiện, một lần truyền đã bị phát hiện sai lệch qua kiểm tra mã băm và được truyền lại toàn bộ, cho thấy bước kiểm tra này là chốt chặn thực sự chứ không phải thủ tục hình thức.

Riêng tệp historical_sales_100 (15.000 dòng) được xoay sang dạng ma trận rộng 150 ngày × 100 SKU và làm tròn đến hai chữ số thập phân trước khi nén, sau đó dựng lại về dạng dài (unique_id, ds, y) và lưu thành historical_sales_100_r2.csv. Sai số làm tròn tối đa 0,005 đơn vị sản phẩm, không đáng kể so với mức bán của các SKU. Sau khi dựng lại, Stage 01 xác nhận đủ 100 mã SKU, mỗi mã đủ 150 ngày liên tục từ 01/04/2026 đến 28/08/2026, không khuyết và không trùng khóa.

### 3.2.7. Kho tri thức của tác tử AI

Nguồn dữ liệu thứ ba là kho tri thức văn bản (thư mục knowledge_base/) mà tác tử AI truy xuất khi lập kế hoạch chiến dịch. Kho gồm năm tệp Markdown, được chia tự động thành 21 đoạn theo tiêu đề cấp hai. Tệp thứ nhất tóm tắt quy định pháp lý về khuyến mại: theo Nghị định 81/2018/NĐ-CP được sửa đổi bởi Nghị định 128/2024/NĐ-CP (ban hành 10/10/2024, hiệu lực 01/12/2024), mức giảm giá tối đa không vượt quá 50% giá ngay trước thời gian khuyến mại, trừ chương trình khuyến mại tập trung và các chương trình do Thủ tướng Chính phủ quyết định được phép tới 100%; giá trị vật chất dùng để khuyến mại cho một đơn vị hàng hóa và tổng giá trị hàng dùng để khuyến mại trong một chương trình đều không vượt quá 50% (Quốc hội, 2005; Chính phủ, 2018, 2024). Tệp thứ hai tóm tắt chính sách thanh toán cho người bán của một sàn lớn: tiền đơn hàng được ghi nhận khi người mua xác nhận đã nhận hàng hoặc sau 4 ngày kể từ khi giao thành công, và rút tiền về ngân hàng mất từ 24 giờ làm việc đến 4 ngày làm việc (MISA eShop, không ghi năm). Tệp thứ ba tóm tắt bối cảnh thị trường có dẫn nguồn: quy mô TMĐT 2024 (Báo Công Thương, 2025), doanh thu bốn sàn lớn năm 2025 đạt 458.160 tỷ đồng, tăng 26% (Nam Linh, 2026), dự báo doanh thu quý IV/2025 khoảng 105 nghìn tỷ đồng với 1,069 tỷ sản phẩm (VnEconomy, 2025) và số liệu TMBL của Cục Thống kê. Tệp thứ tư là **quy chế ra quyết định marketing mẫu do tác giả soạn** cho mục đích mô phỏng, nêu rõ ngay ở tiêu đề rằng đây không phải quy chế của doanh nghiệp thật; quy chế gồm ngưỡng phê duyệt ngân sách, ngưỡng chiết khấu, điều kiện biên đóng góp, quy tắc ROAS hòa vốn, quy tắc vùng dữ liệu và yêu cầu dự trữ tiền mặt. Tệp thứ năm chứa nguyên văn bốn tài liệu ví dụ RAG trên slide Chương 5 (Trần Duy Thanh, 2026a, Ch5 tr.22) để tái lập ví dụ của giảng viên.

Việc tách bạch giữa nội dung có nguồn công khai và nội dung mẫu do tác giả soạn là có chủ đích. Một tác tử AI trong doanh nghiệp thật sẽ truy xuất cả văn bản pháp luật lẫn quy chế nội bộ; quy chế nội bộ không có sẵn cho nghiên cứu, nên tiểu luận soạn một bộ quy chế mẫu hợp lý và minh bạch về nguồn gốc của nó. Mọi kết luận về hành vi của tác tử chỉ phụ thuộc vào logic xử lý quy chế, không phụ thuộc vào việc quy chế đó có phải của một doanh nghiệp cụ thể hay không.

## 3.3. Kiến trúc phần mềm của nghiên cứu

### 3.3.1. Nguyên tắc thiết kế

{F:d03_kien_truc_project.png} mô tả kiến trúc project theo luồng dữ liệu: dữ liệu thô và cấu hình ở bên trái được các mô-đun của thư viện src/ xử lý; mười bốn stage gọi các mô-đun này theo thứ tự cố định (tệp START_WINDOWS.bat hoặc run_all.sh); mọi kết quả được ghi vào outputs/ và REPORT_READY/, từ đó dashboard Streamlit và bộ dựng báo cáo đọc lại mà không tự tạo số liệu. Kiểm thử đơn vị và Stage 10 đóng vai trò cổng chất lượng: pipeline dừng nếu một kiểm tra thất bại.

[[FIG:d03_kien_truc_project.png|Kiến trúc project: dữ liệu, thư viện src/, pipeline 14 stage, đầu ra, dashboard và bộ dựng báo cáo|Nguồn: Tác giả]]

Project phần mềm của tiểu luận (thư mục MegaSale_Marketing_VN) được thiết kế theo bốn nguyên tắc. Nguyên tắc thứ nhất là *mỗi bước một tệp, mỗi tệp một thư mục đầu ra*: mười bốn stage được đánh số từ 01 đến 14, mỗi stage là một chương trình Python độc lập, đọc dữ liệu gốc hoặc đầu ra của stage trước và ghi kết quả vào thư mục outputs/<số_stage>_<tên>/, gồm tệp results.json tổng hợp, các bảng CSV chi tiết, thư mục figures/ chứa hình và tệp run_info.json ghi thời điểm chạy và hạt giống ngẫu nhiên. Cách tổ chức này cho phép kiểm tra từng bước độc lập và chạy lại một bước mà không phải chạy lại toàn bộ. Nguyên tắc thứ hai là *tách logic khỏi kịch bản*: mọi phép tính có thể tái sử dụng (đọc dữ liệu, đặc trưng, mô hình, thước đo, chính sách tồn kho, mô phỏng chiến dịch, phân bổ ngân sách, dòng tiền, tác tử) nằm trong gói src/ và được kiểm thử đơn vị; các stage chỉ điều phối. Nguyên tắc thứ ba là *cấu hình tập trung*: mọi tham số có thể thay đổi (hạt giống, chân trời, siêu tham số, ngưỡng pháp lý, ngưỡng phê duyệt, tham số dòng tiền) nằm trong một tệp config/default.yaml. Nguyên tắc thứ tư là *dashboard chỉ đọc*: ứng dụng Streamlit đọc lại đầu ra của pipeline và gọi lại đúng các hàm trong src/ cho các trang mô phỏng, không tự sinh hay chỉnh sửa số liệu.

### 3.3.2. Mười bốn stage của pipeline

{T:@stages} liệt kê mười bốn stage, nội dung và đầu ra chính. Trình tự stage bám theo trình tự năm chương của học phần: Stage 01–02 tương ứng Chương 1, Stage 03 tương ứng Chương 2, Stage 04–05 tương ứng Chương 3, Stage 06 tương ứng Chương 4, Stage 07–08 tương ứng Chương 5. Các stage 09–14 tổng hợp, kiểm thử, chẩn đoán sai số, phân tích trường hợp, phân tích độ nhạy và chuẩn bị hình, bảng cho báo cáo. Toàn bộ pipeline được chạy bằng một lệnh (run_all.sh trên Linux, START_WINDOWS.bat trên Windows). Lần chạy chính thức mất khoảng năm phút trên máy hai lõi CPU; phần tốn thời gian nhất là so sánh mô hình toàn cục và cục bộ (Stage 05) và dự báo phân vị (Stage 06), mỗi stage gần hai phút.

[[T:@stages Mười bốn stage của pipeline: nội dung, chương slide tương ứng và đầu ra chính
Stage | Tệp | Nội dung | Chương slide | Đầu ra chính (outputs/)
01 | 01_data_validation.py | Kiểm tra 12 tệp, làm sạch dữ liệu bẩn, đối chiếu số liệu Cục Thống kê, mã băm | Ch1 | 01_data: data_inventory, quality_checks, dirty_cleaning, gso_check, sha256
02 | 02_marketing_diagnostics.py | EDA 3 phương diện, OVB, phân rã đóng góp, panel FE, dạng phản hồi, Unit Economics | Ch1 | 02_marketing: eda_descriptive, orders_contribution, panel_by_category, unit_economics
03 | 03_decomposition_seasonality.py | Ví dụ tay Ch2, MSTL, kiểm định hiệu ứng marketing, STL + HP, TMBL Việt Nam | Ch2 | 03_decomposition: mstl_components, adstock_scan, distributed_lag, gso_decomposition
04 | 04_feature_engineering.py | Khung đặc trưng toàn cục, đặc trưng khuyến mãi và lịch, kiểm tra rò rỉ | Ch3 | 04_features: feature_dictionary, leakage_test, calendar_2026_events
05 | 05_uplift_global_models.py | Ví dụ tay Ch3, sản phẩm mới, uplift S/T-learner, toàn cục vs cục bộ, cold-start, ngày đôi | Ch3 | 05_models: global_vs_local_100, promo_uplift_by_product, predictions_100
06 | 06_probabilistic_campaign.py | Ví dụ tay Ch4, 5 họ dự báo phân vị, Newsvendor, ROP, rủi ro quảng cáo, GMV Mega Sale, TMBL | Ch4 | 06_probabilistic: prob_eval_summary, newsvendor_policies, megasale_scenarios, gso_forecast
07 | 07_budget_allocation.py | Đường phản hồi, so sánh chính sách, quét trọng số, giá bóng, bootstrap | Ch5 | 07_budget: policy_comparison, weight_sweep, budget_levels
08 | 08_genai_decision_support.py | RAG, tác tử ReAct + LangGraph + pydantic, HITL, nhật ký kiểm toán | Ch5 | 08_genai: campaign_plans, audit_log.jsonl, agent_comparison
09 | 09_build_research_summary.py | Tổng hợp kết quả theo RQ1–RQ5 | – | 09_summary: research_summary.json, key_findings
10 | 10_pipeline_smoke_test.py | 24 kiểm tra đầu ra và ràng buộc phương pháp, dừng nếu thất bại | – | 10_smoke: smoke_test
11 | 11_forecast_diagnostics.py | Sai số theo chân trời, thứ, ngành, SKU, ngày đôi; phần dư mô hình chiến dịch | Ch3–Ch4 | 11_diagnostics: wape_by_*
12 | 12_case_studies.py | Hai ngày Mega Sale, FMCG lỗ, bẫy vốn lưu động, kế hoạch hàng một SKU | Ch1, Ch4, Ch5 | 12_cases: c1_mega_days, c3_cash_grid, c3_mega_increment
13 | 13_sensitivity_experiments.py | Độ nhạy giá vốn, tỷ trọng tối thiểu, ngưỡng HITL, siêu tham số, biên gộp | – | 13_sensitivity: s1–s5
14 | 14_build_report_ready.py | Gom hình, bảng, workbook Excel cho báo cáo | – | REPORT_READY/figures, tables, tables_all.xlsx
Nguồn: Mã nguồn project (README.md, các tệp 01–14_*.py).
]]

### 3.3.3. Thư viện mã nguồn dùng chung

Gói src/ gồm mười một mô-đun con. Mô-đun src/common.py khai báo đường dẫn, đọc cấu hình, đặt hạt giống ngẫu nhiên cho Python và NumPy, cung cấp các hàm ghi đọc JSON/CSV và lưu hình với một bảng màu thống nhất. Mô-đun src/data/io.py đọc mười hai tệp học phần và hai tệp Cục Thống kê, chuẩn hóa cột ngày, tạo các biến dẫn xuất (AOV, giá vốn, biên đóng góp, chỉ báo Mega Sale) và các biến lịch (Tết, ngày đôi, ngày 15, ngày 25, COVID). Mô-đun src/features/build.py xây dựng khung đặc trưng cho mô hình toàn cục. Mô-đun src/models/train.py chứa bộ so sánh mô hình toàn cục – cục bộ, mô hình phân vị và kiểm định Diebold–Mariano; src/models/macro.py chứa năm mô hình dự báo chuỗi tháng TMBL. Mô-đun src/evaluation/metrics.py chứa các thước đo điểm, thước đo xác suất và kiểm định. Mô-đun src/marketing/response.py chứa các mô hình phản hồi marketing (OLS, adstock, độ trễ phân phối, đường cong Hill, panel, bootstrap). Mô-đun src/scenarios/megasale.py chứa mô hình chiến dịch. Mô-đun src/inventory/policy.py chứa phân vị tới hạn, nội suy phân vị và hàm lợi nhuận Newsvendor. Mô-đun src/budget/allocate.py chứa bài toán phân bổ ngân sách. Mô-đun src/cashflow/sim.py chứa mô phỏng dòng tiền. Mô-đun src/genai/ gồm rag.py (truy xuất), agent.py (tác tử, lược đồ dữ liệu, đồ thị trạng thái, nhật ký kiểm toán) và assistant.py (lớp diễn giải tùy chọn bằng mô hình ngôn ngữ). Mô-đun src/export/report.py xuất báo cáo một trang dạng HTML và mẫu ra quyết định dạng Excel.

### 3.3.4. Cấu hình tập trung

{T:@config} trình bày các tham số chính trong config/default.yaml. Tất cả các ngưỡng mang tính chính sách (ngưỡng chiết khấu pháp lý, ngưỡng phê duyệt, tỷ trọng ngân sách tối thiểu, tham số dòng tiền) được đặt ở đây để người dùng doanh nghiệp có thể thay đổi mà không sửa mã nguồn, và để phân tích độ nhạy ở Stage 13 có thể thay đổi chúng một cách có hệ thống.

[[T:@config Các tham số chính của tệp cấu hình config/default.yaml
Nhóm | Tham số | Giá trị | Ý nghĩa
Chung | seed | 42 | Hạt giống ngẫu nhiên cho Python, NumPy, LightGBM, bootstrap
Lịch | tet; tet_window_days | 8 ngày mùng 1 Tết 2020–2027; 21 | Cửa sổ mua sắm trước Tết
Lịch | payday; mid_month | 25; 15 | Ngày lương và ngày giữa tháng
Lịch | covid_months | 2020-04; 2021-07; 2021-08; 2021-09 | Tháng giãn cách
Marketing | mega_discount_threshold | 0,5 | Ngày có chiết khấu ≥ 50% là ngày Mega Sale
Marketing | adstock_grid; max_lag | 0,0 – 0,9 bước 0,1; 14 | Lưới độ suy giảm adstock; độ trễ tối đa
Marketing | bootstrap | 2.000 | Số lần lấy mẫu lại cho rủi ro quảng cáo
Marketing | legal_max_discount; legal_max_discount_central | 0,5; 1,0 | Mức giảm giá tối đa theo NĐ 81/2018 sửa đổi bởi NĐ 128/2024
Mô hình toàn cục | horizon; n_origins; min_train_origin | 14; 3; 35 | Chân trời, số gốc kiểm định, gốc huấn luyện sớm nhất
Mô hình toàn cục | coldstart_holdout | 10 | Số SKU giữ lại cho thí nghiệm sản phẩm mới
Xác suất | quantiles | 0,1 – 0,9 bước 0,1 | Lưới 9 phân vị
Xác suất | deepar; deepar_max_steps | true; 500 | DeepAR (nếu có thư viện)
Ngân sách | levels; min_share | 50% – 150%; 10% | Mức ngân sách; tỷ trọng tối thiểu mỗi ngành
Dòng tiền | settlement_lag_days; lead_time_days; platform_fee | 0, 7, 10, 14; 7, 30; 0%, 10% | Lưới kịch bản dòng tiền
HITL | budget_quantile; discount_review; require_positive_cm | 0,95; 0,40; true | Ngưỡng chuyển người duyệt
GenAI | enabled; model | false; gpt-5-mini | Lớp diễn giải bằng LLM (mặc định tắt)
Nguồn: Tác giả, config/default.yaml.
]]

### 3.3.5. Kiểm thử và kiểm soát chất lượng

Chất lượng của pipeline được kiểm soát ở hai cấp. Ở cấp đơn vị, tệp tests/test_core.py chứa 11 kiểm thử chạy bằng pytest, kiểm tra các hàm lõi trên những trường hợp có đáp án biết trước: hàm pinball phải cho đúng các giá trị 18; 2; 45; 27; 0 của ví dụ trên slide Chương 4 (tr.40); hàm phân vị tới hạn phải cho đúng 0,5; 0,8; 0,3 của ba SKU ví dụ (tr.61); điểm Winkler của một quan sát nằm trong khoảng phải bằng độ rộng khoảng; adstock hình học của xung đơn vị phải là 1; 0,5; 0,25 với độ suy giảm 0,5; hàm lợi nhuận Newsvendor; nội suy phân vị có kẹp biên; bài toán phân bổ ngân sách phải dùng đúng tổng ngân sách, tôn trọng tỷ trọng tối thiểu và không cho lợi nhuận thấp hơn chia đều; mô phỏng dòng tiền phải cho nhu cầu tiền mặt tăng khi độ trễ đối soát tăng; và lược đồ dữ liệu phải chặn chi phí quảng cáo âm.

Ở cấp pipeline, Stage 10 chạy 24 kiểm tra trên đầu ra thật và dừng toàn bộ quy trình với mã lỗi nếu có kiểm tra thất bại. Các kiểm tra gồm: sự tồn tại của tệp kết quả của mọi stage; đặc trưng không rò rỉ thông tin tương lai; chênh lệch tổng tháng – số năm của Cục Thống kê dưới 5%; Unit Economics khớp số trên slide (FMCG lỗ lũy kế −78,44 triệu VNĐ); đồng nhất thức thiên lệch bỏ sót biến đúng đến 10^−6^; các ví dụ tay của Chương 2 và Chương 4 được tái lập đúng; phân vị sau sắp xếp đơn điệu; lợi nhuận của chính sách biết trước cầu (Oracle) là cận trên; mọi chính sách phân bổ dùng đúng tổng ngân sách; mọi đề xuất chiết khấu trên 50% không thuộc khuyến mại tập trung đều bị từ chối; không đề xuất nào có biên đóng góp âm hoặc nằm ngoài vùng dữ liệu được tự động phê duyệt; payload sai kiểu bị chặn; và điểm RAG 0,3979 trên slide được tái lập. Hai cấp kiểm tra này biến các cam kết phương pháp (không rò rỉ, không bịa số, tôn trọng pháp lý) thành điều kiện máy kiểm tra được.

### 3.3.6. Dashboard tương tác

Sản phẩm thứ hai của tiểu luận là dashboard "Mega Sale Marketing Intelligence" viết bằng Streamlit và Plotly (tệp app.py), gồm mười hai trang ({T:@dash}). Dashboard được khởi động bằng tệp OPEN_DASHBOARD.bat trên Windows (tự tạo môi trường ảo và cài thư viện nếu cần) hoặc lệnh streamlit run app.py. Các trang phân tích đọc trực tiếp các tệp trong outputs/. Bốn trang tương tác (Mô phỏng Mega Sale, Phân bổ ngân sách, Trung tâm quyết định AI, Dòng tiền chiến dịch) cho phép người dùng thay đổi đầu vào và gọi lại đúng các hàm của src/ trên dữ liệu gốc, nhờ đó con số hiển thị luôn nhất quán với pipeline. Trang Trung tâm quyết định AI cho phép người duyệt phê duyệt hoặc từ chối các đề xuất ở trạng thái chờ duyệt; mỗi quyết định được ghi kèm thời điểm và ghi chú vào tệp outputs/08_genai/hitl_decisions.csv, hiện thực hóa yêu cầu lưu vết của khung giám sát quyết định trên slide Chương 5 (Trần Duy Thanh, 2026a, Ch5 tr.59–63). Toàn bộ mười hai trang được kiểm tra tự động bằng công cụ AppTest của Streamlit để bảo đảm không trang nào phát sinh lỗi khi chạy.

[[T:@dash Mười hai trang của dashboard và nguồn dữ liệu
Trang | Nội dung | Nguồn | Tương tác
Tổng quan điều hành | 6 chỉ số chính, quy trình 14 bước, ROAS thực tế vs hòa vốn, phát hiện chính | 02, 09 | Không
01 Dữ liệu & chẩn đoán | Danh mục dữ liệu, kiểm tra chất lượng, làm sạch, đối chiếu Cục Thống kê | 01 | Không
02 Hiệu quả quảng cáo & khuyến mãi | EDA 90 ngày, OVB, phân rã đóng góp, panel, Unit Economics, độ nhạy CM | 02 | Chọn ngành
03 Chuỗi thời gian & mùa vụ | MSTL, kiểm định marketing, 48 tháng, biên lợi nhuận, TMBL | 03 | Không
04 Mô hình toàn cục & uplift | Toàn cục vs cục bộ, uplift sản phẩm, sản phẩm mới, ngày đôi | 05 | Không
05 Dự báo xác suất & rủi ro | Pinball, hiệu chỉnh, phễu bất định, fan chart SKU, Newsvendor, rủi ro quảng cáo | 06 | Chọn SKU, mô hình, ngành
06 Mô phỏng Mega Sale | Quảng cáo, chiết khấu, giả định giá vốn, phí sàn → GMV, CM, cảnh báo ngoại suy và pháp lý | src/scenarios | Có
07 Phân bổ ngân sách | Mức ngân sách, trọng số, tỷ trọng tối thiểu, vùng dữ liệu → phân bổ tối ưu | src/budget | Có
08 Trung tâm quyết định AI | Hàng đợi phê duyệt, gửi đề xuất mới cho tác tử, hỏi RAG, nhật ký kiểm toán | 08, src/genai | Có
09 Dòng tiền chiến dịch | Độ trễ đối soát, lead time, phí sàn → tiền mặt tối thiểu | src/cashflow | Có
10 Kết quả nghiên cứu | Tổng hợp RQ, 24 kiểm tra, chẩn đoán sai số, độ nhạy | 09–13 | Không
11 Xuất báo cáo | Workbook Excel, báo cáo 1 trang HTML, mẫu ra quyết định Excel | 14, src/export | Tải tệp
Nguồn: Tác giả, app.py.
]]

{F:dash00_tong_quan_dieu_hanh.png} là trang "Tổng quan điều hành" của dashboard trong lần chạy chính thức. Thanh bên trái liệt kê mười hai trang; phần chính gồm sáu thẻ chỉ số then chốt, sơ đồ quy trình mười bốn bước, biểu đồ ROAS thực tế so với ROAS hòa vốn của ba ngành và các thẻ phát hiện chính. Mọi con số trên trang được đọc từ outputs/ nên trùng khớp với các bảng của Chương 4; ảnh chụp các trang còn lại được đặt cạnh phần kết quả tương ứng ở Chương 4 và ở Phụ lục E.

[[FIG:dash00_tong_quan_dieu_hanh.png|Trang "Tổng quan điều hành" của dashboard Mega Sale Marketing Intelligence|Nguồn: Ảnh chụp màn hình dashboard của tác giả (app.py) đọc từ outputs/02_marketing và outputs/09_summary.]]

## 3.4. Phương pháp chẩn đoán dữ liệu marketing và mô hình kinh doanh

Mục này trình bày phương pháp của Stage 02, tương ứng với Chương 1 của học phần: chẩn đoán dữ liệu trước khi dự báo. Mục tiêu là trả lời RQ1: quảng cáo, chiết khấu và ngày Mega Sale đóng góp gì vào số đơn, GMV và lợi nhuận, và những sai lầm đo lường nào cần tránh.

### 3.4.1. Phân tích khám phá ba phương diện

Theo cách tiếp cận của slide (Trần Duy Thanh, 2026a, Ch1 tr.55–74), chuỗi 90 ngày được phân tích theo ba phương diện. Phương diện *động thái* xem xét GMV theo thời gian cùng trung bình trượt 7 ngày (SMA7) và đánh dấu hai ngày Mega Sale. Phương diện *phân phối* tính các thống kê mô tả của năm biến (GMV, số đơn, chi phí quảng cáo, chiết khấu, AOV): trung bình, trung vị, độ lệch chuẩn, cực trị, hệ số bất đối xứng Pearson thứ hai, hệ số bất đối xứng Fisher (mô-men bậc ba), độ nhọn dư và p-value của kiểm định Jarque–Bera (Jarque & Bera, 1980). Hai hệ số bất đối xứng được tính song song có chủ đích:

$ Skew~Pearson~ = 3 · (TB − Trung vị) / σ

$ Skew~Fisher~ = (1/n) · Σ (x~i~ − x̄)^3^ / σ^3^

Hệ số Pearson chỉ dựa vào khoảng cách giữa trung bình và trung vị nên gần như không nhạy với vài điểm cực trị, trong khi hệ số Fisher dựa trên lũy thừa bậc ba nên phản ứng mạnh với chúng. Sự chênh lệch giữa hai hệ số là chỉ báo nhanh về việc phân phối có "đuôi sự kiện" hay không. Phương diện *quan hệ* tính ma trận tương quan Pearson và Spearman giữa năm biến.

Để mô tả riêng ngày Mega Sale, Stage 02 so sánh giá trị trung bình của GMV, số đơn, quảng cáo và AOV giữa hai ngày Mega Sale với 88 ngày thường, và xây dựng cửa sổ sự kiện từ 7 ngày trước đến 7 ngày sau mỗi ngày Mega Sale, trong đó GMV mỗi ngày được chia cho GMV trung bình của ngày thường. Cửa sổ này dùng để kiểm tra hai giả thuyết hành vi thường được nhắc đến trong marketing khuyến mãi: khách hàng trì hoãn mua để chờ khuyến mãi (sụt trước sự kiện) và cầu bị kéo về hiện tại (sụt sau sự kiện) (van Heerde và cộng sự, 2000). Mùa vụ theo thứ được kiểm định bằng ANOVA một yếu tố, với và không có hai ngày Mega Sale.

### 3.4.2. Thiên lệch bỏ sót biến và phân rã đóng góp

Câu hỏi trung tâm của chẩn đoán marketing là: một triệu đồng quảng cáo tạo ra bao nhiêu đơn hàng? Slide Chương 1 cảnh báo rằng đọc hệ số này từ tương quan đơn biến là sai lầm nếu các ngày quảng cáo nhiều cũng là các ngày chiết khấu sâu (Trần Duy Thanh, 2026a, Ch1 tr.69–70). Stage 02 ước lượng năm đặc tả hồi quy OLS bằng thư viện statsmodels (Seabold & Perktold, 2010):

$ (1)  Orders~t~ = β~0~ + β~1~ · Ads~t~ + ε~t~

$ (2)  Orders~t~ = β~0~ + β~1~ · Ads~t~ + β~2~ · Disc~t~ + ε~t~

$ (3)  ln Orders~t~ = β~0~ + β~1~ · ln Ads~t~ + β~2~ · Disc~t~ + ε~t~

$ (4)  Orders~t~ = β~0~ + β~1~ · Ads~t~ + β~2~ · Disc~t~ + β~3~ · Mega~t~ + Σ~d~ γ~d~ · Thứ~d,t~ + ε~t~

$ (5)  GMV~t~ = β~0~ + β~1~ · Ads~t~ + β~2~ · Disc~t~ + β~3~ · Mega~t~ + ε~t~

Đặc tả (1) là đặc tả "ngây thơ". Đặc tả (2) kiểm soát chiết khấu. Đặc tả (3) cho hệ số β~1~ là độ co giãn của số đơn theo quảng cáo. Đặc tả (4) bổ sung biến chỉ báo Mega Sale và hiệu ứng thứ trong tuần. Đặc tả (5) đổi biến phụ thuộc thành GMV, khi đó β~1~ là ROAS biên: GMV tăng thêm trên một triệu đồng quảng cáo khi giữ nguyên chiết khấu và loại ngày. Thiên lệch bỏ sót biến (omitted variable bias, OVB) được kiểm chứng bằng đồng nhất thức đại số chính xác của OLS:

$ β̂~1~^(1)^ = β̂~1~^(2)^ + β̂~2~^(2)^ · δ̂,  δ̂ = Cov(Ads, Disc) / Var(Ads)

Stage 10 kiểm tra đồng nhất thức này đúng đến 10^−6^, bảo đảm rằng chênh lệch giữa hai hệ số được giải thích hoàn toàn bởi tương quan giữa quảng cáo và chiết khấu chứ không phải lỗi tính toán. Mức thiên lệch tương đối được tính bằng (β̂~1~^(1)^ − β̂~1~^(2)^)/β̂~1~^(2)^. Các chẩn đoán đi kèm gồm hệ số phóng đại phương sai (VIF) của Ads và Discount và kiểm định Breusch–Pagan về phương sai sai số thay đổi trên phần dư của đặc tả (1) (Breusch & Pagan, 1979). Sai số chuẩn báo cáo cho năm đặc tả là sai số chuẩn OLS thông thường; mô-đun src/marketing/response.py có sẵn hàm ước lượng với sai số chuẩn vững HC3 cho các phân tích mở rộng.

Từ đặc tả (2), số đơn mỗi ngày được phân rã thành bốn phần: phần nền (hằng số β̂~0~), phần quảng cáo β̂~1~ · Ads~t~, phần chiết khấu β̂~2~ · Disc~t~ và phần dư. Tỷ trọng mỗi phần trong tổng số đơn 90 ngày cho biết, theo mô hình tuyến tính, quảng cáo và chiết khấu "giải thích" bao nhiêu phần trăm số đơn. Cần lưu ý rằng đóng góp được tính so với mức 0 của từng biến, nên phần nền có thể âm khi mô hình tuyến tính ngoại suy về vùng không quảng cáo và không chiết khấu, một vùng không có trong dữ liệu.

### 3.4.3. Panel ba ngành và các dạng đường phản hồi

Với panel ba ngành × 30 ngày, Stage 02 ước lượng ba mô hình:

$ Gộp: Orders~it~ = α + β · Ads~it~ + ε~it~

$ Hiệu ứng cố định ngành: Orders~it~ = α~i~ + β · Ads~it~ + ε~it~

$ Độ dốc khác nhau: Orders~it~ = α~i~ + β~i~ · Ads~it~ + ε~it~

Mô hình gộp bỏ qua sự khác biệt về quy mô đơn giữa các ngành (FMCG bán nhiều đơn giá trị thấp, Điện tử bán ít đơn giá trị cao), nên hệ số β bị trộn giữa khác biệt trong ngành và khác biệt giữa ngành, một dạng của nghịch lý Simpson (Simpson, 1951). Mô hình hiệu ứng cố định loại bỏ khác biệt mức giữa ngành (Wooldridge, 2010). Kiểm định F so sánh mô hình độ dốc khác nhau với mô hình hiệu ứng cố định trả lời câu hỏi: hiệu quả quảng cáo có đồng nhất giữa các ngành không. Ngoài ra, mỗi ngành được hồi quy riêng số đơn theo quảng cáo (và GMV theo quảng cáo), và hồi quy log–log để có độ co giãn.

Vì bài toán phân bổ ngân sách ở Stage 07 cần một đường phản hồi có lợi suất giảm dần, Stage 02 so sánh ba dạng hàm cho từng ngành bằng R² và tiêu chí AIC: tuyến tính, logarit và Hill (bão hòa dạng chữ S thường dùng trong mô hình marketing mix; Jin và cộng sự, 2017):

$ Hill: Orders(a) = c + V~max~ · a^s^ / (k^s^ + a^s^)

Hàm Hill được ước lượng bằng bình phương tối thiểu phi tuyến có ràng buộc (scipy.optimize.curve_fit, s trong khoảng 0,3–5). Với chỉ 30 quan sát mỗi ngành, dạng bốn tham số dễ quá khớp; dạng logarit hai tham số được chọn cho Stage 07 vì vừa thể hiện lợi suất giảm dần vừa ổn định (mục 3.8.1).

Ngụy biện tổng gộp được minh họa bằng cách chia 30 ngày thành nửa đầu (15 ngày đầu) và nửa sau, tính tăng trưởng GMV của từng ngành và của tổng gộp. Khi các ngành có quy mô rất khác nhau, tăng trưởng tổng có thể ngược dấu với tăng trưởng của đa số ngành.

### 3.4.4. Unit Economics và lợi nhuận biên của quảng cáo

Unit Economics được tính theo đúng định nghĩa của slide (Trần Duy Thanh, 2026a, Ch1 tr.109–129). Với mỗi ngành, các chỉ số được tính trên tổng lượng của các ngày có hoạt động:

$ AOV = GMV / Đơn,  CAC = Quảng cáo / Đơn,  ROAS = GMV / Quảng cáo

$ CM = AOV − (CAC + COGS/đơn)

$ ROAS~hòa vốn~ = AOV / (AOV − COGS/đơn),  CAC~tối đa~ = AOV − COGS/đơn

ROAS hòa vốn là mức ROAS tối thiểu để biên đóng góp không âm; một ngành có ROAS thực tế thấp hơn ROAS hòa vốn đang lỗ trên mỗi đơn dù doanh thu cao. Stage 02 còn tính tỷ lệ ngày lỗ (ngày có GMV − giá vốn − quảng cáo < 0) và một lưới độ nhạy của CM theo mức tăng AOV (0%, 10%, 20%, 30%, 50%, đại diện cho chiến lược bán combo) và mức giảm giá vốn (0%, 10%, 20%), giữ nguyên CAC.

Để nối chẩn đoán với quyết định ngân sách, lợi nhuận biên của một triệu đồng quảng cáo ở mỗi ngành được tính bằng:

$ LN biên = β~ngành~ · (AOV − COGS/đơn) − 1

trong đó β~ngành~ là độ dốc số đơn theo quảng cáo từ panel và (AOV − COGS/đơn) là biên gộp mỗi đơn từ Unit Economics. Nếu LN biên âm, mỗi triệu đồng quảng cáo thêm làm giảm lợi nhuận. Cần nói rõ rằng hai đại lượng đến từ hai tệp khác nhau (panel và unit_economics), có AOV không hoàn toàn trùng nhau; tiểu luận dùng AOV và giá vốn của tệp unit_economics vì đây là tệp duy nhất có giá vốn.

## 3.5. Phương pháp phân rã chuỗi thời gian và kiểm định hiệu ứng marketing

Mục này trình bày phương pháp của Stage 03, tương ứng với Chương 2 của học phần, nhằm trả lời RQ2.

### 3.5.1. Kiểm chứng các ví dụ tính tay của slide

Trước khi áp dụng các thuật toán phân rã trên dữ liệu, Stage 03 tái lập bằng mã nguồn mọi ví dụ tính tay của Chương 2: phần dư của mô hình cộng và mô hình nhân (tr.8–11), trung bình trượt cổ điển và trung bình trượt kháng nhiễu với trọng số bisquare cho cửa sổ lẻ và chẵn (tr.18–42), thuật toán backfitting tách hai sóng mùa vụ chu kỳ 2 và 3, hai ví dụ GAM với biến sự kiện khuyến mãi và biến sự kiện bất lợi (tr.66–89), ví dụ Prophet năm ngày với biến ngày lễ "mega_sale" (tr.75–79) và ví dụ khử mùa vụ nhân (tr.96–97). Mục đích là bảo đảm rằng mã nguồn hiểu các khái niệm đúng như slide trước khi dùng chúng trên dữ liệu lớn hơn. Trọng số bisquare trong trung bình trượt kháng nhiễu được tính theo:

$ u~i~ = |x~i~ − median(x)| / (6 · MAD),  w~i~ = (1 − u~i~^2^)^2^ nếu u~i~ < 1, ngược lại 0

### 3.5.2. MSTL cho chuỗi doanh thu ngày đa mùa vụ

Chuỗi doanh thu chuẩn hóa 1.095 ngày (2021–2023) được phân rã bằng MSTL (Bandara và cộng sự, 2021) với hai chu kỳ 7 và 365 ngày:

$ Y~t~ = T~t~ + S~t~^(7)^ + S~t~^(365)^ + R~t~

Xu hướng được làm trơn thêm bằng bộ lọc Hodrick–Prescott với λ = 10^8^ cho dữ liệu ngày (Hodrick & Prescott, 1997; Ravn & Uhlig, 2002). Độ mạnh của từng thành phần mùa vụ được đo theo Wang, Smith và Hyndman (2006):

$ F~S~ = max(0; 1 − Var(R~t~) / Var(S~t~ + R~t~))

Ngoài phương sai của từng thành phần, Stage 03 tính trung bình S^(7)^ theo thứ và S^(365)^ theo tháng để mô tả mùa vụ tuần và năm.

### 3.5.3. Kiểm định hiệu ứng chi phí marketing sau khi khử mùa vụ

Đây là phần mở rộng của tiểu luận so với slide. Chuỗi đa mùa vụ có biến chi phí marketing hằng ngày, và câu hỏi tự nhiên là chi phí này có giải thích được biến động doanh thu không. Nếu chỉ tính tương quan thô giữa doanh thu và chi phí marketing, mùa vụ có thể che khuất hoặc tạo ra quan hệ giả. Vì vậy, Stage 03 kiểm định trên chuỗi đã khử mùa vụ D~t~ = Y~t~ − S~t~^(7)^ − S~t~^(365)^ bằng bốn cách.

Cách thứ nhất là tương quan giữa chi phí marketing với chuỗi thô, chuỗi khử mùa vụ và phần dư MSTL, cùng tương quan chéo với độ trễ 0–14 ngày. Cách thứ hai là mô hình adstock hình học (Broadbent, 1979):

$ A~t~(λ) = x~t~ + λ · A~t−1~(λ),  D~t~ = β~0~ + β · A~t~(λ) + u~t~

với λ quét trên lưới 0,0; 0,1; …; 0,9. Mỗi giá trị λ cho một hồi quy OLS; λ tốt nhất được chọn theo AIC, và p-value nhỏ nhất trên lưới được báo cáo như một chỉ báo thận trọng (nếu ngay cả p nhỏ nhất cũng không có ý nghĩa thì không có bằng chứng về hiệu ứng). Cách thứ ba là mô hình độ trễ phân phối không ràng buộc:

$ D~t~ = β~0~ + Σ~k=0..14~ β~k~ · x~t−k~ + u~t~

ước lượng với sai số chuẩn HAC Newey–West độ trễ 7 (Newey & West, 1987) và kiểm định F đồng thời H~0~: β~0~ = … = β~14~ = 0. Cách thứ tư là so sánh Prophet (Taylor & Letham, 2018) có và không có biến hồi quy marketing bằng kiểm định chéo theo thời gian: khởi tạo 730 ngày, bước 60 ngày, chân trời 30 ngày (sáu gốc), độ linh hoạt điểm gãy 0,05, mùa vụ năm và tuần.

Một kết quả "không có ý nghĩa" chỉ có giá trị nếu quy trình đủ nhạy để phát hiện hiệu ứng khi hiệu ứng tồn tại. Vì vậy, Stage 03 bổ sung kiểm tra khả năng phát hiện: cấy một hiệu ứng adstock giả định β · A~t~(0,5) với β ∈ {0,02; 0,05; 0,1; 0,2; 0,5} vào chính chuỗi thật đã khử mùa vụ (giữ nguyên nhiễu thật), rồi ước lượng lại β và p-value. Ngưỡng β nhỏ nhất mà quy trình phát hiện được cho biết quy mô hiệu ứng mà dữ liệu có thể loại trừ.

### 3.5.4. STL và bộ lọc HP cho chuỗi tháng của doanh nghiệp

Chuỗi GMV 48 tháng chỉ có số thứ tự tháng (1–48); để dùng các hàm chuỗi thời gian, Stage 03 gán nhãn tháng quy ước từ 01/2022, nhãn này không mang ý nghĩa lịch. Chuỗi được phân rã bằng STL (Cleveland và cộng sự, 1990) với chu kỳ 12. Khối xu hướng – chu kỳ của STL tiếp tục được tách bằng bộ lọc HP với λ = 14.400 cho dữ liệu tháng thành xu hướng T và chu kỳ C:

$ min~T~ Σ (y~t~ − T~t~)^2^ + λ · Σ [(T~t+1~ − T~t~) − (T~t~ − T~t−1~)]^2^

Tiểu luận lưu ý phê phán của Hamilton (2018) về bộ lọc HP (chu kỳ giả ở hai đầu chuỗi, phụ thuộc λ), nên chu kỳ được diễn giải thận trọng như một mô tả chứ không phải một dự báo. Để chọn giữa STL thường và STL kháng nhiễu, Stage 03 chạy lưới độ nhạy hai lựa chọn kháng nhiễu × ba độ dài cửa sổ mùa vụ (7, 13, 25) và so sánh độ lệch chuẩn phần dư, biên độ mùa vụ, biên độ chu kỳ và F~S~. Hệ số mùa vụ nhân lấy từ STL trên log GMV; chuỗi khử mùa vụ bằng GMV chia hệ số mùa vụ nhân. Tăng trưởng tháng thô và tăng trưởng "lõi" (trên chuỗi khử mùa vụ) được so sánh về dấu và tương quan. Tăng trưởng kép theo năm được tính bằng:

$ CAGR = (Σ Y~tháng 37–48~ / Σ Y~tháng 1–12~)^1/3^ − 1

Chuỗi biên lợi nhuận ròng 72 tháng (2020–2025) được phân rã bằng STL thường và STL kháng nhiễu cùng bộ lọc HP; các tháng có trọng số kháng nhiễu dưới 0,5 được liệt kê như các tháng bất thường.

### 3.5.5. Phân rã Tổng mức bán lẻ Việt Nam

Chuỗi TMBL 82 tháng được phân rã bằng STL kháng nhiễu trên log (chu kỳ 12, cửa sổ mùa vụ 13), nên hệ số mùa vụ có dạng nhân. Song song, Stage 03 ước lượng một hồi quy đặc tả trên log TMBL với sai số chuẩn HAC độ trễ 3:

$ ln TMBL~t~ = β~0~ + β~1~ · t + β~2~ · max(0; t − t~10/2021~) + Σ~m=2..12~ γ~m~ · Tháng~m,t~ + θ · Tết~t~ + φ · COVID~t~ + ε~t~

trong đó số hạng thứ ba cho phép độ dốc xu hướng thay đổi sau khi kết thúc giãn cách (từ 10/2021). Tác động phần trăm của Tết và giãn cách được tính bằng exp(hệ số) − 1. Phần mở rộng quan trọng cho đề tài là *độ trôi của hệ số mùa vụ*: vì STL cho phép mùa vụ thay đổi chậm theo năm, hệ số mùa vụ của tháng 1, 11 và 12 được trích theo từng năm. Nếu các chiến dịch ngày đôi cuối năm làm thay đổi đáng kể hành vi tiêu dùng của cả nước, hệ số mùa vụ tháng 11 và 12 sẽ có xu hướng tăng theo thời gian. Bổ sung, Stage 03 tính tỷ trọng quý IV trong TMBL từng năm 2020–2025.

## 3.6. Phương pháp học máy toàn cục và ước lượng uplift khuyến mãi

Mục này trình bày phương pháp của Stage 04 và Stage 05, tương ứng với Chương 3 của học phần (học máy cho dự báo quy mô lớn), nhằm trả lời RQ3.

### 3.6.1. Tabular hóa chuỗi thời gian và đặc trưng chuẩn hóa quy mô

Mô hình học máy dạng cây không đọc trực tiếp chuỗi thời gian mà cần dữ liệu dạng bảng, mỗi dòng là một mẫu và các cột là đặc trưng (Trần Duy Thanh, 2026a, Ch3 tr.6–27). Hàm make_frame trong src/features/build.py tabular hóa ma trận cầu (ngày × SKU) theo thiết kế *trực tiếp nhiều chân trời* (direct multi-horizon): với mỗi gốc dự báo T và mỗi chân trời h = 1, …, 14, mỗi SKU sinh một dòng với mục tiêu là cầu của ngày T + h, và mọi đặc trưng chỉ được tính từ thông tin đến ngày T. Thiết kế trực tiếp tránh hiện tượng tích lũy sai số của dự báo đệ quy mà slide minh họa (một mô hình hồi quy trên độ trễ 1 với hệ số lớn hơn 1 cho dự báo phân kỳ sau vài bước).

Đặc trưng then chốt là *chuẩn hóa quy mô*: mọi đặc trưng động và cả mục tiêu đều được chia cho m28, trung bình 28 ngày gần nhất của chính SKU đó (Trần Duy Thanh, 2026a, Ch3 tr.69–72):

$ y~r~ = y~T+h~ / m28~T~,  ŷ~T+h~ = f̂(x~r~) · m28~T~

Nhờ chuẩn hóa, một mô hình duy nhất có thể học chung hình dạng biến động của các SKU có quy mô chênh lệch hàng chục lần (điện thoại vài chục đơn vị/ngày, cáp sạc vài trăm đơn vị/ngày), đúng tinh thần của mô hình toàn cục (Montero-Manso & Hyndman, 2021). Từ điển đặc trưng được trình bày ở {T:feat_dict}. Ngoài các đặc trưng trễ, cửa sổ và xu hướng, tiểu luận bổ sung ba đặc trưng lịch gắn với khuyến mãi của sàn TMĐT: ngày đôi (ngày bằng tháng, ví dụ 9.9, 11.11), ngày 15 và ngày 25 (ngày lương phổ biến). Ba đặc trưng tĩnh (ngành hàng, log giá, biên gộp) cho phép mô hình dự báo cả SKU chưa có lịch sử.

[[TAB:feat_dict]]

Với 100 SKU, 150 ngày, gốc huấn luyện sớm nhất là ngày thứ 36 (chỉ số 35, để có đủ 28 ngày lịch sử và đặc trưng cùng thứ 4 tuần) và chân trời 14, khung đặc trưng đầy đủ có 150.500 dòng ứng với 114 gốc. Stage 04 kiểm tra rò rỉ thông tin bằng một thí nghiệm phá hủy: tại gốc 31/07/2026, mọi giá trị cầu sau gốc được thay bằng giá trị vô nghĩa (nhân 10 rồi cộng 999), rồi tính lại đặc trưng. Nếu bất kỳ đặc trưng nào dùng thông tin tương lai, nó sẽ thay đổi. Kết quả chênh lệch tuyệt đối lớn nhất giữa hai lần tính là 4,4 × 10^−16^, tức bằng sai số làm tròn của số thực dấu phẩy động, xác nhận không có rò rỉ.

### 3.6.2. Thiết kế đánh giá walk-forward

Mọi so sánh mô hình dự báo cầu dùng kiểm định cuốn chiếu theo thời gian (walk-forward), không dùng K-Fold xáo trộn (Bergmeir & Benítez, 2012; Trần Duy Thanh, 2026a, Ch3 tr.82–91). {T:@wf} trình bày thiết kế. Với 100 SKU, ba gốc kiểm định là 17/07, 31/07 và 14/08/2026, cách nhau đúng 14 ngày để ba cửa sổ kiểm định không chồng lấn và phủ 42 ngày cuối của dữ liệu. Tại mỗi gốc T~0~, mô hình chỉ được huấn luyện trên các gốc T ≤ T~0~ − 14, sao cho mọi mục tiêu huấn luyện đều thuộc quá khứ của T~0~. Số dòng huấn luyện tăng dần theo gốc: 82.600, 102.200 và 121.800 dòng.

[[T:@wf Thiết kế đánh giá walk-forward của các thí nghiệm dự báo
Thí nghiệm | Dữ liệu | Gốc kiểm định | Chân trời | Huấn luyện
Toàn cục vs cục bộ | 100 SKU × 150 ngày | 17/07, 31/07, 14/08/2026 | 1–14 ngày | Các gốc từ ngày thứ 36 đến T~0~ − 14
Toàn cục vs cục bộ | 15 SKU × 240 ngày | 4 gốc cách nhau 14 ngày, gốc cuối = ngày cuối − 14 | 1–14 ngày | Như trên
Cold-start | 90 SKU huấn luyện, 10 SKU giữ lại | 14/08/2026 | 1–14 ngày | Chỉ 90 SKU
Uplift khuyến mãi | complex_retail 300 dòng | TimeSeriesSplit 3 lần chia | Cửa sổ kế tiếp | Mở rộng dần
Dự báo phân vị | 100 SKU | 3 gốc như trên | 1–14 ngày | Như trên; sai số nội bộ ở 3 gốc trước mỗi gốc
TMBL Việt Nam | 82 tháng | 9/2024 và 9/2025 | 1–12 tháng | Dữ liệu đến hết tháng gốc
Nguồn: Tác giả, mã nguồn Stage 05, 06.
]]

### 3.6.3. Các mô hình được so sánh

Sáu mô hình được so sánh trên cùng các gốc. Hai mô hình chuẩn đơn giản là *naive mùa vụ 7 ngày* (cầu của ngày cùng thứ gần nhất) và *trung bình cùng thứ 4 tuần*. Mô hình thống kê cục bộ là *Holt-Winters* với xu hướng cộng tắt dần và mùa vụ cộng chu kỳ 7, ước lượng riêng cho từng SKU (Hyndman và cộng sự, 2002); nếu tối ưu không hội tụ, mô hình lùi về trung bình 7 ngày. Mô hình học máy cục bộ là *LightGBM cục bộ*: mỗi SKU một mô hình, dùng các đặc trưng động chuẩn hóa và đặc trưng lịch, với 7 lá, tối thiểu 10 mẫu mỗi lá và 150 vòng tăng cường. Hai mô hình toàn cục là *LightGBM toàn cục trên mục tiêu thô* (đặc trưng và mục tiêu chưa chuẩn hóa) và *LightGBM toàn cục trên mục tiêu chuẩn hóa*. So sánh hai mô hình toàn cục cho biết lợi ích riêng của chuẩn hóa quy mô; so sánh toàn cục với cục bộ cho biết lợi ích của việc học chung. Tham số LightGBM (Ke và cộng sự, 2017) được trình bày ở {T:@lgbm}.

[[T:@lgbm Tham số LightGBM của mô hình toàn cục
Tham số | Giá trị | Ghi chú
objective | l2 (điểm); quantile với α = q (phân vị) | –
learning_rate | 0,05 | config: global_models.lgbm
num_leaves | 31 | Độ nhạy 7–63 ở Stage 13
min_data_in_leaf | 40 | Độ nhạy 20–100 ở Stage 13
feature_fraction; bagging_fraction; bagging_freq | 0,9; 0,9; 1 | Chống quá khớp
lambda_l2 | 1,0 | Điều chuẩn L2
num_boost_round | 400 | Cố định, không dừng sớm
seed; deterministic; num_threads | 42; true; 2 | Bảo đảm tái lập
categorical_feature | cat_code | Ngành hàng
Nguồn: src/models/train.py, config/default.yaml.
]]

Thời gian huấn luyện được ghi nhận như một tiêu chí vận hành. Ở gốc cuối, mô hình toàn cục chuẩn hóa huấn luyện trong khoảng 2,2 giây cho cả 100 SKU, trong khi 100 mô hình LightGBM cục bộ mất khoảng 4,2 giây và 100 mô hình Holt-Winters mất khoảng 11,3 giây.

Bộ thí nghiệm được lặp lại trên bộ 15 SKU × 240 ngày với bốn gốc. Bộ dữ liệu này không có thông tin giá nên log giá và biên gộp được đặt bằng 0; mục đích là kiểm tra xem lợi thế của mô hình toàn cục có còn khi số chuỗi ít.

### 3.6.4. Sản phẩm mới: cold-start và warm-start

Để mô phỏng tình huống ra mắt sản phẩm mới cho chiến dịch, Stage 05 chọn ngẫu nhiên (hạt giống 42) 10 SKU và loại hoàn toàn khỏi huấn luyện. Bốn phương án dự báo 14 ngày tại gốc cuối được so sánh. Phương án *cold-start thuần* huấn luyện LightGBM trên mức tuyệt đối với chỉ các đặc trưng tĩnh và lịch (chân trời, thứ, ngành, log giá, biên gộp, ngày đôi, ngày 25, ngày 15). Phương án *trung bình ngành × thứ* dùng cầu trung bình của các SKU cùng ngành vào cùng thứ. Phương án *warm-start 7 ngày* giả định sản phẩm đã bán được 7 ngày: đặc trưng chuẩn hóa được tính trên 7 ngày đó (m28 thay bằng trung bình 7 ngày, độ dốc bằng 0) và đưa vào mô hình toàn cục đã huấn luyện trên 90 SKU. Phương án *đủ lịch sử* dùng đầy đủ đặc trưng của SKU (cận trên). Ví dụ tay về Gradient Boosting cho sản phẩm mới trên slide (Trần Duy Thanh, 2026a, Ch3 tr.45–50) và bài toán sản phẩm mới có khuyến mãi trên tệp raw_sales_data (tr.73–76) được tái lập trước: mô hình Gradient Boosting 50 cây trên số thô được so với phương án học tỷ lệ uplift rồi nhân ngược với mức nền khai báo 500.

### 3.6.5. Ước lượng uplift khuyến mãi theo sản phẩm

Tệp complex_retail_sales có năm sản phẩm, 60 ngày, với biến cuối tuần, biến khuyến mãi và mức nền. Slide mô tả cơ chế sinh dữ liệu: mỗi sản phẩm có hệ số nhân cuối tuần và hệ số nhân khuyến mãi riêng (Trần Duy Thanh, 2026a, Ch3 tr.87). Đây là cơ hội hiếm để kiểm tra xem phương pháp có khôi phục đúng hệ số đã biết hay không. Stage 05 so sánh bốn cách ước lượng hệ số nhân khuyến mãi của từng sản phẩm. Cách *quan sát* lấy tỷ số giữa doanh số trung bình ngày thường có khuyến mãi và ngày thường không khuyến mãi, kèm khoảng tin cậy 95% theo phân phối t. Cách *S-learner* (Künzel và cộng sự, 2019) huấn luyện một mô hình Gradient Boosting toàn cục (100 cây, độ sâu 4) trên ba biến cuối tuần, khuyến mãi, mức nền, rồi tính tỷ số dự báo khi bật và tắt khuyến mãi cho từng sản phẩm:

$ Uplift~S~(i) = f̂(cuối tuần = 0; KM = 1; nền~i~) / f̂(cuối tuần = 0; KM = 0; nền~i~)

Cách *T-learner cục bộ* hồi quy log doanh số theo cuối tuần và khuyến mãi riêng cho từng sản phẩm, uplift bằng exp của hệ số khuyến mãi. Cách *uplift gộp* dùng một con số chung cho mọi sản phẩm, đại diện cho thực hành phổ biến "khuyến mãi tăng doanh số X%". Cũng trên tệp này, Stage 05 tái lập so sánh của slide giữa walk-forward (TimeSeriesSplit ba lần chia) và K-Fold xáo trộn ba lần chia để định lượng mức lạc quan do rò rỉ thời gian.

### 3.6.6. Kiểm định "hiệu ứng ngày đôi"

Một giả thuyết phổ biến trong TMĐT là cầu tăng vọt vào các ngày đôi. Stage 05 kiểm định giả thuyết này trên dữ liệu 100 SKU theo hai cách và so sánh kết quả. Cách thứ nhất là so sánh thô: cầu mỗi ngày chia cho trung bình trượt 7 ngày căn giữa của chính SKU, rồi so sánh tỷ số này giữa ngày đôi và ngày khác bằng kiểm định t Welch. Cách thứ hai là hồi quy hiệu ứng cố định trên log cầu:

$ ln y~it~ = α~i~ + Σ~d~ γ~d~ · Thứ~d,t~ + δ~i~ · t + β~1~ · NgàyĐôi~t~ + β~2~ · Ngày25~t~ + β~3~ · Ngày15~t~ + ε~it~

với hiệu ứng cố định SKU, hiệu ứng thứ, xu hướng riêng từng SKU và sai số chuẩn cụm theo ngày (vì mọi SKU cùng ngày chịu chung cú sốc). Hồi quy được ước lượng cho toàn bộ và cho từng ngành. Nếu so sánh thô cho kết quả có ý nghĩa nhưng hồi quy có kiểm soát thì không, "hiệu ứng ngày đôi" chỉ là hiệu ứng thứ trong tuần bị gán nhầm, vì phần lớn ngày đôi trong cửa sổ dữ liệu rơi vào thứ Bảy.

### 3.6.7. Chẩn đoán sai số

Stage 11 phân tích sai số của dự báo trên 4.200 điểm kiểm định (100 SKU × 14 ngày × 3 gốc) theo bốn chiều: chân trời h, thứ trong tuần, ngành và ngày đôi; tính WAPE theo từng SKU và tương quan giữa WAPE với hệ số biến thiên của chuỗi; và phân tích phần dư của mô hình chiến dịch (mục 3.7.4) theo loại ngày (thường/cuối tuần/Mega Sale).

## 3.7. Phương pháp dự báo xác suất và đánh giá rủi ro chiến dịch

Mục này trình bày phương pháp của Stage 06, tương ứng với Chương 4 của học phần, nhằm trả lời RQ4: dự báo xác suất cải thiện quyết định chuẩn bị hàng và đánh giá rủi ro tài chính của chiến dịch đến đâu.

### 3.7.1. Năm họ dự báo phân vị

Stage 06 xây dựng dự báo cho lưới chín phân vị q ∈ {0,1; 0,2; …; 0,9} của cầu 100 SKU tại ba gốc walk-forward, theo năm họ phương pháp. Ví dụ tính tay của slide về Z-score (tr.10–20), quantile loss (tr.36–41) và Newsvendor (tr.56–65) được tái lập trước.

Họ thứ nhất là **Z-chuẩn**, theo đúng cách làm của slide: dự báo điểm cộng sai lệch trung bình (bias) và z-score nhân độ lệch chuẩn sai số:

$ P~q~ = ŷ + bias + z~q~ · σ~e~

Dự báo điểm ŷ là LightGBM toàn cục chuẩn hóa. Bias và σ~e~ được ước lượng riêng cho từng SKU từ sai số *kiểm định nội bộ*: tại mỗi gốc T~0~, ba mô hình phụ được huấn luyện ở ba gốc trước đó T~0~ − 14, T~0~ − 28, T~0~ − 42, mỗi mô hình chỉ dùng dữ liệu đến gốc của nó, và sai số của chúng trên 14 ngày kế tiếp tạo thành tập sai số nội bộ. Cách làm này bảo đảm thông tin dùng để hiệu chỉnh khoảng dự báo hoàn toàn thuộc quá khứ của gốc kiểm định.

Họ thứ hai là **phân vị phần dư thực nghiệm**: thay vì giả định sai số chuẩn, lấy trực tiếp phân vị thực nghiệm của sai số chuẩn hóa (e/m28) trong tập sai số nội bộ, tách theo chân trời h, rồi nhân ngược với m28:

$ P~q~ = ŷ + Q~q~(e/m28 ∣ h) · m28

Đây là một phiên bản gần với hiệu chỉnh conformal theo chân trời (Romano và cộng sự, 2019), không giả định dạng phân phối và tự động nới rộng theo chân trời nếu sai số xa hơn lớn hơn.

Họ thứ ba là **Quantile LightGBM toàn cục**: chín mô hình LightGBM với hàm mục tiêu phân vị (Koenker & Bassett, 1978), mỗi mô hình một mức q, cùng đặc trưng và mục tiêu chuẩn hóa như mô hình điểm, 400 vòng tăng cường. Vì chín mô hình được huấn luyện độc lập, phân vị dự báo có thể "giao cắt" (P~0,6~ < P~0,5~); Stage 06 ghi nhận tỷ lệ dòng có giao cắt trước khi sắp xếp lại các phân vị theo thứ tự tăng dần.

Họ thứ tư là **DeepAR** (Salinas và cộng sự, 2020) qua thư viện NeuralForecast, với phân phối Student-t, độ dài đầu vào 28 ngày, lớp LSTM 64 đơn vị, chuẩn hóa robust, 500 bước tối ưu và hạt giống 42; khoảng dự báo ở các mức 20%, 40%, 60%, 80% được quy đổi thành chín phân vị. DeepAR được đánh giá qua cùng ba cửa sổ walk-forward (cross_validation với ba cửa sổ, bước 14 ngày), và Stage 06 kiểm tra rằng ngày cắt của từng cửa sổ trùng khớp với ba gốc kiểm định.

Họ thứ năm là **heuristic của mã minh họa học phần**. Tệp ai_train_reorder_point.py của case study Chương 4 sinh dải dự báo bằng một quy tắc cố định: lấy dự báo P50 của mạng LSTM đa phân vị, kẹp trong khoảng ±20% trung bình lịch sử, nhân 1,3 vào cuối tuần, rồi tạo dải bất định với độ lệch chuẩn bằng 15% trung bình P50 nhân √t (t là chân trời). Stage 06 tái lập đúng quy tắc này, trong đó P50 lấy từ một mô hình LSTM với hàm mất mát đa phân vị huấn luyện qua NeuralForecast (150 bước), để đánh giá nó như một họ dự báo ngang hàng với các họ khác.

Nếu thư viện NeuralForecast không có trong môi trường chạy, Stage 06 dùng kết quả kiểm định chéo đã lưu trong data/interim/cache/ của lần chạy chính thức; nếu cả bộ nhớ đệm cũng không có, hai họ DeepAR và heuristic được bỏ qua và mọi so sánh tự động thu hẹp về ba họ còn lại.

### 3.7.2. Đánh giá dự báo xác suất

Năm họ được đánh giá trên 4.200 điểm (100 SKU × 14 ngày × 3 gốc) bằng các thước đo nêu ở mục 3.10: pinball trung bình trên chín phân vị và tại các mức 0,1; 0,5; 0,9; độ phủ của khoảng P10–P90 (danh nghĩa 80%); độ rộng tương đối của khoảng so với cầu trung bình; điểm Winkler của khoảng 80%; MAE của P50; đường hiệu chỉnh (tỷ lệ cầu thực tế nhỏ hơn hoặc bằng P~q~ ở mỗi q); phễu bất định (độ rộng khoảng chuẩn hóa theo m28 tại từng chân trời); và các thước đo này theo ngành. Khác biệt pinball giữa các cặp họ được kiểm định bằng Diebold–Mariano.

### 3.7.3. Chuẩn bị hàng theo Newsvendor và điểm đặt hàng lại

Với mỗi SKU, phân vị tới hạn được tính từ giá bán p, giá vốn c và giá thanh lý s (Arrow và cộng sự, 1951; Khouja, 1999):

$ q^*^ = C~u~ / (C~u~ + C~o~) = (p − c) / (p − s)

$ Q^*^ = F^−1^(q^*^)

trong đó C~u~ = p − c là chi phí thiếu hàng (lãi gộp bị mất) và C~o~ = c − s là chi phí thừa hàng (lỗ khi thanh lý). Vì mô hình chỉ cho lưới phân vị P10–P90, Q^*^ được nội suy tuyến tính trên lưới và q^*^ được kẹp vào khoảng [0,1; 0,9]. Lợi nhuận mỗi ngày của một quyết định đặt hàng Q khi cầu thực tế là D được tính bằng:

$ Π(Q, D) = p · min(Q, D) − c · Q + s · (Q − D)^+^

Tám chính sách đặt hàng ngày được so sánh trên ba gốc × 14 ngày: đặt theo dự báo điểm P50; đặt P90 cho mọi SKU (thực hành "dự trữ an toàn cao"); đặt theo q^*^ với phân vị của từng họ Z-chuẩn, Quantile LightGBM, phân vị phần dư, DeepAR; chính sách của mã minh họa học phần (chọn phân vị gần q^*^ nhất trong năm mức P10, P30, P50, P70, P90 của dải heuristic, theo script strategy_reorder_point.py); và chính sách Oracle biết trước cầu (cận trên). Ngoài lợi nhuận, Stage 06 ghi nhận tỷ lệ đáp ứng (fill-rate), vốn hàng đặt c · Q, lỗ thanh lý và lãi gộp bị mất do thiếu hàng, tổng thể và theo ngành. Nhãn chiến lược của từng SKU theo ngưỡng của script (q^*^ ≥ 0,75 là tấn công, q^*^ ≤ 0,35 là phòng thủ) cũng được tính.

Điểm đặt hàng lại (ROP) được đánh giá với lead time L ∈ {3, 7, 14} ngày và mức phục vụ mục tiêu 80%, 90%, 95% theo ba phương pháp. Phương pháp *chuẩn √L* giả định sai số ngày độc lập, phân phối chuẩn:

$ ROP = Σ~h≤L~ ŷ~h~ + z~α~ · σ~1~ · √L

Phương pháp *thực nghiệm* dùng trực tiếp phân vị của tổng sai số L ngày (chuẩn hóa theo m28) trong tập sai số nội bộ. Phương pháp *tổng phân vị DeepAR* cộng các phân vị ngày của DeepAR, một xấp xỉ bảo thủ chỉ đúng khi sai số các ngày tương quan dương hoàn toàn. Mức phục vụ chu kỳ thực đạt (CSL) là tỷ lệ SKU có tổng cầu L ngày không vượt ROP. Để giải thích sai lệch của phương pháp √L, Stage 06 tính tự tương quan bậc một trung bình của sai số ngày chuẩn hóa.

### 3.7.4. Mô hình chiến dịch và giả định giá vốn

Để đánh giá một kịch bản chiến dịch (quảng cáo a, chiết khấu d, có phải ngày Mega Sale hay không), lớp CampaignModel trong src/scenarios/megasale.py kết hợp hai hồi quy ước lượng trên 90 ngày:

$ Orders = β~0~ + β~1~ · Ads + β~2~ · Disc + β~3~ · Mega + ε

$ AOV = α~0~ + α~1~ · Disc + u

Với một kịch bản, số đơn được mô phỏng 4.000 lần từ phân phối chuẩn có trung bình bằng dự báo của mô hình và phương sai bằng tổng phương sai của trung bình dự báo (bất định tham số) và phương sai phần dư (nhiễu ngày); GMV bằng số đơn nhân AOV dự báo; biên đóng góp (CM) bằng GMV trừ giá vốn, phí sàn và quảng cáo. Từ 4.000 mẫu, Stage 06 báo cáo P10, P50, P90 của số đơn, GMV và CM cùng xác suất CM âm.

Giá vốn là giả định có ảnh hưởng lớn nhất đến kết luận về lợi nhuận Mega Sale, nên tiểu luận mô hình hóa hai giả định và báo cáo cả hai ({T:@cost}). Giả định *lạc quan* coi giá vốn là một tỷ lệ cố định của GMV, bằng tỷ lệ giá vốn/GMV quan sát trong tệp unit_economics (0,613). Giả định này ngầm cho rằng chiết khấu không ăn vào biên, điều chỉ đúng nếu nhà cung cấp hoặc sàn tài trợ toàn bộ chiết khấu. Giả định *thận trọng* (mặc định) coi giá vốn tỷ lệ với giá trị hàng trước chiết khấu:

$ Giá vốn = κ · GMV / (1 − d)

trong đó κ được hiệu chỉnh để tổng giá vốn của 90 ngày đúng bằng 0,613 lần tổng GMV quan sát, cho κ ≈ 0,477. Theo giả định này, ở chiết khấu 50% giá vốn chiếm khoảng 95% GMV, tức chiết khấu sâu gần như xóa sạch biên gộp. Phân tích độ nhạy ở Stage 13 thay đổi thêm tỷ lệ giá vốn ±10%.

[[T:@cost Hai giả định giá vốn của mô hình chiến dịch
Giả định | Công thức giá vốn | Tỷ lệ giá vốn/GMV ở chiết khấu d | Khi nào hợp lý
Theo GMV (lạc quan) | 0,613 × GMV | 0,613 với mọi d | Chiết khấu do nhà cung cấp hoặc sàn tài trợ hoàn toàn
Theo giá niêm yết (thận trọng, mặc định) | κ × GMV/(1 − d), κ ≈ 0,477 | ≈ 0,477/(1 − d): 0,53 ở d = 10%; 0,95 ở d = 50% | Người bán tự chịu chiết khấu
Nguồn: Tác giả; src/scenarios/megasale.py; tỷ lệ 0,613 từ ecommerce_unit_economics.
]]

Giới hạn nhận dạng nêu ở mục 3.1.1 được mã hóa trực tiếp vào mô hình. Vì hai ngày Mega Sale đều có chiết khấu 50% và không ngày thường nào có chiết khấu 50%, hệ số β~3~ của biến Mega và hiệu ứng của chiết khấu ở mức 50% không thể tách rời. CampaignModel lưu tập mức chiết khấu đã quan sát vào ngày Mega Sale và gắn cờ *ngoại suy* cho mọi kịch bản Mega Sale có chiết khấu khác các mức đó, ngoài cờ ngoại suy thông thường khi quảng cáo hoặc chiết khấu nằm ngoài khoảng quan sát (quảng cáo 5,43–33,54 triệu VNĐ/ngày; chiết khấu 0,05–0,50). Độ tin cậy của mô hình với ngày Mega Sale được kiểm tra bằng thí nghiệm bỏ-một-ngày: bỏ một trong hai ngày Mega Sale khỏi dữ liệu, ước lượng lại mô hình và kiểm tra xem khoảng P10–P90 có chứa GMV thực tế của ngày bị bỏ ra hay không. Lưới kịch bản quảng cáo {5, 10, …, 40} × chiết khấu {10%, …, 50%} được tính cho cả hai giả định giá vốn, và với phí sàn 10%.

### 3.7.5. Rủi ro tài chính của việc tăng ngân sách quảng cáo

Để trả lời câu hỏi "tăng quảng cáo có thể lỗ với xác suất bao nhiêu", Stage 06 dùng bootstrap theo cặp (Efron & Tibshirani, 1993) với 2.000 lần lấy mẫu lại. Ở cấp toàn cửa hàng, mỗi lần lấy mẫu lại 90 ngày có hoàn lại, ước lượng lại đặc tả (2) và tính lợi nhuận tăng thêm khi tăng quảng cáo thêm Δ triệu VNĐ/ngày:

$ ΔΠ = β̂~1~^(b)^ · Δ · AOV · (1 − 0,613) − Δ

với Δ ∈ {1, 2, 5, 10}. Ở cấp ngành, mỗi lần lấy mẫu lại 30 ngày của một ngành, ước lượng lại độ dốc số đơn theo quảng cáo và tính lợi nhuận tăng thêm trên một triệu đồng quảng cáo bằng độ dốc nhân biên gộp mỗi đơn của ngành trừ 1. Phân phối bootstrap cho các phân vị P5, P50, P95 và xác suất lỗ.

### 3.7.6. Dự báo Tổng mức bán lẻ Việt Nam

Năm mô hình dự báo chuỗi tháng TMBL được hiện thực trong src/models/macro.py: naive mùa vụ có điều chỉnh tăng trưởng (giá trị 12 tháng gần nhất nhân tỷ số tổng 12 tháng gần nhất trên tổng 12 tháng trước đó); ETS trên log với xu hướng cộng tắt dần và mùa vụ cộng chu kỳ 12, khoảng 80% xấp xỉ bằng ±1,2816 · σ · √h; SARIMA(1,1,1)(0,1,1)~12~ trên log với hai biến ngoại sinh Tết và COVID (Box và cộng sự, 2015); Prophet trên log với hai biến hồi quy Tết và COVID, khoảng 80% từ 1.000 mẫu bất định; và LightGBM trên tăng trưởng cùng kỳ (log), dự báo đệ quy 12 bước. Năm mô hình được đánh giá walk-forward tại hai gốc 9/2024 và 9/2025, mỗi gốc 12 tháng. Kịch bản 10/2026–9/2027 lấy trung bình cộng của SARIMA, Prophet và ETS. Dự báo này chỉ là đầu ra mô hình trên số liệu công bố, không phải số liệu chính thức.

## 3.8. Phương pháp phân bổ ngân sách và tác tử AI hỗ trợ quyết định

Mục này trình bày phương pháp của Stage 07 và Stage 08, tương ứng với Chương 5 của học phần, nhằm trả lời RQ5.

### 3.8.1. Phân bổ ngân sách quảng cáo như bài toán của tác tử điều phối

Slide Chương 5 mô tả kiến trúc đa tác tử trong đó một tác tử điều phối cân bằng mục tiêu doanh thu của tác tử bán hàng và mục tiêu chi phí của tác tử tài chính thông qua hàm mục tiêu có trọng số w~1~ · R(x) − w~2~ · C(x) (Trần Duy Thanh, 2026a, Ch5 tr.31–35). Stage 07 áp dụng cấu trúc này cho bài toán phân bổ ngân sách quảng cáo/ngày giữa ba ngành. Đường phản hồi số đơn theo quảng cáo của mỗi ngành c được ước lượng trên panel ở dạng logarit:

$ Orders~c~(a) = max(0; α~c~ + β~c~ · ln a)

GMV và giá vốn của ngành bằng số đơn nhân AOV và giá vốn mỗi đơn lấy từ tệp unit_economics. Bài toán của tác tử điều phối là:

$ max~a~ Σ~c~ [ w~1~ · AOV~c~ · Orders~c~(a~c~) − w~2~ · (COGS~c~ · Orders~c~(a~c~) + a~c~) ]

$ với Σ~c~ a~c~ = B,  a~c~ ≥ m · B

Với w~1~ = w~2~ = 1, mục tiêu là lợi nhuận gộp sau quảng cáo; với w~2~ = 0, mục tiêu là GMV. Tỷ trọng tối thiểu m = 10% bảo đảm mỗi ngành duy trì hiện diện quảng cáo. Ngân sách hiện tại B được lấy bằng tổng chi phí quảng cáo trung bình mỗi ngày của ba ngành trong panel (khoảng 16,33 triệu VNĐ/ngày). Bài toán được giải bằng SLSQP (scipy) với nhiều điểm khởi đầu (chia đều và dồn về từng ngành), giữ nghiệm tốt nhất. Khi không ràng buộc tổng ngân sách, điều kiện bậc nhất cho mức chi tối ưu riêng của mỗi ngành là a~c~^*^ = (AOV~c~ − COGS~c~) · β~c~.

Vì đường phản hồi chỉ được quan sát trong khoảng chi quảng cáo của dữ liệu (khoảng 2–10 triệu VNĐ/ngày mỗi ngành), tiểu luận giải thêm một phiên bản *trong vùng dữ liệu*, giới hạn mỗi a~c~ trong khoảng đã quan sát. Sáu chính sách được so sánh ở mức ngân sách hiện tại: hiện trạng (trung bình 30 ngày), chia đều, chia theo ROAS trung bình (heuristic phổ biến), tối ưu lợi nhuận, tối ưu GMV và tối ưu lợi nhuận trong vùng dữ liệu. Stage 07 còn quét trọng số w~2~ từ 0 đến 1,5 (w~1~ = 1), quét ngân sách từ 50% đến 150% hiện tại và tính *giá bóng* λ, tức lợi nhuận tăng thêm của một triệu đồng ngân sách cuối cùng, bằng sai phân hữu hạn bước 0,01. Cuối cùng, bất định tham số được đánh giá bằng bootstrap 1.000 lần: mỗi lần lấy mẫu lại 30 ngày của mỗi ngành, ước lượng lại đường phản hồi và tính lợi nhuận của các phân bổ đã chọn, từ đó có phân phối lợi nhuận và xác suất phân bổ tối ưu thắng hiện trạng.

### 3.8.2. Truy xuất tri thức có ngưỡng từ chối

Lớp truy xuất (src/genai/rag.py) chia kho tri thức thành 21 đoạn và biểu diễn mỗi đoạn bằng véc-tơ TF-IDF (Salton & Buckley, 1988); mức độ liên quan giữa câu hỏi và đoạn là độ tương đồng cosine. Đây đúng là kỹ thuật slide dùng để minh họa RAG (Trần Duy Thanh, 2026a, Ch5 tr.21–26; Lewis và cộng sự, 2020), và ví dụ bốn tài liệu trên slide được tái lập trước. Hai cách biểu diễn được so sánh: TF-IDF theo từ và TF-IDF theo n-gram ký tự 2–4 trong ranh giới từ; cách thứ hai bền vững hơn với dấu tiếng Việt và biến thể chính tả. Độ chính xác truy xuất được đánh giá trên 16 câu hỏi có đáp án đúng (đoạn vàng) bằng Precision@1 và Mean Reciprocal Rank.

Một RAG dùng cho quyết định tài chính phải biết *khi nào không trả lời*. Tiểu luận đặt ngưỡng từ chối τ bằng phân vị 5% của điểm tương đồng lớn nhất trên các câu hỏi trong miền; câu hỏi có điểm lớn nhất dưới τ bị từ chối với thông báo thiếu căn cứ. Bốn câu hỏi ngoài miền (giá vàng, thời tiết, lãi suất tiền gửi, tỷ số bóng đá) dùng để kiểm tra cơ chế từ chối.

### 3.8.3. Tác tử lập kế hoạch chiến dịch

Tác tử (lớp CampaignAgent trong src/genai/agent.py) nhận một đề xuất chiến dịch gồm tên chiến dịch, ngân sách quảng cáo/ngày, mức chiết khấu, cờ ngày Mega Sale và cờ chương trình khuyến mại tập trung. Tác tử vận hành theo chu trình Quan sát – Suy luận – Hành động của ReAct (Yao và cộng sự, 2023; Trần Duy Thanh, 2026a, Ch5 tr.6–16), được hiện thực thành bốn nút của một đồ thị trạng thái LangGraph (Ch5 tr.52–58). Nút *observe* truy xuất ba đoạn tri thức liên quan đến mức chiết khấu, ngân sách và biên đóng góp. Nút *simulate* gọi công cụ CampaignModel để dự báo P10–P90 của GMV, CM và xác suất CM âm. Nút *check* kiểm tra sáu điều kiện. Nút *decide* phát hành một kế hoạch có cấu trúc cùng trạng thái phê duyệt. Nếu thư viện LangGraph không có, bốn nút được gọi tuần tự với cùng logic.

Luồng xử lý của tác tử được minh họa ở {F:d04_luong_tac_tu.png}. Một đề xuất chiến dịch (mức quảng cáo/ngày, chiết khấu, có phải ngày Mega Sale, có thuộc chương trình khuyến mại tập trung) đi qua bốn nút của đồ thị trạng thái: truy xuất tri thức (OBSERVE), mô phỏng GMV và biên đóng góp (REASON), kiểm tra pháp lý – quy chế – vùng dữ liệu (CHECK) và phát hành kế hoạch định chuẩn (ACT). Kết quả rẽ thành ba nhánh: tự duyệt, chuyển người duyệt hoặc từ chối; mọi nhánh đều được ghi vào nhật ký kiểm toán, và quyết định của người duyệt trên dashboard được lưu thành tệp riêng.

[[FIG:d04_luong_tac_tu.png|Luồng tác tử lập kế hoạch chiến dịch trên đồ thị trạng thái và cơ chế Human-in-the-loop|Nguồn: Tác giả, hiện thực trong src/genai/agent.py]]

Sáu điều kiện kiểm tra và quy tắc phê duyệt được trình bày ở {T:@hitl}. Điều kiện pháp lý là điều kiện cứng: mọi đề xuất chiết khấu vượt 50% (hoặc 100% nếu thuộc khuyến mại tập trung) bị từ chối, bất kể dự báo lợi nhuận. Năm điều kiện còn lại là điều kiện mềm: nếu vi phạm bất kỳ điều kiện nào, đề xuất được chuyển cho con người phê duyệt kèm danh sách lý do; nếu không vi phạm điều kiện nào, đề xuất được tự động phê duyệt. Ngưỡng ngân sách P95 tính từ chi phí quảng cáo/ngày của 90 ngày là 19,27 triệu VNĐ.

[[T:@hitl Điều kiện kiểm tra và quy tắc phê duyệt của tác tử
Điều kiện | Ngưỡng | Loại | Căn cứ
Chiết khấu vượt mức tối đa pháp lý | > 50% (khuyến mại tập trung: > 100%) | Cứng: từ chối | NĐ 81/2018 sửa đổi bởi NĐ 128/2024
Chiết khấu sâu | ≥ 40% | Mềm: người duyệt | Quy chế mẫu (knowledge_base/04)
Ngân sách quảng cáo/ngày lớn | > P95 lịch sử (19,27 triệu VNĐ) | Mềm: người duyệt | Quy chế mẫu
Biên đóng góp kỳ vọng âm | CM P50 < 0 | Mềm: người duyệt | Quy chế mẫu
Rủi ro biên đóng góp | P(CM < 0) > 20% | Mềm: người duyệt | Quy chế mẫu
Ngoại suy | Ngoài vùng dữ liệu hoặc Mega Sale với chiết khấu ≠ 50% | Mềm: người duyệt | Quy chế mẫu; giới hạn nhận dạng
Nguồn: Tác giả; src/genai/agent.py; config/default.yaml (mục hitl).
]]

Đầu vào và đầu ra của tác tử được ràng buộc bằng lược đồ pydantic (Ch5 tr.41–52). Lược đồ đề xuất yêu cầu tên chiến dịch tối thiểu ba ký tự, ngân sách không âm và chiết khấu trong [0; 1]; lược đồ kế hoạch yêu cầu xác suất trong [0; 1] và trạng thái thuộc đúng ba giá trị cho phép. Bốn payload sai được thử để kiểm tra lược đồ có chặn đúng hay không. Mỗi kế hoạch được ghi một bản ghi kiểm toán (audit_log.jsonl) gồm thời điểm, đề xuất, dự báo, trạng thái, lý do, mã đoạn tri thức được trích, công cụ đã gọi và động cơ chạy (LangGraph hoặc tuần tự), đáp ứng yêu cầu truy vết của khung giám sát quyết định (Ch5 tr.59–63). Lớp diễn giải (src/genai/assistant.py) mặc định sinh phiếu khuyến nghị bằng quy tắc; khi người dùng cấp khóa API và bật cấu hình, mô hình ngôn ngữ chỉ được diễn giải kế hoạch bằng lời và được yêu cầu không thay đổi con số.

Mười hai đề xuất được thiết kế để phủ các tình huống điển hình ({T:@req}): ngày thường duy trì và tăng quảng cáo, các ngày Mega Sale với chiết khấu 20% đến 60%, một chương trình khuyến mại tập trung 70%, một đề xuất ngân sách rất lớn, flash sale cuối tuần, ngày lương và Mega Sale ngân sách thấp. Ngoài ra, Stage 08 so sánh hai "phong cách" tác tử trên cùng lưới quyết định (quảng cáo 6–32 triệu VNĐ/ngày bước 2, chiết khấu 10–50%): tác tử *chỉ tối đa GMV*, không có rào chắn, và tác tử *tối đa biên đóng góp có rào chắn* (chỉ chọn phương án trong vùng dữ liệu, hợp pháp và có xác suất CM âm không quá 20%).

[[T:@req Mười hai đề xuất chiến dịch dùng để đánh giá tác tử
ID | Chiến dịch | Quảng cáo/ngày (triệu VNĐ) | Chiết khấu | Ngày Mega Sale | KM tập trung
R01 | Ngày thường – duy trì | 12 | 15% | Không | Không
R02 | Ngày thường – tăng quảng cáo | 20 | 15% | Không | Không
R03 | Mega Sale 9.9 – chiết khấu vừa | 15 | 20% | Có | Không
R04 | Mega Sale 10.10 – chiết khấu 30% | 18 | 30% | Có | Không
R05 | Mega Sale 11.11 – chiết khấu 40% | 25 | 40% | Có | Không
R06 | Mega Sale 11.11 – chiết khấu 50% | 30 | 50% | Có | Không
R07 | Mega Sale 12.12 – chiết khấu 60% | 30 | 60% | Có | Không
R08 | Khuyến mại tập trung – 70% | 30 | 70% | Có | Có
R09 | Mega Sale – ngân sách lớn | 40 | 30% | Có | Không
R10 | Flash sale cuối tuần | 10 | 25% | Không | Không
R11 | Payday 25 – chiết khấu 20% | 14 | 20% | Không | Không
R12 | Mega Sale 9.9 – ngân sách thấp | 8 | 20% | Có | Không
Nguồn: Tác giả; 08_genai_decision_support.py.
]]

## 3.9. Phân tích trường hợp, dòng tiền chiến dịch và độ nhạy

### 3.9.1. Phân tích trường hợp

Stage 12 thực hiện bốn phân tích trường hợp. Trường hợp thứ nhất giải phẫu hai ngày Mega Sale: đơn, AOV, quảng cáo, chiết khấu và biên đóng góp theo hai giả định giá vốn, so với ngày thường trung bình. Trường hợp thứ hai phân tích ngành FMCG, ngành có nhiều đơn nhất nhưng lỗ, và tìm tổ hợp tăng AOV (bán combo) và giảm giá vốn tối thiểu để biên đóng góp dương. Trường hợp thứ ba là bẫy vốn lưu động của chiến dịch (mục 3.9.2). Trường hợp thứ tư lập kế hoạch hàng 14 ngày cho một SKU điện thoại theo q^*^, đối chiếu P10, P50, P90 với cầu thực tế.

### 3.9.2. Mô phỏng dòng tiền chiến dịch

Một chiến dịch có lãi vẫn có thể làm doanh nghiệp thiếu tiền mặt nếu tiền nhập hàng phải trả trước nhiều ngày trong khi tiền bán hàng về sau nhiều ngày, đây là bản chất của chu kỳ chuyển đổi tiền mặt (Richards & Laughlin, 1980; Deloof, 2003) và là phiên bản Việt Nam của case dòng tiền Mega Sale trên slide Chương 2 (Trần Duy Thanh, 2026a, Ch2 tr.103). Hàm simulate trong src/cashflow/sim.py mô phỏng dòng tiền ngày của 90 ngày dữ liệu theo ba quy tắc: giá vốn của hàng bán ngày t (0,613 × GMV~t~) được trả vào ngày t − L (lead time nhập hàng); quảng cáo được trả ngay ngày t; tiền bán hàng, sau khi trừ phí sàn f, về tài khoản vào ngày t + lag (độ trễ đối soát):

$ Tiền~t~ = Σ~s≤t~ [ GMV~s−lag~ · (1 − f) − 0,613 · GMV~s+L~ − Ads~s~ ]

Tiền mặt tối thiểu cần chuẩn bị là độ sâu của đáy dòng tiền lũy kế, max(0; −min~t~ Tiền~t~). Các tham số được quét theo {T:@cash}. Mức độ trễ đối soát được chọn dựa trên chính sách công khai của một sàn lớn (tiền ghi nhận khi người mua xác nhận hoặc sau 4 ngày kể từ giao thành công; rút tiền mất thêm đến 4 ngày làm việc) cộng thời gian giao hàng, và là *tham số kịch bản* chứ không phải số liệu đo được. Phần vốn bị khóa thêm do hai ngày Mega Sale được đo bằng chênh lệch dòng tiền lũy kế giữa kịch bản thật và kịch bản thay GMV, quảng cáo của hai ngày đó bằng trung vị.

[[T:@cash Tham số kịch bản của mô phỏng dòng tiền
Tham số | Giá trị | Căn cứ
Tỷ lệ giá vốn/GMV | 0,613 | ecommerce_unit_economics (tổng giá vốn / tổng GMV)
Độ trễ đối soát (ngày) | 0; 7; 10; 14 | Chính sách đối soát công khai + thời gian giao hàng (kịch bản)
Lead time nhập hàng (ngày) | 7; 30 | Kịch bản nhập trong nước và nhập khẩu
Phí sàn (% GMV) | 0%; 10% | Kịch bản
Dữ liệu doanh thu, quảng cáo | 90 ngày 01/07–28/09/2026 | ecommerce_90days
Nguồn: Tác giả; config/default.yaml (mục cashflow); src/cashflow/sim.py.
]]

### 3.9.3. Phân tích độ nhạy

Stage 13 thực hiện năm thí nghiệm độ nhạy. Thí nghiệm thứ nhất thay đổi giả định giá vốn (theo GMV hoặc theo giá niêm yết) và tỷ lệ giá vốn (0,9; 1,0; 1,1 lần mức cơ sở), đo biên đóng góp dự báo của hai ngày Mega Sale. Thí nghiệm thứ hai thay đổi tỷ trọng ngân sách tối thiểu mỗi ngành (0% đến 30%). Thí nghiệm thứ ba thay đổi ngưỡng HITL (phân vị ngân sách 90%, 95%, 99%; ngưỡng chiết khấu 30%, 40%, 50%) và đếm số đề xuất tự duyệt, cần người duyệt và bị từ chối. Thí nghiệm thứ tư thay đổi siêu tham số của LightGBM toàn cục (num_leaves 7–63; min_data_in_leaf 20–100) tại gốc cuối. Thí nghiệm thứ năm thay đổi biên gộp của từng ngành ±20% và quan sát phân bổ ngân sách tối ưu thay đổi ra sao.

## 3.10. Thước đo đánh giá và kiểm định thống kê

### 3.10.1. Thước đo dự báo điểm

Mô-đun src/evaluation/metrics.py tính các thước đo dự báo điểm theo Hyndman và Koehler (2006). Với y là giá trị thực và ŷ là dự báo:

$ MAE = (1/n) · Σ |y − ŷ|,  RMSE = √[(1/n) · Σ (y − ŷ)^2^]

$ WAPE = Σ |y − ŷ| / Σ |y| × 100%,  Bias = Σ (ŷ − y) / Σ y × 100%

$ MASE = (1/n) · Σ |y − ŷ| / s,  s = TB |y~t~ − y~t−7~| trên dữ liệu huấn luyện

WAPE là thước đo chính vì có ý nghĩa kinh doanh trực tiếp (tỷ lệ sai số trên tổng lượng bán) và không bị bùng nổ khi cầu nhỏ như MAPE. Bias dương nghĩa là dự báo cao hơn thực tế. MASE so sánh với naive mùa vụ 7 ngày trong mẫu, giá trị dưới 1 nghĩa là tốt hơn naive.

### 3.10.2. Thước đo dự báo xác suất

Pinball loss tại mức q (Koenker & Bassett, 1978; Trần Duy Thanh, 2026a, Ch4 tr.36–41):

$ L~q~(y, P~q~) = q · (y − P~q~) nếu y ≥ P~q~;  (1 − q) · (P~q~ − y) nếu y < P~q~

là một quy tắc chấm điểm đúng cho phân vị (Gneiting & Raftery, 2007); trung bình trên chín mức là xấp xỉ của CRPS. Độ phủ khoảng 80% là tỷ lệ quan sát nằm trong [P~0,1~; P~0,9~]. Điểm Winkler (1972) của khoảng (1 − α) kết hợp độ rộng và mức phạt khi quan sát nằm ngoài:

$ W = (U − L) + (2/α) · (L − y) · 1[y < L] + (2/α) · (y − U) · 1[y > U]

Điểm Winkler thấp nghĩa là khoảng vừa hẹp vừa phủ tốt; một khoảng quá rộng có độ phủ cao nhưng điểm Winkler kém. Đường hiệu chỉnh vẽ tỷ lệ y ≤ P~q~ theo q; mô hình hiệu chỉnh tốt nằm trên đường chéo.

### 3.10.3. Thước đo quyết định

Quyết định chuẩn bị hàng được đánh giá bằng lợi nhuận Newsvendor, tỷ lệ so với Oracle, fill-rate, vốn hàng đặt, lỗ thanh lý và lãi gộp bị mất. ROP được đánh giá bằng CSL thực đạt so với mục tiêu và tồn kho an toàn trung bình. Phân bổ ngân sách được đánh giá bằng lợi nhuận gộp sau quảng cáo, GMV, giá bóng và xác suất thắng hiện trạng dưới bootstrap. Tác tử được đánh giá bằng P@1, MRR, tỷ lệ từ chối đúng câu hỏi ngoài miền, trạng thái phê duyệt của mười hai đề xuất và kết quả kiểm tra lược đồ. Dòng tiền được đánh giá bằng tiền mặt tối thiểu, ngày đáy và vốn bị khóa thêm.

### 3.10.4. Kiểm định thống kê

Khác biệt độ chính xác giữa hai mô hình được kiểm định bằng Diebold–Mariano (1995) trên chuỗi chênh lệch tổn thất d~t~ = L~A,t~ − L~B,t~, với phương sai dài hạn Newey–West:

$ DM = d̄ / √(LRV / n),  LRV = γ~0~ + 2 · Σ~k=1..h−1~ (1 − k/h) · γ~k~

Với dự báo nhiều chuỗi, tiểu luận báo cáo hai phiên bản. Phiên bản *gộp điểm* coi 4.200 cặp SKU × ngày là chuỗi tổn thất (h = 1). Phiên bản *gộp chéo* lấy trung bình tổn thất theo SKU cho từng cặp (gốc, chân trời), sắp theo thời gian thành 42 điểm và dùng phương sai HAC độ trễ 13 (h = 14), vì sai số của các chân trời xuất phát từ cùng một gốc tương quan với nhau. Hai phiên bản trả lời hai câu hỏi khác nhau: phiên bản gộp điểm đo mức chắc chắn rằng một mô hình tốt hơn trên một SKU ngẫu nhiên, còn phiên bản gộp chéo đo mức chắc chắn rằng nó tốt hơn trên tổng danh mục. Với dự báo xác suất, kiểm định DM áp dụng cho pinball trung bình chín phân vị. Các kiểm định khác gồm Jarque–Bera, Breusch–Pagan, ANOVA một yếu tố, kiểm định F lồng nhau, kiểm định t Welch, Ljung–Box cho phần dư STL và kiểm định F đồng thời cho mô hình độ trễ phân phối. Mức ý nghĩa danh nghĩa là 5%; vì tiểu luận thực hiện nhiều kiểm định, các p-value gần ngưỡng được diễn giải thận trọng.

## 3.11. Khả năng tái lập và đạo đức nghiên cứu

### 3.11.1. Khả năng tái lập

Khả năng tái lập được bảo đảm ở năm điểm. Thứ nhất, dữ liệu đầu vào được định danh bằng mã băm SHA-256 (outputs/01_data/sha256.json). Thứ hai, mọi nguồn ngẫu nhiên được cố định bằng hạt giống 42, LightGBM chạy ở chế độ tất định với hai luồng. Thứ ba, toàn bộ pipeline chạy bằng một lệnh và tự dừng nếu kiểm tra ở Stage 10 thất bại. Thứ tư, mọi bảng trong báo cáo được dựng tự động từ outputs/, và một chương trình đối chiếu số liệu so khớp các con số trong văn bản với tệp kết quả. Thứ năm, môi trường của lần chạy chính thức được ghi lại ({T:@env}). Trên Windows, tệp requirements.txt cho phép pandas 2.x để tương thích Python 3.11–3.12; khác biệt phiên bản thư viện có thể làm thay đổi chữ số thập phân cuối của các mô hình học máy nhưng không làm thay đổi kết luận. DeepAR và LSTM cần PyTorch (requirements-neural.txt); nếu không cài, Stage 06 dùng kết quả kiểm định chéo đã lưu của lần chạy chính thức, và người dùng có thể xóa thư mục bộ nhớ đệm để buộc huấn luyện lại.

[[T:@env Môi trường của lần chạy chính thức
Thành phần | Phiên bản | Vai trò
Python | 3.13 | Ngôn ngữ
pandas; numpy | 3.0.5; 2.5.3 | Xử lý dữ liệu
scikit-learn | 1.9.1 | Gradient Boosting, TF-IDF, kiểm định chéo
lightgbm | 4.7.0 | Mô hình toàn cục, mô hình phân vị
statsmodels | 0.15.0 | OLS, STL, MSTL, HP, ETS, SARIMA
prophet | 1.5.0 | Prophet
neuralforecast | 3.3.0 | DeepAR, LSTM đa phân vị
langgraph; pydantic | 1.2.16; 2.13.5 | Đồ thị trạng thái, lược đồ dữ liệu
streamlit; plotly | 1.66.1; 7.1.0 | Dashboard
Phần cứng | Linux, 2 lõi CPU | Toàn bộ pipeline khoảng 5 phút
Nguồn: docs/reproducibility.md.
]]

### 3.11.2. Đạo đức nghiên cứu và sử dụng công cụ AI

Tiểu luận tuân thủ bốn nguyên tắc đạo đức. Thứ nhất, *không bịa số liệu*: mọi con số đến từ dữ liệu có nguồn, từ đầu ra của mã nguồn có thể chạy lại, hoặc từ phép tính đơn giản được nêu rõ trên các con số đó. Thứ hai, *minh bạch về bản chất dữ liệu*: dữ liệu học phần được nêu rõ là dữ liệu mô phỏng, quy chế marketing được nêu rõ là quy chế mẫu do tác giả soạn, dự báo TMBL được nêu rõ là đầu ra mô hình. Thứ ba, *tôn trọng nguồn và quy định truy cập*: số liệu Cục Thống kê được thu thập qua giao diện công khai, có lưu đường dẫn từng bài; các nguồn báo chí và văn bản pháp luật được trích dẫn đầy đủ. Thứ tư, *trách nhiệm với quyết định tự động*: tác tử AI được thiết kế để không tự động phê duyệt các quyết định có rủi ro pháp lý hoặc tài chính, mọi quyết định đều được ghi nhật ký và có thể truy vết.

Về công cụ AI, tác giả sử dụng trợ lý AI để hỗ trợ lập trình và soạn thảo dưới sự kiểm soát của tác giả. Mọi kết quả số được sinh bởi mã nguồn chạy thật trên dữ liệu và được kiểm tra bằng bộ kiểm thử tự động; không con số nào được sinh trực tiếp bởi mô hình ngôn ngữ. Trong chính hệ thống được xây dựng, lớp mô hình ngôn ngữ mặc định tắt; khi bật, nó chỉ diễn giải kế hoạch đã được công cụ tính toán và quy tắc kiểm tra, không được phép thay đổi con số, phù hợp với nguyên tắc "hộp kính" mà slide Chương 5 đề cao.

### 3.11.3. Tiểu kết

Chương 3 đã trình bày ba nguồn dữ liệu, kiến trúc phần mềm mười bốn stage cùng dashboard mười hai trang, và phương pháp của từng tầng phân tích. Ba đặc điểm phương pháp cần ghi nhớ khi đọc Chương 4. Một là mọi đánh giá dự báo dùng walk-forward không rò rỉ, đã được kiểm tra bằng thí nghiệm phá hủy. Hai là mọi kết luận về chiến dịch là dự báo có điều kiện, không phải nhân quả, và bị giới hạn bởi việc hai ngày Mega Sale đều chiết khấu 50%. Ba là kết luận về lợi nhuận Mega Sale phụ thuộc giả định giá vốn, nên luôn được báo cáo theo cả hai giả định. Chương 4 trình bày kết quả theo đúng trình tự năm tầng đã thiết kế.
