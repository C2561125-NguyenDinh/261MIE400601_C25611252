# LỜI CAM ĐOAN

Tôi xin cam đoan tiểu luận "Đo lường hiệu quả quảng cáo – khuyến mãi và dự báo GMV mùa Mega Sale cho doanh nghiệp thương mại điện tử Việt Nam: từ chẩn đoán dữ liệu, phân rã chuỗi thời gian, học máy toàn cục, dự báo xác suất đến tác tử AI phân bổ ngân sách marketing" là công trình do tôi thực hiện dưới sự hướng dẫn của TS. Trần Duy Thanh, trong khuôn khổ học phần Các mô hình dự báo trong kinh doanh (MIE4006) thuộc chương trình Thạc sĩ Thương mại điện tử, Trường Đại học Kinh tế – Luật, Đại học Quốc gia Thành phố Hồ Chí Minh. Mọi kết quả định lượng trong tiểu luận được sinh ra từ một hệ thống mã nguồn do tôi xây dựng, gồm mười bốn bước xử lý (stage) chạy tuần tự và một bảng điều khiển (dashboard) trình bày kết quả. Các bảng số liệu ở những chương kết quả được tạo tự động từ tệp đầu ra của chương trình; không có bảng kết quả nào được nhập tay.

Tôi xin cam đoan rõ về bản chất của từng nguồn dữ liệu. Thứ nhất, mười hai bộ dữ liệu cấp doanh nghiệp được sử dụng (chuỗi giao dịch 90 ngày có quảng cáo và chiết khấu, dữ liệu bẩn, dữ liệu bảng ba ngành, Unit Economics, biên lợi nhuận 72 tháng, chuỗi ngày đa mùa vụ có chi phí marketing, chuỗi 48 tháng, dữ liệu sản phẩm mới, dữ liệu bán lẻ có khuyến mãi, dữ liệu 15 SKU, dữ liệu 100 SKU và siêu dữ liệu tài chính của 100 SKU) là học liệu do giảng viên công bố tại trang tranduythanh.com/forecasting-models. Đây là dữ liệu mô phỏng: chính slide bài giảng ghi chú nguồn "src: Synthetic Data" (Trần Duy Thanh, 2026a, Ch1 tr.11 và tr.20). Vì vậy, mọi kết luận rút ra từ các bộ dữ liệu này được trình bày như minh chứng về phương pháp và về logic ra quyết định, không phải bằng chứng thực nghiệm về hành vi của người tiêu dùng hay hiệu quả quảng cáo trên thị trường thương mại điện tử Việt Nam.

Thứ hai, số liệu thật của Việt Nam gồm chuỗi tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng (TMBL) theo tháng từ tháng 12/2019 đến tháng 9/2026 (82 tháng) và số liệu năm 2019–2025, do tôi tổng hợp trực tiếp từ các báo cáo tình hình kinh tế – xã hội hằng tháng, hằng quý của Cục Thống kê; đường dẫn tới từng kỳ báo cáo được liệt kê ở phần Phụ lục. Hai giá trị tháng (12/2020 và 6/2021) không được công bố riêng nên được suy ra bằng cách lấy tổng quý trừ hai tháng còn lại; cách làm này được nêu công khai và kiểm tra bằng đối chiếu với số liệu năm. Các số liệu bối cảnh khác (quy mô thương mại điện tử năm 2024, doanh thu bốn sàn năm 2025, dự báo quý IV/2025, quy định về mức giảm giá tối đa, chính sách đối soát của sàn) được trích từ các nguồn công khai có ghi rõ đường dẫn trong danh mục tài liệu tham khảo. Riêng "quy chế marketing" dùng trong mô phỏng tác tử AI là quy chế mẫu do tôi soạn, không phải quy chế của một doanh nghiệp cụ thể, và được ghi nhãn như vậy ở mọi nơi xuất hiện.

