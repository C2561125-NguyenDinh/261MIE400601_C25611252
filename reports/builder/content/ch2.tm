# CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ TỔNG QUAN NGHIÊN CỨU

Chương này xây dựng nền tảng lý thuyết cho bài toán trung tâm của tiểu luận: đo lường hiệu quả của quảng cáo và khuyến mãi, dự báo giá trị giao dịch (GMV) trong mùa Mega Sale và chuyển các dự báo đó thành quyết định phân bổ ngân sách marketing có kiểm soát. Trình tự trình bày đi theo mạch logic của học phần Các mô hình dự báo trong kinh doanh: các khái niệm kinh tế của marketing trong thương mại điện tử (TMĐT), chẩn đoán dữ liệu, phân rã chuỗi thời gian, học máy toàn cục, dự báo xác suất và cuối cùng là tác tử trí tuệ nhân tạo (AI) hỗ trợ quyết định. Ở mỗi khối, tiểu luận phân biệt hai lớp nội dung. Lớp thứ nhất là khái niệm, công thức và ví dụ tính tay được giảng viên trình bày trong slide bài giảng (Trần Duy Thanh, 2026a); các trang slide được dẫn cụ thể để người đọc đối chiếu. Lớp thứ hai là phần mở rộng học thuật của tác giả, dựa trên các tài liệu kinh điển về mô hình phản hồi thị trường, khuyến mãi, suy luận nhân quả, dự báo và tối ưu hóa, nhằm làm rõ giả định, giới hạn và cách đánh giá của từng phương pháp. Chương 2 chỉ trình bày lý thuyết và các ví dụ minh họa của slide; mọi kết quả thực nghiệm của tiểu luận được để dành cho Chương 4.

Mục 2.1 định nghĩa các đại lượng kinh tế của marketing TMĐT và các mô hình phản hồi quảng cáo – khuyến mãi. Mục 2.2 tổng hợp kỹ thuật chẩn đoán dữ liệu, trong đó thiên lệch bỏ sót biến và tính dị biệt giữa các ngành là hai vấn đề có hệ quả trực tiếp đối với đo lường hiệu quả quảng cáo. Mục 2.3 trình bày họ phương pháp phân rã chuỗi thời gian và cách mô hình hóa sự kiện lịch. Mục 2.4 chuyển sang học máy toàn cục và ước lượng uplift khuyến mãi, phân biệt rõ dự báo có điều kiện với ước lượng nhân quả. Mục 2.5 đặt nền tảng cho dự báo xác suất, mô hình Newsvendor và đánh giá rủi ro tài chính của chiến dịch. Mục 2.6 trình bày khung lý thuyết về tác tử AI và bài toán phân bổ ngân sách đa mục tiêu. Mục 2.7 tóm tắt khung pháp lý khuyến mại và cơ chế đối soát của sàn tại Việt Nam – hai ràng buộc thể chế mà mọi đề xuất chiến dịch phải tuân thủ. Mục 2.8 tổng quan các nghiên cứu liên quan và chỉ ra khoảng trống; Mục 2.9 tổng hợp thành khung phân tích của tiểu luận.

## 2.1. Kinh tế học marketing trong thương mại điện tử

### 2.1.1. Dự báo như một quá trình lượng hóa rủi ro

Slide mở đầu học phần định nghĩa bản chất kinh tế của dự báo: dự báo không phải là hành vi phỏng đoán tương lai một cách ngẫu nhiên, mà là quá trình lượng hóa các biến số kinh doanh nhằm giảm thiểu rủi ro trong điều kiện bất định (Trần Duy Thanh, 2026a, Ch1 tr.4). Tình huống minh họa là một doanh nghiệp gia dụng chuẩn bị cho chiến dịch 11/11: nếu ban quản lý dựa vào cảm tính kiểu "năm ngoái bán 1.000 cái, năm nay cứ nhập 3.000 cái", doanh nghiệp có thể chỉ bán được 800 cái và phải chôn vốn vào 2.200 sản phẩm tồn kho (Trần Duy Thanh, 2026a, Ch1 tr.5). Cách tiếp cận đúng là tách bài toán thành các biến số định lượng như tốc độ tăng trưởng lịch sử, ngân sách marketing, lưu lượng truy cập và độ co giãn giá, rồi kết hợp chúng thành một dự báo có căn cứ (Trần Duy Thanh, 2026a, Ch1 tr.6). Đáng chú ý là chính tình huống mở đầu của học phần đã là một tình huống Mega Sale, và các biến được nêu – ngân sách marketing, độ co giãn giá – là những biến điều khiển mà phòng marketing nắm trong tay. Điều này cho thấy dự báo trong mùa khuyến mãi không phải là bài toán thụ động "đoán xem khách sẽ mua bao nhiêu" mà là bài toán có điều kiện "nếu ta chi bao nhiêu và giảm giá bao nhiêu thì kết quả sẽ phân bố ra sao".

Slide phân biệt hai tầng dự báo. Dự báo vĩ mô (macro-forecasting) hướng tới tổng cầu và tổng doanh thu, phục vụ chiến lược tài chính dài hạn. Dự báo vi mô (micro-forecasting) đi tới độ chi tiết SKU × kho × ngày, là trọng tâm của TMĐT vì nó chi phối trực tiếp dòng tiền thông qua tự động hóa đặt hàng và phân bổ tồn kho (Trần Duy Thanh, 2026a, Ch1 tr.7). Tiểu luận sử dụng cả hai tầng: chuỗi tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng (TMBL) của Việt Nam đại diện cho tầng vĩ mô – nơi có thể kiểm tra xem "mùa mua sắm cuối năm" có để lại dấu vết trong số liệu tiêu dùng của nền kinh tế hay không – còn các bộ dữ liệu cấp shop, ngành hàng và SKU của học phần đại diện cho tầng vi mô, nơi diễn ra các quyết định về quảng cáo, chiết khấu và chuẩn bị hàng.

Từ hai tầng đó, slide xây dựng một hệ sinh thái dự báo sáu lớp (Trần Duy Thanh, 2026a, Ch1 tr.11–18). Lớp 1 xác định bài toán: dự báo nhu cầu, tài chính, khách hàng, marketing, chuỗi cung ứng và giá. Lớp 2 xác định các chiều của bài toán: tầm nhìn thời gian, độ chi tiết và loại dự báo (điểm, khoảng, phân phối xác suất). Lớp 3 là các yếu tố tác động, gồm biến nội sinh (giá, khuyến mãi, tồn kho), biến ngoại sinh (chỉ số giá, thu nhập, lịch lễ) và tín hiệu số (xu hướng tìm kiếm, thảo luận mạng xã hội). Lớp 4 là ngăn xếp công nghệ, từ tầng dữ liệu đến tầng mô hình và tầng vận hành. Lớp 5 là người sử dụng dự báo, trong đó có bộ phận marketing. Lớp 6 là quyết định và giá trị. Tiểu luận kế thừa quan điểm rằng giá trị của dự báo chỉ được hiện thực hóa ở lớp 6; với bài toán marketing, lớp 6 cụ thể là ba quyết định: chi bao nhiêu cho quảng cáo, giảm giá bao nhiêu, và phân bổ ngân sách cho ngành hàng nào.

Quan điểm ấy được cụ thể hóa trong vòng đời dự án dự báo gồm bảy giai đoạn (Trần Duy Thanh, 2026a, Ch1 tr.19–31): hiểu bài toán kinh doanh; thu thập và tích hợp dữ liệu; chuẩn bị dữ liệu và xây dựng đặc trưng; xây dựng và đánh giá mô hình; triển khai và tích hợp vào quy trình; giám sát và phát hiện trôi dạt; học liên tục và tái huấn luyện. Slide nhấn mạnh giai đoạn đầu tiên là quan trọng nhất, vì mục tiêu không phải chọn thuật toán mà là xác định doanh nghiệp cần ra quyết định gì (Trần Duy Thanh, 2026a, Ch1 tr.22). Slide cũng lưu ý rằng chất lượng đặc trưng thường ảnh hưởng tới độ chính xác nhiều hơn việc thay đổi thuật toán (Trần Duy Thanh, 2026a, Ch1 tr.25), và việc chọn mô hình phải cân nhắc cả thời gian huấn luyện, khả năng mở rộng và khả năng giải thích chứ không chỉ sai số (Trần Duy Thanh, 2026a, Ch1 tr.27). Đối với marketing, khả năng giải thích có trọng lượng đặc biệt: một mô hình chỉ cho biết "GMV ngày mai bằng 180 triệu" mà không cho biết phần nào đến từ quảng cáo và phần nào đến từ giảm giá thì không giúp được nhà quản trị phân bổ ngân sách.

### 2.1.2. Hệ thước đo kinh tế đơn vị (Unit Economics)

Nguyên lý quản trị nền tảng được slide phát biểu rõ: không bao giờ dự báo để mở rộng một mô hình kinh doanh đang thất bại từ cốt lõi; nếu doanh nghiệp đang lỗ trên mỗi đơn hàng, dùng thuật toán để thúc đẩy tăng trưởng thực chất chỉ là dự báo tốc độ phá sản (Trần Duy Thanh, 2026a, Ch1 tr.109). Nguyên lý này đặc biệt đúng với marketing, vì quảng cáo và khuyến mãi là hai công cụ "thúc đẩy tăng trưởng" trực tiếp nhất. Trước khi dự báo, cần chuẩn hóa quy mô kinh doanh về một hệ quy chiếu chung bằng bốn thước đo tỷ lệ. Với ngành hàng i và kỳ quan sát t, các thước đo được định nghĩa trên tổng tích lũy chứ không phải trung bình của các tỷ số theo ngày (Trần Duy Thanh, 2026a, Ch1 tr.110–111, tr.116–117).

$ AOV~i~ = Σ~t~ GMV~i,t~ / Σ~t~ Orders~i,t~

$ CAC~i~ = Σ~t~ Ad_Spend~i,t~ / Σ~t~ Orders~i,t~

$ ROAS~i~ = Σ~t~ GMV~i,t~ / Σ~t~ Ad_Spend~i,t~

$ CM~i~ = AOV~i~ − (CAC~i~ + COGS~i~)

Trong đó GMV (Gross Merchandise Value) là tổng giá trị hàng hóa giao dịch, AOV (Average Order Value) là giá trị trung bình mỗi đơn, CAC (Customer Acquisition Cost) ở đây được hiểu là chi phí quảng cáo bình quân để có một đơn hàng thành công, ROAS (Return on Ad Spend) là doanh thu thu về trên mỗi đồng quảng cáo, và CM (Contribution Margin) là biên đóng góp trên mỗi đơn sau khi trừ chi phí thu hút và giá vốn hàng bán (COGS). Slide gọi CM là "chỉ số sinh tử": mô hình kinh doanh chỉ bền vững khi CM > 0 (Trần Duy Thanh, 2026a, Ch1 tr.111). Việc dùng tổng tích lũy là một lựa chọn phương pháp luận có ý nghĩa: trung bình của các tỷ số theo ngày gán trọng số bằng nhau cho một ngày có 10 đơn và một ngày có 500 đơn, trong khi tỷ số của các tổng gán trọng số theo quy mô giao dịch thực tế. Với dữ liệu có ngày Mega Sale, khác biệt này không nhỏ: một ngày sự kiện có thể chiếm vài phần trăm GMV của cả quý, và trung bình tỷ số ngày sẽ đánh giá thấp vai trò của ngày đó.

Từ bốn thước đo, slide đề xuất một ma trận chiến lược (Trần Duy Thanh, 2026a, Ch1 tr.112). Vùng đốt tiền (Bleeding Zone) xảy ra khi CAC > AOV, tức chi phí lôi kéo khách còn đắt hơn số tiền khách trả. Vùng bò sữa (Cash Cow) xảy ra khi AOV vượt xa tổng CAC và COGS và ROAS rất cao; đây là nơi nên dồn ngân sách. Ví dụ 1 của slide về ngành FMCG trong ba ngày chạy quảng cáo cho thấy cái bẫy của ROAS: tổng GMV 36 triệu đồng, tổng quảng cáo 15 triệu đồng, 300 đơn, suy ra AOV = 0,12, CAC = 0,05 và ROAS = 2,4; với COGS 0,09 triệu đồng/đơn thì CM = 0,12 − (0,05 + 0,09) = −0,02 triệu đồng/đơn (Trần Duy Thanh, 2026a, Ch1 tr.113–115). ROAS lớn hơn 1 và GMV trông khả quan, nhưng mỗi đơn hàng thực chất làm doanh nghiệp lỗ 20.000 đồng.

Tiểu luận mở rộng ví dụ trên thành một điều kiện hòa vốn tổng quát. Viết lại CM theo ROAS bằng cách để ý rằng CAC = AOV/ROAS, ta có:

$ CM = AOV − AOV/ROAS − COGS = AOV·(1 − 1/ROAS) − COGS

Điều kiện CM ≥ 0 tương đương với:

$ ROAS ≥ ROAS~BE~ = AOV / (AOV − COGS), với AOV > COGS

và tương đương với một trần chi phí thu hút:

$ CAC ≤ CAC~max~ = AOV − COGS

Đại lượng ROAS~BE~ (break-even ROAS) cho biết ngưỡng hiệu quả quảng cáo tối thiểu mà một ngành hàng phải đạt để không lỗ trên đơn vị, còn CAC~max~ là số tiền quảng cáo tối đa được phép chi để có một đơn. Hai công thức này làm rõ một hàm ý mà ma trận chiến lược của slide mới ngầm định: ngành có biên gộp mỏng đòi hỏi ROAS rất cao để hòa vốn, nên cùng một mức ROAS có thể là "tốt" với ngành này nhưng là "lỗ" với ngành khác. Áp vào ví dụ FMCG của slide, ROAS~BE~ = 0,12/(0,12 − 0,09) = 4, cao hơn nhiều so với ROAS thực tế 2,4, giải thích vì sao CM âm. Hệ quả thứ hai là có ba đòn bẩy để thoát vùng lỗ: tăng AOV (bán kèm, bán combo), giảm COGS, hoặc cải thiện hiệu quả quảng cáo. Hệ quả thứ ba, ít được chú ý hơn, là giảm giá tác động lên cả AOV lẫn ROAS~BE~: khi chiết khấu tăng, AOV sau giảm giá giảm trong khi giá vốn của giỏ hàng không đổi, nên ROAS~BE~ tăng – chiến dịch giảm giá sâu tự nâng cao ngưỡng hiệu quả mà chính quảng cáo của nó phải vượt qua.

Để chính thức hóa hệ quả thứ ba, gọi P là giá trị giỏ hàng theo giá niêm yết, δ là tỷ lệ chiết khấu và c là tỷ lệ giá vốn trên giá niêm yết. Khi đó AOV = P·(1 − δ), COGS = c·P và:

$ ROAS~BE~(δ) = (1 − δ) / (1 − δ − c), với δ < 1 − c

Hàm này tăng theo δ và tiến ra vô cùng khi δ → 1 − c: ở mức chiết khấu bằng biên gộp theo giá niêm yết, không có mức ROAS nào đủ để hòa vốn. Đây là lý do mà tiểu luận, khi đánh giá biên đóng góp của ngày Mega Sale ở Chương 3 và Chương 4, xem xét song song hai giả định kế toán: giá vốn tỷ lệ cố định theo GMV (bỏ qua việc chiết khấu ăn vào biên) và giá vốn tỷ lệ theo giá trị trước chiết khấu. Bảng {T:@c2m_thuocdo} tổng hợp hệ thước đo kinh tế đơn vị được sử dụng trong tiểu luận.

[[T:@c2m_thuocdo Hệ thước đo kinh tế đơn vị của marketing TMĐT và ý nghĩa quản trị
Thước đo | Công thức | Ý nghĩa quản trị | Nguồn
GMV | Σ giá trị đơn thành công | Quy mô giao dịch, chưa phản ánh lợi nhuận | Ch1 tr.55
AOV | Σ GMV / Σ Orders | Sức mua mỗi giỏ hàng, năng lực bán chéo | Ch1 tr.110
CAC | Σ Ad_Spend / Σ Orders | Chi phí quảng cáo bình quân để có một đơn | Ch1 tr.110
ROAS | Σ GMV / Σ Ad_Spend | Đòn bẩy marketing, dễ gây ảo giác hiệu quả | Ch1 tr.111
CM | AOV − (CAC + COGS) | Chỉ số sinh tử; bền vững khi CM > 0 | Ch1 tr.111
ROAS hòa vốn | AOV / (AOV − COGS) | Ngưỡng ROAS tối thiểu để CM ≥ 0 | Mở rộng của tác giả
CAC tối đa | AOV − COGS | Trần chi phí quảng cáo cho một đơn | Mở rộng của tác giả
ROAS hòa vốn theo chiết khấu | (1 − δ)/(1 − δ − c) | Giảm giá sâu nâng ngưỡng hiệu quả quảng cáo | Mở rộng của tác giả
Lãi/lỗ lũy kế | CM × Σ Orders | Tác động tài chính tổng của ngành hàng | Ch1 tr.121
Nguồn: Tổng hợp từ Trần Duy Thanh (2026a) và mở rộng của tác giả.
]]

### 2.1.3. Mô hình phản hồi quảng cáo: tác động trễ, bão hòa và lợi suất biên

Các thước đo ở Mục 2.1.2 là thước đo trung bình: ROAS cho biết mỗi đồng quảng cáo đã chi "đi kèm" bao nhiêu đồng GMV, nhưng không cho biết đồng quảng cáo tiếp theo sẽ mang lại bao nhiêu. Quyết định phân bổ ngân sách lại cần chính đại lượng thứ hai. Văn liệu về mô hình phản hồi thị trường (market response models) chính thức hóa khác biệt này bằng cách mô hình hóa doanh số như một hàm của các biến marketing, rồi đọc hiệu quả biên từ đạo hàm của hàm đó (Hanssens và cộng sự, 2001). Dạng đơn giản nhất là hồi quy tuyến tính của số đơn theo chi phí quảng cáo:

$ Orders~t~ = α + β · Ad~t~ + ε~t~

trong đó β là số đơn tăng thêm cho mỗi đơn vị tiền quảng cáo. Nếu biên gộp của một đơn (trước quảng cáo) là g = AOV − COGS, thì lợi nhuận biên của một đơn vị quảng cáo bằng:

$ ∂Π/∂Ad = β · g − 1

và chi thêm quảng cáo chỉ có lãi khi β·g > 1, tức khi ROAS biên β·AOV vượt ROAS~BE~. Điều kiện này khác với điều kiện ROAS trung bình > ROAS~BE~ ở Mục 2.1.2: một ngành có thể có ROAS trung bình cao (vì phần lớn đơn hàng đến từ nhu cầu nền, không phụ thuộc quảng cáo) nhưng ROAS biên thấp, và ngược lại. Phân biệt giữa hiệu quả trung bình và hiệu quả biên là nền tảng của mọi bài toán phân bổ ngân sách ở Mục 2.6.6.

Mô hình tuyến tính có hai giới hạn mà văn liệu đã chỉ ra từ lâu. Giới hạn thứ nhất là lợi suất biên giảm dần. Slide minh họa hiện tượng này trên biểu đồ hồi quy đơn hàng theo quảng cáo: dải tin cậy phình to khi chi phí quảng cáo vượt khoảng 20 triệu đồng/ngày, và slide diễn giải rằng khi doanh nghiệp "bơm quá nhiều tiền" vào một tệp khách hàng có giới hạn, thuật toán quảng cáo bắt đầu tiếp cận những người kém tiềm năng hơn, nên "ngân sách tăng gấp đôi chưa chắc đơn hàng tăng gấp đôi" (Trần Duy Thanh, 2026a, Ch1 tr.69). Hai dạng hàm thường dùng để biểu diễn lợi suất giảm dần là hàm logarit và hàm bão hòa dạng Hill:

$ Orders~t~ = α + β · ln(Ad~t~) + ε~t~

$ Orders~t~ = c + V~max~ · Ad~t~^s^ / (K^s^ + Ad~t~^s^) + ε~t~

Với dạng logarit, sản phẩm biên ∂Orders/∂Ad = β/Ad giảm tỷ lệ nghịch với mức chi; với dạng Hill, V~max~ là mức đơn tăng thêm tối đa có thể đạt, K là mức chi tại đó đạt một nửa V~max~ và s điều chỉnh độ dốc của đường cong chữ S. Jin và cộng sự (2017) dùng dạng Hill trong khung mô hình hỗn hợp truyền thông (media mix model) để biểu diễn hiệu ứng "hình dạng" của chi tiêu quảng cáo. Một hệ quả trực tiếp của dạng logarit là độ co giãn của số đơn theo quảng cáo không đổi khi mô hình được viết ở dạng log–log:

$ ln(Orders~t~) = a + e · ln(Ad~t~) + ε~t~, với e = (∂Orders/∂Ad)·(Ad/Orders)

trong đó e cho biết phần trăm thay đổi của số đơn khi quảng cáo tăng 1%. Độ co giãn nhỏ hơn 1 nghĩa là tăng gấp đôi ngân sách làm số đơn tăng ít hơn gấp đôi, đúng với lời cảnh báo của slide.

Giới hạn thứ hai là tác động trễ. Quảng cáo hôm nay có thể còn ảnh hưởng tới doanh số những ngày sau do người xem ghi nhớ thương hiệu, lưu sản phẩm vào giỏ hoặc quay lại mua. Broadbent (1979) đề xuất khái niệm "adstock" để biểu diễn lượng quảng cáo tích lũy suy giảm dần theo thời gian:

$ A~t~ = Ad~t~ + λ · A~t−1~, với 0 ≤ λ < 1

$ Orders~t~ = α + β · A~t~ + ε~t~

Tham số λ là tỷ lệ tác động còn lại sau mỗi kỳ; λ = 0 quay về mô hình không có trễ, λ gần 1 là quảng cáo có tác động dài hạn. Khai triển đệ quy cho thấy A~t~ = Σ~k≥0~ λ^k^·Ad~t−k~, tức adstock là một trường hợp đặc biệt của mô hình độ trễ phân phối (distributed lag) với các hệ số giảm theo cấp số nhân:

$ Orders~t~ = α + Σ~k=0~^K^ β~k~ · Ad~t−k~ + ε~t~

Mô hình độ trễ phân phối tổng quát hơn vì không áp đặt hình dạng cho β~k~, nhưng tốn nhiều tham số hơn. Tổng tác động dài hạn của một đơn vị quảng cáo là Σ~k~ β~k~, hoặc β/(1 − λ) trong mô hình adstock. Jin và cộng sự (2017) kết hợp adstock và bão hòa trong cùng một mô hình và chỉ ra rằng với dữ liệu quan sát có độ biến thiên hạn chế, các tham số hình dạng thường khó nhận dạng chính xác; đây là một lời cảnh báo phương pháp luận quan trọng cho nghiên cứu sử dụng chuỗi ngắn.

Từ góc độ kiểm định, mô hình adstock và độ trễ phân phối cho phép đặt một giả thuyết có thể bác bỏ: "chi phí marketing không giải thích được biến động doanh thu sau khi đã loại bỏ mùa vụ". Giả thuyết không tương ứng với β = 0 (với mọi λ) hoặc β~0~ = β~1~ = … = β~K~ = 0. Kiểm định phải thực hiện trên chuỗi đã khử mùa vụ, vì nếu ngân sách marketing được tăng theo mùa (chi nhiều vào mùa cao điểm), tương quan thô giữa chi tiêu và doanh thu sẽ phản ánh mùa vụ chung chứ không phải hiệu quả quảng cáo. Ngược lại, nếu kiểm định không bác bỏ được giả thuyết không, cần phân biệt hai khả năng: quảng cáo thực sự không có tác dụng, hoặc dữ liệu không đủ mạnh để phát hiện tác dụng. Khả năng thứ hai được đánh giá bằng phân tích công suất: cấy một hiệu ứng có kích thước biết trước vào chuỗi thật và kiểm tra xem quy trình có phát hiện được hay không. Tiểu luận áp dụng logic này ở Chương 3.

### 2.1.4. Khuyến mãi, sự kiện Mega Sale và cấu trúc nhu cầu đặc thù của TMĐT

Một đặc điểm phân biệt TMĐT với bán lẻ truyền thống là mật độ và cường độ của các sự kiện khuyến mãi do sàn tổ chức. Slide học phần nhiều lần dùng các ngày Mega Sale làm ví dụ cho các cú sốc doanh số đột ngột (Trần Duy Thanh, 2026a, Ch1 tr.4, tr.63), và đặt case study dòng tiền của Chương 2 vào đúng bối cảnh một chiến dịch Mega Sale làm doanh số tăng gấp năm lần (Trần Duy Thanh, 2026a, Ch2 tr.103). Khi phân tích chuỗi GMV 90 ngày, slide diễn giải hai đỉnh nhọn giữa tháng 8 và cuối tháng 9 là các chiến dịch Mega Sale, trong đó doanh nghiệp "có thể đã phải đốt gấp đôi tiền quảng cáo và hy sinh biên lợi nhuận cực lớn với mức giảm giá chạm sàn 50%" (Trần Duy Thanh, 2026a, Ch1 tr.63). Câu diễn giải này chứa ba ý mà tiểu luận tách ra để kiểm định riêng: quảng cáo và chiết khấu đồng thời tăng trong ngày sự kiện, chiết khấu sâu làm mất biên, và doanh số tăng đột biến không đồng nghĩa với lợi nhuận tăng.

Văn liệu marketing về khuyến mãi phân rã phản ứng của người mua trước một đợt giảm giá thành nhiều thành phần. Gupta (1988) phân tách mức tăng doanh số của một thương hiệu trong kỳ khuyến mãi thành ba quyết định của người tiêu dùng: khi nào mua (dịch chuyển thời điểm mua), mua gì (chuyển đổi thương hiệu) và mua bao nhiêu (tích trữ); kết quả của ông cho thấy phần lớn mức tăng doanh số đến từ chuyển đổi thương hiệu chứ không phải tăng tiêu dùng. Blattberg và cộng sự (1995) tổng kết các quy luật thực nghiệm về khuyến mãi, trong đó có nhận định rằng khuyến mãi giảm giá tạm thời làm doanh số tăng mạnh trong ngắn hạn. van Heerde và cộng sự (2000) chỉ ra rằng các "hố" doanh số trước và sau kỳ khuyến mãi (pre- and post-promotion dips) có thể được ước lượng từ dữ liệu cấp cửa hàng, và việc bỏ qua chúng làm đánh giá quá cao hiệu quả ròng của khuyến mãi. Các quan sát này thống nhất với hai hiện tượng mà slide nêu cho bối cảnh TMĐT: hiệu ứng "kéo cầu về hiện tại" (demand pull-forward), khi khách hàng "đã gom hết tiền để mua hàng giá rẻ trong ngày Sale" và rơi vào trạng thái "no nê" sau đó (Trần Duy Thanh, 2026a, Ch1 tr.63); và hiệu ứng "ăn mòn doanh thu" (cannibalization) của chiết khấu, khi giảm giá kéo số đơn lên mạnh nhưng mỗi đơn mang về ít tiền hơn nên tác động lên GMV yếu hơn tác động lên số đơn (Trần Duy Thanh, 2026a, Ch1 tr.73).