Thứ ba, tôi có sử dụng công cụ trí tuệ nhân tạo để hỗ trợ lập trình, rà soát mã nguồn và soạn thảo văn bản. Mọi lựa chọn đề tài, thiết kế nghiên cứu, cấu hình mô hình, diễn giải kết quả và kết luận đều do tôi quyết định và chịu trách nhiệm. Để hạn chế sai sót khi chuyển số liệu từ chương trình sang văn bản, tôi xây dựng một kịch bản đối chiếu tự động: các con số thập phân trong văn bản được so với tệp kết quả, dữ liệu gốc và nội dung slide; những con số không khớp trực tiếp (thường là hiệu số hoặc tỷ số tính từ các số có sẵn) được kiểm tra lại thủ công. Ngoài ra, chương trình có 24 kiểm tra tự động về tính nhất quán của đầu ra và 11 kiểm thử đơn vị cho các hàm lõi.

Các tài liệu tham khảo đều được trích dẫn theo đúng nguồn. Tôi không sao chép công trình của người khác dưới danh nghĩa của mình và không tạo ra số liệu không có nguồn gốc. Nếu có bất kỳ sai phạm nào, tôi xin hoàn toàn chịu trách nhiệm.

Thành phố Hồ Chí Minh, năm 2026

Học viên

Đinh Nguyễn Tấn Nguyên

# LỜI CẢM ƠN

Tôi xin chân thành cảm ơn TS. Trần Duy Thanh, giảng viên học phần Các mô hình dự báo trong kinh doanh, đã xây dựng một hệ thống bài giảng gắn chặt với bài toán của doanh nghiệp thương mại điện tử: từ việc chẩn đoán dữ liệu và mô hình kinh doanh, phân rã chuỗi thời gian, học máy cho dự báo quy mô lớn, dự báo xác suất và quản trị tồn kho, đến AI tạo sinh và tác tử AI hỗ trợ ra quyết định. Những tình huống thảo luận trên lớp, đặc biệt là tình huống chuẩn bị cho mùa chiến dịch Mega Sale 11/11, tình huống dòng tiền chiến dịch Mega Sale và các ví dụ về Unit Economics, là điểm xuất phát trực tiếp cho câu hỏi nghiên cứu của tiểu luận này. Bộ dữ liệu và mã nguồn minh họa thầy công bố giúp tôi có thể tái lập từng ví dụ tính tay trên slide trước khi mở rộng sang các phân tích sâu hơn.

Tôi xin cảm ơn Khoa Hệ thống Thông tin, Trường Đại học Kinh tế – Luật, đã tạo môi trường học tập và cung cấp tài liệu học phần. Tôi cũng xin cảm ơn các anh chị, các bạn trong lớp cao học Thương mại điện tử đã trao đổi, góp ý về cách đặt vấn đề và cách trình bày kết quả, đặc biệt là những góp ý về việc phân biệt rõ phần nội dung thuộc bài giảng với phần mở rộng của cá nhân.

Tôi biết ơn Cục Thống kê vì đã công bố đều đặn báo cáo tình hình kinh tế – xã hội hằng tháng trên cổng thông tin điện tử; nhờ đó, tiểu luận có thể đặt các phân tích trên dữ liệu mô phỏng bên cạnh một chuỗi số liệu thật về tiêu dùng của Việt Nam.

Cuối cùng, tôi xin cảm ơn gia đình đã luôn động viên trong suốt thời gian học tập. Dù đã cố gắng kiểm tra kỹ lưỡng, tiểu luận chắc chắn không tránh khỏi thiếu sót; tôi rất mong nhận được ý kiến đóng góp của thầy và các bạn.

# TÓM TẮT

Mùa Mega Sale – các ngày đôi như 9.9, 10.10, 11.11, 12.12 và giai đoạn mua sắm cuối năm – là thời điểm doanh nghiệp thương mại điện tử Việt Nam dồn phần lớn ngân sách quảng cáo và chiết khấu. Năm 2024, thị trường thương mại điện tử Việt Nam vượt 25 tỷ USD, tăng khoảng 20% và chiếm khoảng 9% tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng (Báo Công Thương, 2025); năm 2025, giá trị giao dịch trên bốn sàn lớn đạt 458.160 tỷ đồng, tăng 26% (Nam Linh, 2026). Trong bối cảnh đó, câu hỏi quản trị không chỉ là "chiến dịch bán được bao nhiêu" mà là "mỗi đồng quảng cáo và mỗi điểm phần trăm chiết khấu tạo ra bao nhiêu lợi nhuận, với mức bất định nào, và có hợp pháp, có đủ tiền mặt hay không". Tiểu luận xây dựng một quy trình năm tầng bám theo năm chương của học phần Các mô hình dự báo trong kinh doanh để trả lời câu hỏi này: chẩn đoán dữ liệu và Unit Economics, phân rã chuỗi thời gian, học máy toàn cục và ước lượng uplift khuyến mãi, dự báo xác suất và rủi ro chiến dịch, và tác tử AI phân bổ ngân sách có kiểm soát của con người.

Dữ liệu gồm mười hai bộ dữ liệu mô phỏng của học phần (20.501 dòng) và chuỗi 82 tháng tổng mức bán lẻ (TMBL) do Cục Thống kê công bố. Sản phẩm phần mềm gồm mười bốn stage xử lý chạy tuần tự (khoảng 5 phút trên máy 2 nhân), 24 kiểm tra tự động, 11 kiểm thử đơn vị và một dashboard Streamlit 12 trang, trong đó có các trang mô phỏng Mega Sale, phân bổ ngân sách, dòng tiền chiến dịch và trung tâm phê duyệt đề xuất của tác tử.

Các kết quả chính như sau. Ở tầng chẩn đoán, trên 90 ngày giao dịch, hệ số của chi phí quảng cáo lên số đơn giảm từ 9,08 xuống 7,31 khi đưa mức chiết khấu vào mô hình – thiên lệch bỏ sót biến khoảng 24,1%; ROAS trung bình là 5,50 nhưng ROAS biên sau khi kiểm soát chiết khấu và ngày Mega Sale chỉ là 2,45. Trên dữ liệu bảng ba ngành, hồi quy gộp cho độ dốc quảng cáo 1,05 trong khi mô hình hiệu ứng cố định cho 2,70; tổng GMV giảm 2,11% dù hai trong ba ngành tăng. Ngành FMCG có ROAS 2,03, thấp hơn ROAS hòa vốn 3,00, nên lỗ lũy kế 78,44 triệu VNĐ dù có nhiều đơn nhất. Ở tầng phân rã, mùa vụ năm giải thích phần lớn biến động của chuỗi ngày (độ mạnh 0,967), còn chi phí marketing không có quan hệ phát hiện được với phần dư (hệ số tương quan −0,026; kiểm định chung độ trễ 0–14 ngày có p = 0,9999). Với TMBL Việt Nam, hệ số mùa vụ cao nhất rơi vào tháng 11 (1,0415) và thấp nhất vào tháng 5 (0,9526); hiệu ứng tháng giãn cách là −29,6%; hiệu ứng cửa sổ trước Tết (+3,0%) không có ý nghĩa thống kê; đáng chú ý, hệ số mùa vụ tháng 11 giảm dần từ 1,0824 (2020) xuống 0,9994 (2025).