Gọi u~t~ là nhu cầu nền khi không có sự kiện và H~t~ là biến chỉ báo ngày sự kiện. Một đặc tả đơn giản cho các tác động trên trong mô hình nhân là:

$ Y~t~ = u~t~ · (1 + η~0~ · H~t~) · Π~j≠0~ (1 + η~j~ · H~t−j~)

trong đó η~0~ > 0 là hiệu ứng ngày sự kiện và η~j~ < 0 với j ở lân cận là hiệu ứng trì hoãn mua (j < 0, người mua chờ sự kiện) và kéo cầu (j > 0, người mua đã tích trữ). Hiệu ứng ròng của sự kiện trên toàn cửa sổ là:

$ Δ~ròng~ ≈ η~0~ + Σ~j≠0~ η~j~

Nếu Δ~ròng~ gần 0, sự kiện chủ yếu dịch chuyển doanh số theo thời gian chứ không tạo ra doanh số mới; khi đó lợi ích thực của chiến dịch phải được đánh giá bằng biên đóng góp chứ không phải bằng GMV ngày đỉnh. Đặc tả này cũng cho thấy một khó khăn nhận dạng mà tiểu luận gặp phải trên dữ liệu: nếu mọi ngày sự kiện đều đi kèm cùng một mức chiết khấu (chẳng hạn 50%), thì H~t~ và biến chiết khấu trùng nhau tại các ngày đó, và dữ liệu không thể tách "hiệu ứng sự kiện" khỏi "hiệu ứng giảm giá sâu". Mọi dự báo cho một ngày sự kiện với mức chiết khấu khác là ngoại suy về mặt nhận dạng, dù các biến vẫn nằm trong khoảng giá trị đã quan sát.

Slide còn nêu một hiện tượng vận hành đáng chú ý: tương quan giữa chi phí quảng cáo và chiết khấu rất yếu, bộc lộ sự phân mảnh giữa đội marketing (chạy quảng cáo) và đội thương mại (chạy mã giảm giá); khuyến nghị là dồn ngân sách quảng cáo vào đúng những ngày có voucher sâu để tạo hiệu ứng cộng hưởng (Trần Duy Thanh, 2026a, Ch1 tr.74). Khuyến nghị cộng hưởng tương ứng với một số hạng tương tác trong mô hình phản hồi:

$ Orders~t~ = α + β~1~·Ad~t~ + β~2~·δ~t~ + β~3~·Ad~t~·δ~t~ + ε~t~

Cộng hưởng tồn tại khi β~3~ > 0. Tuy nhiên, kết luận về β~3~ cần thận trọng về lợi nhuận: ngay cả khi β~3~ > 0, chiết khấu sâu làm giảm biên của mọi đơn (kể cả các đơn lẽ ra vẫn mua ở giá gốc), nên cộng hưởng về số đơn không đảm bảo cộng hưởng về lợi nhuận.

Đối với dự báo, sự kiện khuyến mãi đặt ra ba yêu cầu. Thứ nhất, lịch sự kiện tương lai phải được biết trước và đưa vào mô hình như biến ngoại sinh, vì không mô hình nào học được từ lịch sử một sự kiện chưa từng xảy ra. Thứ hai, độ bất định trong ngày sự kiện lớn hơn nhiều so với ngày thường, nên dự báo xác suất cho ngày sự kiện cần có khoảng rộng hơn; một mô hình dùng chung một độ lệch chuẩn phần dư cho mọi ngày sẽ đánh giá thấp rủi ro trong ngày sự kiện. Thứ ba, số ngày sự kiện trong một chuỗi ngắn thường rất ít (một quý có thể chỉ có hai hoặc ba ngày), nên mọi ước lượng về hiệu ứng sự kiện dựa trên rất ít quan sát và cần được kiểm tra bằng các thủ tục như bỏ-một-quan-sát (leave-one-out).

### 2.1.5. Từ lợi nhuận đến dòng tiền: chu kỳ chuyển đổi tiền mặt của chiến dịch

Biên đóng góp dương là điều kiện cần nhưng chưa đủ cho sự bền vững của một nhà bán hàng TMĐT trong mùa Mega Sale, bởi lợi nhuận kế toán và tiền mặt không đi cùng nhịp. Doanh nghiệp phải trả tiền nhập hàng và tiền quảng cáo trước, trong khi doanh thu bán trên sàn chỉ được đối soát và chuyển về tài khoản sau một độ trễ. Richards và Laughlin (1980) đề xuất chu kỳ chuyển đổi tiền mặt (Cash Conversion Cycle – CCC) như một thước đo động của thanh khoản:

$ CCC = DIO + DSO − DPO

Trong đó DIO là số ngày tồn kho bình quân, DSO là số ngày thu tiền bình quân và DPO là số ngày trả tiền nhà cung cấp bình quân. Với nhà bán hàng trên sàn, DSO gắn trực tiếp với cơ chế đối soát (Mục 2.7.3). Deloof (2003) cung cấp bằng chứng thực nghiệm trên các doanh nghiệp Bỉ rằng rút ngắn số ngày phải thu và số ngày tồn kho có liên hệ với khả năng sinh lời cao hơn, gợi ý rằng quản trị vốn lưu động không chỉ là vấn đề thanh khoản mà còn là vấn đề hiệu quả. Tiểu luận không kiểm định lại giả thuyết của Deloof (2003) mà dùng khung CCC làm cơ sở mô phỏng nhu cầu vốn của chiến dịch.

Gọi GMV~t~ là doanh số ngày t, κ là tỷ lệ giá vốn trên GMV, φ là phí sàn, L là lead time nhập hàng và d là độ trễ đối soát. Dòng chi nhập hàng I~t~, dòng thu O~t~ và tiền lũy kế được mô hình hóa:

$ I~t~ = κ · GMV~t+L~

$ O~t~ = (1 − φ) · GMV~t−d~

$ Cash~t~ = Cash~0~ + Σ~s≤t~ (O~s~ − I~s~ − Ad~s~)

Tiền mặt tối thiểu cần chuẩn bị là giá trị khiến đường Cash~t~ không bao giờ âm:

$ Cash~0~^*^ = max(0, −min~t~ Σ~s≤t~ (O~s~ − I~s~ − Ad~s~))

Mô hình này chính thức hóa "bẫy vốn lưu động" mà slide nêu trong case study cuối Chương 2: doanh nghiệp tăng trưởng doanh số gấp năm lần trong chiến dịch Mega Sale nhưng tài khoản lại cạn tiền mặt trước khi kịp nhận tiền đối soát (Trần Duy Thanh, 2026a, Ch2 tr.103). Cơ chế kinh tế rất rõ: một đỉnh doanh số đòi hỏi tiền nhập hàng tăng ở thời điểm t − L và tiền quảng cáo tăng ngay tại t, trong khi tiền thu về chỉ xuất hiện ở t + d; khoảng L + d ngày giữa hai sự kiện là khoảng vốn bị "khóa". Như vậy chiến dịch Mega Sale có ba lớp rủi ro chồng lên nhau: rủi ro hiệu quả (quảng cáo và chiết khấu không tạo đủ đơn), rủi ro biên (chiết khấu sâu làm biên âm) và rủi ro thanh khoản (đỉnh doanh số khóa vốn). Ba lớp này tương ứng với ba câu hỏi mà khung phân tích của tiểu luận trả lời lần lượt ở Chương 4.

Bối cảnh Việt Nam làm cho bài toán có ý nghĩa thực tiễn. Theo Bộ Công Thương, quy mô thị trường TMĐT Việt Nam năm 2024 vượt 25 tỷ USD, tăng khoảng 20% so với năm 2023 và chiếm khoảng 9% tổng mức bán lẻ hàng hóa và doanh thu dịch vụ tiêu dùng cả nước (Báo Công Thương, 2025). Theo số liệu của YouNet ECI được Báo Pháp luật Việt Nam dẫn lại, tổng giá trị giao dịch trên bốn sàn lớn năm 2025 đạt 458.160 tỷ đồng, tăng 26% (Nam Linh, 2026), và Metric.vn dự báo doanh thu TMĐT quý IV/2025 khoảng 105 nghìn tỷ đồng với các chiến dịch 11.11 và 12.12 là động lực của các tháng cuối năm (VnEconomy, 2025). Với quy mô và tốc độ đó, quyết định marketing của mùa cao điểm cuối năm không còn là chi tiết chiến thuật mà là quyết định tài chính có trọng lượng của nhà bán hàng.

## 2.2. Chẩn đoán dữ liệu và mô hình kinh doanh

### 2.2.1. Phân tích khám phá dữ liệu theo ba phương diện

Phân tích khám phá dữ liệu (Exploratory Data Analysis – EDA) được Tukey (1977) xác lập như một triết lý phân tích bổ sung cho thống kê suy diễn: trước khi kiểm định giả thuyết, nhà phân tích cần "để dữ liệu tự nói" thông qua các tóm tắt bền vững và các biểu đồ. Slide của học phần định vị EDA là bước kiểm định thống kê tiên quyết nhằm tóm tắt đặc tính cốt lõi của tập dữ liệu trước khi áp đặt các giả định mô hình hóa, và đối với chuỗi thời gian TMĐT thì EDA đóng vai trò cầu nối giữa dữ liệu thô và các thuật toán phân rã (Trần Duy Thanh, 2026a, Ch1 tr.32). Học phần tổ chức EDA thành ba phương diện bổ trợ nhau, và tiểu luận giữ nguyên cấu trúc này.

Phương diện thứ nhất là động thái thời gian (temporal dynamics). Công cụ cơ bản là trung bình trượt đơn giản (Simple Moving Average – SMA), đóng vai trò bộ lọc thông thấp giúp triệt tiêu nhiễu tần số cao và làm lộ xu hướng (Trần Duy Thanh, 2026a, Ch1 tr.33–34):

$ SMA~k~(t) = (1/k) · Σ~i=0..k−1~ Y~t−i~

Ví dụ của slide với chuỗi doanh số 5 ngày Y = (10, 12, 15, 14, 20) triệu đồng và k = 3 cho SMA~3~(4) = 41/3 ≈ 13,67 và SMA~3~(5) = 49/3 ≈ 16,33; các thời điểm t = 1, 2 không đủ cửa sổ nên không xác định (Trần Duy Thanh, 2026a, Ch1 tr.35). Lưu ý rằng SMA một phía như trên là bộ lọc nhân quả, phù hợp cho giám sát thời gian thực nhưng tạo độ trễ pha bằng (k − 1)/2 kỳ; trung bình trượt trung tâm dùng trong phân rã cổ điển (Mục 2.3.2) không có độ trễ này nhưng mất dữ liệu ở cả hai đầu chuỗi.

Phương diện thứ hai là hình thái phân phối thống kê. Slide lập luận rằng dữ liệu TMĐT thường vi phạm giả định phân phối chuẩn và có xu hướng lệch phải: phần lớn quan sát tập trung ở mức thấp hoặc trung bình, một số ít ngày siêu khuyến mãi kéo dài đuôi phải, khiến trung bình cộng bị kéo lệch và trung vị trở thành thước đo đại diện vững hơn (Trần Duy Thanh, 2026a, Ch1 tr.39). Các đại lượng được dùng là trung bình, trung vị, độ lệch chuẩn tổng thể và hệ số lệch Pearson (Trần Duy Thanh, 2026a, Ch1 tr.40–41):

$ X̄ = (1/n) · Σ~i~ X~i~ ;  S = √[(1/n) · Σ~i~ (X~i~ − X̄)^2^]

$ Sk~P~ = 3 · (X̄ − Me) / S

Ví dụ minh họa với GMV 5 ngày X = (5, 6, 7, 8, 50), trong đó ngày cuối là Mega Sale, cho trung bình 15,2, trung vị 7, độ lệch chuẩn khoảng 17,43 và Sk~P~ ≈ 1,41 > 0, chứng tỏ phân phối lệch phải mạnh và ngày Mega Sale đã kéo trung bình lên mức phi thực tế (Trần Duy Thanh, 2026a, Ch1 tr.42–43).

Tiểu luận bổ sung hai điểm cho phương diện này. Thứ nhất, hệ số Pearson dựa trên khoảng cách giữa trung bình và trung vị nên chỉ nhạy với độ lệch "ở thân" phân phối; khi phân phối gần đối xứng ở phần lõi nhưng có một vài điểm cực đoan ở đuôi, Sk~P~ có thể gần 0 trong khi phân phối rõ ràng không chuẩn. Vì vậy cần dùng thêm hệ số lệch dựa trên mô-men bậc ba (Fisher) và độ nhọn dư dựa trên mô-men bậc bốn:

$ g~1~ = m~3~ / m~2~^3/2^ ;  g~2~ = m~4~ / m~2~^2^ − 3, với m~r~ = (1/n) · Σ~i~ (X~i~ − X̄)^r^

Thứ hai, có thể kiểm định chính thức giả thuyết phân phối chuẩn bằng thống kê Jarque–Bera, kết hợp cả độ lệch và độ nhọn (Jarque & Bera, 1980):

$ JB = (n/6) · [g~1~^2^ + g~2~^2^/4] ∼ χ^2^(2) dưới H~0~

Sự kết hợp Sk~P~, g~1~, g~2~ và JB cho phép phân biệt hai tình huống mà một con số đơn lẻ không phân biệt được: lệch ở thân phân phối và đuôi dày do sự kiện. Phân biệt này có hệ quả cho dự báo xác suất ở Mục 2.5, vì giả định chuẩn dẫn tới đánh giá thấp xác suất của các ngày cực đoan.

Phương diện thứ ba là cấu trúc tương quan đa biến. Slide dùng hệ số tương quan Pearson để kiểm định các giả thuyết kinh tế cơ bản như mối liên hệ giữa chi phí quảng cáo và GMV, với kỳ vọng tương quan dương mạnh; một hệ số thấp là chỉ báo về sự kém hiệu quả vận hành (Trần Duy Thanh, 2026a, Ch1 tr.48–49):

$ r~XY~ = Σ~i~ (X~i~ − X̄)(Y~i~ − Ȳ) / √[Σ~i~ (X~i~ − X̄)^2^ · Σ~i~ (Y~i~ − Ȳ)^2^]

Ví dụ tính tay với tiền quảng cáo X = (2, 5, 4, 9) và số đơn Y = (5, 9, 7, 11) cho tử số 22, mẫu số √520 ≈ 22,8 và r ≈ 0,96, tức tương quan dương rất mạnh nhưng không hoàn hảo (Trần Duy Thanh, 2026a, Ch1 tr.50–51). Ví dụ nâng cao yêu cầu thực hiện đầy đủ ba phương diện EDA trên tệp ecommerce_90days gồm Date, GMV, Orders, Ad_Spend và Discount trong khoảng 90 ngày từ tháng 7 đến tháng 9/2026, đồng thời luận giải dưới góc nhìn kinh tế (Trần Duy Thanh, 2026a, Ch1 tr.55). Tiểu luận bổ sung hệ số tương quan hạng Spearman, vốn là hệ số Pearson tính trên thứ hạng và do đó vững hơn trước ngoại lai và chỉ đòi hỏi quan hệ đơn điệu thay vì tuyến tính. Khi hệ số Pearson và Spearman chênh nhau đáng kể, đó là dấu hiệu quan hệ bị chi phối bởi một số ít điểm cực đoan.

### 2.2.2. Tương quan, nhân quả và thiên lệch bỏ sót biến

Tương quan song biến cao giữa chi phí quảng cáo và số đơn không đồng nghĩa với hiệu ứng nhân quả của quảng cáo. Trong TMĐT, các chiến dịch lớn thường đồng thời tăng quảng cáo và tăng mức giảm giá; nếu chỉ hồi quy số đơn trên quảng cáo, hệ số ước lượng sẽ hấp thụ một phần tác động của giảm giá. Hiện tượng này là thiên lệch bỏ sót biến (Omitted Variable Bias – OVB) trong kinh tế lượng (Wooldridge, 2010). Giả sử mô hình đúng là:

$ Orders~t~ = β~0~ + β~1~ · Ad~t~ + β~2~ · Disc~t~ + u~t~

nhưng nhà phân tích ước lượng mô hình rút gọn Orders~t~ = α~0~ + α~1~ · Ad~t~ + v~t~. Khi đó, kỳ vọng của hệ số rút gọn là:

$ E[α̂~1~] = β~1~ + β~2~ · δ~1~, với δ~1~ = Cov(Ad, Disc) / Var(Ad)

Thiên lệch β~2~ · δ~1~ dương khi giảm giá làm tăng số đơn (β~2~ > 0) và quảng cáo tương quan dương với giảm giá (δ~1~ > 0). Hệ quả quản trị là hiệu quả quảng cáo bị phóng đại, dẫn tới phân bổ ngân sách quá mức cho kênh quảng cáo. Tiểu luận dùng lập luận này để kiểm tra tính hợp lệ của diễn giải "quảng cáo kéo đơn hàng" mà phương diện tương quan trong slide gợi ý.

Một vấn đề liên quan là phương sai sai số thay đổi (heteroskedasticity). Trong dữ liệu TMĐT, độ biến động của doanh số thường tăng theo quy mô chiến dịch, khiến sai số chuẩn OLS thông thường không còn đáng tin cậy. Kiểm định Breusch–Pagan hồi quy bình phương phần dư lên các biến giải thích và dùng thống kê nhân tử Lagrange để kiểm định giả thuyết phương sai không đổi (Breusch & Pagan, 1979). Khi chuỗi thời gian còn có tự tương quan, sai số chuẩn vững theo Newey và West (1987) (HAC) là lựa chọn phù hợp. Về mặt dự báo, phương sai thay đổi theo quy mô là một lập luận ủng hộ mô hình nhân hoặc biến đổi log ở Mục 2.3.1, và ủng hộ các khoảng dự báo có độ rộng tỷ lệ với mức dự báo ở Mục 2.5.

### 2.2.3. Dữ liệu khuyết

Dữ liệu vận hành TMĐT đến từ nhiều hệ thống như ERP, WMS, web log và cổng thanh toán, nên hầu như không bao giờ sạch hoàn toàn; hai vấn đề cốt lõi là dữ liệu khuyết và nhiễu – ngoại lai, và nếu xử lý sai thì các mô hình AI sẽ học sai lệch (Trần Duy Thanh, 2026a, Ch1 tr.75). Slide minh họa bằng 20 ngày giao dịch của một cửa hàng, trong đó có hai ngày bị lỗi hệ thống ghi nhận GMV bằng 0 (stock-out ảo), hai ngày mất dữ liệu do lỗi API, một ngày sai giá trị và một ngày Flash Sale hợp lệ (Trần Duy Thanh, 2026a, Ch1 tr.76).

Về phân loại, slide trình bày ba cơ chế khuyết theo Little và Rubin (Trần Duy Thanh, 2026a, Ch1 tr.77; Little & Rubin, 2019). Khuyết hoàn toàn ngẫu nhiên (MCAR) xảy ra khi xác suất khuyết không phụ thuộc vào bất kỳ biến nào, ví dụ mất mạng server đột xuất. Khuyết ngẫu nhiên có điều kiện (MAR) xảy ra khi xác suất khuyết phụ thuộc vào các biến quan sát được, ví dụ ngày nhân sự nghỉ không nhập liệu. Khuyết không ngẫu nhiên (MNAR) xảy ra khi xác suất khuyết phụ thuộc vào chính giá trị bị khuyết, ví dụ sản phẩm hết hàng nên hệ thống không ghi nhận doanh số. Ký hiệu M là chỉ báo khuyết, Y~obs~ và Y~mis~ là phần quan sát và phần khuyết, ba cơ chế được phát biểu hình thức như sau:

$ MCAR: P(M | Y~obs~, Y~mis~) = P(M) ;  MAR: P(M | Y~obs~, Y~mis~) = P(M | Y~obs~) ;  MNAR: phụ thuộc Y~mis~

Phân loại này quyết định phương pháp xử lý. Slide liệt kê ba cách phổ biến: điền giá trị liền trước (forward fill), nội suy tuyến tính và gán giá trị 0 khi ngày đó thực sự không có giao dịch (Trần Duy Thanh, 2026a, Ch1 tr.78). Nội suy tuyến tính giả định giá trị biến thiên với tốc độ không đổi trong khoảng trống, về hình học là nối thẳng điểm hợp lệ trước và sau (Trần Duy Thanh, 2026a, Ch1 tr.79–81):

$ y = y~0~ + [(y~1~ − y~0~)/(x~1~ − x~0~)] · (x − x~0~)

Slide diễn giải ý nghĩa kinh tế: giá trị của ngày lỗi bằng giá trị ngày bình thường trước đó cộng phần chênh lệch tích lũy với tốc độ biến thiên mỗi ngày là m (Trần Duy Thanh, 2026a, Ch1 tr.81). Cần lưu ý một điểm tinh tế mà ví dụ của slide đặt ra: các ngày ghi GMV = 0 do lỗi hệ thống là "khuyết trá hình". Giá trị 0 ở đây không phải là doanh số thật mà là dấu hiệu của MNAR hoặc lỗi ghi nhận, nên phải được chuyển thành giá trị khuyết rồi mới nội suy; ngược lại, nếu một sản phẩm thật sự hết hàng, giá trị 0 phản ánh doanh số bán được nhưng không phản ánh nhu cầu, và việc dùng nó để huấn luyện mô hình dự báo nhu cầu sẽ gây thiên lệch xuống (demand censoring). Phân biệt giữa doanh số quan sát và nhu cầu tiềm ẩn này rất quan trọng cho mô hình Newsvendor ở Mục 2.5.6, vốn được định nghĩa trên nhu cầu chứ không phải doanh số.

### 2.2.4. Nhiễu và điểm ngoại lai

Ngoại lai trong TMĐT có ba nguồn chính: các chương trình Flash Sale lớn làm doanh số vọt lên đột ngột, lỗi nhập liệu giá (như bán điện thoại giá 1 đồng) và lỗi hệ thống đếm trùng đơn (Trần Duy Thanh, 2026a, Ch1 tr.82). Slide trình bày hai kỹ thuật phát hiện. Kỹ thuật thứ nhất là phương pháp khoảng tứ phân vị (IQR) của Tukey (1977):

$ IQR = Q~3~ − Q~1~ ;  Lower = Q~1~ − 1,5 · IQR ;  Upper = Q~3~ + 1,5 · IQR

Để tính tứ phân vị, slide dùng công thức nội suy vị trí trên dãy đã sắp xếp tăng dần Y~(1)~ ≤ … ≤ Y~(N)~ (Trần Duy Thanh, 2026a, Ch1 tr.83–85):

$ Pos~p~ = 1 + p · (N − 1) ;  Q~p~ = Y~(i)~ + f · (Y~(i+1)~ − Y~(i)~), với i = ⌊Pos~p~⌋, f = Pos~p~ − i

Áp vào 20 ngày đã nội suy, Pos~Q1~ = 1 + 0,25 × 19 = 5,75 cho Q~1~ = 14,8 + 0,75 × (15,0 − 14,8) = 14,95; Pos~Q3~ = 15,25 cho Q~3~ = 17,85; từ đó IQR = 2,90, ngưỡng dưới 10,60 và ngưỡng trên 22,20 triệu đồng; hai ngày vượt ngưỡng là ngày 15 (150 triệu) và ngày 19 (85 triệu) (Trần Duy Thanh, 2026a, Ch1 tr.91–94). Slide nhấn mạnh ưu điểm của IQR: đây là độ rộng vùng chứa 50% dữ liệu ở giữa và miễn nhiễm với các điểm cực đoan ở hai đầu, khác với phương sai và độ lệch chuẩn (Trần Duy Thanh, 2026a, Ch1 tr.86).

Kỹ thuật thứ hai là Z-score theo cửa sổ trượt, đánh dấu các điểm vượt quá ngưỡng lệch chuẩn cục bộ, thường |Z| > 3 (Trần Duy Thanh, 2026a, Ch1 tr.82):

$ Z~t~ = (Y~t~ − μ~t,w~) / σ~t,w~

trong đó μ~t,w~ và σ~t,w~ là trung bình và độ lệch chuẩn của w quan sát gần nhất. Tiểu luận lưu ý một hạn chế cấu trúc của kỹ thuật này mà người dùng thường bỏ qua: chính ngoại lai cần phát hiện cũng làm tăng σ~t,w~ khi nó nằm trong cửa sổ, và trong cửa sổ ngắn, một điểm cực đoan có thể "tự che" mình. Cụ thể, với cửa sổ w quan sát chứa đúng một điểm lệch khỏi phần còn lại một khoảng Δ, Z-score của chính điểm đó bị chặn trên bởi một hằng số chỉ phụ thuộc vào w, bất kể Δ lớn đến đâu; với w nhỏ, hằng số này có thể thấp hơn 3. Đây là hiện tượng che lấp (masking) quen thuộc trong thống kê vững.

Giải pháp mở rộng là Z-score vững dựa trên trung vị và độ lệch tuyệt đối trung vị (MAD), vốn có điểm gãy (breakdown point) 50% thay vì 0% như trung bình và độ lệch chuẩn (Rousseeuw & Croux, 1993):

$ MAD = median~i~ |Y~i~ − median(Y)| ;  Z~i~^rob^ = (Y~i~ − median(Y)) / (1,4826 · MAD)

Hằng số 1,4826 làm cho 1,4826 × MAD là ước lượng nhất quán của σ dưới phân phối chuẩn; slide Chương 2 dùng cùng ý tưởng khi nói 1 MAD tương đương khoảng 0,6745σ (Trần Duy Thanh, 2026a, Ch2 tr.20). Bảng {T:@c2m_ngoailai} so sánh ba kỹ thuật.

[[T:@c2m_ngoailai So sánh các phương pháp phát hiện ngoại lai cho chuỗi doanh số TMĐT
Tiêu chí | IQR (Tukey) | Z-score cửa sổ trượt | Z-score vững (MAD)
Thước đo vị trí | Q1, Q3 | Trung bình cục bộ | Trung vị
Thước đo phân tán | IQR | Độ lệch chuẩn cục bộ | 1,4826 × MAD
Điểm gãy | 25% | 0% | 50%
Nhạy với xu hướng, mùa vụ | Có (tính trên toàn chuỗi) | Thấp (thích nghi cục bộ) | Có nếu tính toàn chuỗi
Rủi ro che lấp | Thấp | Cao khi cửa sổ ngắn | Thấp
Ngưỡng điển hình | 1,5 × IQR | abs(Z) > 3 | abs(Z) > 3 hoặc 3,5
Nguồn trong học phần | Ch1 tr.82–94 | Ch1 tr.82 | Mở rộng (liên hệ Ch2 tr.19–21)
Nguồn: Tổng hợp từ Trần Duy Thanh (2026a), Tukey (1977), Rousseeuw và Croux (1993).
]]