Ở tầng học máy, trên 100 SKU, LightGBM toàn cục với mục tiêu chuẩn hóa theo quy mô đạt WAPE 6,548%, so với 6,631% của Holt-Winters cục bộ; kiểm định Diebold–Mariano gộp mọi điểm cho p = 0,076, nhưng khi lấy trung bình chéo theo gốc và chân trời thì p < 0,001. Trên bộ 15 SKU, Holt-Winters lại tốt nhất (8,913% so với 9,192%). Một SKU mới chỉ cần bảy ngày lịch sử để WAPE giảm từ 38,75% (chỉ đặc trưng tĩnh) xuống 8,43%. So sánh thô cho thấy cầu ngày đôi cao hơn 15,3% so với trung bình tuần, nhưng sau khi kiểm soát thứ trong tuần chỉ còn 0,79% (p = 0,273): "hiệu ứng ngày đôi" trong dữ liệu này là hiệu ứng cuối tuần. Ở tầng xác suất, phân vị phần dư thực nghiệm và Quantile LightGBM cho pinball thấp nhất (5,410 và 5,414), tốt hơn DeepAR (5,741) và vượt xa dải heuristic trong mã minh họa của học phần (13,100). Chuẩn bị hàng theo phân vị tới hạn q* mang lại lợi nhuận 663.207,1 triệu VNĐ (94,76% mức lợi nhuận khi biết trước cầu), cao hơn đặt theo P50 (659.032,6) và đặt P90 cho mọi SKU (626.277,9). Phân phối bootstrap cho thấy xác suất lỗ khi tăng quảng cáo FMCG là 100%. Kiểm tra bỏ-một-ngày trên hai ngày Mega Sale cho thấy khoảng dự báo 80% không phủ được GMV thực tế ở cả hai ngày.

Ở tầng tác tử, tối ưu hóa phân bổ ngân sách quảng cáo giữa ba ngành trong vùng dữ liệu đã quan sát nâng lợi nhuận gộp sau quảng cáo từ 61,93 lên 71,73 triệu VNĐ/ngày với cùng ngân sách; trong 1.000 lần bootstrap, phương án tối ưu luôn tốt hơn hiện trạng. Tác tử lập kế hoạch chiến dịch (RAG, công cụ dự báo, kiểm tra pháp lý theo mức giảm giá tối đa 50%, quy chế phê duyệt) xử lý 12 đề xuất: 3 tự động duyệt, 8 chuyển người duyệt và 1 bị từ chối. Biên đóng góp của hai ngày Mega Sale (chiết khấu 50%) đổi dấu theo giả định giá vốn: dương (46,26 và 40,78 triệu VNĐ) nếu giá vốn là tỷ lệ cố định theo GMV, âm (−10,48 và −24,57 triệu VNĐ) nếu giá vốn tính theo giá niêm yết. Mô phỏng dòng tiền cho thấy với lead time 30 ngày, tiền mặt tối thiểu tăng từ 1.228,8 triệu VNĐ (đối soát tức thì) lên 2.027,7 triệu VNĐ (trễ 14 ngày); hai ngày Mega Sale khóa thêm tối đa 139,28 triệu VNĐ trong 72–79 ngày.

Đóng góp của tiểu luận gồm một khung tích hợp năm tầng có sản phẩm phần mềm tái lập được; bằng chứng tái lập các ví dụ của học phần kèm báo cáo các điểm chưa khớp; và các nguyên tắc thiết kế tác tử AI đặt ràng buộc kinh tế, pháp lý và dòng tiền lên trên khả năng sinh văn bản. Hạn chế chính là dữ liệu cấp doanh nghiệp là dữ liệu mô phỏng, trong đó cả hai ngày Mega Sale đều có cùng mức chiết khấu 50%, nên hiệu ứng sự kiện và hiệu ứng chiết khấu không tách được; các kết luận cần được kiểm định lại bằng dữ liệu giao dịch và thử nghiệm có đối chứng của doanh nghiệp Việt Nam.

Từ khóa: Mega Sale; hiệu quả quảng cáo; uplift khuyến mãi; Unit Economics; MSTL; LightGBM toàn cục; dự báo xác suất; Newsvendor; phân bổ ngân sách; tác tử AI; Human-in-the-loop; thương mại điện tử Việt Nam.

# ABSTRACT

Mega Sale seasons – the "double days" such as 9.9, 10.10, 11.11 and 12.12 and the year-end shopping period – are when Vietnamese e-commerce firms concentrate most of their advertising and discount budgets. In 2024 the Vietnamese e-commerce market exceeded USD 25 billion, growing by about 20% and accounting for about 9% of total retail sales of goods and consumer services; in 2025 the gross merchandise value on the four largest marketplaces reached VND 458,160 billion, up 26%. This term paper builds a five-layer workflow that follows the five chapters of the course Business Forecasting Models: data and unit-economics diagnosis, time-series decomposition, global machine learning and promotion uplift, probabilistic forecasting and campaign risk, and an AI agent that allocates the marketing budget under human oversight.

The data consist of twelve synthetic course datasets (20,501 rows) and 82 months of official retail sales published by the General Statistics Office of Vietnam. The software comprises fourteen sequential pipeline stages, 24 automated checks, 11 unit tests and a 12-page Streamlit dashboard with interactive Mega Sale, budget-allocation, cash-flow and approval pages.

On 90 days of transactions, the advertising coefficient on orders falls from 9.08 to 7.31 once the discount rate is controlled for (about 24.1% omitted-variable bias); average ROAS is 5.50 while marginal ROAS is 2.45. Pooled panel regression gives an advertising slope of 1.05 against 2.70 under category fixed effects. The FMCG category has ROAS 2.03 below its break-even ROAS of 3.00 and loses VND 78.44 million despite having the most orders. Yearly seasonality dominates the daily revenue series (strength 0.967), whereas marketing spend shows no detectable relation with the residual (r = −0.026; joint lag test p = 0.9999). Vietnamese retail sales peak seasonally in November (1.0415) and trough in May (0.9526); the November factor declines from 1.0824 in 2020 to 0.9994 in 2025.

A global LightGBM model reaches WAPE 6.548% on 100 SKUs versus 6.631% for local Holt-Winters, but Holt-Winters wins on 15 SKUs. Seven days of history reduce WAPE for new SKUs from 38.75% to 8.43%. A naive comparison suggests a 15.3% double-day uplift, which shrinks to 0.79% (p = 0.273) after controlling for day of week. Empirical residual quantiles and quantile LightGBM give the lowest pinball loss (5.410 and 5.414); ordering at the critical fractile yields VND 663,207.1 million, 94.76% of the perfect-foresight profit. Leave-one-out checks on the two Mega Sale days show that 80% intervals miss both actual values.

Optimising the advertising budget across three categories within the observed data range raises daily contribution after advertising from VND 61.93 million to 71.73 million. The campaign-planning agent processes 12 proposals: 3 are auto-approved, 8 are escalated to a human reviewer and 1 is rejected for exceeding the legal 50% discount cap. The profitability of the Mega Sale days changes sign with the cost-of-goods assumption, and with a 30-day lead time the minimum cash buffer rises from VND 1,228.8 million to 2,027.7 million as the settlement lag grows from 0 to 14 days. The firm-level data are synthetic and both Mega Sale days carry the same 50% discount, so event and discount effects cannot be separated; the conclusions should be re-tested on real transaction data and controlled experiments.

Keywords: Mega Sale; advertising effectiveness; promotion uplift; unit economics; global forecasting; probabilistic forecasting; newsvendor; budget allocation; AI agents; human-in-the-loop; Vietnam e-commerce.

# DANH MỤC TỪ VIẾT TẮT