Về chiến lược xử lý, slide đưa ra một quy tắc quản trị quan trọng: đối với sự kiện Flash Sale hợp lệ như ngày 19/08/2026 đạt 85 triệu đồng, tuyệt đối không xóa mà phải giữ lại và chuyển hóa thành biến ngoại sinh (Promotion Flag) để mô hình học được tác động của sự kiện; chỉ hiệu chỉnh các ngoại lai do lỗi kỹ thuật hoặc lỗi nhập liệu (Trần Duy Thanh, 2026a, Ch1 tr.82). Như vậy, phát hiện ngoại lai chỉ là bước thống kê; phân loại ngoại lai thành "lỗi" và "sự kiện" là bước nghiệp vụ, đòi hỏi thông tin ngữ cảnh mà thuật toán không có. Quy tắc này nhất quán với cách mô hình GAM và Prophet xử lý ngày lễ như một thành phần h(t) riêng (Mục 2.3.6) và với cách tiểu luận dùng biến giả cho các tháng giãn cách xã hội trong chuỗi TMBL.

### 2.2.5. Dữ liệu bảng, tính dị biệt và ngụy biện tổng gộp

Dữ liệu bảng (panel data) là cấu trúc trong đó các thực thể độc lập được quan sát lặp lại qua nhiều thời điểm; nếu chuỗi thời gian đơn được ký hiệu Y~t~ thì dữ liệu bảng được biểu diễn trong không gian hai chiều Y~i,t~ với i là thực thể (ngành hàng, SKU, cửa hàng) và t là thời gian (Trần Duy Thanh, 2026a, Ch1 tr.102). Slide nêu vai trò cốt lõi của dữ liệu bảng là tránh ngụy biện tổng gộp (aggregation fallacy hay ecological fallacy): tổng doanh thu toàn sàn đi ngang có thể che giấu việc ngành điện tử suy thoái nghiêm trọng trong khi ngành FMCG bùng nổ và gánh toàn bộ thâm hụt (Trần Duy Thanh, 2026a, Ch1 tr.103). Tệp ecommerce_panel_data_raw gồm khoảng một tháng dữ liệu của ba ngành hàng Thời trang, Điện tử và FMCG ở dạng thô cần sắp xếp lại theo Date và Category (Trần Duy Thanh, 2026a, Ch1 tr.104), và phần trực quan hóa trên slide nhấn mạnh tính dị biệt (heterogeneity) của quan hệ quảng cáo – đơn hàng giữa các ngành (Trần Duy Thanh, 2026a, Ch1 tr.106–107).

Về mặt kinh tế lượng, có ba đặc tả cơ bản cho quan hệ giữa số đơn và chi phí quảng cáo trên dữ liệu bảng (Wooldridge, 2010). Mô hình gộp (pooled OLS) giả định mọi ngành có chung hệ số chặn và hệ số góc:

$ Orders~i,t~ = α + β · Ad~i,t~ + ε~i,t~

Mô hình hiệu ứng cố định (fixed effects – FE) cho phép mỗi ngành có hệ số chặn riêng α~i~, hấp thụ các khác biệt không đổi theo thời gian như mức giá hay quy mô thị trường:

$ Orders~i,t~ = α~i~ + β · Ad~i,t~ + ε~i,t~

Mô hình hệ số dị biệt cho phép cả hệ số góc khác nhau:

$ Orders~i,t~ = α~i~ + β~i~ · Ad~i,t~ + ε~i,t~

Giả thuyết đồng nhất độ dốc H~0~: β~1~ = β~2~ = … = β~N~ có thể kiểm định bằng thống kê F so sánh tổng bình phương phần dư của mô hình FE và mô hình hệ số dị biệt. Điểm then chốt là khi các ngành có quy mô đơn hàng và mức chi quảng cáo rất khác nhau, mô hình gộp có thể cho hệ số góc gần 0 hoặc thậm chí trái dấu, vì biến thiên giữa các ngành lấn át biến thiên trong từng ngành. Đây là phiên bản hồi quy của nghịch lý Simpson: một quan hệ đúng trong mọi nhóm con có thể biến mất hoặc đảo chiều khi gộp nhóm (Simpson, 1951). Với nhà quản trị TMĐT, hệ quả là một kết luận dạng "quảng cáo không hiệu quả" rút ra từ dữ liệu toàn sàn có thể hoàn toàn sai ở cấp ngành hàng.

Ngụy biện tổng gộp cũng áp dụng cho tăng trưởng. Gọi G~i~^(1)^ và G~i~^(2)^ là GMV của ngành i trong hai kỳ, tăng trưởng tổng có thể phân tích thành bình quân gia quyền của tăng trưởng từng ngành:

$ g~total~ = Σ~i~ w~i~ · g~i~, với w~i~ = G~i~^(1)^ / Σ~j~ G~j~^(1)^

Khi ngành có tỷ trọng lớn nhất suy giảm, tổng có thể giảm ngay cả khi phần lớn các ngành còn lại tăng trưởng. Công thức đơn giản này giải thích chính xác tình huống slide mô tả và là cơ sở để tiểu luận đọc kết quả panel ở Chương 4.

## 2.3. Phân rã chuỗi thời gian

### 2.3.1. Cấu trúc thành phần và lựa chọn giữa mô hình cộng và mô hình nhân

Khác với dữ liệu chéo, EDA đối với chuỗi thời gian tập trung vào bóc tách cấu trúc ẩn trước khi đưa vào mô hình (Trần Duy Thanh, 2026a, Ch2 tr.4). Theo slide, một quan sát Y~t~ là hợp lực của bốn thành phần: xu hướng lõi T~t~ phản ánh quỹ đạo dài hạn; mùa vụ S~t~ gồm các biến động lặp lại theo chu kỳ cố định và có thể đoán trước; chu kỳ kinh tế C~t~ gồm các làn sóng dài hạn không có mốc cố định do hưng thịnh hay suy thoái vĩ mô, như khủng hoảng 2008 hay đại dịch COVID-19; và phần dư R~t~ gồm các cú sốc ngẫu nhiên không theo quy luật (Trần Duy Thanh, 2026a, Ch2 tr.5). Hai dạng kết hợp được trình bày là mô hình cộng và mô hình nhân (Trần Duy Thanh, 2026a, Ch2 tr.6):

$ Y~t~ = T~t~ + S~t~ + C~t~ + R~t~

$ Y~t~ = T~t~ × S~t~ × C~t~ × R~t~

Ví dụ của slide xét doanh số điện thoại quý 3/2026 là 150 triệu đồng với xu hướng 100 triệu, đóng góp mùa tựu trường 35 triệu và đóng góp chu kỳ 10 triệu. Theo mô hình cộng, R~t~ = 150 − (100 + 35 + 10) = 5 triệu đồng (Trần Duy Thanh, 2026a, Ch2 tr.7–8). Theo mô hình nhân, các đóng góp được quy đổi thành hệ số S~t~ = 1,35 và C~t~ = 1,10, nên R~t~ = 150/(100 × 1,35 × 1,10) = 150/148,5 ≈ 1,0101, tức nhiễu làm doanh số tăng khoảng 1,01% so với tích các thành phần cơ bản (Trần Duy Thanh, 2026a, Ch2 tr.10–11). Bản chất của hai mô hình được slide tóm tắt: mô hình cộng giả định tác động tuyệt đối, các thành phần độc lập tuyến tính và quy mô thị trường không làm thay đổi sức nặng tuyệt đối của mùa vụ; mô hình nhân giả định tác động tương đối, quy mô càng lớn thì biên độ mùa vụ và chu kỳ càng phình to, phù hợp với TMĐT nơi một chiến dịch tạo ra mức tăng tính bằng phần trăm (Trần Duy Thanh, 2026a, Ch2 tr.9, tr.12–13).

Tiểu luận bổ sung một liên hệ kỹ thuật thường được dùng trong thực hành: lấy logarit hai vế của mô hình nhân sẽ đưa nó về mô hình cộng trên thang log,

$ log Y~t~ = log T~t~ + log S~t~ + log C~t~ + log R~t~

Do đó, có thể áp dụng các thuật toán phân rã cộng như STL lên log Y~t~ rồi lấy mũ các thành phần để thu được hệ số mùa vụ nhân (Hyndman & Athanasopoulos, 2021). Biến đổi log còn có lợi ích phụ là ổn định phương sai khi độ biến động tăng theo quy mô (Mục 2.2.2), và biến chênh lệch log thành xấp xỉ tốc độ tăng trưởng phần trăm. Tiểu luận sử dụng cách tiếp cận này cho chuỗi TMBL Việt Nam. Bảng {T:@c2m_congnhan} tổng hợp các tiêu chí lựa chọn.

[[T:@c2m_congnhan So sánh mô hình phân rã cộng và mô hình phân rã nhân
Tiêu chí | Mô hình cộng | Mô hình nhân
Biểu diễn | Y = T + S + C + R | Y = T × S × C × R
Đơn vị của S, C | Cùng đơn vị với Y (triệu đồng) | Hệ số không thứ nguyên
Giả định kinh tế | Biên độ mùa vụ không đổi theo quy mô | Biên độ mùa vụ tỷ lệ với quy mô
Khử mùa vụ | Y − S (− H) | Y / (S × H)
Ví dụ slide (phần dư) | R = 5 triệu đồng | R ≈ 1,0101
Phù hợp với | Chuỗi ổn định, đã lấy log, biên lợi nhuận (%) | Doanh số tăng trưởng, TMĐT
Liên hệ | Áp dụng trên log Y tương đương mô hình nhân | Lấy log để dùng thuật toán cộng
Nguồn: Tổng hợp từ Trần Duy Thanh (2026a, Ch2 tr.6–13, tr.92–102) và Hyndman và Athanasopoulos (2021).
]]

Để tách đủ bốn thành phần, slide đề xuất kết hợp hai kỹ thuật: STL để tách mùa vụ, phần dư và khối xu hướng – chu kỳ TC~t~, khắc phục việc mất dữ liệu ở hai đầu của trung bình trượt trung tâm; và bộ lọc Hodrick–Prescott để cắt khối TC~t~ thành xu hướng lõi T~t~ và chu kỳ C~t~ (Trần Duy Thanh, 2026a, Ch2 tr.14). Các mục tiếp theo trình bày từng kỹ thuật.

### 2.3.2. Phân rã cổ điển bằng trung bình trượt và giới hạn của nó

Thuật toán phân rã cổ điển dùng trung bình trượt để ước lượng xu hướng. Điểm yếu cốt lõi, theo slide, là chỉ cần một phần tử cực lớn do lỗi nhập liệu hay một ngày Mega Sale thì tử số phình to và toàn bộ đường xu hướng bị bẻ cong (Trần Duy Thanh, 2026a, Ch2 tr.16). Với cửa sổ lẻ n = 2k + 1, xu hướng được neo vào điểm giữa:

$ T~t~ = (1/n) · Σ~j=−k..k~ Y~t+j~

Bài toán 1 của slide xét doanh thu 5 ngày Y = (10, 12, 100, 11, 13), trong đó sức khỏe lõi chỉ quanh 11–12 và ngày 3 là điểm dị biệt; với n = 5, T~3~ = (10 + 12 + 100 + 11 + 13)/5 = 29,2, tức thuật toán báo cáo xu hướng lõi cao gấp khoảng 2,5 lần thực tế (Trần Duy Thanh, 2026a, Ch2 tr.17–18). Với cửa sổ chẵn n = 2k, trung bình của n điểm rơi vào một mốc thời gian không tồn tại (ví dụ quý 2,5), nên cần trung bình trượt kép (2 × MA), tương đương với một trung bình có trọng số trong đó hai đầu cửa sổ nhận trọng số một nửa (Trần Duy Thanh, 2026a, Ch2 tr.28–29):

$ T~t~ = (1/n) · [0,5 · Y~t−k~ + Σ~j=−k+1..k−1~ Y~t+j~ + 0,5 · Y~t+k~]

Với n = 4 và trọng số vị trí d = (0,5; 1; 1; 1; 0,5), xu hướng tại ngày 3 của cùng dãy số là T~3~ = Σ d~i~Y~i~/Σ d~i~ = 134,5/4 = 33,625 (Trần Duy Thanh, 2026a, Ch2 tr.31–32). Cả hai kết quả đều minh họa cùng một kết luận: trung bình cộng có điểm gãy bằng 0, nên một quan sát duy nhất đủ làm hỏng ước lượng xu hướng. Ngoài ra, phân rã cổ điển giả định mùa vụ không đổi qua các năm và không ước lượng được xu hướng ở k điểm đầu và cuối chuỗi, đúng là những điểm mà nhà quản trị cần nhất khi dự báo (Hyndman & Athanasopoulos, 2021).

### 2.3.3. STL và cơ chế kháng nhiễu bisquare

STL (Seasonal and Trend decomposition using Loess) do Cleveland và cộng sự (1990) đề xuất khắc phục các hạn chế trên bằng hồi quy cục bộ có trọng số (LOESS) và một vòng lặp kháng nhiễu. Thuật toán gồm vòng lặp trong và vòng lặp ngoài. Ở vòng lặp trong, chuỗi được khử xu hướng, các chuỗi con theo từng vị trí mùa vụ (ví dụ tất cả các tháng 1, tất cả các tháng 2) được làm trơn bằng LOESS để thu được thành phần mùa vụ, thành phần này được lọc thông thấp để loại bỏ phần xu hướng lẫn vào, rồi chuỗi khử mùa vụ được làm trơn bằng LOESS để thu được xu hướng. Ở vòng lặp ngoài, phần dư R~t~ = Y~t~ − T~t~ − S~t~ được dùng để tính trọng số vững cho từng quan sát, và vòng lặp trong được chạy lại với các trọng số này (Cleveland và cộng sự, 1990). Nhờ LOESS, STL ước lượng được xu hướng ở cả hai đầu chuỗi và cho phép mùa vụ biến đổi chậm theo thời gian, với độ trơn điều khiển bằng tham số cửa sổ mùa vụ.

Slide trình bày chi tiết cơ chế kháng nhiễu bằng hàm trọng số bisquare (Trần Duy Thanh, 2026a, Ch2 tr.19–21). Đầu tiên tính phần dư R~i~ và độ lệch tuyệt đối trung vị M = median(|R~1~|, …, |R~n~|). Sau đó chuẩn hóa và tính trọng số:

$ u~i~ = |R~i~| / (6M)

$ w~i~ = (1 − u~i~^2^)^2^ nếu u~i~ < 1 ;  w~i~ = 0 nếu u~i~ ≥ 1

Slide giải thích vì sao chọn 6M: do 1 MAD ≈ 0,6745σ dưới phân phối chuẩn, ngưỡng 6M tương ứng khoảng 4,05σ, vượt xa vùng ±3σ chứa 99,7% dữ liệu bình thường, nên điểm có |R~i~| ≥ 6M chắc chắn là cực đoan và bị loại hoàn toàn khỏi đường xu hướng; các điểm trong ranh giới được giữ lại nhưng càng xa trung tâm thì trọng số càng giảm (Trần Duy Thanh, 2026a, Ch2 tr.20–21). Xu hướng mới được tính bằng trung bình có trọng số:

$ T~t~ = Σ~i~ W~i~ · Y~i~ / Σ~i~ W~i~, với W~i~ = w~i~ · d~i~

trong đó d~i~ là trọng số vị trí của cửa sổ (bằng 1 cho cửa sổ lẻ, bằng 0,5 ở hai đầu cho cửa sổ chẵn). Ví dụ tính tay của slide trên cùng dãy (10, 12, 100, 11, 13) khởi tạo đường nền bằng trung vị 12, tính phần dư (−2; 0; 88; −1; 1), M = 1, ngưỡng 6M = 6, các trọng số w ≈ (0,790; 1; 0; 0,945; 0,945). Với cửa sổ lẻ n = 5, T~3~ ≈ 42,58/3,68 ≈ 11,57; với cửa sổ chẵn n = 4, trọng số tổng hợp W ≈ (0,395; 1; 0; 0,945; 0,473) cho T~3~ ≈ 32,4915/2,81285 ≈ 11,55 (Trần Duy Thanh, 2026a, Ch2 tr.22–27, tr.33–38). So với 29,2 và 33,625 của phân rã cổ điển, xu hướng kháng nhiễu trở về đúng vùng sức khỏe lõi của doanh nghiệp.

Tiểu luận lưu ý hai điểm khi vận dụng STL kháng nhiễu vào dữ liệu kinh doanh. Thứ nhất, kháng nhiễu là con dao hai lưỡi: một cú sốc kéo dài nhiều kỳ, như một năm suy thoái, có thể bị coi là "ngoại lai" và bị giảm trọng số, khiến biến động chu kỳ thật bị đẩy vào phần dư thay vì được giữ trong khối xu hướng – chu kỳ. Vì vậy, lựa chọn có kháng nhiễu hay không cần được kiểm tra độ nhạy chứ không nên mặc định. Thứ hai, có thể định lượng độ mạnh của xu hướng và mùa vụ sau phân rã theo Wang, Smith và Hyndman (2006), như được trình bày trong Hyndman và Athanasopoulos (2021):

$ F~T~ = max(0; 1 − Var(R~t~) / Var(T~t~ + R~t~))

$ F~S~ = max(0; 1 − Var(R~t~) / Var(S~t~ + R~t~))

Hai chỉ số nằm trong [0; 1]; giá trị gần 1 cho biết thành phần tương ứng chi phối mạnh so với phần dư. Chỉ số F~S~ cho phép trả lời một câu hỏi quản trị cụ thể: có nên lập kế hoạch tồn kho và dòng tiền theo mùa hay không. Nếu F~S~ thấp, các "mùa cao điểm" quan sát được có thể chỉ là nhiễu.

### 2.3.4. Bộ lọc Hodrick–Prescott tách xu hướng và chu kỳ

Bộ lọc Hodrick–Prescott (HP) tách một chuỗi x~t~ (ở đây là khối xu hướng – chu kỳ TC~t~ từ STL) thành thành phần xu hướng trơn τ~t~ và thành phần chu kỳ c~t~ = x~t~ − τ~t~ bằng cách giải bài toán tối ưu (Hodrick & Prescott, 1997):

$ min~τ~ { Σ~t=1..T~ (x~t~ − τ~t~)^2^ + λ · Σ~t=2..T−1~ [(τ~t+1~ − τ~t~) − (τ~t~ − τ~t−1~)]^2^ }