[[T:@viettat Danh mục từ viết tắt sử dụng trong tiểu luận
Từ viết tắt | Tiếng Anh | Nghĩa tiếng Việt
AI | Artificial Intelligence | Trí tuệ nhân tạo
AIC | Akaike Information Criterion | Tiêu chuẩn thông tin Akaike
AOV | Average Order Value | Giá trị trung bình mỗi đơn hàng
CAC | Customer Acquisition Cost | Chi phí quảng cáo cho một đơn hàng
CK | – | Chiết khấu
CM | Contribution Margin | Biên đóng góp
COGS | Cost of Goods Sold | Giá vốn hàng bán
CSL | Cycle Service Level | Mức phục vụ chu kỳ
CV | Coefficient of Variation | Hệ số biến thiên
DM | Diebold–Mariano test | Kiểm định Diebold–Mariano
EDA | Exploratory Data Analysis | Phân tích khám phá dữ liệu
ERP | Enterprise Resource Planning | Hệ thống hoạch định nguồn lực doanh nghiệp
ETS | Error–Trend–Seasonal | Mô hình làm trơn mũ
FE | Fixed Effects | Hiệu ứng cố định
FMCG | Fast-Moving Consumer Goods | Hàng tiêu dùng nhanh
GAM | Generalized Additive Model | Mô hình cộng tổng quát
GB | Gradient Boosting | Tăng cường độ dốc
GMV | Gross Merchandise Value | Tổng giá trị hàng hóa giao dịch
GV | – | Giảng viên (dữ liệu học phần)
HAC | Heteroskedasticity and Autocorrelation Consistent | Sai số chuẩn vững với phương sai thay đổi và tự tương quan
HITL | Human-in-the-loop | Con người trong vòng lặp phê duyệt
HP | Hodrick–Prescott filter | Bộ lọc Hodrick–Prescott
HW | Holt-Winters | Mô hình Holt-Winters
KM | – | Khuyến mại/khuyến mãi
LGBM | LightGBM | Thư viện Gradient Boosting của Microsoft
LLM | Large Language Model | Mô hình ngôn ngữ lớn
LN | – | Lợi nhuận
LOO | Leave-One-Out | Bỏ một quan sát để kiểm tra
MAE | Mean Absolute Error | Sai số tuyệt đối trung bình
MAD | Median Absolute Deviation | Độ lệch tuyệt đối trung vị
MAPE | Mean Absolute Percentage Error | Sai số phần trăm tuyệt đối trung bình
MASE | Mean Absolute Scaled Error | Sai số tuyệt đối chuẩn hóa trung bình
MRR | Mean Reciprocal Rank | Thứ hạng nghịch đảo trung bình
MSTL | Multiple Seasonal-Trend decomposition using LOESS | Phân rã đa mùa vụ dựa trên LOESS
NĐ | – | Nghị định
OLS | Ordinary Least Squares | Bình phương nhỏ nhất thông thường
OVB | Omitted Variable Bias | Thiên lệch bỏ sót biến
P@1 | Precision at 1 | Độ chính xác ở vị trí đầu
PI | Prediction Interval | Khoảng dự báo
QC | – | Quảng cáo
RAG | Retrieval-Augmented Generation | Sinh văn bản tăng cường truy xuất
RMSE | Root Mean Squared Error | Căn sai số bình phương trung bình
ROAS | Return on Ad Spend | Doanh thu trên chi phí quảng cáo
ROP | Reorder Point | Điểm đặt hàng lại
RQ | Research Question | Câu hỏi nghiên cứu
SARIMA | Seasonal ARIMA | Mô hình ARIMA mùa vụ
SKU | Stock Keeping Unit | Mã hàng
SS | Safety Stock | Tồn kho an toàn
STL | Seasonal-Trend decomposition using LOESS | Phân rã mùa vụ – xu hướng dựa trên LOESS
TF-IDF | Term Frequency – Inverse Document Frequency | Trọng số tần suất từ – nghịch đảo tần suất tài liệu
TMBL | – | Tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng
TMĐT | – | Thương mại điện tử
VNĐ | – | Việt Nam đồng
WAPE | Weighted Absolute Percentage Error | Sai số phần trăm tuyệt đối có trọng số
Nguồn: Tác giả tổng hợp.
]]