Số hạng thứ nhất phạt độ lệch giữa xu hướng và dữ liệu, số hạng thứ hai phạt độ cong (sai phân bậc hai) của xu hướng. Tham số λ điều khiển sự đánh đổi: λ → 0 cho τ~t~ = x~t~, λ → ∞ cho xu hướng tuyến tính. Bài toán có nghiệm dạng đóng τ = (I + λD'D)^−1^x, với D là ma trận sai phân bậc hai. Hodrick và Prescott (1997) đề xuất λ = 1.600 cho dữ liệu quý; với dữ liệu tháng, giá trị quy ước phổ biến là 14.400, trong khi Ravn và Uhlig (2002) lập luận rằng λ nên được điều chỉnh theo lũy thừa bậc bốn của tỷ lệ tần suất quan sát, cho giá trị khoảng 129.600 với dữ liệu tháng. Tiểu luận dùng λ = 14.400 cho dữ liệu tháng theo đúng thực hành phổ biến và mã nguồn của học phần, đồng thời ghi nhận rằng kết quả chu kỳ nhạy với lựa chọn này.

Hamilton (2018) chỉ ra ba hạn chế của bộ lọc HP: nó có thể tạo ra các chu kỳ giả không có trong quá trình sinh dữ liệu, giá trị ở cuối mẫu khác biệt hệ thống với giá trị ở giữa mẫu (do bộ lọc hai phía trở thành một phía ở điểm cuối), và giá trị λ phổ biến không có cơ sở thống kê vững chắc. Hạn chế thứ hai đặc biệt quan trọng cho dự báo, vì nhà quản trị thường quan tâm nhất đến trạng thái chu kỳ ở thời điểm hiện tại, chính là điểm cuối mẫu. Tiểu luận vẫn dùng HP vì đây là công cụ của học phần và vì mục tiêu ở đây là mô tả cấu trúc chứ không phải suy diễn về chu kỳ kinh doanh, nhưng các kết luận về chu kỳ ở cuối mẫu được diễn giải thận trọng.

Ví dụ nâng cao của slide yêu cầu kết hợp STL và HP trong Python để bóc tách bốn thành phần của biên lợi nhuận ròng (cột net_profit_margin_pct) trong tệp ecommerce_profit_margin_2020_2025 (Trần Duy Thanh, 2026a, Ch2 tr.43–45). Vì biên lợi nhuận là một tỷ lệ phần trăm có thể âm, mô hình cộng là lựa chọn tự nhiên cho chuỗi này.

### 2.3.5. Phân rã đa chu kỳ mùa vụ và thuật toán backfitting

Dữ liệu TMĐT theo ngày thường chứa nhiều lớp mùa vụ chồng lên nhau: chu kỳ ngắn theo tuần, khi doanh thu đạt đỉnh vào cuối tuần và giảm vào thứ Hai, và chu kỳ dài theo năm, khi doanh thu bùng nổ vào các đợt Mega Sale tháng 11 và 12 (Trần Duy Thanh, 2026a, Ch2 tr.46). Mô hình MSTL (Multiple Seasonal-Trend decomposition using Loess) tách mùa vụ thành tổng của nhiều lớp (Trần Duy Thanh, 2026a, Ch2 tr.47; Bandara và cộng sự, 2021):

$ S~t~ = S~1,t~ + S~2,t~ + … + S~n,t~ ;  Y~t~ = T~t~ + S~tuần,t~ + S~năm,t~ + C~t~ + R~t~

Slide lưu ý rằng trong các thư viện thực tế, thành phần chu kỳ thường được gộp vào xu hướng hoặc phần dư, nên cần bộ lọc HP để tách riêng (Trần Duy Thanh, 2026a, Ch2 tr.47). Về thuật toán, MSTL ước lượng các thành phần mùa vụ bằng cách lặp: mỗi lớp mùa vụ được ước lượng bằng STL trên chuỗi đã trừ đi các lớp mùa vụ khác, và vòng lặp tiếp tục cho tới khi các thành phần ổn định (Bandara và cộng sự, 2021). Nguyên lý này là một trường hợp của thuật toán backfitting dùng cho mô hình cộng tổng quát (Hastie & Tibshirani, 1990).

Slide minh họa backfitting bằng hai ví dụ tính tay. Ví dụ 1 với bốn ngày Y = (12, 5, 18, 9) và xu hướng không đổi T = 11 cho chuỗi khử xu hướng (1; −6; 7; −2), từ đó sóng chu kỳ 2 ngày là S~1~ = (4; −4; 4; −4) và phần còn lại (−3; −2; 3; 2) chính là sóng chu kỳ 4 ngày S~2~ (Trần Duy Thanh, 2026a, Ch2 tr.48–49). Ví dụ 2 với bảy ngày Y = (26, 16, 20, 22, 20, 13, 26), xu hướng T = 20, sóng S~1~ chu kỳ 2 ngày (Flash Sale cách ngày) và sóng S~2~ chu kỳ 3 ngày (chu kỳ nhập hàng): chuỗi khử xu hướng là (6; −4; 0; 2; 0; −7; 6), sóng S~1~ = (3; −3; 3; −3; 3; −3; 3), phần còn lại (3; −1; −3; 5; −3; −4; 3) cho sóng S~2~ = (3,67; −2,00; −3,50) lặp lại, và phần dư R~t~ = (−0,67; 1; 0,5; 1,33; −1; −0,5; −0,67) (Trần Duy Thanh, 2026a, Ch2 tr.50–53, tr.58). Bảng so khớp trên slide cho thấy phương trình Y~t~ = T~t~ + S~1~ + S~2~ + R~t~ được bảo toàn chính xác ở mọi ngày, và kết quả tính tay khớp với kết quả lập trình (Trần Duy Thanh, 2026a, Ch2 tr.53, tr.58).

Một tính chất quan trọng mà ví dụ này ngầm định là mỗi sóng mùa vụ được chuẩn hóa để có tổng bằng 0 trong một chu kỳ; nếu không, mức trung bình của sóng sẽ lẫn vào xu hướng và phân rã không xác định duy nhất. Một tính chất khác là thứ tự bóc tách có ý nghĩa khi các chu kỳ không trực giao: sóng ước lượng trước sẽ hấp thụ một phần biến thiên của sóng sau. Vòng lặp backfitting giảm thiểu vấn đề này bằng cách cập nhật luân phiên. Ví dụ nâng cao của slide áp dụng MSTL cho tệp ecommerce_daily_multiseasonal với biến mục tiêu revenue_zscore (Trần Duy Thanh, 2026a, Ch2 tr.59–60).

Để định lượng đóng góp của từng thành phần sau phân rã đa chu kỳ, tiểu luận dùng tỷ trọng phương sai Var(S~k,t~)/Var(Y~t~) và chỉ số độ mạnh F~S~ riêng cho từng lớp mùa vụ. Cần lưu ý tổng các tỷ trọng phương sai không nhất thiết bằng 100% vì các thành phần ước lượng không hoàn toàn trực giao:

$ Var(Y) = Σ~k~ Var(X~k~) + 2 · Σ~k<l~ Cov(X~k~, X~l~)

với X~k~ lần lượt là xu hướng, các lớp mùa vụ và phần dư.

### 2.3.6. Mô hình cộng tổng quát và Prophet

Mô hình cộng tổng quát (Generalized Additive Model – GAM) biểu diễn biến phụ thuộc như tổng của các hàm trơn của từng biến giải thích (Hastie & Tibshirani, 1990). Prophet, công cụ do Meta phát triển, áp dụng ý tưởng này cho chuỗi thời gian với ba thành phần chính và nhiễu (Taylor & Letham, 2018; Trần Duy Thanh, 2026a, Ch2 tr.64–65):

$ Y~t~ = g(t) + s(t) + h(t) + ε~t~

Theo slide, g(t) là xu hướng dạng đường thẳng hoặc đường cong có thể tự bẻ gãy tại các điểm ngoặt (changepoints); s(t) là mùa vụ biểu diễn bằng chuỗi Fourier để tạo sóng trơn; h(t) là các xung lực ngày lễ kích hoạt bằng 1 vào ngày diễn ra sự kiện; và ε~t~ là sai số không giải thích được (Trần Duy Thanh, 2026a, Ch2 tr.65). Slide nhấn mạnh ưu điểm khả năng giải thích: với mạng nơ-ron, nhà phân tích khó trả lời "tại sao dự báo tăng 20%", còn với Prophet có thể mở phương trình để thấy đóng góp của xu hướng, mùa vụ và sự kiện (Trần Duy Thanh, 2026a, Ch2 tr.64). Về mặt hình thức, Taylor và Letham (2018) đặc tả xu hướng tuyến tính từng đoạn và mùa vụ Fourier như sau:

$ g(t) = (k + a(t)'δ) · t + (m + a(t)'γ)

$ s(t) = Σ~n=1..N~ [a~n~ · cos(2πnt/P) + b~n~ · sin(2πnt/P)]

trong đó k là tốc độ tăng trưởng gốc, δ là vector thay đổi tốc độ tại các điểm ngoặt, a(t) là vector chỉ báo các điểm ngoặt đã qua, γ đảm bảo tính liên tục, P là chu kỳ (7 cho tuần, 365,25 cho năm) và N là số bậc Fourier. Các tham số được ước lượng theo khung Bayes với tiên nghiệm Laplace trên δ, khiến phần lớn các thay đổi tốc độ bị co về 0 trừ khi dữ liệu đòi hỏi; tham số changepoint_prior_scale điều khiển độ linh hoạt này.

Slide trình bày hai ví dụ tính tay để làm rõ cơ chế. Ví dụ 1 xét doanh thu 5 ngày Y = (15, 12, 50, 16, 20) với Mega Sale ở ngày 3 (Trần Duy Thanh, 2026a, Ch2 tr.66). Mô hình rút gọn là:

$ Y~t~ = β~0~ + β~1~ · t + β~2~ · H~t~ + ε~t~

Bước 1 tạm loại ngày sale để cô lập ngày bình thường, cho t̄ = 3 và Ȳ = 15,75; bước 2 ước lượng β~1~ = 1,4 bằng bình phương tối thiểu; bước 3 tính β~0~ = 15,75 − 1,4 × 3 = 11,55; bước 4 tính hiệu ứng sale β~2~ = 50 − (11,55 + 1,4 × 3) = 34,25 (Trần Duy Thanh, 2026a, Ch2 tr.67–68). Từ đó dự báo ngày 6 không sale là Ŷ~6~ = 11,55 + 1,4 × 6 = 19,95 và ngày 7 có sale là Ŷ~7~ = 11,55 + 9,8 + 34,25 = 55,60 (Trần Duy Thanh, 2026a, Ch2 tr.70). Ví dụ 2 mở rộng với một cú sốc tin xấu ở ngày 4, dữ liệu Y = (20, 22, 70, 5, 28), và phương trình có thêm hai biến sự kiện H~sale~ và H~bad~ (Trần Duy Thanh, 2026a, Ch2 tr.82). Ý nghĩa kinh tế của các ví dụ là tách bạch "đà tăng trưởng tự nhiên" khỏi "hiệu ứng sự kiện", để nhà quản trị không nhầm lẫn doanh thu do khuyến mãi với sức khỏe nội tại của doanh nghiệp. Slide cũng minh họa cùng dữ liệu bằng thư viện Prophet với growth tuyến tính, tắt các mùa vụ, khai báo ngày lễ và changepoint_prior_scale = 0,01 (Trần Duy Thanh, 2026a, Ch2 tr.75–79); do có tiên nghiệm và chính quy hóa, kết quả của Prophet chỉ xấp xỉ chứ không trùng khít với lời giải bình phương tối thiểu tính tay.

Về đánh giá, Prophet cung cấp khoảng bất định dựa trên mô phỏng sự thay đổi xu hướng trong tương lai và nhiễu quan sát. Khoảng này không bao gồm bất định về mùa vụ theo mặc định và giả định tần suất, độ lớn của các điểm ngoặt trong tương lai giống quá khứ, nên độ phủ thực tế có thể khác danh nghĩa (Taylor & Letham, 2018). Tiểu luận vì vậy đánh giá độ phủ thực tế của khoảng Prophet bằng kiểm định chéo theo thời gian thay vì chấp nhận mức danh nghĩa.

### 2.3.7. Khử mùa vụ và tăng trưởng lõi

Slide đặt vấn đề bằng "cái bẫy của dữ liệu thô": tháng 12 doanh thu tăng vọt so với tháng 11 khiến lãnh đạo thưởng lớn, nhưng thực chất đó có thể chỉ là hiệu ứng mùa vụ; ngược lại tháng 2 sụt giảm có thể chỉ vì mùa thấp điểm (Trần Duy Thanh, 2026a, Ch2 tr.91). Phương trình tổng quát được mở rộng thêm thành phần sự kiện H~t~ (Trần Duy Thanh, 2026a, Ch2 tr.92–93):

$ Y~t~ = T~t~ × C~t~ × S~t~ × H~t~ × R~t~

Mục tiêu của khử mùa vụ là loại bỏ các yếu tố ngoại cảnh S~t~, H~t~ để cô lập tăng trưởng lõi (Trần Duy Thanh, 2026a, Ch2 tr.94). Với mô hình nhân và mô hình cộng, chuỗi khử mùa vụ lần lượt là:

$ Y~t~^SA^ = Y~t~ / (S~t~ × H~t~)

$ Y~t~^SA^ = Y~t~ − (S~t~ + H~t~)

Ví dụ của slide xét ba tháng: tháng 11 doanh thu 100 triệu với hệ số 1,0 × 1,0; tháng 12 doanh thu 150 triệu với hệ số 1,4 × 1,1 = 1,54; tháng 1 doanh thu 90 triệu với hệ số 0,8 × 1,0 (Trần Duy Thanh, 2026a, Ch2 tr.95). Kết quả khử mùa vụ là 100; 97,40 và 112,50 triệu đồng: tháng 12 với doanh thu thô cao nhất thực chất có tăng trưởng lõi thấp hơn tháng 11, còn tháng 1 với doanh thu thô thấp nhất mới là "ngôi sao" về hiệu suất nội tại (Trần Duy Thanh, 2026a, Ch2 tr.96–98). Với mô hình cộng và các hiệu ứng tuyệt đối 0; +50; −10 triệu, cả ba tháng đều có giá trị khử mùa vụ bằng 100 triệu (Trần Duy Thanh, 2026a, Ch2 tr.100–101). Slide kết luận rằng mô hình cộng ít dùng trong TMĐT vì quy mô doanh nghiệp thay đổi theo năm, trong khi mô hình nhân giả định hiệu ứng mùa vụ tỷ lệ theo quy mô (Trần Duy Thanh, 2026a, Ch2 tr.102).

Từ chuỗi khử mùa vụ, tăng trưởng lõi theo tháng (month-over-month, MoM) được tính như sau và có thể so sánh với tăng trưởng thô:

$ g~t~^raw^ = Y~t~ / Y~t−1~ − 1 ;  g~t~^core^ = Y~t~^SA^ / Y~t−1~^SA^ − 1

Khi hai tốc độ này trái dấu, tín hiệu tăng trưởng thô là "báo động giả". Tiểu luận mở rộng ý tưởng sang chỉ tiêu tăng trưởng thực: đối với một chuỗi danh nghĩa như TMBL, tăng trưởng danh nghĩa còn chứa thành phần giá. Khi biết tăng trưởng danh nghĩa g~N~ và tăng trưởng thực g~R~ (theo giá so sánh) do cơ quan thống kê công bố, chỉ số giảm phát ngầm định có thể suy ra:

$ π~impl~ = (1 + g~N~) / (1 + g~R~) − 1

Đây là lớp "khử nhiễu" thứ hai bên cạnh khử mùa vụ: khử mùa vụ trả lời câu hỏi doanh nghiệp tăng trưởng do nội lực hay do mùa, còn khử lạm phát trả lời câu hỏi tăng trưởng do lượng hay do giá.

### 2.3.8. Các mô hình chuẩn so sánh thống kê

Một kết luận về hiệu quả của mô hình phức tạp chỉ có ý nghĩa khi được so sánh với các chuẩn so sánh (benchmark) đơn giản nhưng mạnh. Tiểu luận sử dụng ba họ chuẩn so sánh thống kê. Họ thứ nhất là các phương pháp naive. Dự báo naive mùa vụ với chu kỳ m lấy giá trị của cùng vị trí mùa vụ ở chu kỳ trước:

$ Ŷ~T+h~ = Y~T+h−m·⌈h/m⌉~

Với dữ liệu ngày có mùa vụ tuần, m = 7, dự báo cho thứ Hai tuần tới là doanh số thứ Hai gần nhất. Một biến thể vững hơn là trung bình của cùng thứ trong k tuần gần nhất, giảm ảnh hưởng của một tuần bất thường. Với dữ liệu tháng có tăng trưởng, naive mùa vụ có thể được nhân thêm tốc độ tăng trưởng so cùng kỳ gần nhất để không bị thiên lệch xuống một cách hệ thống. Chuẩn so sánh naive mùa vụ cũng là mẫu số của MASE (Mục 2.5.5), nên mọi mô hình có MASE nhỏ hơn 1 đều đã vượt qua chuẩn này trong mẫu.

Họ thứ hai là san bằng mũ, trong đó mô hình Holt-Winters là đại diện quen thuộc nhất. Hyndman và cộng sự (2002) đặt các phương pháp san bằng mũ vào khung không gian trạng thái ETS (Error, Trend, Seasonal), cho phép ước lượng bằng hợp lý cực đại, chọn mô hình bằng tiêu chí thông tin và dựng khoảng dự báo có cơ sở xác suất. Dạng cộng có xu hướng và mùa vụ của Holt-Winters gồm các phương trình cập nhật mức ℓ~t~, xu hướng b~t~ và mùa vụ s~t~:

$ ℓ~t~ = α · (Y~t~ − s~t−m~) + (1 − α) · (ℓ~t−1~ + b~t−1~)

$ b~t~ = β · (ℓ~t~ − ℓ~t−1~) + (1 − β) · b~t−1~

$ s~t~ = γ · (Y~t~ − ℓ~t−1~ − b~t−1~) + (1 − γ) · s~t−m~ ;  Ŷ~T+h~ = ℓ~T~ + h · b~T~ + s~T+h−m·⌈h/m⌉~

Các tham số α, β, γ ∈ [0; 1] điều khiển tốc độ cập nhật; giá trị lớn làm mô hình phản ứng nhanh với dữ liệu mới nhưng nhạy với nhiễu. Có thể áp dụng mô hình cộng trên log Y~t~ để có dạng nhân. San bằng mũ là mô hình cục bộ điển hình: mỗi chuỗi có bộ tham số riêng, và vì số tham số ít nên nó ước lượng được ngay cả trên chuỗi tương đối ngắn. Đây là đối thủ trực tiếp của mô hình toàn cục ở Mục 2.4.2.

Họ thứ ba là mô hình ARIMA mùa vụ (SARIMA) theo truyền thống Box–Jenkins (Box và cộng sự, 2015). Với toán tử trễ B (BY~t~ = Y~t−1~), mô hình SARIMA(p, d, q)(P, D, Q)~m~ có dạng:

$ φ(B) · Φ(B^m^) · (1 − B)^d^ · (1 − B^m^)^D^ · Y~t~ = θ(B) · Θ(B^m^) · ε~t~

trong đó φ, θ là các đa thức tự hồi quy và trung bình trượt bậc p, q; Φ, Θ là các đa thức mùa vụ bậc P, Q; d, D là bậc sai phân thường và sai phân mùa vụ. Mô hình có thể được mở rộng với các biến ngoại sinh (SARIMAX), chẳng hạn biến lịch cho Tết Nguyên đán hay biến giả cho giai đoạn giãn cách xã hội; khi đó phần dư hồi quy được mô hình hóa bằng cấu trúc ARIMA. Ưu điểm của SARIMA là khoảng dự báo được suy ra trực tiếp từ cấu trúc mô hình, và với chuỗi tháng có mùa vụ ổn định, nó thường là một chuẩn so sánh khó vượt. Hạn chế là giả định tuyến tính và phương sai không đổi, nên thường cần biến đổi log trước.

Ba họ chuẩn so sánh này, cùng với Prophet (Mục 2.3.6) và các mô hình học máy (Mục 2.4), tạo thành một phổ từ đơn giản đến phức tạp. Kinh nghiệm từ các cuộc thi dự báo cho thấy không có mô hình nào thắng tuyệt đối trên mọi bộ dữ liệu, và các mô hình phức tạp chỉ phát huy lợi thế khi có đủ dữ liệu và đủ cấu trúc chung để học (Makridakis và cộng sự, 2022; Montero-Manso & Hyndman, 2021). Với chuỗi vĩ mô ngắn như vài chục quan sát tháng, nguyên tắc tiết kiệm tham số thường được ưu tiên.

### 2.3.9. Hiệu ứng lịch âm, sự kiện và cú sốc cấu trúc trong chuỗi vĩ mô Việt Nam

Đối với chuỗi bán lẻ Việt Nam, mùa vụ dương lịch không mô tả đầy đủ biến động, vì Tết Nguyên đán, đợt mua sắm lớn nhất trong năm, theo âm lịch và rơi vào tháng 1 hoặc tháng 2 dương lịch tùy năm. Một hệ số mùa vụ cố định cho tháng 1 vì vậy sẽ trộn lẫn những năm có Tết sớm và những năm có Tết muộn, làm mờ cả hai. Một cách xử lý phổ biến trong thống kê nhà nước là xây dựng biến hồi quy lịch đo tỷ lệ số ngày của một cửa sổ trước Tết rơi vào từng tháng dương lịch:

$ Tet~t~ = (1/w) · Σ~j=1..w~ 1{ngày (Tết − j) thuộc tháng t}

trong đó w là độ dài cửa sổ mua sắm trước Tết (ví dụ 21 ngày). Biến này nhận giá trị từ 0 đến 1, phân bổ hiệu ứng Tết cho tháng 12, tháng 1 hoặc tháng 2 tùy năm. Kết hợp với biến giả mùa vụ tháng, xu hướng và biến giả cho các tháng chịu tác động giãn cách xã hội, ta có một mô hình hồi quy trên log:

$ log Y~t~ = β~0~ + β~1~ · t + β~2~ · (t − t~0~)^+^ + Σ~k=2..12~ δ~k~ · M~k,t~ + γ · Tet~t~ + κ · Covid~t~ + u~t~

Số hạng (t − t~0~)^+^ cho phép độ dốc xu hướng thay đổi sau một mốc t~0~ (xu hướng gãy khúc), phản ánh pha phục hồi sau đại dịch. Hệ số γ và κ diễn giải xấp xỉ thành phần trăm thay đổi qua 100 · (e^γ^ − 1)%. Do u~t~ có thể tự tương quan và phương sai thay đổi, sai số chuẩn nên được tính theo Newey và West (1987). Trong ngôn ngữ của slide, đây là một mô hình GAM tuyến tính với thành phần lễ hội h(t) được thiết kế cho lịch âm, và với các cú sốc được mô hình hóa như sự kiện thay vì bị loại bỏ như ngoại lai (Trần Duy Thanh, 2026a, Ch1 tr.82; Ch2 tr.65).

Cú sốc COVID-19 là một ví dụ điển hình cho phân biệt giữa chu kỳ kinh tế C~t~ và nhiễu R~t~ mà slide nêu (Trần Duy Thanh, 2026a, Ch2 tr.5). Nếu không được mô hình hóa, các tháng giãn cách sẽ hoặc kéo xu hướng xuống (trong phân rã cổ điển), hoặc bị đẩy vào phần dư và làm phình độ bất định (trong STL kháng nhiễu), hoặc làm lệch hệ số mùa vụ của các tháng bị ảnh hưởng. Biến giả sự kiện cho phép tách hiệu ứng này một cách minh bạch, đồng thời giữ cho ước lượng mùa vụ và xu hướng của các giai đoạn bình thường không bị nhiễm.

### 2.3.10. Biến lịch khuyến mãi của TMĐT và vấn đề nhiễu do thứ trong tuần

Ngoài Tết Nguyên đán, lịch mua sắm của TMĐT Việt Nam có một hệ thống mốc khuyến mãi riêng do các sàn tạo ra: các "ngày đôi" (ngày trùng tháng như 9.9, 10.10, 11.11, 12.12), các đợt khuyến mãi giữa tháng và các đợt "Payday" gắn với kỳ nhận lương cuối tháng. Slide gợi đến các mốc này khi diễn giải hai đỉnh doanh số trong dữ liệu 90 ngày là "các chiến dịch Mega Sale (như 8/8 hoặc Payday Sale)" (Trần Duy Thanh, 2026a, Ch1 tr.63). Về mặt mô hình, các mốc lịch này có thể được biểu diễn bằng biến chỉ báo xác định trước:

$ DD~t~ = 1{ngày(t) = tháng(t)} ;  PAY~t~ = 1{ngày(t) = 25} ;  MID~t~ = 1{ngày(t) = 15}

Vì là biến xác định từ lịch, chúng có thể đưa vào cả mô hình phân rã (như thành phần h(t) của Prophet) lẫn mô hình học máy (như đặc trưng của LightGBM) mà không gây rò rỉ thông tin.

Kiểm định "hiệu ứng ngày đôi" trên dữ liệu ngày lại có một bẫy phương pháp luận dễ bị bỏ qua: nhiễu do thứ trong tuần (confounding by day-of-week). Một năm chỉ có 12 ngày đôi, và thứ trong tuần của các ngày này thay đổi theo năm. Nếu nhu cầu có mùa vụ tuần mạnh (cuối tuần cao hơn ngày thường), và nếu phần lớn ngày đôi trong cửa sổ quan sát rơi vào cuối tuần, phép so sánh thô "doanh số ngày đôi so với trung bình các ngày xung quanh" sẽ gán cho ngày đôi hiệu ứng thực chất của ngày cuối tuần. Đây là một trường hợp cụ thể của thiên lệch bỏ sót biến (Mục 2.2.2), với biến bị bỏ sót là thứ trong tuần. Cách xử lý là ước lượng hiệu ứng lịch trong một mô hình kiểm soát đồng thời thứ trong tuần, đặc điểm riêng của từng chuỗi và xu hướng:

$ ln y~i,t~ = μ~i~ + τ~i~ · t + Σ~d~ θ~d~ · DOW~d,t~ + γ~DD~ · DD~t~ + γ~PAY~ · PAY~t~ + γ~MID~ · MID~t~ + ε~i,t~

trong đó μ~i~ là hiệu ứng cố định của chuỗi i, τ~i~ là xu hướng riêng, θ~d~ là hiệu ứng thứ trong tuần. Hệ số 100·(e^γ_DD^ − 1)% là phần trăm thay đổi của nhu cầu vào ngày đôi so với một ngày cùng thứ không phải ngày đôi. Vì mọi chuỗi cùng chịu một cú sốc chung vào cùng một ngày, sai số của các quan sát trong cùng ngày có tương quan với nhau; sai số chuẩn cần được tính theo cụm (cluster) theo ngày, nếu không số bậc tự do hiệu dụng bị thổi phồng hàng trăm lần và một hiệu ứng rất nhỏ cũng có thể trở nên "có ý nghĩa thống kê" (Wooldridge, 2010). Tiểu luận sử dụng chính đặc tả này ở Chương 3 để phân biệt hiệu ứng lịch thật với hiệu ứng giả.

## 2.4. Học máy toàn cục cho dự báo đa chuỗi

### 2.4.1. Chuyển bài toán chuỗi thời gian thành bài toán hồi quy trên bảng

Các thuật toán học máy dạng cây như XGBoost hay LightGBM không "hiểu" trục thời gian; chúng chỉ làm việc với dữ liệu dạng bảng. Vì vậy, slide Chương 3 mô tả bước chuyển cốt lõi "từ chuỗi thành ma trận": chuỗi thời gian của tất cả các mã sản phẩm được cắt thành các khung cửa sổ và xếp chồng thành một ma trận hồi quy (Trần Duy Thanh, 2026a, Ch3 tr.4). Phương trình dự báo khi đó có cả chiều thời gian t và chiều thực thể i (Trần Duy Thanh, 2026a, Ch3 tr.5):

$ Y~i,t~ = f(X~i,t~) + ε~i,t~ ;  X~i,t~ = (Y~i,t−1~, Y~i,t−2~, …, Features~i~, Time~t~)

Ba nhóm đầu vào lần lượt là lịch sử của chính chuỗi (các biến trễ), đặc tính tĩnh của sản phẩm và các đặc trưng lịch – mùa vụ. Slide minh họa với hai sản phẩm SKU_A (điện thoại, doanh thu 100; 120; 150) và SKU_B (ốp lưng, doanh thu 10; 12; 15) trong ba ngày: thao tác shift theo từng mã tạo cột Lag 1, các dòng ngày 1 có Lag 1 khuyết bị loại, và ma trận cuối cùng gồm bốn mẫu học (Lag 1 = 100 → 120; 120 → 150; 10 → 12; 12 → 15) (Trần Duy Thanh, 2026a, Ch3 tr.6–9). Ma trận này được dùng để huấn luyện hàm f; slide dùng hồi quy tuyến tính để minh bạch hóa quá trình, rồi dự báo ngày 4 bằng cách đưa doanh số thực tế ngày 3 (150 và 15) vào làm Lag 1 (Trần Duy Thanh, 2026a, Ch3 tr.15–20).

Khi cần dự báo nhiều bước tới, có hai chiến lược. Chiến lược đệ quy (recursive) dùng chính dự báo bước h − 1 làm đầu vào cho bước h; slide minh họa bằng việc cập nhật mã để dự báo liên tục N = 7 ngày (Trần Duy Thanh, 2026a, Ch3 tr.22–26):

$ Ŷ~i,T+h~ = f(Ŷ~i,T+h−1~, …) , h = 1, 2, …, H

Chiến lược trực tiếp (direct) huấn luyện một hàm riêng, hoặc một hàm chung có chân trời h như một đặc trưng, ánh xạ trực tiếp thông tin tại gốc dự báo T sang giá trị tại T + h:

$ Ŷ~i,T+h~ = f~h~(X~i,T~) hoặc Ŷ~i,T+h~ = f(X~i,T~, h)

Tiểu luận lưu ý một tính chất quan trọng của chiến lược đệ quy mà ví dụ trên slide cho phép quan sát: sai số và cả cấu trúc hàm được lan truyền qua các bước. Với một hàm tuyến tính Ŷ~t~ = a + b · Y~t−1~ học từ chuỗi đang tăng, nếu b > 1 thì dự báo đệ quy tăng theo cấp số nhân và phân kỳ; nếu b < 1 thì hội tụ về điểm cố định a/(1 − b). Trong cả hai trường hợp, quỹ đạo dài hạn được quyết định bởi tính chất của hàm hơn là bởi dữ liệu. Chiến lược trực tiếp tránh tích lũy sai số đầu vào nhưng phải ước lượng nhiều quan hệ hơn. Với chân trời 14 ngày và mô hình cây, tiểu luận chọn chiến lược trực tiếp với h là một đặc trưng, để một mô hình duy nhất học được cách độ bất định và mức dự báo thay đổi theo chân trời.

### 2.4.2. Mô hình cục bộ và mô hình toàn cục

Cách tiếp cận truyền thống là mô hình cục bộ (local model): mỗi chuỗi thời gian có không gian tham số riêng, nguyên lý "1 mô hình = 1 chuỗi" (Trần Duy Thanh, 2026a, Ch3 tr.30). Slide chỉ ra ba điểm nghẽn của cách tiếp cận này ở quy mô công nghiệp với hàng chục nghìn SKU: chi phí điện toán để huấn luyện và vận hành hàng chục nghìn mô hình; đứt gãy thông tin vì mỗi mô hình không nhìn thấy các quy luật chung của thị trường; và bất lực trước sản phẩm mới không có lịch sử (Trần Duy Thanh, 2026a, Ch3 tr.30). Mô hình toàn cục (global model) gộp dữ liệu của N chuỗi thành một ma trận phẳng và tìm một hàm f duy nhất tối thiểu hóa tổn thất trên toàn bộ không gian quan sát (Trần Duy Thanh, 2026a, Ch3 tr.31):

$ min~f~ Σ~i=1..N~ Σ~t=1..Ti~ L(Y~i,t~, f(X~i,t~)) + Ω(f)

với Ω(f) là số hạng chính quy hóa độ phức tạp. Slide nhấn mạnh rằng học chéo (cross-learning) không phải là một siêu tham số có thể bật tắt, mà là hệ quả tất yếu của hàm mục tiêu gộp: các chuỗi chia sẻ những yếu tố chung như lịch, thời tiết, khuyến mãi, nên thuật toán có thể "vay mượn thông tin" giữa các chuỗi (Trần Duy Thanh, 2026a, Ch3 tr.32). Trong cây quyết định tăng cường gradient, học chéo được thực thi qua phân hoạch không gian dựa trên đặc trưng thay vì dựa trên ID: khi dò điểm cắt tối ưu, thuật toán rà soát toàn bộ không gian vector X~i,t~ mà không quan tâm dòng dữ liệu thuộc về chuỗi nào (Trần Duy Thanh, 2026a, Ch3 tr.33).

Về mặt lý thuyết, Montero-Manso và Hyndman (2021) chứng minh rằng với một tập chuỗi hữu hạn, mọi phương pháp cục bộ đều có thể được biểu diễn tương đương bằng một phương pháp toàn cục, nên mô hình toàn cục không kém tổng quát hơn; đồng thời chúng có độ phức tạp tính trên từng chuỗi thấp hơn, cho phép dùng các lớp hàm phong phú hơn mà không bị quá khớp. Các tác giả cũng chỉ ra điều kiện để mô hình toàn cục phát huy lợi thế: tập chuỗi phải đủ lớn và các chuỗi phải chia sẻ cấu trúc ở mức nhất định; với các tập chuỗi nhỏ và dị biệt, mô hình cục bộ được tinh chỉnh tốt vẫn có thể cạnh tranh. Bằng chứng thực nghiệm quy mô lớn đến từ cuộc thi M5 trên dữ liệu bán lẻ Walmart, mà slide giới thiệu như một case study với 30.490 chuỗi cấp sản phẩm – cửa hàng (3.049 sản phẩm tại 10 cửa hàng ở 3 bang), lịch sử 5 năm và chân trời 28 ngày (Trần Duy Thanh, 2026a, Ch3 tr.93). Khi tính cả các cấp tổng hợp, bài toán gồm 42.840 chuỗi; các giải pháp dẫn đầu phần lớn dựa trên LightGBM huấn luyện toàn cục trên nhiều chuỗi, và các phương pháp học máy vượt trội rõ rệt so với các chuẩn so sánh thống kê (Makridakis và cộng sự, 2022). Bảng {T:@c2m_localglobal} tổng hợp sự khác biệt.

[[T:@c2m_localglobal So sánh mô hình cục bộ và mô hình toàn cục trong dự báo đa chuỗi
Tiêu chí | Mô hình cục bộ (Local) | Mô hình toàn cục (Global)
Số mô hình | N mô hình cho N chuỗi | 1 mô hình cho N chuỗi
Hàm mục tiêu | Σ~t~ L(Y~t~, f~i~(X~t~)) riêng từng chuỗi | Σ~i~ Σ~t~ L(Y~i,t~, f(X~i,t~)) gộp
Chia sẻ thông tin | Không | Có (học chéo qua đặc trưng chung)
Sản phẩm mới | Không dự báo được | Dự báo qua đặc trưng tĩnh và đặc trưng ngành
Yêu cầu về quy mô | Hiệu quả với ít chuỗi, chuỗi dài | Hiệu quả với nhiều chuỗi chia sẻ cấu trúc
Rủi ro chính | Quá khớp từng chuỗi, chi phí vận hành | Thiên lệch do chênh lệch quy mô giữa chuỗi
Ví dụ điển hình | ETS, ARIMA, Holt-Winters | LightGBM, DeepAR trên dữ liệu gộp
Nguồn: Tổng hợp từ Trần Duy Thanh (2026a, Ch3 tr.30–43) và Montero-Manso và Hyndman (2021).
]]

### 2.4.3. Gradient Boosting và LightGBM

Gradient Boosting (Friedman, 2001) xây dựng một mô hình cộng gồm các cây hồi quy yếu được thêm vào tuần tự, mỗi cây khớp với gradient âm của hàm tổn thất tại dự báo hiện thời. Slide trình bày thuật toán theo các bước sau (Trần Duy Thanh, 2026a, Ch3 tr.34–40). Bước khởi tạo tìm hằng số tối ưu trên toàn bộ ma trận:

$ F~0~(x) = arg min~γ~ Σ~i=1..N~ L(y~i~, γ)

Với tổn thất bình phương, F~0~ là trung bình cộng của biến mục tiêu; slide gọi đây là bước chia sẻ thông tin nền tảng đầu tiên vì mọi chuỗi xuất phát từ cùng một vạch (Trần Duy Thanh, 2026a, Ch3 tr.35). Tại mỗi vòng m = 1, …, M, thuật toán tính thặng dư giả (pseudo-residuals):

$ r~i,m~ = −[∂L(y~i~, F(x~i~)) / ∂F(x~i~)] tại F = F~m−1~

khớp một cây hồi quy h~m~ chia không gian thành J vùng lá R~j,m~ (Trần Duy Thanh, 2026a, Ch3 tr.36–37), tính trọng số tối ưu cho từng lá:

$ γ~j,m~ = arg min~γ~ Σ~xi∈Rj,m~ L(y~i~, F~m−1~(x~i~) + γ)

và cập nhật mô hình với tốc độ học η ∈ (0; 1] (Trần Duy Thanh, 2026a, Ch3 tr.38–39):

$ F~m~(x) = F~m−1~(x) + η · Σ~j=1..J~ γ~j,m~ · I(x ∈ R~j,m~)

Mô hình hội tụ là F~M~(x) = F~0~(x) + Σ~m~ η · h~m~(x) (Trần Duy Thanh, 2026a, Ch3 tr.40). Khi có truy vấn mới, kể cả của một sản phẩm chưa có lịch sử, vector đặc trưng được truyền qua M cây và nhận trọng số của lá mà nó rơi vào ở mỗi cây (Trần Duy Thanh, 2026a, Ch3 tr.41).

Ví dụ tính tay của slide làm rõ cơ chế học chéo (Trần Duy Thanh, 2026a, Ch3 tr.42–50). Ba sản phẩm đồ uống lạnh A (trà sữa), B (nước mía) và C (nước ép mới ra mắt) có năm quan sát lịch sử: A bán 200 ở 36°C và 50 ở 30°C, B bán 180 ở 37°C và 40 ở 32°C, C bán 45 ở 31°C và chưa từng trải qua ngày trên 35°C. Khởi tạo F~0~ = (200 + 50 + 180 + 40 + 45)/5 = 103; thặng dư là (+97; −53; +77; −63; −58); cây số 1 tìm ra ranh giới nhiệt độ 35°C tách hai vùng với trọng số lá γ~1~ = (97 + 77)/2 = +87 và γ~2~ = (−53 − 63 − 58)/3 = −58. Với η = 1, truy vấn của C ở 36°C rơi vào vùng R~1~ và nhận dự báo 103 + 87 = 190 đơn vị (Trần Duy Thanh, 2026a, Ch3 tr.45–50). Slide nhấn mạnh rằng con số +87 hoàn toàn được kết tinh từ thặng dư của A và B, nhưng nhờ chia sẻ không gian đặc trưng mà C kế thừa được tri thức đó (Trần Duy Thanh, 2026a, Ch3 tr.50). Tiểu luận lưu ý thêm rằng ngưỡng cắt mà một thư viện cụ thể chọn có thể là bất kỳ giá trị nào giữa hai giá trị nhiệt độ liền kề phân tách tốt nhất (ở đây giữa 32°C và 36°C), nên ngưỡng 35°C trên slide là một lựa chọn minh họa trong khoảng tương đương; kết quả dự báo cho C không thay đổi.

LightGBM (Ke và cộng sự, 2017) là một triển khai hiệu năng cao của Gradient Boosting với bốn cải tiến chính: xây dựng cây dựa trên histogram, gom giá trị liên tục vào các bin rời rạc để giảm chi phí tìm điểm cắt; tăng trưởng cây theo lá (leaf-wise) thay vì theo tầng, chọn lá có mức giảm tổn thất lớn nhất để phân tách; lấy mẫu một phía dựa trên gradient (GOSS), giữ lại các quan sát có gradient lớn và lấy mẫu ngẫu nhiên các quan sát có gradient nhỏ; và gộp các đặc trưng loại trừ nhau (EFB) để giảm số chiều. Ngoài tổn thất bình phương, LightGBM hỗ trợ tổn thất phân vị, cho phép huấn luyện trực tiếp các mô hình dự báo phân vị (Mục 2.5.3). Tầm quan trọng đặc trưng theo gain, tức tổng mức giảm tổn thất do các phép phân tách dùng đặc trưng đó, cung cấp một chỉ báo về đóng góp tương đối của từng đặc trưng, dù chỉ báo này không có nghĩa nhân quả.

### 2.4.4. Kỹ thuật tạo đặc trưng

Slide khẳng định rằng với mô hình toàn cục quy mô lớn, chất lượng dữ liệu đầu vào quyết định phần lớn độ chính xác, vì dữ liệu doanh số thô tự nó chứa rất ít ngữ cảnh (Trần Duy Thanh, 2026a, Ch3 tr.56). Không gian đặc trưng được tổ chức thành bốn nhóm (Trần Duy Thanh, 2026a, Ch3 tr.57–60): đặc trưng thời gian và lịch (thứ trong tuần, tháng, ngày trong tháng, cuối tuần); đặc trưng trễ và cửa sổ trượt (Y~t−1~, Y~t−7~, Y~t−30~, trung bình và độ lệch chuẩn trượt); đặc trưng tĩnh định danh và phân khúc (ngành hàng, phân khúc giá, thương hiệu, giá niêm yết); và đặc trưng ngoại sinh (thời tiết, khuyến mãi, sự kiện như Black Friday và Tết Nguyên đán). Hệ thống phân loại mở rộng bổ sung đặc trưng tốc độ và động lượng, chẳng hạn tốc độ tăng trưởng ngày so với ngày V~1d~ = (Y~t−1~ − Y~t−2~)/(Y~t−2~ + ε) và độ dốc xu hướng trên cửa sổ 7 ngày (Trần Duy Thanh, 2026a, Ch3 tr.66); đặc trưng tỷ lệ giá tương đối P~ratio~ = Price~t~/RollingMean(Price)~30d~ (Trần Duy Thanh, 2026a, Ch3 tr.67); và đặc trưng tương tác không gian – thời gian như nhiệt độ × nhóm ngành để thời tiết nóng chỉ kích thích nhóm đồ uống mà không tác động cùng chiều lên điện tử (Trần Duy Thanh, 2026a, Ch3 tr.68).

Một thách thức đặc thù của mô hình toàn cục là chênh lệch quy mô (scale imbalance) giữa các chuỗi. Slide minh họa bằng mì tôm bán khoảng 10.000 gói/ngày và laptop bán khoảng 5 chiếc/ngày, cả hai cùng chạy giảm giá 30% (Trần Duy Thanh, 2026a, Ch3 tr.69). Nếu huấn luyện trên số tuyệt đối, tổn thất bình phương bị chi phối hoàn toàn bởi chuỗi lớn, và các phân tách của cây sẽ chủ yếu phục vụ chuỗi đó. Giải pháp của slide là tính đường cơ sở Baseline~30d~ cho từng sản phẩm và tạo đặc trưng biến động tương đối, để mô hình học hệ số nhân thay vì số tuyệt đối (Trần Duy Thanh, 2026a, Ch3 tr.70–71). Tiểu luận hình thức hóa giải pháp này thành phép chuẩn hóa mục tiêu theo quy mô:

$ ỹ~i,t~ = Y~i,t~ / m~i,T~ ;  Ŷ~i,T+h~ = m~i,T~ · f(X̃~i,T~, h)

trong đó m~i,T~ là mức trung bình của chuỗi i trong một cửa sổ gần gốc dự báo T (ví dụ 28 ngày), và các đặc trưng trễ cũng được chia cho m~i,T~. Với phép biến đổi này, các chuỗi có quy mô khác nhau nhưng cùng "hình dạng" sẽ rơi vào cùng vùng không gian đặc trưng và chia sẻ trọng số lá, đúng tinh thần học chéo. Bài tập trên tệp raw_sales_data yêu cầu dùng kỹ thuật đặc trưng để dự báo doanh thu cho sản phẩm mới (Trần Duy Thanh, 2026a, Ch3 tr.73).

Slide còn giải quyết mâu thuẫn quanh mã sản phẩm (Product_ID) theo hai nguyên tắc (Trần Duy Thanh, 2026a, Ch3 tr.77–79). Nguyên tắc 1: giữ Product_ID như khóa tra cứu (lookup key) trong bảng kết quả để biết dự báo thuộc mặt hàng nào, nhưng không dùng làm biến học tập. Nguyên tắc 2: dịch Product_ID thành các đặc trưng tĩnh như ngành hàng, phân khúc giá, tính dễ hỏng, để khi một sản phẩm mới ra mắt, mô hình nhận diện nó qua thuộc tính thay vì qua tên. Hai nguyên tắc này là điều kiện để mô hình toàn cục xử lý được bài toán khởi tạo lạnh.

### 2.4.5. Bài toán sản phẩm mới (cold-start)

Bài toán khởi tạo lạnh xuất hiện khi cần dự báo cho một thực thể không có hoặc có rất ít lịch sử. Theo lập luận của slide, mô hình cục bộ như ARIMA cho sản phẩm C chỉ nhìn vào một tuần lịch sử của chính nó, nên không thể phản ứng với một điều kiện chưa từng gặp như nhiệt độ trên 35°C, trong khi mô hình toàn cục cho phép C kế thừa tri thức từ A và B qua đặc trưng chung (Trần Duy Thanh, 2026a, Ch3 tr.42–44). Slide về DeepAR cũng nêu cùng ý tưởng: khi đưa một cuốn sách mới vào hệ thống, mô hình dùng các đặc trưng tĩnh như thể loại, tác giả, giá để đối chiếu với hàng nghìn cuốn tương tự và vẽ ra ngay dải phân phối xác suất (Trần Duy Thanh, 2026a, Ch4 tr.25).

Tiểu luận phân biệt ba mức độ khởi tạo lạnh, vì mỗi mức đòi hỏi thông tin khác nhau. Ở mức khởi tạo lạnh hoàn toàn (zero-shot), mô hình chỉ có đặc trưng tĩnh và lịch, nên dự báo về bản chất là dự báo cho một "sản phẩm điển hình" của ngành có cùng mức giá; sai số phụ thuộc vào mức độ mà đặc trưng tĩnh giải thích được quy mô nhu cầu. Ở mức khởi động ấm (warm-start), sản phẩm đã có vài ngày lịch sử, đủ để ước lượng quy mô m~i,T~; khi đó phép chuẩn hóa theo quy mô ở Mục 2.4.4 cho phép mô hình toàn cục áp dụng ngay hình dạng chung (mùa vụ tuần, động lượng) mà nó học từ các sản phẩm khác. Ở mức đủ lịch sử, sản phẩm trở thành một chuỗi bình thường. Giả thuyết lý thuyết rút ra là phần lớn khó khăn của khởi tạo lạnh nằm ở việc ước lượng quy mô chứ không ở việc ước lượng hình dạng, và vì vậy chỉ cần một lượng nhỏ lịch sử là đủ để thu hẹp đáng kể sai số. Chương 4 kiểm định giả thuyết này.

### 2.4.6. Chiến lược kiểm định cho dự báo chuỗi thời gian

Kiểm định chéo K-fold truyền thống xáo trộn dữ liệu và chia thành K phần; áp dụng nguyên xi vào chuỗi thời gian sẽ dẫn tới sai lầm phương pháp luận (Trần Duy Thanh, 2026a, Ch3 tr.82). Lý do là giả định độc lập bị vi phạm: Y~t~ phụ thuộc chặt chẽ vào Y~t−1~, Y~t−2~, nên xáo trộn khiến mô hình dùng tương lai để dự báo quá khứ, một hiện tượng rò rỉ dữ liệu (data leakage) (Trần Duy Thanh, 2026a, Ch3 tr.83). Ví dụ năm ngày của slide cho thấy nếu tập huấn luyện ngẫu nhiên gồm ngày 1, 3, 5 và tập kiểm tra gồm ngày 2, 4 thì để dự báo ngày 2 mô hình đã thấy ngày 3 và 5, tức "gian lận thời gian" (Trần Duy Thanh, 2026a, Ch3 tr.86). Giải pháp là kiểm định cửa sổ trượt (rolling-origin hay walk-forward): ở lần gập thứ k, tập huấn luyện gồm các ngày từ 1 đến T + (k − 1)H và tập kiểm tra gồm H ngày kế tiếp, mô phỏng đúng quy trình doanh nghiệp định kỳ cập nhật dữ liệu và huấn luyện lại (Trần Duy Thanh, 2026a, Ch3 tr.84–85):

$ Train~k~ = {1, …, T + (k − 1)H} ;  Test~k~ = {T + (k − 1)H + 1, …, T + kH}

Slide cũng đặt câu hỏi về mục tiêu của kiểm định: kiểm định khả năng dự báo tương lai cho sản phẩm cũ, hay khả năng dự báo cho sản phẩm hoàn toàn mới (Trần Duy Thanh, 2026a, Ch3 tr.84). Hai mục tiêu này đòi hỏi hai thiết kế khác nhau: chia theo thời gian cho câu hỏi thứ nhất, và giữ lại toàn bộ một nhóm thực thể khỏi huấn luyện cho câu hỏi thứ hai. Ví dụ trên tệp complex_retail_sales mô tả năm sản phẩm với cơ chế hành vi trái ngược nhau về cuối tuần và khuyến mãi, và dùng TimeSeriesSplit ba lần gập với Gradient Boosting trên các đặc trưng Is_Weekend, Discount, Baseline_Sales mà không dùng Product_ID (Trần Duy Thanh, 2026a, Ch3 tr.87–89).

Bergmeir và Benítez (2012) bổ sung một sắc thái: với các mô hình tự hồi quy thuần túy có phần dư không tương quan, kiểm định chéo thông thường không nhất thiết sai về lý thuyết, nhưng trong thực hành với chuỗi có xu hướng, mùa vụ và đặc trưng cửa sổ trượt, đánh giá theo thứ tự thời gian vẫn là lựa chọn an toàn và phản ánh đúng quy trình vận hành. Tiểu luận áp dụng nhất quán nguyên tắc walk-forward cho mọi so sánh mô hình, và dùng K-fold xáo trộn chỉ như một đối chứng để định lượng mức độ lạc quan giả tạo mà rò rỉ có thể gây ra.

### 2.4.7. Ước lượng uplift khuyến mãi: từ đặc trưng chuẩn hóa đến meta-learner

Slide Chương 3 đưa khái niệm uplift vào kỹ thuật tạo đặc trưng: thay vì đưa số lượng bán tuyệt đối vào mô hình, hệ thống tính đường cơ sở là trung bình doanh số 30 ngày của từng sản phẩm và tạo đặc trưng biến động tương đối (Trần Duy Thanh, 2026a, Ch3 tr.70):

$ X~uplift~ = (Y~t~ − Baseline~30d~) / Baseline~30d~

Ví dụ của slide cho thấy ý nghĩa của phép chuẩn hóa: khi mì tôm bán từ 10.000 lên 20.000 gói và laptop bán từ 5 lên 10 chiếc trong ngày khuyến mãi, cả hai có cùng X~uplift~ = +1,0, nhờ đó một sản phẩm mới chưa có lịch sử có thể "nội suy" mức tăng từ cụm sản phẩm có cùng mức giảm giá (Trần Duy Thanh, 2026a, Ch3 tr.70–71). Cách tiếp cận này ngầm định rằng uplift là một đại lượng có thể chuyển giao giữa các sản phẩm. Ví dụ kiểm định chéo của slide lại cho thấy giả định đó không luôn đúng: trong tệp complex_retail_sales, cà phê có hệ số khuyến mãi ×1,3, nước ép chỉ ×1,1 vì "khuyến mãi ít tác dụng", bánh mì công sở có độ nhạy khuyến mãi "cực cao" ×1,5, còn trà đá "không bao giờ chạy khuyến mãi" (Trần Duy Thanh, 2026a, Ch3 tr.87). Nói cách khác, hiệu ứng khuyến mãi là dị biệt theo sản phẩm, và câu hỏi quản trị "nên khuyến mãi sản phẩm nào" chính là câu hỏi về sự dị biệt đó.

Văn liệu suy luận nhân quả cung cấp ngôn ngữ chính xác cho câu hỏi này. Theo khung kết quả tiềm năng (potential outcomes), với mỗi quan sát i có hai kết quả Y~i~(1) khi được khuyến mãi và Y~i~(0) khi không; hiệu ứng có điều kiện theo đặc trưng x là:

$ τ(x) = E[Y(1) − Y(0) | X = x]

hoặc ở dạng tỷ lệ (hệ số nhân uplift):

$ m(x) = E[Y(1) | X = x] / E[Y(0) | X = x]

Künzel và cộng sự (2019) phân loại các cách dùng mô hình học máy để ước lượng τ(x) thành các "meta-learner". S-learner huấn luyện một mô hình duy nhất μ̂(x, w) với biến can thiệp w là một đặc trưng, rồi lấy hiệu dự báo:

$ τ̂~S~(x) = μ̂(x, 1) − μ̂(x, 0)

T-learner huấn luyện hai mô hình riêng cho nhóm có và không có can thiệp:

$ τ̂~T~(x) = μ̂~1~(x) − μ̂~0~(x)

S-learner tận dụng toàn bộ dữ liệu và phù hợp khi hiệu ứng nhỏ so với biến động nền, nhưng có thể "bỏ qua" biến can thiệp nếu thuật toán cây không chọn nó để chia nhánh; T-learner linh hoạt hơn nhưng mỗi mô hình chỉ học trên một phần dữ liệu, nên phương sai cao khi nhóm có can thiệp nhỏ. Athey và Imbens (2016) phát triển các cây quyết định được thiết kế trực tiếp cho việc ước lượng hiệu ứng dị biệt, với tiêu chí chia nhánh tối ưu cho độ chính xác của τ̂(x) thay vì của dự báo Y. Đối với dữ liệu khuyến mãi bán lẻ, một S-learner dùng Gradient Boosting với các biến cuối tuần, khuyến mãi và quy mô nền chính là mô hình toàn cục của slide; khi đó hệ số nhân uplift mà mô hình "học được" cho sản phẩm có quy mô b là:

$ m̂(b) = f̂(Weekend = 0, Promo = 1, Base = b) / f̂(Weekend = 0, Promo = 0, Base = b)

Một chuẩn so sánh tối thiểu là uplift gộp (pooled uplift): một con số duy nhất bằng tỷ số doanh số trung bình có và không có khuyến mãi trên toàn bộ dữ liệu. Uplift gộp là cách mà nhiều đội thương mại vẫn dùng khi lập kế hoạch ("khuyến mãi làm doanh số tăng khoảng 40%"), và chính sự khác biệt giữa uplift gộp với uplift theo sản phẩm đo lường giá trị của việc mô hình hóa dị biệt.

### 2.4.8. Dự báo có điều kiện, ước lượng nhân quả và vai trò của thử nghiệm có đối chứng

Một phân biệt có ý nghĩa quyết định đối với toàn bộ tiểu luận là khác biệt giữa dự báo có điều kiện và ước lượng nhân quả. Dự báo có điều kiện trả lời câu hỏi "khi quan sát thấy quảng cáo bằng a và chiết khấu bằng δ thì doanh số thường bằng bao nhiêu", tức ước lượng E[Y | Ad = a, δ]. Ước lượng nhân quả trả lời câu hỏi "nếu ta can thiệp đặt quảng cáo bằng a thì doanh số sẽ bằng bao nhiêu", tức E[Y | do(Ad = a)]. Hai đại lượng trùng nhau khi việc gán mức quảng cáo độc lập với các yếu tố khác ảnh hưởng đến doanh số, điều hiếm khi đúng với dữ liệu quan sát: doanh nghiệp tăng quảng cáo đúng vào những ngày đã biết trước là cao điểm (ngày sự kiện, cuối tuần), nên một phần tương quan giữa quảng cáo và doanh số là do lịch chứ không phải do quảng cáo. Thiên lệch bỏ sót biến ở Mục 2.2.2 là biểu hiện tuyến tính của vấn đề này.

Kohavi và cộng sự (2020) trình bày thử nghiệm có đối chứng trực tuyến (A/B test) như tiêu chuẩn để ước lượng hiệu ứng nhân quả trong môi trường số: chia ngẫu nhiên đơn vị (người dùng, phiên, ngày hoặc vùng) thành nhóm can thiệp và nhóm đối chứng, sau đó so sánh kết quả. Ngẫu nhiên hóa bảo đảm rằng các yếu tố gây nhiễu được phân bố như nhau giữa hai nhóm, nên hiệu trung bình là ước lượng không chệch của hiệu ứng trung bình:

$ τ̂~ATE~ = Ȳ~can thiệp~ − Ȳ~đối chứng~ ;  SE(τ̂) = √(s~1~^2^/n~1~ + s~0~^2^/n~0~)

Đối với nhà bán hàng TMĐT, việc ngẫu nhiên hóa ở cấp người dùng thường do sàn kiểm soát, nhưng nhà bán hàng vẫn có thể thiết kế thử nghiệm ở cấp ngày (luân phiên mức ngân sách theo lịch ngẫu nhiên) hoặc cấp sản phẩm (ngẫu nhiên chọn sản phẩm được khuyến mãi). Thử nghiệm đặc biệt cần thiết khi dữ liệu lịch sử không chứa biến thiên độc lập của hai biến: nếu mọi ngày Mega Sale đều có chiết khấu 50%, không có thuật toán nào trên dữ liệu quan sát có thể cho biết một ngày Mega Sale với chiết khấu 30% sẽ ra sao. Tiểu luận vì vậy nhất quán dùng thuật ngữ "dự báo có điều kiện" cho mọi kịch bản chiến dịch, gắn cờ "ngoại suy" khi kịch bản nằm ngoài vùng dữ liệu, và coi thử nghiệm có đối chứng là bước tiếp theo cần thiết trước khi biến kết quả thành chính sách.

## 2.5. Dự báo xác suất, quyết định chuẩn bị hàng và rủi ro chiến dịch

### 2.5.1. Từ dự báo điểm đến dự báo phân phối

Chương 4 của học phần mở đầu bằng sự chuyển dịch câu hỏi: nếu các chương trước trả lời "doanh số ngày mai là bao nhiêu" thì nhà quản trị cần biết "biên độ dao động an toàn là gì và phải giữ bao nhiêu hàng để không đứt gãy chuỗi cung ứng" (Trần Duy Thanh, 2026a, Ch4 tr.4). Ví dụ trên slide rất trực quan: dự báo điểm ngày mai bán 150 sản phẩm, nhưng xác suất bán đúng 150 gần như bằng 0; nếu nhập đúng 150 thì rủi ro đứt hàng là khoảng 50% khi phân phối nhu cầu đối xứng quanh dự báo (Trần Duy Thanh, 2026a, Ch4 tr.4). Dự báo xác suất trả về phân phối có điều kiện P(y~T+h~ | x~T+h~) hoặc một tập phân vị, và giao tiếp bằng ngôn ngữ rủi ro: "có 90% khả năng doanh số rơi vào khoảng 120 đến 180" (Trần Duy Thanh, 2026a, Ch4 tr.5). Phân vị mức q của nhu cầu D là:

$ P~q~ = F~D~^−1^(q) = inf{y : P(D ≤ y) ≥ q}

Lý do cốt lõi để chuỗi cung ứng cần dự báo xác suất là chi phí sai lầm không đối xứng (Trần Duy Thanh, 2026a, Ch4 tr.6): tồn kho thừa 30 sản phẩm có thể chỉ tốn chi phí lưu kho nhỏ, nhưng thiếu 30 sản phẩm làm mất lợi nhuận gộp, mất khách và tổn hại uy tín. Bảng so sánh trên slide tóm tắt khác biệt: dự báo điểm cho một con số, hầu như không bao phủ rủi ro và phù hợp để đặt mục tiêu kinh doanh; dự báo xác suất cho một dải phân vị, nhìn thấy cả kịch bản bi quan và lạc quan, và phù hợp để tối ưu tồn kho an toàn và quản trị rủi ro (Trần Duy Thanh, 2026a, Ch4 tr.7).

Slide cũng phân định hai khái niệm thường bị đồng nhất (Trần Duy Thanh, 2026a, Ch4 tr.51). Khoảng tin cậy (Confidence Interval – CI) định lượng bất định của các tham số ước lượng; độ rộng của nó tiến về 0 khi cỡ mẫu tăng, nên không phản ánh rủi ro vận hành. Khoảng dự báo (Prediction Interval – PI) định lượng bất định của một quan sát tương lai, bao gồm cả nhiễu nội tại của quá trình; độ rộng của nó không tiến về 0 dù dữ liệu nhiều đến đâu. Quyết định tồn kho cần PI chứ không phải CI. Khoảng cách giữa P90 và P10 là chỉ báo định lượng về rủi ro của danh mục: biên độ hẹp phù hợp với chuỗi cung ứng tinh gọn, biên độ rộng đòi hỏi tồn kho đệm và chuỗi cung ứng linh hoạt (Trần Duy Thanh, 2026a, Ch4 tr.52).

### 2.5.2. Tiếp cận Z-score có hiệu chỉnh thiên lệch

Cách tiếp cận đơn giản nhất xây dựng phân vị từ một dự báo điểm cộng với độ bất định giả định chuẩn. Bảng Z trên slide liệt kê các mốc thường dùng: P1 ứng với Z = −2,33; P5 với −1,645; P10 với −1,28; P50 với 0; P90 với +1,28; P95 với +1,645 và P99 với +2,33 (Trần Duy Thanh, 2026a, Ch4 tr.9). Quy trình của slide gồm bốn bước (Trần Duy Thanh, 2026a, Ch4 tr.10–17). Bước 1 dự báo điểm bằng SMA 3 ngày; với doanh số 8 ngày (100, 110, 120, 130, 110, 150, 100, 170), dự báo ngày 9 là (150 + 100 + 170)/3 = 140. Bước 2 dự báo ngược quá khứ cho các ngày 4 đến 8 và tính sai số e = y − ŷ, với quy ước sai số dương là cháy hàng và sai số âm là tồn thừa; kết quả là (+20; −10; +30; −30; +50). Bước 3 tính thiên lệch và độ lệch chuẩn mẫu:

$ ē = (1/n) · Σ~i~ e~i~ ;  σ̂ = √[Σ~i~ (e~i~ − ē)^2^ / (n − 1)]

cho ē = 60/5 = 12, tổng bình phương 4.080, phương sai 1.020 và σ̂ ≈ 31,94 sản phẩm. Bước 4 dựng phân vị có hiệu chỉnh thiên lệch:

$ P~q~ = ŷ + ē + Z~q~ · σ̂

Với q = 0,9 và Z~0,9~ = 1,28, P90 = 140 + 12 + 1,28 × 31,94 ≈ 193 sản phẩm (Trần Duy Thanh, 2026a, Ch4 tr.17). Mã Python của slide dùng Z~0,9~ = norm.ppf(0,9) ≈ 1,2816 để tính lượng tồn kho phòng thủ (Trần Duy Thanh, 2026a, Ch4 tr.18–20). Ý nghĩa của bước hiệu chỉnh là quan trọng: mô hình SMA trên chuỗi đang tăng có xu hướng dự báo thiếu một cách hệ thống, và nếu không cộng bù thiên lệch thì mọi phân vị đều bị dịch xuống.

Slide phân tích ba sai lầm khi dùng Z-score và phân phối chuẩn cho bán lẻ (Trần Duy Thanh, 2026a, Ch4 tr.22). Thứ nhất là giả định đối xứng, trong khi dữ liệu bán lẻ thường lệch phải: có thể bán vượt 500 cái nhờ một video viral, nhưng không thể bán âm 500 cái. Thứ hai là xuyên thủng ranh giới 0: với mặt hàng bán chậm có dự báo nhỏ và độ lệch chuẩn tương đối lớn, phân vị thấp của phân phối chuẩn có thể âm. Thứ ba là giả định độ bất định không đổi giữa các sản phẩm và các thời điểm. Tiểu luận bổ sung một hạn chế thứ tư: σ̂ ước lượng từ sai số một bước không phản ánh độ bất định nhiều bước; với chân trời h, phương sai sai số tích lũy thường tăng theo h, như cấu trúc "phễu bất định" mà slide mô tả ở Mục 2.5.7.

### 2.5.3. Hồi quy phân vị và hàm tổn thất pinball

Các hàm tổn thất đối xứng như MAE và RMSE phạt sai số dương và âm như nhau, khiến mô hình hội tụ về trung bình (với RMSE) hoặc trung vị (với MAE) (Trần Duy Thanh, 2026a, Ch4 tr.35). Để mô hình hội tụ về một phân vị q bất kỳ, Koenker và Bassett (1978) đề xuất hồi quy phân vị với hàm tổn thất tuyến tính từng phần, thường gọi là quantile loss hay pinball loss (Trần Duy Thanh, 2026a, Ch4 tr.36):

$ L~q~(y, ŷ) = max[q · (y − ŷ), (q − 1) · (y − ŷ)]

Khi thực tế vượt dự báo (y ≥ ŷ), mức phạt là q(y − ŷ); khi dự báo vượt thực tế, mức phạt là (1 − q)(ŷ − y). Ví dụ của slide với q = 0,9 và ŷ = 150: nếu y = 170 thì L = 0,9 × 20 = 18; nếu y = 130 thì L = 0,1 × 20 = 2 (Trần Duy Thanh, 2026a, Ch4 tr.37). Sự bất đối xứng của gradient đẩy mô hình dịch lên phía trên cho tới khi xác suất bao phủ nhu cầu đạt đúng 90% (Trần Duy Thanh, 2026a, Ch4 tr.38). Về mặt toán học, điều này được chứng minh bằng cách lấy đạo hàm của tổn thất kỳ vọng theo ŷ:

$ ∂E[L~q~(D, ŷ)]/∂ŷ = −q · P(D > ŷ) + (1 − q) · P(D ≤ ŷ) = F~D~(ŷ) − q

Đặt đạo hàm bằng 0 cho F~D~(ŷ^*^) = q, tức ŷ^*^ chính là phân vị mức q của phân phối nhu cầu. Kết quả này là cầu nối trực tiếp giữa hàm tổn thất trong học máy và mô hình Newsvendor ở Mục 2.5.6: nếu q được chọn bằng tỷ lệ tới hạn của bài toán kinh tế, thì việc tối thiểu hóa pinball loss tương đương với tối đa hóa lợi nhuận kỳ vọng.

Trong thực tế, doanh nghiệp ít khi huấn luyện ba mô hình riêng cho P10, P50, P90 vì lãng phí tài nguyên và mất tương quan giữa các phân vị; các hệ thống hiện đại dùng học đa nhiệm, với một "bộ não" chung và một lớp đầu ra gồm nhiều nút, mỗi nút tối ưu một phân vị (Trần Duy Thanh, 2026a, Ch4 tr.43). Tổn thất đa phân vị là tổng các pinball loss:

$ L~MQ~ = Σ~q∈Q~ Σ~t~ L~q~(y~t~, ŷ~q,t~)

Slide minh họa bằng mô hình LSTM với hàm MQLoss của thư viện neuralforecast (Trần Duy Thanh, 2026a, Ch4 tr.44–45); kiến trúc này thuộc dòng các mô hình dự báo phân vị nhiều chân trời như MQ-RNN của Wen và cộng sự (2017), xây trên mạng LSTM (Hochreiter & Schmidhuber, 1997). Một vấn đề kỹ thuật cần lưu ý là hiện tượng giao cắt phân vị (quantile crossing): khi các phân vị được ước lượng độc lập, có thể xảy ra P~0,6~ < P~0,5~ ở một số quan sát, vi phạm tính đơn điệu của hàm phân phối. Cách khắc phục đơn giản là sắp xếp lại các phân vị ước lượng tại mỗi điểm, một phép hậu xử lý không làm tăng tổn thất pinball trung bình.

### 2.5.4. DeepAR: dự báo phân phối bằng mạng nơ-ron tự hồi quy

DeepAR do Amazon phát triển (Salinas và cộng sự, 2020) thay đổi mục tiêu đầu ra của mạng nơ-ron: thay vì xuất ra một con số dự báo, mạng xuất ra các tham số của một hàm phân phối xác suất (Trần Duy Thanh, 2026a, Ch4 tr.23). Với một chuỗi i, trạng thái ẩn h~i,t~ của mạng LSTM được cập nhật từ trạng thái trước, giá trị trước và các biến đồng hành x~i,t~:

$ h~i,t~ = LSTM(h~i,t−1~, z~i,t−1~, x~i,t~) ;  θ~i,t~ = g(h~i,t~) ;  z~i,t~ ∼ ℓ(· | θ~i,t~)

Mô hình được huấn luyện bằng cách cực đại hóa log-likelihood trên toàn bộ các chuỗi, tức là một mô hình toàn cục (Trần Duy Thanh, 2026a, Ch4 tr.25). Slide mô tả trường hợp dùng phân phối nhị thức âm (negative binomial), phù hợp với dữ liệu đếm nguyên dương: tại mỗi bước, mạng xuất ra giá trị kỳ vọng μ~t~ và độ phân tán α~t~ (Trần Duy Thanh, 2026a, Ch4 tr.24), với phương sai Var(z) = μ + αμ^2^ tăng nhanh hơn trung bình, khớp với hiện tượng phương sai tăng theo quy mô. Một lựa chọn khác cho dữ liệu liên tục có đuôi dày là phân phối Student-t với tham số vị trí, tỷ lệ và bậc tự do. Để xử lý chênh lệch quy mô giữa các chuỗi, Salinas và cộng sự (2020) chia đầu vào cho một hệ số tỷ lệ riêng của từng chuỗi và nhân ngược đầu ra, cùng tinh thần với phép chuẩn hóa ở Mục 2.4.4. Khi dự báo, các quỹ đạo mẫu được sinh tuần tự bằng cách lấy mẫu từ phân phối dự báo ở mỗi bước và đưa mẫu đó làm đầu vào cho bước sau; các phân vị được tính từ tập quỹ đạo. Cách lấy mẫu này cho phép DeepAR biểu diễn được phân phối của tổng nhu cầu nhiều ngày, điều mà các phân vị biên từng ngày không cho phép trực tiếp.

Slide liệt kê thêm các công nghệ mới để học viên thảo luận gồm Temporal Fusion Transformer, N-HiTS, Chronos, TimeGPT và TimesFM (Trần Duy Thanh, 2026a, Ch4 tr.26), và minh họa DeepAR trên tệp ecommerce_sales_multi_sku gồm 3.600 bản ghi của 15 SKU thuộc 7 ngành hàng trong 240 ngày từ 01/01 đến 28/08/2026 (Trần Duy Thanh, 2026a, Ch4 tr.27–29). Tiểu luận không đánh giá các mô hình nền tảng vì phạm vi chỉ giới hạn ở các phương pháp có thể tái lập đầy đủ trên dữ liệu học phần.

### 2.5.5. Đánh giá dự báo xác suất

Đánh giá dự báo xác suất đòi hỏi các thước đo khác với dự báo điểm. Nguyên tắc chỉ đạo là tối đa hóa độ sắc nét (sharpness) với điều kiện hiệu chỉnh (calibration) đúng: khoảng dự báo càng hẹp càng tốt, nhưng chỉ khi tần suất bao phủ thực tế khớp với mức danh nghĩa (Gneiting & Raftery, 2007). Gneiting và Raftery (2007) định nghĩa quy tắc chấm điểm đúng đắn (proper scoring rule) là quy tắc mà điểm kỳ vọng được tối ưu khi dự báo trùng với phân phối thật; một người dự báo trung thực không thể cải thiện điểm bằng cách bóp méo dự báo. Pinball loss là quy tắc đúng đắn cho từng phân vị, và trung bình pinball trên một lưới phân vị dày xấp xỉ điểm CRPS (Continuous Ranked Probability Score) của toàn bộ phân phối:

$ CRPS(F, y) = ∫ (F(z) − 1{y ≤ z})^2^ dz = 2 · ∫~0..1~ L~q~(y, F^−1^(q)) dq

Tiểu luận sử dụng các thước đo sau. Độ phủ của khoảng (1 − α) là tỷ lệ quan sát rơi vào [P~α/2~; P~1−α/2~]; với khoảng 80% từ P10 đến P90, giá trị lý tưởng là 80%. Hiệu chỉnh từng phân vị được kiểm tra bằng tỷ lệ quan sát có y ≤ P~q~, lý tưởng bằng q với mọi q. Độ rộng tương đối là (P90 − P10) chia cho mức nhu cầu trung bình. Điểm Winkler (Winkler, 1972) kết hợp độ rộng và mức phạt khi trượt khoảng:

$ W~α~ = (U − L) + (2/α) · (L − y) · 1{y < L} + (2/α) · (y − U) · 1{y > U}

trong đó [L; U] là khoảng (1 − α). Điểm Winkler nhỏ hơn là tốt hơn, và một mô hình chỉ đạt độ phủ cao nhờ khoảng rất rộng sẽ bị phạt ở số hạng (U − L).

Với dự báo điểm, tiểu luận dùng các thước đo chuẩn mà slide liệt kê, gồm MAE, RMSE, MAPE, SMAPE và WAPE (Trần Duy Thanh, 2026a, Ch1 tr.27), cùng với sai số chuẩn hóa MASE (Hyndman & Koehler, 2006):

$ WAPE = Σ~i,t~ |y~i,t~ − ŷ~i,t~| / Σ~i,t~ |y~i,t~|

$ MASE = mean(|y~t~ − ŷ~t~|) / [(1/(n − m)) · Σ~t=m+1..n~ |y~t~ − y~t−m~|]

WAPE được ưa dùng trong bán lẻ vì không bùng nổ khi nhu cầu gần 0 như MAPE và gán trọng số theo quy mô. MASE chia sai số cho sai số trong mẫu của dự báo naive mùa vụ với chu kỳ m, nên MASE < 1 nghĩa là mô hình tốt hơn naive mùa vụ; Hyndman và Koehler (2006) khuyến nghị MASE vì nó không phụ thuộc thang đo và xác định được ngay cả khi có giá trị 0.

Để kiểm định sự khác biệt về độ chính xác giữa hai mô hình, tiểu luận dùng kiểm định Diebold–Mariano (Diebold & Mariano, 1995). Với chuỗi chênh lệch tổn thất d~t~ = L(e~1,t~) − L(e~2,t~), thống kê kiểm định là:

$ DM = d̄ / √(V̂(d̄)) ∼ N(0, 1) dưới H~0~: E[d~t~] = 0

trong đó V̂(d̄) là ước lượng phương sai dài hạn của trung bình, có tính đến tự tương quan của d~t~. Kiểm định áp dụng được cho mọi hàm tổn thất, kể cả pinball loss, nên cho phép so sánh cả dự báo điểm và dự báo xác suất. Cuối cùng, conformal quantile regression (Romano và cộng sự, 2019) cung cấp một cách hiệu chỉnh hậu kỳ: dùng phần dư trên một tập hiệu chỉnh để nới rộng hoặc thu hẹp các phân vị, đảm bảo độ phủ biên hữu hạn mẫu dưới giả định hoán đổi được. Trong bối cảnh chuỗi thời gian, giả định hoán đổi chỉ đúng xấp xỉ, nhưng ý tưởng dùng phân phối thực nghiệm của phần dư walk-forward để dựng phân vị là một chuẩn so sánh mạnh và đơn giản. Bảng {T:@c2m_thuocdo_dubao} tổng hợp các thước đo.

[[T:@c2m_thuocdo_dubao Các thước đo đánh giá dự báo điểm và dự báo xác suất sử dụng trong tiểu luận
Thước đo | Loại | Công thức tóm tắt | Diễn giải
WAPE | Điểm | Σ abs(e) / Σ y | Sai số tuyệt đối theo tỷ lệ tổng cầu; thấp hơn là tốt hơn
MASE | Điểm | MAE / MAE naive mùa vụ trong mẫu | Nhỏ hơn 1 là tốt hơn naive mùa vụ
Bias | Điểm | Σ (ŷ − y) / Σ y | Dương: dự báo thừa; âm: dự báo thiếu
Pinball (q) | Phân vị | max[q·e, (q − 1)·e] | Quy tắc đúng đắn cho phân vị q
Pinball trung bình | Phân phối | Trung bình trên lưới q | Xấp xỉ CRPS
Độ phủ 80% | Khoảng | Tỷ lệ y ∈ [P10; P90] | Lý tưởng 80%
Hiệu chỉnh | Phân vị | Tỷ lệ y ≤ P~q~ | Lý tưởng bằng q
Độ rộng tương đối | Khoảng | (P90 − P10) / mức cầu | Độ sắc nét; càng hẹp càng tốt nếu phủ đúng
Winkler | Khoảng | Độ rộng + phạt trượt khoảng | Kết hợp sắc nét và hiệu chỉnh
Diebold–Mariano | Kiểm định | d̄ / SE(d̄) | So sánh hai mô hình trên cùng tổn thất
Nguồn: Tổng hợp từ Hyndman và Koehler (2006), Gneiting và Raftery (2007), Winkler (1972), Diebold và Mariano (1995).
]]

### 2.5.6. Mô hình Newsvendor và phân vị tối ưu

Slide đặt câu hỏi then chốt: ai quyết định con số 90%, tại sao không phải P95 để phục vụ khách tốt hơn hay P80 để tiết kiệm vốn (Trần Duy Thanh, 2026a, Ch4 tr.56). Câu trả lời đến từ mô hình người bán báo (Newsvendor), một bài toán kinh điển của quản trị tồn kho một kỳ có gốc rễ từ Arrow, Harris và Marschak (1951) và được tổng quan bởi Khouja (1999). Slide phân rã cấu trúc chi phí biên thành hai thành phần (Trần Duy Thanh, 2026a, Ch4 tr.57). Chi phí thiếu hụt biên C~u~ là tổn thất khi nhu cầu vượt lượng dự trữ đúng một đơn vị, gồm lợi nhuận biên bị mất, bồi thường hợp đồng nếu có và tổn hại uy tín; công thức cơ bản là C~u~ = p − c. Chi phí dư thừa biên C~o~ là tổn thất khi dự trữ vượt nhu cầu đúng một đơn vị, gồm chi phí lưu bãi, chi phí vốn bị đọng và mức giảm giá trị do lỗi thời; công thức cơ bản là C~o~ = c − s. Với giá bán p, chi phí c, giá thanh lý s, lượng đặt Q và nhu cầu ngẫu nhiên D, lợi nhuận là:

$ π(Q, D) = p · min(Q, D) − c · Q + s · (Q − D)^+^

Lợi nhuận kỳ vọng E[π(Q, D)] là hàm lõm theo Q. Đạo hàm theo Q bằng p · P(D > Q) − c + s · P(D ≤ Q); đặt bằng 0 cho định lý tỷ lệ tới hạn (Trần Duy Thanh, 2026a, Ch4 tr.58):

$ q^*^ = P(D ≤ Q^*^) = C~u~ / (C~u~ + C~o~) = (p − c) / (p − s)

$ Q^*^ = F~D~^−1^(q^*^)

Kết quả này có hai hàm ý. Thứ nhất, mức phục vụ tối ưu không phải là một hằng số quản trị mà là một biến kinh tế phụ thuộc vào cấu trúc giá – chi phí của từng sản phẩm. Thứ hai, để thực thi quyết định tối ưu, doanh nghiệp cần dự báo phân vị mức q^*^ của nhu cầu, tức là cần dự báo xác suất chứ không chỉ dự báo điểm; kết hợp với kết quả ở Mục 2.5.3, mô hình học máy huấn luyện với pinball loss tại q = q^*^ chính là bộ dự báo tối ưu cho bài toán kinh tế. Slide phân tích độ nhạy của tỷ lệ tới hạn: khi C~u~ ≫ C~o~, như dược phẩm thiết yếu hay linh kiện biên lợi nhuận cao, doanh nghiệp nên chọn P95 hoặc cao hơn để bảo vệ doanh thu; khi C~o~ ≫ C~u~, như hàng dễ hỏng hay lỗi thời nhanh, doanh nghiệp nên chọn P80 hoặc thấp hơn để phòng vệ vốn (Trần Duy Thanh, 2026a, Ch4 tr.58). Quy trình tích hợp được đề xuất gồm: tài chính xác định (p, c, s) cho từng SKU để tính q^*^; q^*^ được truyền vào thuật toán học máy dưới dạng hàm tổn thất; mô hình xuất ra phân vị tương ứng làm lượng đặt (Trần Duy Thanh, 2026a, Ch4 tr.59).

Ví dụ tính tay của slide xét ba SKU với đặc tính rủi ro trái ngược (đơn vị nghìn đồng) (Trần Duy Thanh, 2026a, Ch4 tr.60–61). Điện thoại thông minh có p = 30.000, c = 25.000, s = 20.000, nên C~u~ = C~o~ = 5.000 và q^*^ = 0,50: rủi ro đối xứng, nhắm vào trung vị. Cáp sạc có p = 200, c = 40, s = 0, nên C~u~ = 160, C~o~ = 40 và q^*^ = 0,80: biên lợi nhuận lớn, chiến lược tấn công, nhập dư để không mất doanh thu. Thực phẩm chức năng cận hạn có p = 60, c = 45, s = 10, nên C~u~ = 15, C~o~ = 35 và q^*^ = 0,30: biên mỏng, rủi ro tồn kho lớn, chiến lược phòng thủ. Case study tính điểm đặt hàng lại cho 100 SKU thuộc ba nhóm thiết bị công nghệ, phụ kiện và hàng tiêu dùng nhanh dựa trên hai tệp historical_sales_100 (15.000 dòng, 150 ngày từ 01/04 đến 28/08/2026) và financial_metadata_100 (Trần Duy Thanh, 2026a, Ch4 tr.67–68), với mô hình máy học xuất ra các phân vị P10, P30, P50, P70, P90 (Trần Duy Thanh, 2026a, Ch4 tr.69–70) và một script chiến lược phân loại SKU theo q^*^ (Trần Duy Thanh, 2026a, Ch4 tr.71).

Tiểu luận lưu ý một khoảng cách giữa lý thuyết và triển khai. Khi mô hình chỉ cung cấp một lưới phân vị rời rạc (như P10, P30, P50, P70, P90), việc chọn "phân vị gần q^*^ nhất" chỉ là xấp xỉ; nội suy tuyến tính giữa hai phân vị kề nhau cho xấp xỉ tốt hơn F~D~^−1^(q^*^). Ngoài ra, mô hình Newsvendor một kỳ giả định hàng thừa được thanh lý ở giá s ngay cuối kỳ; trong bán lẻ trực tuyến, hàng thừa thường được bán ở kỳ sau, nên C~o~ thực tế gần với chi phí lưu kho và chi phí vốn hơn là c − s. Vì vậy, áp dụng q^*^ theo công thức một kỳ cho đặt hàng theo ngày là một xấp xỉ bảo thủ, thiên về phía đặt ít.

### 2.5.7. Điểm đặt hàng lại, tồn kho an toàn và phễu bất định

Khi hàng hóa cần L ngày để về kho, quyết định không còn là lượng đặt cho một ngày mà là mức tồn kho cần có để phục vụ nhu cầu trong suốt lead time. Điểm đặt hàng lại (Reorder Point – ROP) cổ điển dưới giả định nhu cầu ngày độc lập, cùng phân phối chuẩn với trung bình μ và độ lệch chuẩn σ là (Silver và cộng sự, 2017):

$ ROP = μ · L + Z~CSL~ · σ · √L ;  SS = Z~CSL~ · σ · √L

trong đó CSL (Cycle Service Level) là xác suất không hết hàng trong một chu kỳ bổ sung và SS là tồn kho an toàn. Công thức dựa trên hai giả định có thể vi phạm: phân phối chuẩn và độc lập giữa các ngày. Nếu sai số dự báo các ngày có tương quan dương, phương sai tổng tăng nhanh hơn L và công thức √L đánh giá thấp tồn kho an toàn; nếu tương quan âm thì ngược lại. Phương án thay thế phi tham số là lấy phân vị thực nghiệm của tổng sai số L ngày từ lịch sử dự báo walk-forward. Phương án thứ ba là cộng trực tiếp các phân vị biên từng ngày, nhưng cần lưu ý rằng tổng các phân vị không phải là phân vị của tổng: với các biến dương có tương quan không hoàn hảo, cộng các P90 từng ngày cho một giá trị lớn hơn P90 của tổng, dẫn tới tồn kho an toàn quá mức.

Slide mô tả hiện tượng này dưới hình ảnh "phễu bất định" (cone of uncertainty): khi ngoại suy theo thời gian, khoảng dự báo không giữ biên độ song song mà nở rộng do tích lũy phương sai sai số dọc theo chân trời (Trần Duy Thanh, 2026a, Ch4 tr.53). Hàm ý vận hành là lead time ngắn đặt điểm ra quyết định ở "cuống phễu" nơi bất định nhỏ, còn lead time dài như nhập khẩu quốc tế đặt điểm ra quyết định ở "miệng phễu", khuếch đại khoảng cách giữa kịch bản nhu cầu tối đa và tối thiểu; do đó can thiệp rút ngắn lead time có giá trị kinh tế trực tiếp (Trần Duy Thanh, 2026a, Ch4 tr.53). Cùng một cơ chế cũng chi phối nhu cầu vốn ở Mục 2.1.5: lead time dài vừa làm phễu bất định rộng hơn, vừa kéo dài khoảng thời gian vốn bị khóa.

### 2.5.8. Từ bất định nhu cầu đến bất định dòng tiền

Các mục trên xem dự báo xác suất như đầu vào cho quyết định tồn kho. Tiểu luận mở rộng thêm một bước: phân phối nhu cầu cũng quyết định phân phối của nhu cầu vốn. Nếu lượng đặt cho mỗi kỳ được chọn theo phân vị Q~t~ = F̂~D,t~^−1^(q^*^), thì vốn chi ra để nhập hàng tại thời điểm t − L là c · Q~t~, còn tiền thu về tại t + d là (1 − φ) · p · min(Q~t~, D~t~) cộng với giá trị thanh lý của phần thừa. Do đó, cùng một mô hình dự báo xác suất vừa quyết định lợi nhuận kỳ vọng, vừa quyết định quỹ đạo tiền mặt. Một phân vị cao hơn làm tăng doanh thu kỳ vọng nhưng đồng thời tăng vốn bị khóa trong hàng tồn; nếu doanh nghiệp bị ràng buộc thanh khoản, lựa chọn phân vị không còn thuần túy là bài toán Newsvendor mà trở thành bài toán Newsvendor có ràng buộc ngân sách, đúng như mở rộng Lagrange ở Mục 2.6.3.

Mối quan hệ này cũng cho thấy giới hạn của việc đánh giá mô hình dự báo chỉ bằng thước đo sai số. Hai mô hình có cùng pinball loss trung bình có thể dẫn tới hai mức vốn bị khóa khác nhau nếu một mô hình có khoảng dự báo rộng đều còn mô hình kia hẹp ở ngày thường và rộng ở ngày sự kiện. Vì vậy, bên cạnh các thước đo ở Mục 2.5.5, tiểu luận đánh giá các chính sách đặt hàng bằng một bộ chỉ tiêu kinh tế gồm lợi nhuận mô phỏng, tỷ lệ đáp ứng nhu cầu (fill-rate), vốn hàng đặt, tổn thất thanh lý và lãi gộp bị mất do thiếu hàng:

$ FillRate = Σ~t~ min(Q~t~, D~t~) / Σ~t~ D~t~

$ Lost~t~ = (p − c) · (D~t~ − Q~t~)^+^ ;  Salv~t~ = (c − s) · (Q~t~ − D~t~)^+^

Theo định nghĩa, lợi nhuận của chính sách bằng lợi nhuận của chính sách "biết trước cầu" (Oracle) trừ đi tổng hai loại tổn thất Lost và Salv, vì Oracle đặt đúng Q~t~ = D~t~ và không chịu tổn thất nào. Đẳng thức này cho phép phân rã khoảng cách giữa một chính sách và Oracle thành phần do thiếu hàng và phần do thừa hàng, qua đó chỉ ra chính sách đó đang sai về phía nào. Tỷ lệ lợi nhuận đạt được so với Oracle là một thước đo giá trị kinh tế của thông tin dự báo, có thể so sánh giữa các ngành hàng có quy mô khác nhau.

### 2.5.9. Bootstrap và đánh giá rủi ro tài chính của quyết định marketing

Các mục trên xem bất định là bất định của nhu cầu tương lai khi mô hình đã biết. Với quyết định marketing còn một nguồn bất định thứ hai, thường lớn hơn: bất định của chính các tham số phản hồi được ước lượng từ dữ liệu ngắn. Một hệ số β ước lượng từ 30 ngày quan sát có sai số chuẩn đáng kể, và quyết định "tăng ngân sách quảng cáo" có lãi hay lỗ phụ thuộc vào việc β thật nằm ở đâu trong khoảng tin cậy. Efron và Tibshirani (1993) trình bày bootstrap như một phương pháp tổng quát để xấp xỉ phân phối mẫu của một thống kê bằng cách lấy mẫu lại có hoàn lại từ chính dữ liệu. Với bootstrap theo cặp (case resampling), mỗi lần lặp b lấy ngẫu nhiên có hoàn lại n quan sát (x~i~, y~i~), ước lượng lại tham số β̂^(b)^ và tính đại lượng quan tâm:

$ Π^(b)^(ΔAd) = β̂^(b)^ · ΔAd · g − ΔAd, b = 1, …, B

trong đó ΔAd là mức tăng ngân sách và g là biên gộp mỗi đơn. Từ B giá trị Π^(b)^, các phân vị cho khoảng tin cậy và tỷ lệ Π^(b)^ < 0 xấp xỉ xác suất quyết định tăng ngân sách bị lỗ:

$ P̂(lỗ) = (1/B) · Σ~b~ 1{Π^(b)^ < 0}

Bootstrap theo cặp không giả định phân phối chuẩn của sai số và giữ nguyên cấu trúc phương sai thay đổi nếu có, nhưng giả định các quan sát độc lập; với dữ liệu ngày có tự tương quan, nó có xu hướng đánh giá thấp bất định. Đại lượng P̂(lỗ) có giá trị quản trị trực tiếp: nó chuyển một kết luận thống kê ("hệ số không có ý nghĩa") thành một ngôn ngữ rủi ro mà nhà quản trị marketing hiểu được ("chi thêm 1 triệu đồng quảng cáo cho ngành này có xác suất lỗ bao nhiêu phần trăm").

Với các sự kiện hiếm như ngày Mega Sale, cả bootstrap lẫn khoảng dự báo dựa trên phần dư đều gặp giới hạn: phần dư được ước lượng chủ yếu từ ngày thường, nên độ rộng khoảng phản ánh biến động ngày thường. Một kiểm tra đơn giản nhưng trung thực là bỏ-một-sự-kiện (leave-one-event-out): ước lượng mô hình khi loại một ngày sự kiện, dự báo ngày đó, và kiểm tra khoảng dự báo có phủ giá trị thực hay không. Với số sự kiện rất nhỏ, kiểm tra này không đủ để ước lượng độ phủ, nhưng đủ để phát hiện khoảng dự báo hẹp một cách phi thực tế.

## 2.6. Tác tử trí tuệ nhân tạo hỗ trợ quyết định

### 2.6.1. Từ mô hình ngôn ngữ đến tác tử: định nghĩa và kiến trúc

Các mô hình ngôn ngữ lớn (Large Language Models – LLM) mang lại năng lực tổng hợp và phân tích ngôn ngữ tự nhiên vượt trội, nhưng trong quản trị vận hành, năng lực xử lý thông tin đơn thuần là chưa đủ; kỷ nguyên AI tác tử (Agentic AI) đánh dấu bước chuyển từ trả lời sang hành động (Trần Duy Thanh, 2026a, Ch5 tr.4). Slide định nghĩa tác tử thông minh là một hệ thống điện toán có mức độ tự trị cao, về mặt toán học là một ánh xạ từ chuỗi trạng thái nhận thức tới tập hành động, f: 𝒫^*^ → 𝒜, với cấu trúc vi mô gồm bốn phân hệ: mô-đun nhận thức dựa trên mô hình nền tảng, đảm nhiệm phân tích ngữ nghĩa, lập kế hoạch và lập luận; hệ thống quản trị trạng thái gồm bộ nhớ ngắn hạn (cửa sổ ngữ cảnh) và bộ nhớ dài hạn (cơ sở dữ liệu vector); tích hợp công cụ qua gọi hàm để truy xuất API, truy vấn SQL hay tương tác với ERP và CRM; và không gian hành động (Trần Duy Thanh, 2026a, Ch5 tr.5).

Chu trình vận hành của tác tử được hệ thống hóa qua khung ReAct (Reasoning and Acting) hoặc mô hình OODA (Observe – Orient – Decide – Act), nhằm giảm thiểu hiện tượng ảo giác và tối ưu tính chính xác (Trần Duy Thanh, 2026a, Ch5 tr.6). ReAct, do Yao và cộng sự (2023) đề xuất, xen kẽ các bước suy luận bằng ngôn ngữ (thought) với các hành động gọi công cụ (action) và quan sát kết quả trả về (observation); việc suy luận được "neo" vào thông tin quan sát từ công cụ giúp giảm việc mô hình tự bịa thông tin so với chỉ suy luận thuần túy. Slide lập luận rằng trong chuỗi cung ứng quy mô lớn, các hệ thống dựa trên luật tĩnh hay dashboard BI có nhược điểm cấu trúc là độ trễ quyết định, vì đòi hỏi con người can thiệp ở khâu lập luận và chuyển giao quy trình (Trần Duy Thanh, 2026a, Ch5 tr.7). Ví dụ minh họa dùng LangChain với Google Gemini để mô phỏng một tác tử đọc hai tệp financial_metadata_100 và historical_sales_100, tự tính C~u~, C~o~, đề xuất lượng nhập và gọi hàm phát hành đơn đặt hàng (Trần Duy Thanh, 2026a, Ch5 tr.8).

Kết quả chạy của tác tử trên slide cho mã TECH_PHONE_001 minh họa rõ cả tiềm năng lẫn rủi ro. Tác tử tính C~u~ = 34.655 − 30.795 = 3.860 và C~o~ = 30.795 − 19.606 = 11.189, nhận định rủi ro dư thừa lớn hơn rủi ro thiếu hụt, và quyết định lượng đặt bằng 80% nhu cầu trung bình 7 ngày gần nhất (67,18 đơn vị), tức 54 đơn vị (Trần Duy Thanh, 2026a, Ch5 tr.15–16). Lập luận kinh tế của tác tử là đúng hướng, nhưng quy tắc "80% trung bình" là một heuristic do mô hình ngôn ngữ tự đặt ra chứ không phải nghiệm của bài toán tối ưu. Theo lý thuyết Newsvendor ở Mục 2.5.6, lượng đặt tối ưu là phân vị mức q^*^ = 3.860/(3.860 + 11.189) ≈ 0,26 của phân phối nhu cầu, và khoảng cách giữa phân vị này với 80% trung bình phụ thuộc vào độ phân tán của nhu cầu, thứ mà quy tắc heuristic bỏ qua. Đây là khoảng trống mà tiểu luận khai thác: thay vì để LLM tự sáng tác quy tắc định lượng, tác tử nên dùng LLM cho phần nhận thức và điều phối, còn phần tính toán định lượng được giao cho công cụ tối ưu có cơ sở lý thuyết.

### 2.6.2. Truy xuất tăng cường sinh tạo (RAG)

Mô hình sinh văn bản truyền thống dự đoán đầu ra y từ truy vấn x qua P(y | x). Kiến trúc RAG (Retrieval-Augmented Generation) bổ sung một biến ngữ cảnh z được truy xuất từ cơ sở tri thức nội bộ 𝒟, đưa bài toán về P(y | x, z) (Trần Duy Thanh, 2026a, Ch5 tr.17). Lewis và cộng sự (2020) hình thức hóa mô hình này bằng cách lấy biên theo các tài liệu truy xuất được:

$ P(y | x) ≈ Σ~z∈top-k(𝒟; x)~ P~η~(z | x) · P~θ~(y | x, z)

trong đó P~η~ là bộ truy xuất và P~θ~ là bộ sinh. Slide mô tả ba phân hệ: mã hóa không gian ngữ nghĩa, chuyển cơ sở tri thức thành vector trong ℝ^d^; truy xuất không gian gần bằng độ đo cosine; và sinh tạo có điều kiện trên ngữ cảnh truy xuất (Trần Duy Thanh, 2026a, Ch5 tr.18). Mục tiêu thực tiễn không phải "hỏi đáp tài liệu" mà là xây dựng nhận thức quy trình (process awareness): ví dụ một email phi cấu trúc báo tàu hàng chở mã TECH_001 gặp bão tại cảng Cát Lái, dự kiến trễ 5 ngày, được vector hóa ngay và được truy xuất khi tác tử kiểm soát tồn kho chạy chu trình đánh giá định kỳ (Trần Duy Thanh, 2026a, Ch5 tr.19–20).

Để minh họa cơ chế truy xuất mà không phụ thuộc vào mô hình nhúng nơ-ron, slide dùng TF-IDF kết hợp độ tương đồng cosine làm đại diện toán học (Trần Duy Thanh, 2026a, Ch5 tr.21). Trọng số TF-IDF của từ w trong tài liệu d, theo truyền thống của Salton và Buckley (1988), là:

$ tfidf(w, d) = tf(w, d) · {log[(1 + N) / (1 + df(w))] + 1}

(dạng làm trơn như trong scikit-learn; Pedregosa và cộng sự, 2011), và độ tương đồng giữa truy vấn q và tài liệu d là:

$ cos(q, d) = (v~q~ · v~d~) / (‖v~q~‖ · ‖v~d~‖)

Trên kho bốn tài liệu gồm quy chế kho (hệ số dự trữ an toàn 15% cho linh kiện điện tử), báo cáo tài chính (chi phí lưu kho quý 3/2026 tăng 5%), email khẩn về tàu hàng và chính sách giá (giảm giá 10% khi tồn kho vượt 200% định mức), kết quả truy xuất cho tài liệu email có điểm cao nhất 0,3979 (Trần Duy Thanh, 2026a, Ch5 tr.26, tr.28). Slide tiếp tục nâng cấp ví dụ với hai ngữ cảnh: không đủ cơ sở dữ liệu để quyết định, và đủ cơ sở rồi để tác tử Gemini ra quyết định (Trần Duy Thanh, 2026a, Ch5 tr.27–30). Hai ngữ cảnh này đặt ra một yêu cầu thiết kế mà tiểu luận hình thức hóa: tác tử cần biết khi nào nên từ chối trả lời. Một cơ chế đơn giản là ngưỡng từ chối τ trên điểm truy xuất cao nhất: nếu max~d~ cos(q, d) < τ, tác tử báo "không đủ căn cứ" thay vì suy luận. Chất lượng truy xuất được đánh giá bằng độ chính xác tại hạng 1 (P@1) và hạng nghịch đảo trung bình (MRR):

$ P@1 = (1/|Q|) · Σ~q~ 1{rank~q~ = 1} ;  MRR = (1/|Q|) · Σ~q~ 1/rank~q~

trong đó rank~q~ là thứ hạng của tài liệu đúng cho truy vấn q. Tiểu luận lưu ý một đặc thù ngôn ngữ: tiếng Việt viết tách âm tiết nên một từ ghép như "tồn kho" bị TF-IDF cấp từ tách thành hai đơn vị; biểu diễn n-gram ký tự có thể bắt được cấu trúc này tốt hơn trong các kho nhỏ.

### 2.6.3. Kiến trúc đa tác tử và tối ưu đa mục tiêu

Trong doanh nghiệp, một quyết định tối ưu hiếm khi xuất phát từ một lăng kính đơn lẻ: phòng kinh doanh muốn tồn kho tối đa để không mất khách, phòng tài chính muốn tồn kho tối thiểu để giảm chi phí; một tác tử duy nhất dễ thiên lệch theo dữ liệu huấn luyện hoặc theo cấu trúc prompt (Trần Duy Thanh, 2026a, Ch5 tr.31). Kiến trúc đa tác tử phân cấp gồm các tác tử chuyên gia mỗi tác tử phục vụ một hàm mục tiêu và một tác tử điều phối (Trần Duy Thanh, 2026a, Ch5 tr.32). Trên cùng không gian quyết định x (lượng hàng nhập), tác tử kinh doanh cực đại hóa doanh thu và mức phục vụ max R(x), tác tử tài chính cực tiểu hóa chi phí lưu kho và vốn min C(x) (Trần Duy Thanh, 2026a, Ch5 tr.33). Tác tử điều phối giải bài toán đa mục tiêu bằng mô hình tổng trọng số theo nguyên lý Pareto (Trần Duy Thanh, 2026a, Ch5 tr.34):

$ max~x~ ℱ(x) = w~1~ · R(x) − w~2~ · C(x)

với w~1~, w~2~ là các trọng số chiến lược động; slide gợi ý rằng khi công ty cạn kiệt tiền mặt, tác tử điều phối sẽ tự động tăng w~2~, khiến điểm tối ưu dịch về phía tác tử tài chính (Trần Duy Thanh, 2026a, Ch5 tr.34). Kết quả mô phỏng với w~1~ = 0,3 và w~2~ = 0,7 cho thấy tác tử điều phối chọn nhập 800 sản phẩm ở đợt 1 kèm điều kiện kích hoạt đợt 2, nghiêng hẳn về phía tài chính thay vì chia đôi một cách cảm tính (Trần Duy Thanh, 2026a, Ch5 tr.41–44). Slide còn chỉ ra lợi ích của việc buộc LLM đóng vai các bên độc lập để tránh "ảo giác đồng thuận" (echo chamber) (Trần Duy Thanh, 2026a, Ch5 tr.45).

Tiểu luận đề xuất một cách định lượng hóa hàm mục tiêu trên để tác tử điều phối không phải dựa hoàn toàn vào suy luận ngôn ngữ. Đặt doanh thu kỳ vọng và chi phí kỳ vọng theo cấu trúc Newsvendor:

$ R(x) = p · E[min(x, D)] ;  C(x) = c · x − s · E[(x − D)^+^]

Đạo hàm ℱ(x) theo x cho w~1~ · p · P(D > x) − w~2~ · c + w~2~ · s · P(D ≤ x). Đặt bằng 0 và giải cho F(x^*^) = P(D ≤ x^*^):

$ F(x^*^) = (w~1~ · p − w~2~ · c) / (w~1~ · p − w~2~ · s), với điều kiện w~1~ · p > w~2~ · c

Khi w~1~ = w~2~, công thức trở về tỷ lệ tới hạn Newsvendor (p − c)/(p − s). Khi w~2~ tăng, tử số giảm nhanh hơn mẫu số (vì c > s), nên phân vị mục tiêu giảm và tác tử đặt ít hàng hơn, đúng như trực giác của slide. Khi w~2~ · c ≥ w~1~ · p, mỗi đơn vị nhập thêm có giá trị biên âm ngay cả khi chắc chắn bán được, và nghiệm tối ưu là không nhập. Kết quả này biến trọng số "chiến lược" mơ hồ thành một phân vị mục tiêu cụ thể cho từng SKU, có thể đưa thẳng vào bộ dự báo phân vị.

Mở rộng thứ hai là ràng buộc ngân sách. Khi tổng vốn nhập hàng cho N SKU bị giới hạn bởi B, bài toán trở thành:

$ max~x1..xN~ Σ~i~ E[π~i~(x~i~)] với ràng buộc Σ~i~ c~i~ · x~i~ ≤ B

Dùng nhân tử Lagrange λ ≥ 0 cho ràng buộc ngân sách, điều kiện tối ưu cho từng SKU trở thành:

$ F~i~(x~i~^*^) = (p~i~ − c~i~ · (1 + λ)) / (p~i~ − s~i~)

Nhân tử λ đóng vai trò "giá bóng" của vốn: khi ngân sách eo hẹp, λ tăng, chi phí hiệu dụng của mỗi đồng vốn tăng, và phân vị mục tiêu của mọi SKU giảm theo tỷ lệ khác nhau tùy cấu trúc giá – chi phí. Các SKU có biên lợi nhuận mỏng bị cắt trước. Giá trị λ được tìm bằng tìm kiếm nhị phân sao cho ràng buộc ngân sách vừa chặt.

### 2.6.4. Chuyển suy luận thành hành động: đầu ra định chuẩn và đồ thị trạng thái

Các hệ thống ERP và CRM vận hành trên logic tất định và không thể xử lý trực tiếp chuỗi ngôn ngữ tự nhiên sinh từ mô hình xác suất; đây là thách thức tích hợp mang tính cấu trúc (Trần Duy Thanh, 2026a, Ch5 tr.46). Giải pháp thứ nhất là ràng buộc cú pháp qua đầu ra định chuẩn (structured outputs): dữ liệu trao đổi phải theo định dạng chuẩn như JSON với hệ thống kiểu chặt chẽ (Trần Duy Thanh, 2026a, Ch5 tr.47). Kỹ thuật này can thiệp vào pha giải mã bằng cách áp đặt một lược đồ dữ liệu 𝒮, ràng buộc hàm sinh thành (Trần Duy Thanh, 2026a, Ch5 tr.48):

$ y ∼ P(y | x, 𝒮)

Các tham số như mã SKU hay số lượng Q bị cưỡng chế trích xuất vào các trường tương ứng của 𝒮, đảm bảo tính toàn vẹn và khả năng tương tác với API (Trần Duy Thanh, 2026a, Ch5 tr.48). Trong thực hành Python, lược đồ thường được khai báo bằng thư viện pydantic với các ràng buộc kiểu và miền giá trị, như mã SKU theo mẫu ký tự, số lượng nguyên không âm; một đầu ra vi phạm lược đồ bị chặn trước khi tới hệ thống thực thi.

Giải pháp thứ hai là mô hình hóa luồng thực thi qua đồ thị trạng thái, nhằm duy trì tính liên tục của suy luận đa bước và ngăn mô hình mất định hướng (Trần Duy Thanh, 2026a, Ch5 tr.49). Quy trình nghiệp vụ được biểu diễn thành đồ thị có hướng 𝒢 = (V, E), trong đó V là tập đỉnh gồm các nút suy luận gọi LLM và các nút hành động gọi API, E là tập cạnh xác định luồng điều khiển và hàm định tuyến, và S là không gian trạng thái toàn cục được cập nhật sau mỗi đỉnh (Trần Duy Thanh, 2026a, Ch5 tr.50). Thư viện LangGraph hiện thực hóa mô hình này. Kịch bản demo của slide: phòng kinh doanh yêu cầu nhập 500 sản phẩm, kho chỉ còn chỗ cho 300, đơn giá 1.000 USD và ngân sách tiền mặt chỉ còn 200.000 USD; kỳ vọng là hệ thống tự tính 200.000/1.000 = 200 sản phẩm, so với sức chứa 300 và tự động ép lượng đặt xuống 200 (Trần Duy Thanh, 2026a, Ch5 tr.52, tr.57–58). Về mặt logic, nghiệm khả thi là Q = min(nhu cầu; sức chứa; ngân sách/đơn giá). Điểm quan trọng là một phép tính tất định như vậy không nên phó mặc cho LLM; vai trò của LLM là diễn giải văn bản quy chế thành các tham số, còn phép min và việc kiểm tra kiểu dữ liệu do mã tất định thực hiện.

### 2.6.5. Quản trị quyết định: khả năng giải thích, con người trong vòng lặp và đạo đức

Chuyển từ hệ hỗ trợ quyết định sang tác tử tự chủ mang lại tốc độ nhưng làm nảy sinh rủi ro phi truyền thống: không chỉ sai số điện toán mà còn rủi ro về chuẩn mực đạo đức và thiên lệch thuật toán (Trần Duy Thanh, 2026a, Ch5 tr.59). Slide đề xuất ba trụ cột quản trị. Trụ cột thứ nhất là khả năng giải thích (XAI) và hồ sơ kiểm toán: khi tác tử từ chối nhà cung cấp hay hủy đơn, các bên cần biết chính xác chuỗi logic phía sau; hệ thống phải là "hộp kính" chứ không phải "hộp đen", và mọi quyết định phải được ghi vết (Trần Duy Thanh, 2026a, Ch5 tr.60). Trụ cột thứ hai là kiến trúc con người trong vòng lặp (Human-in-the-Loop – HITL) qua hàm ngắt rủi ro: sự tự chủ được phân tầng theo mức rủi ro, và khi chỉ số rủi ro vượt ngưỡng chấp nhận, hệ thống đình chỉ luồng thực thi và chuyển quyền phủ quyết cho người quản lý (Trần Duy Thanh, 2026a, Ch5 tr.61):

$ Action = Execute nếu ℛ ≤ τ ;  Action = Escalate nếu ℛ > τ

Ngưỡng rủi ro không chỉ đo bằng giá trị tài chính ℛ~finance~ mà còn bằng các chỉ số định tính như rủi ro chiến lược hay thay đổi cấu trúc chuỗi cung ứng (Trần Duy Thanh, 2026a, Ch5 tr.61). Trụ cột thứ ba là đạo đức thuật toán và tuân thủ ESG: một tác tử tối ưu thuần túy cho chi phí có thể chọn nhà cung cấp dùng lao động bất hợp pháp hoặc tuyến vận tải phát thải cao, nên phải được lập trình với các ràng buộc bền vững (Trần Duy Thanh, 2026a, Ch5 tr.62). Demo trên slide mô phỏng một lớp trung gian giám sát: khi tác tử đề xuất chọn nhà cung cấp B để tiết kiệm 20.000 USD nhưng điểm ESG chỉ 40, hệ thống chặn lệnh và yêu cầu con người duyệt; hồ sơ kiểm toán ghi lại đề xuất, chuỗi lập luận và trạng thái cuối cùng là bị phủ quyết hoặc được con người chấp thuận bất chấp rủi ro (Trần Duy Thanh, 2026a, Ch5 tr.63–71).

Tiểu luận mở rộng hàm ngắt rủi ro thành một quy tắc đa điều kiện có thể hiệu chỉnh bằng dữ liệu. Một lệnh đặt hàng được chuyển cho con người nếu giá trị lệnh vượt một phân vị cao của phân phối giá trị lệnh lịch sử, hoặc nếu lượng đặt lệch khỏi dự báo trung vị quá một tỷ lệ cho trước:

$ Escalate~i~ = 1{V~i~ > τ~V~} ∨ 1{|Q~i~ − P50~i~| / P50~i~ > τ~dev~}

Ngưỡng τ~V~ đặt theo phân vị cho phép nhà quản trị kiểm soát trực tiếp "khối lượng việc" của con người (ví dụ 5% số lệnh lớn nhất), đồng thời đo được tỷ trọng giá trị được con người kiểm soát. Đây là một đánh đổi rõ ràng giữa tốc độ tự động hóa và mức độ giám sát, có thể được định lượng và điều chỉnh.

### 2.6.6. Phân bổ ngân sách quảng cáo giữa các ngành như một bài toán tối ưu lồi

Mục 2.6.3 áp dụng hàm mục tiêu có trọng số của slide cho quyết định số lượng nhập hàng. Cùng cấu trúc đó có thể áp dụng cho quyết định phân bổ ngân sách quảng cáo – câu hỏi mà Tác tử Điều phối của một phòng marketing phải trả lời hằng ngày. Gọi a~c~ là ngân sách quảng cáo/ngày cho ngành c, Orders~c~(a~c~) là đường phản hồi của ngành (Mục 2.1.5), AOV~c~ và COGS~c~ là giá trị và giá vốn mỗi đơn. Tác tử Kinh doanh muốn tối đa GMV, Tác tử Tài chính muốn tối thiểu chi phí (giá vốn và quảng cáo), và Tác tử Điều phối giải:

$ max~a~ Σ~c~ [ w~1~ · AOV~c~ · Orders~c~(a~c~) − w~2~ · (COGS~c~ · Orders~c~(a~c~) + a~c~) ]

$ với ràng buộc Σ~c~ a~c~ = B ;  a~c~ ≥ m · B ;  a~c~ ∈ [a~c~^min^, a~c~^max^] (tùy chọn)

trong đó B là tổng ngân sách, m là tỷ trọng tối thiểu để duy trì hiện diện của mỗi ngành và khoảng [a~c~^min^, a~c~^max^] là vùng chi tiêu đã quan sát (ràng buộc chống ngoại suy). Khi w~1~ = w~2~ = 1, hàm mục tiêu là lợi nhuận gộp sau quảng cáo; khi w~2~ = 0, đó là tối đa GMV.

Nếu đường phản hồi có dạng logarit Orders~c~(a) = α~c~ + β~c~·ln a với β~c~ ≥ 0, mỗi số hạng của hàm mục tiêu là lõm theo a~c~, tập ràng buộc là tập lồi, nên bài toán là bài toán tối ưu lồi và mọi nghiệm cục bộ là nghiệm toàn cục (Boyd & Vandenberghe, 2004). Điều kiện Karush–Kuhn–Tucker cho nghiệm trong miền (các ràng buộc cận không chặt) là:

$ (w~1~ · AOV~c~ − w~2~ · COGS~c~) · β~c~ / a~c~ − w~2~ = λ, với mọi c

trong đó λ là nhân tử Lagrange của ràng buộc ngân sách. Giải ra:

$ a~c~^*^ = (w~1~ · AOV~c~ − w~2~ · COGS~c~) · β~c~ / (w~2~ + λ)

Công thức cho thấy ba điều. Thứ nhất, ngân sách tối ưu của mỗi ngành tỷ lệ với tích "biên gộp có trọng số × độ nhạy quảng cáo" (w~1~·AOV~c~ − w~2~·COGS~c~)·β~c~, chứ không tỷ lệ với ROAS trung bình như cách phân bổ theo kinh nghiệm thường làm. Thứ hai, λ có ý nghĩa kinh tế là giá bóng của ngân sách: lợi nhuận tăng thêm khi nới ngân sách thêm một đơn vị; λ > 0 nghĩa là ngân sách đang là ràng buộc chặt và tăng ngân sách còn có lãi, λ < 0 nghĩa là doanh nghiệp đang chi quá mức tối ưu không ràng buộc. Thứ ba, ngành có β~c~ không khác 0 về mặt thống kê, hoặc có biên gộp gần 0, sẽ bị đẩy về cận dưới m·B; ràng buộc tỷ trọng tối thiểu vì vậy là một lựa chọn quản trị (duy trì hiện diện thương hiệu) chứ không phải hệ quả của tối ưu. Khi không ràng buộc tổng, mức chi tối ưu riêng của mỗi ngành (λ = 0, w~1~ = w~2~ = 1) là:

$ a~c~^free^ = (AOV~c~ − COGS~c~) · β~c~

Bài toán này nhạy với sai số ước lượng của β~c~. Một cách đánh giá độ vững là lặp lại phép tối ưu trên các mẫu bootstrap của dữ liệu phản hồi (Mục 2.5.9) và tính xác suất chính sách tối ưu cho lợi nhuận cao hơn hiện trạng, thay vì chỉ báo cáo lợi nhuận tại ước lượng điểm.

### 2.6.7. Tác tử lập kế hoạch chiến dịch với rào chắn pháp lý và tài chính

Kết hợp các thành phần trên, một tác tử lập kế hoạch chiến dịch có thể được mô tả như một hàm ánh xạ đề xuất r = (a, δ, loại ngày, chương trình) thành một kế hoạch có trạng thái. Theo chu trình ReAct, tác tử quan sát (truy xuất quy định và quy chế liên quan bằng RAG), suy luận (gọi mô hình chiến dịch để dự báo phân phối GMV và biên đóng góp, gọi bộ kiểm tra chính sách) và hành động (phát hành kế hoạch theo lược đồ định chuẩn). Tiểu luận chính thức hóa bước kiểm tra như một tập chấp nhận được:

$ 𝒜 = {r : δ ≤ δ~max~(chương trình) ; P50(CM | r) ≥ 0 ; P(CM < 0 | r) ≤ π ; a ≤ Q~0,95~(Ad) ; r ∈ vùng dữ liệu}

trong đó δ~max~ là mức giảm giá tối đa theo pháp luật (Mục 2.7.2), π là mức chấp nhận rủi ro biên âm và Q~0,95~(Ad) là phân vị 95% của ngân sách ngày trong lịch sử. Trạng thái của kế hoạch được xác định theo thứ bậc: vi phạm pháp lý dẫn tới từ chối; thuộc 𝒜 dẫn tới tự động phê duyệt; còn lại chuyển con người phê duyệt kèm danh sách lý do. Thiết kế này tách bạch ba loại tri thức: tri thức pháp lý (cứng, không thương lượng), tri thức tài chính (định lượng, từ mô hình) và tri thức quản trị (ngưỡng do con người đặt), đúng với tinh thần "hộp kính" của slide khi yêu cầu mọi quyết định phải truy vết được ngữ cảnh, tham số suy luận và lập luận (Trần Duy Thanh, 2026a, Ch5 tr.60). Điểm then chốt là các con số trong kế hoạch được sinh bởi công cụ tính toán chứ không bởi mô hình ngôn ngữ; nếu có dùng LLM, vai trò của nó giới hạn ở diễn giải kế hoạch bằng ngôn ngữ tự nhiên.

## 2.7. Khung pháp lý khuyến mại và cơ chế đối soát của sàn tại Việt Nam

Các mô hình ở những mục trên cho biết một chiến dịch có thể mang lại bao nhiêu đơn hàng và bao nhiêu lợi nhuận. Tuy nhiên, tập phương án mà một doanh nghiệp được phép lựa chọn còn bị giới hạn bởi pháp luật và bởi điều khoản của sàn. Mục này tóm tắt hai nhóm ràng buộc thể chế được đưa vào tiểu luận dưới dạng quy tắc cứng của tác tử. Phần trình bày dựa trên văn bản pháp luật và bản tóm tắt của đơn vị tư vấn pháp lý; nó phục vụ mục đích nghiên cứu và không thay thế tư vấn pháp lý.

### 2.7.1. Khuyến mại trong Luật Thương mại và các văn bản hướng dẫn

Luật Thương mại năm 2005 xếp khuyến mại vào nhóm hoạt động xúc tiến thương mại, là hoạt động của thương nhân nhằm xúc tiến việc mua bán hàng hóa, cung ứng dịch vụ bằng cách dành cho khách hàng những lợi ích nhất định, và quy định các hình thức khuyến mại như giảm giá, tặng hàng, phát phiếu mua hàng, tổ chức chương trình khách hàng thường xuyên (Quốc hội, 2005). Nghị định 81/2018/NĐ-CP quy định chi tiết Luật Thương mại về hoạt động xúc tiến thương mại, trong đó có hạn mức tối đa về giá trị hàng hóa, dịch vụ dùng để khuyến mại và mức giảm giá tối đa (Chính phủ, 2018). Nghị định 128/2024/NĐ-CP, ban hành ngày 10/10/2024 và có hiệu lực từ ngày 01/12/2024, sửa đổi, bổ sung một số điều của Nghị định 81/2018/NĐ-CP (Chính phủ, 2024).

### 2.7.2. Mức giảm giá tối đa và hạn mức giá trị khuyến mại

Theo bản tóm tắt của Luật Việt An về Nghị định 128/2024/NĐ-CP, mức giảm giá tối đa đối với hàng hóa, dịch vụ được khuyến mại không được vượt quá 50% giá của hàng hóa, dịch vụ đó ngay trước thời gian khuyến mại; đối với chương trình khuyến mại tập trung và các chương trình, hoạt động xúc tiến thương mại do Thủ tướng Chính phủ quyết định, mức giảm giá tối đa có thể tới 100% (Chính phủ, 2024). Cũng theo bản tóm tắt này, giá trị vật chất dùng để khuyến mại cho một đơn vị hàng hóa, dịch vụ không được vượt quá 50% giá bán ngay trước thời gian khuyến mại, và tổng giá trị hàng hóa, dịch vụ dùng để khuyến mại trong một chương trình không được vượt quá 50% tổng giá trị hàng hóa, dịch vụ được khuyến mại, với một số ngoại lệ theo hình thức khuyến mại.

Đối với mô hình hóa, quy định về mức giảm giá tối đa chuyển thành một ràng buộc cứng trên biến quyết định chiết khấu:

$ δ ≤ δ~max~ ; δ~max~ = 0,5 (thông thường) hoặc 1,0 (khuyến mại tập trung)

Ràng buộc này có hai hệ quả. Thứ nhất, nó cắt bỏ một vùng của không gian kịch bản trước khi bất kỳ mô hình dự báo nào được gọi; một tác tử tối đa GMV thuần túy có thể đề xuất mức giảm giá vượt trần nếu mô hình phản hồi cho thấy số đơn tăng theo chiết khấu, và rào chắn pháp lý là lớp bảo vệ đầu tiên. Thứ hai, trong dữ liệu lịch sử, mức chiết khấu 50% là cận trên hợp pháp thông thường, nên các ngày có chiết khấu "chạm sàn 50%" như slide mô tả (Trần Duy Thanh, 2026a, Ch1 tr.63) nằm đúng tại biên của vùng được phép; mọi kịch bản vượt mức này vừa là ngoại suy thống kê vừa là vi phạm pháp lý (trừ chương trình tập trung).

### 2.7.3. Cơ chế đối soát và giải ngân của sàn

Dòng tiền của nhà bán hàng trên sàn phụ thuộc vào thời điểm tiền đơn hàng được ghi nhận và thời gian rút tiền. Theo mô tả của MISA eShop về chính sách của sàn Shopee, tiền đơn hàng được ghi nhận vào số dư người bán khi người mua xác nhận "Đã nhận được hàng"; nếu người mua không xác nhận, tiền được ghi nhận sau 4 ngày kể từ khi giao hàng thành công (áp dụng từ 29/03/2024), với điều kiện không có yêu cầu trả hàng/hoàn tiền; việc rút tiền về ngân hàng mất trong vòng 24 giờ làm việc với một số ngân hàng và có thể kéo dài đến 4 ngày làm việc với ngân hàng khác (MISA eShop, không ghi năm). Cộng thêm thời gian giao hàng, độ trễ từ ngày bán đến ngày tiền về tài khoản có thể kéo dài từ vài ngày đến khoảng hai tuần tùy tình huống. Vì đây là mô tả chính sách của một sàn tại một thời điểm và độ trễ thực tế phụ thuộc vào vận chuyển, tiểu luận không coi độ trễ là một hằng số đo được mà xem nó là tham số kịch bản d trong mô hình dòng tiền ở Mục 2.1.5, với các mức 0, 7, 10 và 14 ngày.

### 2.7.4. Hàm ý cho thiết kế mô hình và tác tử

Ba ràng buộc thể chế – trần chiết khấu, hạn mức giá trị khuyến mại và độ trễ đối soát – có vị trí khác nhau trong khung phân tích. Trần chiết khấu là ràng buộc cứng trên biến quyết định và được đặt ở bước kiểm tra chính sách của tác tử (Mục 2.6.7): mọi đề xuất vi phạm bị từ chối, không phụ thuộc vào dự báo lợi nhuận. Hạn mức giá trị khuyến mại là ràng buộc trên thiết kế chương trình (quà tặng, voucher) mà dữ liệu học phần không mô tả, nên tiểu luận chỉ ghi nhận trong kho tri thức của tác tử. Độ trễ đối soát là tham số của mô hình dòng tiền và ảnh hưởng đến quyết định thông qua nhu cầu vốn. Việc mã hóa các quy định thành quy tắc tường minh, thay vì để mô hình ngôn ngữ "tự nhớ" quy định, cũng là một biện pháp chống ảo giác: một tác tử dùng RAG có thể truy xuất đúng điều khoản và trích dẫn nguồn, nhưng quyết định chấp nhận hay từ chối phải được thực hiện bởi phép so sánh số học, có thể kiểm toán.

## 2.8. Tổng quan nghiên cứu liên quan và khoảng trống nghiên cứu

### 2.8.1. Các dòng nghiên cứu chính

Các nghiên cứu liên quan đến tiểu luận có thể được nhóm thành năm dòng. Dòng thứ nhất là mô hình phản hồi thị trường và đo lường hiệu quả marketing. Broadbent (1979) đề xuất khái niệm adstock để mô tả tác động suy giảm dần của quảng cáo truyền hình; Hanssens và cộng sự (2001) hệ thống hóa các mô hình kinh tế lượng và chuỗi thời gian về phản hồi của doanh số đối với các biến marketing; Jin và cộng sự (2017) đưa đồng thời tác động trễ và tác động bão hòa vào khung Bayes của mô hình hỗn hợp truyền thông và lưu ý khó khăn nhận dạng các tham số hình dạng khi dữ liệu có biến thiên hạn chế. Điểm chung của dòng này là dữ liệu chi tiêu quảng cáo theo kênh với chuỗi dài; trọng tâm là lượng hóa đóng góp và lợi nhuận trên chi tiêu của từng kênh.

Dòng thứ hai là nghiên cứu về khuyến mãi bán lẻ. Gupta (1988) phân tách mức tăng doanh số trong kỳ khuyến mãi thành các quyết định về thời điểm mua, lựa chọn thương hiệu và số lượng mua; Blattberg và cộng sự (1995) tổng kết các quy luật thực nghiệm về cách khuyến mãi tác động lên doanh số; van Heerde và cộng sự (2000) ước lượng các "hố" doanh số trước và sau khuyến mãi từ dữ liệu quét mã vạch cấp cửa hàng. Dòng này cung cấp nền tảng cho việc không đánh đồng mức tăng doanh số trong ngày khuyến mãi với hiệu quả ròng của khuyến mãi. Phần lớn bằng chứng của dòng này đến từ bán lẻ hàng tiêu dùng đóng gói tại các thị trường phát triển, trước khi các sự kiện mua sắm trực tuyến quy mô lớn như ngày đôi trở nên phổ biến.

Dòng thứ ba là suy luận nhân quả và thử nghiệm có đối chứng. Athey và Imbens (2016) và Künzel và cộng sự (2019) phát triển các phương pháp học máy để ước lượng hiệu ứng can thiệp dị biệt theo đặc trưng; Kohavi và cộng sự (2020) trình bày thực hành thử nghiệm có đối chứng trực tuyến trong các doanh nghiệp số. Dòng này cung cấp ngôn ngữ để phân biệt dự báo có điều kiện với ước lượng nhân quả và chỉ ra điều kiện để một hệ số hồi quy được diễn giải như hiệu quả của quảng cáo.

Dòng thứ tư là dự báo nhiều chuỗi và dự báo xác suất. Montero-Manso và Hyndman (2021) chứng minh rằng mô hình toàn cục có thể đạt độ chính xác tương đương hoặc tốt hơn mô hình cục bộ ngay cả khi các chuỗi không đồng nhất; cuộc thi M5 trên dữ liệu bán lẻ của Walmart cho thấy các giải pháp dẫn đầu phần lớn dựa trên LightGBM toàn cục (Makridakis và cộng sự, 2022; Ke và cộng sự, 2017); Salinas và cộng sự (2020) đề xuất DeepAR cho dự báo phân phối; Koenker và Bassett (1978) đặt nền tảng cho hồi quy phân vị; Gneiting và Raftery (2007) xây dựng lý thuyết quy tắc chấm điểm thích đáng cho đánh giá dự báo xác suất; Khouja (1999) tổng quan mô hình Newsvendor như cầu nối giữa phân phối nhu cầu và quyết định số lượng. Trong dòng này, khuyến mãi thường xuất hiện như một biến giải thích của mô hình dự báo nhu cầu chứ không phải là biến quyết định được tối ưu.

Dòng thứ năm là tác tử AI và quản trị quyết định tự động. Yao và cộng sự (2023) đề xuất khung ReAct xen kẽ suy luận và hành động; Lewis và cộng sự (2020) đề xuất RAG để neo mô hình ngôn ngữ vào tri thức bên ngoài. Các nghiên cứu này chủ yếu đánh giá tác tử trên các nhiệm vụ hỏi đáp và ra quyết định tổng quát; việc đánh giá tác tử bằng hệ quả kinh tế của quyết định, dưới các ràng buộc pháp lý cụ thể của một thị trường, ít được đề cập. Bảng {T:@c2m_tongquan} tóm tắt các nghiên cứu tiêu biểu và mối liên hệ với tiểu luận.

[[T:@c2m_tongquan Tổng quan các nghiên cứu tiêu biểu liên quan đến tiểu luận
Tác giả (năm) | Phương pháp/đóng góp | Bối cảnh dữ liệu | Liên hệ với tiểu luận
Broadbent (1979) | Khái niệm adstock – tác động quảng cáo suy giảm dần | Quảng cáo truyền hình | Kiểm định tác động trễ của chi phí marketing (Ch2 slide)
Gupta (1988) | Phân tách mức tăng doanh số khuyến mãi theo thời điểm, thương hiệu, số lượng | Dữ liệu mua hàng hộ gia đình | Không đánh đồng đỉnh doanh số với hiệu quả ròng
Blattberg và cộng sự (1995) | Tổng kết quy luật thực nghiệm về khuyến mãi | Bán lẻ hàng tiêu dùng | Khung diễn giải hiệu ứng ngày Mega Sale
van Heerde và cộng sự (2000) | Ước lượng hố doanh số trước/sau khuyến mãi | Dữ liệu quét mã vạch cấp cửa hàng | Kiểm tra hiệu ứng kéo cầu quanh ngày sự kiện
Hanssens và cộng sự (2001) | Hệ thống hóa mô hình phản hồi thị trường | Nhiều ngành | Phân biệt hiệu quả trung bình và hiệu quả biên
Jin và cộng sự (2017) | Media mix model Bayes với adstock và bão hòa Hill | Dữ liệu mô phỏng và kênh quảng cáo | Dạng hàm bão hòa, cảnh báo nhận dạng
Athey và Imbens (2016) | Cây nhân quả cho hiệu ứng dị biệt | Dữ liệu thử nghiệm | Uplift khuyến mãi theo sản phẩm
Künzel và cộng sự (2019) | Meta-learner S/T/X | Mô phỏng và thử nghiệm | S-learner toàn cục và T-learner cục bộ
Kohavi và cộng sự (2020) | Thực hành thử nghiệm có đối chứng trực tuyến | Doanh nghiệp số | Đề xuất thử nghiệm khi dữ liệu không nhận dạng được hiệu ứng
Montero-Manso và Hyndman (2021) | Lý thuyết mô hình toàn cục vs cục bộ | Nhiều bộ chuỗi chuẩn | Dự báo cầu nhiều SKU trước chiến dịch
Makridakis và cộng sự (2022) | Kết quả cuộc thi M5 | Bán lẻ Walmart | Căn cứ chọn LightGBM toàn cục
Salinas và cộng sự (2020) | DeepAR – dự báo phân phối | Bán lẻ, nhu cầu | Mô hình xác suất so sánh
Gneiting và Raftery (2007) | Quy tắc chấm điểm thích đáng | Lý thuyết | Pinball, hiệu chỉnh, Winkler
Khouja (1999) | Tổng quan Newsvendor | Lý thuyết tồn kho | Chuẩn bị hàng theo phân vị tới hạn
Yao và cộng sự (2023); Lewis và cộng sự (2020) | ReAct; RAG | Nhiệm vụ ngôn ngữ | Kiến trúc tác tử lập kế hoạch chiến dịch
Richards và Laughlin (1980); Deloof (2003) | Chu kỳ chuyển đổi tiền mặt; vốn lưu động và sinh lời | Doanh nghiệp | Mô phỏng bẫy vốn lưu động của chiến dịch
Nguồn: Tác giả tổng hợp.
]]

### 2.8.2. Khoảng trống nghiên cứu

Đối chiếu năm dòng nghiên cứu trên với bài toán của một nhà bán hàng TMĐT Việt Nam trong mùa Mega Sale, tiểu luận nhận diện bốn khoảng trống, với lưu ý rằng nhận định chỉ áp dụng trong phạm vi tài liệu tiểu luận khảo sát.

Khoảng trống thứ nhất là sự tách rời giữa đo lường hiệu quả marketing và dự báo vận hành. Văn liệu mô hình phản hồi tập trung vào lượng hóa đóng góp của từng kênh, còn văn liệu dự báo tập trung vào độ chính xác của dự báo nhu cầu; trong phạm vi tài liệu tiểu luận khảo sát, chưa thấy một quy trình thống nhất đi từ chẩn đoán hiệu quả quảng cáo – khuyến mãi qua dự báo cầu nhiều sản phẩm, dự báo xác suất đến quyết định phân bổ ngân sách và chuẩn bị hàng cho cùng một chiến dịch.

Khoảng trống thứ hai là thiếu đánh giá trung thực về giới hạn nhận dạng của dữ liệu quan sát trong bối cảnh sự kiện TMĐT. Các ngày Mega Sale thường đi kèm đồng thời quảng cáo cao, chiết khấu sâu và lịch đặc biệt, nên dữ liệu lịch sử của một nhà bán hàng thường không chứa biến thiên độc lập đủ để tách các hiệu ứng. Trong phạm vi tài liệu tiểu luận khảo sát, các nghiên cứu ứng dụng ít khi gắn cờ tường minh những kịch bản chiến dịch là ngoại suy về mặt nhận dạng.

Khoảng trống thứ ba là sự vắng mặt của ràng buộc pháp lý và cơ chế thanh toán của thị trường cụ thể trong mô hình ra quyết định. Trần chiết khấu theo pháp luật Việt Nam và độ trễ đối soát của sàn là các ràng buộc có hệ quả trực tiếp đến tập phương án và nhu cầu vốn, nhưng trong phạm vi tài liệu tiểu luận khảo sát, chúng chưa được đưa vào các khung tối ưu chiến dịch dưới dạng ràng buộc tường minh.

Khoảng trống thứ tư là thiếu đánh giá tác tử AI bằng hệ quả kinh tế. Các khung tác tử như ReAct và RAG được đánh giá chủ yếu bằng chất lượng câu trả lời; câu hỏi tác tử nên được thiết kế thế nào để đề xuất của nó vừa hợp pháp, vừa có lãi, vừa nằm trong vùng mà dữ liệu cho phép tin cậy, và vừa để lại hồ sơ kiểm toán, chưa được trả lời bằng thực nghiệm trong phạm vi tài liệu tiểu luận khảo sát.

Tiểu luận không tuyên bố lấp đầy các khoảng trống này bằng bằng chứng về thị trường thật, vì dữ liệu cấp doanh nghiệp là dữ liệu mô phỏng của học phần. Đóng góp được xác lập là một khung phương pháp tích hợp, có mã nguồn tái lập, được minh chứng trên dữ liệu mô phỏng và được neo vào số liệu vĩ mô thật cùng các ràng buộc thể chế thật của Việt Nam.

## 2.9. Khung phân tích của tiểu luận

Từ cơ sở lý thuyết và khoảng trống trên, tiểu luận xây dựng một khung phân tích năm tầng tương ứng với năm chương của học phần. Mỗi tầng nhận đầu vào từ tầng trước, áp dụng một họ phương pháp và tạo ra một đầu ra trở thành ràng buộc hoặc tham số cho tầng sau. Khung được hiện thực thành một pipeline phần mềm 14 bước và một dashboard tương tác, mô tả ở Chương 3.

{F:d01_khung_nghien_cuu.png} trình bày khung nghiên cứu dưới dạng sơ đồ. Mỗi hàng là một tầng phân tích tương ứng với một chương của học phần và một câu hỏi nghiên cứu (RQ1–RQ5); mỗi cột mô tả lần lượt dữ liệu đầu vào, nhóm phương pháp, đầu ra phân tích và quyết định quản trị mà đầu ra đó phục vụ. Các mũi tên dọc thể hiện quan hệ phụ thuộc giữa các tầng: kết quả chẩn đoán (ví dụ hệ số quảng cáo đã kiểm soát chiết khấu, ROAS hòa vốn) trở thành ràng buộc cho tầng phân rã và mô hình hóa; phân phối dự báo của tầng xác suất là đầu vào trực tiếp cho tầng tác tử khi đánh giá rủi ro của một đề xuất chiến dịch. Dải dưới cùng ghi các yếu tố bối cảnh Việt Nam được dùng như số liệu thật hoặc ràng buộc pháp lý – tài chính của toàn bộ khung.

[[FIG:d01_khung_nghien_cuu.png|Khung nghiên cứu của tiểu luận: năm tầng phân tích từ dữ liệu marketing đến quyết định chiến dịch Mega Sale|Nguồn: Tác giả đề xuất dựa trên cấu trúc năm chương của học phần (Trần Duy Thanh, 2026a, 2026b)]]

Tầng 1 (chẩn đoán) biến dữ liệu thô thành các thước đo kinh tế đơn vị, hệ số phản hồi quảng cáo – chiết khấu đã kiểm soát thiên lệch bỏ sót biến và đánh giá tính dị biệt giữa các ngành; đầu ra là danh sách ngành đang lỗ, ROAS hòa vốn và lợi nhuận biên của quảng cáo. Tầng 2 (phân rã) tách mùa vụ tuần, năm, Tết và sự kiện khỏi chuỗi doanh thu, kiểm định xem chi phí marketing còn giải thích được phần nào sau khi khử mùa vụ, và đặt doanh nghiệp vào bối cảnh mùa vụ tiêu dùng quốc gia; đầu ra là hệ số mùa vụ và bằng chứng (hoặc sự vắng mặt của bằng chứng) về hiệu ứng marketing. Tầng 3 (học máy toàn cục) dự báo cầu nhiều SKU trước chiến dịch, ước lượng uplift khuyến mãi theo sản phẩm, xử lý sản phẩm mới và kiểm định hiệu ứng lịch có kiểm soát; đầu ra là dự báo điểm và hệ số uplift. Tầng 4 (dự báo xác suất) chuyển dự báo điểm thành phân phối, đánh giá hiệu chỉnh, chọn lượng hàng theo phân vị tới hạn và lượng hóa xác suất lỗ của quyết định quảng cáo cũng như phân phối GMV của ngày sự kiện. Tầng 5 (tác tử) phân bổ ngân sách giữa các ngành bằng tối ưu lồi, kiểm tra đề xuất chiến dịch theo ràng buộc pháp lý, tài chính và vùng dữ liệu, chuyển con người phê duyệt khi cần và mô phỏng nhu cầu vốn theo độ trễ đối soát.

$ 𝒟~raw~ →(T1) {CM~c~, ROAS~BE,c~, β~c~} →(T2) {S~t~, H~t~, β~mkt~} →(T3) {ŷ~i,t~, m̂~i~} →(T4) {F̂~i,t~, q^*^~i~, P(lỗ)} →(T5) {a^*^, trạng thái, Cash~0~^*^}

Bảng {T:@c2m_khung} tóm tắt khung phân tích, gắn mỗi tầng với chương slide, câu hỏi nghiên cứu, phương pháp và đầu ra quyết định.

[[T:@c2m_khung Khung phân tích năm tầng của tiểu luận
Tầng | Chương slide | Câu hỏi nghiên cứu | Phương pháp chính | Đầu ra cho quyết định
1. Chẩn đoán | Chương 1 | RQ1 | EDA 3 phương diện; OLS có kiểm soát; panel hiệu ứng cố định; Unit Economics | Ngành lỗ, ROAS hòa vốn, lợi nhuận biên của quảng cáo
2. Phân rã | Chương 2 | RQ2 | STL, MSTL, HP, Prophet; adstock, độ trễ phân phối; hồi quy Tết – COVID | Hệ số mùa vụ; bằng chứng về hiệu ứng marketing
3. Học máy toàn cục | Chương 3 | RQ3 | LightGBM toàn cục, walk-forward, S/T-learner, cold-start, hồi quy hiệu ứng cố định | Dự báo cầu SKU; uplift theo sản phẩm
4. Dự báo xác suất | Chương 4 | RQ4 | Quantile LightGBM, phân vị phần dư, DeepAR; pinball; Newsvendor; bootstrap | Lượng hàng theo q*; xác suất lỗ; phân phối GMV ngày sự kiện
5. Tác tử AI | Chương 5 | RQ5 | Tối ưu lồi có trọng số; RAG; ReAct; lược đồ định chuẩn; HITL; mô phỏng dòng tiền | Phân bổ ngân sách; trạng thái kế hoạch; tiền mặt tối thiểu
Nguồn: Tác giả đề xuất.
]]

Khung này có ba đặc điểm cần nhấn mạnh. Thứ nhất, các tầng không độc lập: hệ số phản hồi của tầng 1 là đầu vào của bài toán phân bổ ngân sách ở tầng 5, phân phối dự báo của tầng 4 là đầu vào của quyết định chuẩn bị hàng và của mô hình dòng tiền. Thứ hai, mỗi tầng có một "cửa kiểm soát" phương pháp luận: kiểm soát thiên lệch bỏ sót biến ở tầng 1, khử mùa vụ trước khi kiểm định hiệu ứng marketing ở tầng 2, walk-forward và kiểm tra rò rỉ ở tầng 3, hiệu chỉnh và kiểm tra bỏ-một-sự-kiện ở tầng 4, ràng buộc pháp lý và vùng dữ liệu ở tầng 5. Thứ ba, mọi con số dẫn tới quyết định đều được sinh bởi mô hình có thể tái lập, còn con người giữ quyền phê duyệt ở những điểm mà mô hình không đủ căn cứ – đúng với yêu cầu "hộp kính" của học phần.
