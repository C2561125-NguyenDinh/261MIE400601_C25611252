"""Sơ đồ khung nghiên cứu, quy trình nghiên cứu, kiến trúc phần mềm, luồng tác tử AI và quy trình chiến dịch Mega Sale.
Vẽ bằng matplotlib để đưa vào báo cáo (REPORT_READY/figures). Nội dung sơ đồ phản ánh đúng cấu trúc của project."""
from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch  # noqa: E402

NAVY, TEAL, AMBER, RED, GREEN, GREY, LIGHT = "#0E2A33", "#1B8A8F", "#E8A33D", "#D05A4E", "#3C8D5A", "#9AAEB2", "#F4F8F8"
TINT = {"teal": "#E3F2F2", "amber": "#FDF1DE", "navy": "#E6ECEE", "green": "#E7F3EB", "red": "#FBE9E7", "grey": "#F2F4F5"}


def _box(ax, x, y, w, h, text, fc="#FFFFFF", ec=NAVY, fs=7.5, bold=False, color="#0E2A33", lw=1.0, ha="center", style="round,pad=0.002,rounding_size=0.008"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle=style, fc=fc, ec=ec, lw=lw, mutation_aspect=1))
    tx = x + w / 2 if ha == "center" else x + 0.008
    ax.text(tx, y + h / 2, text, ha=ha, va="center", fontsize=fs, fontweight="bold" if bold else "normal", color=color, wrap=True, linespacing=1.25)


def _arrow(ax, p, q, color=NAVY, lw=1.1, style="-|>", ls="-", rad=0.0):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle=style, mutation_scale=9, color=color, lw=lw, linestyle=ls,
                                 connectionstyle=f"arc3,rad={rad}", shrinkA=1, shrinkB=1))


def _canvas(w, h):
    fig = plt.figure(figsize=(w, h))
    ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis("off")
    return fig, ax


def research_framework(path: Path):
    """Khung nghiên cứu 5 tầng: dữ liệu → phương pháp (chương slide) → đầu ra → quyết định, kèm RQ và bối cảnh Việt Nam."""
    fig, ax = _canvas(9.0, 7.6)
    ax.text(0.5, 0.995, "KHUNG NGHIÊN CỨU: TỪ DỮ LIỆU MARKETING ĐẾN QUYẾT ĐỊNH CHIẾN DỊCH MEGA SALE", ha="center", va="top", fontsize=10.5, fontweight="bold", color=NAVY)
    cols = [(0.02, 0.18, "DỮ LIỆU ĐẦU VÀO"), (0.225, 0.30, "TẦNG PHƯƠNG PHÁP (CHƯƠNG HỌC PHẦN)"), (0.55, 0.22, "ĐẦU RA PHÂN TÍCH"), (0.795, 0.185, "QUYẾT ĐỊNH QUẢN TRỊ")]
    for x, w, t in cols:
        _box(ax, x, 0.90, w, 0.045, t, fc=NAVY, ec=NAVY, fs=7.6, bold=True, color="white")
    layers = [
        ("RQ1", "teal", "90 ngày GMV–Ads–Discount;\npanel 3 ngành; Unit Economics;\ndữ liệu bẩn",
         "Tầng 1 – CHẨN ĐOÁN (Ch1)\nEDA 3 phương diện · IQR/MAD · OVB\nPanel hiệu ứng cố định · Simpson\nCM = AOV − (CAC + COGS)",
         "β quảng cáo có kiểm soát;\nROAS biên vs ROAS hòa vốn;\nngành lỗ/lãi trên mỗi đơn", "Ngành nào được\ntăng/giảm quảng cáo"),
        ("RQ2", "green", "Doanh thu ngày 3 năm + chi\nmarketing; GMV 48 tháng; biên\nlợi nhuận 72 tháng; TMBL VN",
         "Tầng 2 – PHÂN RÃ (Ch2)\nSTL/MSTL · HP · GAM/Prophet\nAdstock · độ trễ phân phối\nTết · COVID · độ trôi mùa vụ",
         "Mùa vụ tuần/năm/cuối năm;\ntăng trưởng lõi; hiệu ứng\nmarketing sau khử mùa vụ", "Lịch chiến dịch theo\nmùa vụ, không theo\ncảm tính"),
        ("RQ3", "amber", "100 SKU × 150 ngày; 15 SKU;\n5 sản phẩm có khuyến mãi;\nsản phẩm mới",
         "Tầng 3 – HỌC MÁY TOÀN CỤC (Ch3)\nLightGBM toàn cục vs cục bộ\nWalk-forward · rò rỉ · cold-start\nUplift S/T-learner · ngày đôi",
         "Dự báo cầu nhiều SKU trước\nchiến dịch; uplift theo sản\nphẩm; hiệu ứng lịch thật/giả", "Chọn SKU và mức\nkhuyến mãi theo\nsản phẩm"),
        ("RQ4", "red", "Dự báo phân vị 100 SKU;\ngiá–vốn–thanh lý;\nphản hồi quảng cáo",
         "Tầng 4 – XÁC SUẤT (Ch4)\nQuantile LGBM · DeepAR · Z · EMP\nPinball · hiệu chỉnh · Winkler\nNewsvendor q* · ROP · bootstrap",
         "Phân phối GMV/biên đóng góp\nngày Mega Sale; P(lỗ) khi tăng\nquảng cáo; lượng hàng q*", "Lượng hàng chuẩn bị;\nmức rủi ro chấp nhận"),
        ("RQ5", "navy", "Kết quả tầng 1–4; kho tri thức\n(pháp lý, đối soát sàn, quy\nchế); đề xuất chiến dịch",
         "Tầng 5 – TÁC TỬ AI (Ch5)\nTối ưu ngân sách w₁/w₂ + Lagrange\nRAG · ReAct · LangGraph · pydantic\nHITL · nhật ký kiểm toán",
         "Phân bổ ngân sách tối ưu; kế\nhoạch chiến dịch đã kiểm tra\npháp lý – lợi nhuận – vùng dữ liệu", "Tự duyệt / chuyển\nngười duyệt / từ chối"),
    ]
    top, hh, gap = 0.885, 0.142, 0.012
    for i, (rq, tint, dat, meth, outp, dec) in enumerate(layers):
        y = top - (i + 1) * hh - i * gap + gap
        col = {"teal": TEAL, "green": GREEN, "amber": AMBER, "red": RED, "navy": NAVY}[tint]
        _box(ax, 0.02, y, 0.18, hh - 0.012, dat, fc=TINT["grey"], ec=GREY, fs=6.6)
        _box(ax, 0.225, y, 0.30, hh - 0.012, meth, fc=TINT[tint], ec=col, fs=6.9, lw=1.4)
        ax.text(0.232, y + hh - 0.026, rq, fontsize=6.6, fontweight="bold", color="white", ha="left", va="center",
                bbox=dict(boxstyle="round,pad=0.25", fc=col, ec=col))
        _box(ax, 0.55, y, 0.22, hh - 0.012, outp, fc="#FFFFFF", ec=col, fs=6.6)
        _box(ax, 0.795, y, 0.185, hh - 0.012, dec, fc=TINT[tint], ec=col, fs=6.8, bold=True)
        ym = y + (hh - 0.012) / 2
        for a, b in [(0.20, 0.225), (0.525, 0.55), (0.77, 0.795)]:
            _arrow(ax, (a, ym), (b, ym), color=col)
        if i < 4:
            _arrow(ax, (0.375, y), (0.375, y - gap - 0.0), color=GREY, lw=0.9)
    # dải bối cảnh Việt Nam
    _box(ax, 0.02, 0.02, 0.96, 0.055, "BỐI CẢNH VIỆT NAM (số liệu thật): Tổng mức bán lẻ 82 tháng – Cục Thống kê · TMĐT 2024 > 25 tỷ USD, ≈ 9% TMBL · Mức giảm giá tối đa 50% (NĐ 81/2018, sửa đổi bởi NĐ 128/2024)\n"
         "· Đối soát sàn: ghi nhận khi người mua xác nhận hoặc sau 4 ngày giao thành công → độ trễ dòng tiền của chiến dịch",
         fc=TINT["amber"], ec=AMBER, fs=6.6)
    _arrow(ax, (0.5, 0.075), (0.5, 0.098), color=AMBER, lw=1.0)
    ax.text(0.985, 0.112, "Mũi tên dọc: đầu ra tầng trên là ràng buộc/đầu vào của tầng dưới", ha="right", fontsize=6.2, color=GREY, style="italic")
    fig.savefig(path, dpi=220, bbox_inches="tight", facecolor="white"); plt.close(fig)


def research_process(path: Path):
    """Quy trình nghiên cứu 7 bước."""
    fig, ax = _canvas(9.0, 4.4)
    ax.text(0.5, 0.99, "QUY TRÌNH NGHIÊN CỨU", ha="center", va="top", fontsize=10.5, fontweight="bold", color=NAVY)
    steps = [("1", "Xác định vấn đề\n& câu hỏi\nRQ1–RQ5", "Slide Ch0–Ch5;\nbối cảnh TMĐT VN"),
             ("2", "Thu thập &\nkiểm tra dữ liệu", "12 bộ dữ liệu GV;\nTMBL Cục Thống kê;\nSHA-256 (Stage 01)"),
             ("3", "Chẩn đoán &\nphân rã", "Stage 02–03:\nOVB, panel, Unit\nEconomics, STL/MSTL"),
             ("4", "Mô hình dự báo", "Stage 04–06:\ntoàn cục, uplift,\nphân vị, Newsvendor"),
             ("5", "Tối ưu & tác tử", "Stage 07–08:\nngân sách, RAG,\nLangGraph, HITL"),
             ("6", "Kiểm định &\nđộ nhạy", "Stage 09–13:\n24 kiểm tra, sai số,\ncase, độ nhạy"),
             ("7", "Báo cáo &\ndashboard", "Stage 14: REPORT_READY;\nStreamlit 12 trang;\nbáo cáo tiểu luận")]
    n = len(steps); w = 0.118; gap = (0.96 - n * w) / (n - 1)
    for i, (k, t, d) in enumerate(steps):
        x = 0.02 + i * (w + gap)
        col = [TEAL, TEAL, GREEN, AMBER, RED, NAVY, NAVY][i]
        _box(ax, x, 0.50, w, 0.28, t, fc=TINT["teal"] if i < 2 else (TINT["green"] if i == 2 else TINT["amber"] if i == 3 else TINT["red"] if i == 4 else TINT["navy"]), ec=col, fs=7.4, bold=True, lw=1.4)
        ax.text(x + w / 2, 0.81, k, ha="center", va="center", fontsize=8, fontweight="bold", color="white", bbox=dict(boxstyle="circle,pad=0.3", fc=col, ec=col))
        _box(ax, x, 0.13, w, 0.30, d, fc="#FFFFFF", ec=GREY, fs=6.3)
        _arrow(ax, (x + w / 2, 0.50), (x + w / 2, 0.43), color=GREY, lw=0.8)
        if i < n - 1:
            _arrow(ax, (x + w, 0.65), (x + w + gap, 0.65), color=NAVY)
    _arrow(ax, (0.02 + 5 * (w + gap) + w / 2, 0.13), (0.02 + 2 * (w + gap) + w / 2, 0.13), color=AMBER, ls="--", rad=-0.25)
    ax.text(0.5, 0.0, "Mũi tên cam: vòng lặp hiệu chỉnh khi kiểm định/độ nhạy phát hiện vấn đề (ví dụ: STL kháng nhiễu, giả định giá vốn, cờ ngoại suy Mega Sale)",
            ha="center", fontsize=6.4, color=GREY, style="italic")
    fig.savefig(path, dpi=220, bbox_inches="tight", facecolor="white"); plt.close(fig)


def software_architecture(path: Path):
    fig, ax = _canvas(9.0, 5.6)
    ax.text(0.5, 0.975, "KIẾN TRÚC PROJECT: DỮ LIỆU → THƯ VIỆN src/ → PIPELINE 14 STAGE → ĐẦU RA → DASHBOARD & BÁO CÁO", ha="center", va="top", fontsize=9.6, fontweight="bold", color=NAVY)
    _box(ax, 0.02, 0.62, 0.16, 0.27, "data/raw/gv\n(12 bộ GV)\n\ndata/raw/gso\n(TMBL 82 tháng)\n\nknowledge_base\n(5 tệp .md)\n\nconfig/default.yaml", fc=TINT["grey"], ec=GREY, fs=6.8)
    mods = ["data · io", "features · build", "models · train, macro", "evaluation · metrics", "marketing · response", "scenarios · megasale",
            "inventory · policy", "budget · allocate", "cashflow · sim", "genai · rag, agent,\nassistant", "export · report,\ndiagrams", "common"]
    _box(ax, 0.21, 0.88, 0.25, 0.04, "Thư viện src/", fc=TEAL, ec=TEAL, fs=7.4, bold=True, color="white")
    for i, m in enumerate(mods):
        r, c = divmod(i, 2)
        _box(ax, 0.21 + c * 0.128, 0.80 - r * 0.072, 0.122, 0.058, m, fc=TINT["teal"], ec=TEAL, fs=6.1)
    stages = ["01 Kiểm tra dữ liệu", "02 Chẩn đoán marketing", "03 Phân rã & mùa vụ", "04 Đặc trưng", "05 Toàn cục & uplift", "06 Dự báo xác suất",
              "07 Phân bổ ngân sách", "08 Tác tử AI + RAG", "09 Tổng hợp", "10 Kiểm thử (24)", "11 Chẩn đoán sai số", "12 Case study", "13 Độ nhạy", "14 REPORT_READY"]
    _box(ax, 0.50, 0.88, 0.22, 0.04, "Pipeline (START_WINDOWS.bat)", fc=AMBER, ec=AMBER, fs=7.2, bold=True, color="white")
    for i, s in enumerate(stages):
        _box(ax, 0.50, 0.835 - i * 0.054, 0.22, 0.040, s, fc=TINT["amber"], ec=AMBER, fs=6.4)
        if i < len(stages) - 1:
            _arrow(ax, (0.61, 0.835 - i * 0.054), (0.61, 0.835 - (i + 1) * 0.054 + 0.040), color=AMBER, lw=0.7)
    _box(ax, 0.76, 0.62, 0.22, 0.27, "outputs/<stage>/\nresults.json · *.csv\nfigures/*.png\naudit_log.jsonl\n\nREPORT_READY/\nfigures · tables\ntables_all.xlsx", fc=TINT["green"], ec=GREEN, fs=6.8)
    _box(ax, 0.76, 0.33, 0.22, 0.24, "app.py – Streamlit 12 trang\n(OPEN_DASHBOARD.bat)\nmô phỏng Mega Sale · ngân sách ·\ndòng tiền · tác tử + phê duyệt\nHITL · xuất Excel/HTML", fc=TINT["navy"], ec=NAVY, fs=6.6)
    _box(ax, 0.76, 0.08, 0.22, 0.20, "reports/builder/\nbuild.py · tables.py · content/*.tm\n→ báo cáo .docx/.pdf\ncheck/numcheck.py\n(đối chiếu số liệu)", fc=TINT["red"], ec=RED, fs=6.5)
    _box(ax, 0.21, 0.08, 0.25, 0.18, "tests/test_core.py (11 kiểm thử đơn vị)\n+ Stage 10 (24 kiểm tra ràng buộc)\n→ pipeline dừng nếu thất bại", fc=TINT["grey"], ec=GREY, fs=6.5)
    _arrow(ax, (0.18, 0.755), (0.21, 0.755)); _arrow(ax, (0.46, 0.70), (0.50, 0.70)); _arrow(ax, (0.72, 0.755), (0.76, 0.755))
    _arrow(ax, (0.87, 0.62), (0.87, 0.57), color=NAVY); _arrow(ax, (0.765, 0.62), (0.765, 0.28), color=RED, rad=0.35)
    _arrow(ax, (0.335, 0.26), (0.335, 0.41), color=GREY, ls="--")
    fig.savefig(path, dpi=220, bbox_inches="tight", facecolor="white"); plt.close(fig)


def agent_flow(path: Path):
    fig, ax = _canvas(9.0, 4.6)
    ax.text(0.5, 0.975, "LUỒNG TÁC TỬ LẬP KẾ HOẠCH CHIẾN DỊCH (LangGraph) VÀ HUMAN-IN-THE-LOOP", ha="center", va="top", fontsize=10, fontweight="bold", color=NAVY)
    _box(ax, 0.01, 0.55, 0.13, 0.22, "Đề xuất chiến dịch\n(CampaignRequest)\nQC/ngày · chiết\nkhấu · Mega · KM\ntập trung", fc=TINT["grey"], ec=GREY, fs=6.6)
    nodes = [("OBSERVE", "rag.search\nkho tri thức:\npháp lý · quy chế\n· đối soát sàn", TEAL), ("REASON", "campaign_model\n.predict →\nGMV/CM P10–P90,\nP(CM < 0)", GREEN),
             ("CHECK", "policy_check:\nchiết khấu ≤ 50%?\nNS > P95? CK ≥ 40%?\nCM âm? ngoại suy?", AMBER), ("ACT", "emit_plan\n(CampaignPlan –\npydantic) + lý do\n+ trích dẫn", RED)]
    for i, (t, d, col) in enumerate(nodes):
        x = 0.165 + i * 0.155
        _box(ax, x, 0.55, 0.13, 0.22, d, fc="#FFFFFF", ec=col, fs=6.3, lw=1.4)
        ax.text(x + 0.065, 0.80, t, ha="center", fontsize=7.6, fontweight="bold", color="white", bbox=dict(boxstyle="round,pad=0.3", fc=col, ec=col))
        _arrow(ax, (x - 0.025 if i else 0.14, 0.66), (x, 0.66))
    xa = 0.165 + 3 * 0.155 + 0.13
    outs = [("AUTO_APPROVED", "Ghi ERP/lịch chiến dịch", GREEN, 0.86), ("NEEDS_HUMAN_REVIEW", "Hàng đợi phê duyệt –\ndashboard trang 08", AMBER, 0.60), ("REJECTED", "Vi phạm pháp lý\n(chiết khấu > 50%)", RED, 0.36)]
    for t, d, col, y in outs:
        _box(ax, 0.81, y - 0.06, 0.18, 0.13, f"{t}\n{d}", fc=TINT["green"] if col == GREEN else TINT["amber"] if col == AMBER else TINT["red"], ec=col, fs=6.2, bold=False)
        _arrow(ax, (xa, 0.66), (0.81, y), color=col, rad=0.0)
    _box(ax, 0.17, 0.12, 0.47, 0.22, "Nhật ký kiểm toán (audit_log.jsonl): thời điểm · đề xuất · dự báo P10/P50/P90 · CM · trạng thái ·\nlý do · trích dẫn tài liệu · dấu vết công cụ (OBSERVE → REASON → CHECK → ACT)\n\n"
         "Người duyệt: Phê duyệt / Từ chối + ghi chú → outputs/08_genai/hitl_decisions.csv", fc=TINT["navy"], ec=NAVY, fs=6.5)
    _arrow(ax, (0.62, 0.55), (0.55, 0.34), color=NAVY, ls="--")
    _arrow(ax, (0.81, 0.54), (0.64, 0.30), color=AMBER, ls="--", rad=0.15)
    _box(ax, 0.67, 0.07, 0.32, 0.12, "LLM (tùy chọn, OPENAI_API_KEY) chỉ DIỄN GIẢI kế hoạch;\nkhông được thay đổi con số do công cụ tính", fc=TINT["grey"], ec=GREY, fs=6.3)
    fig.savefig(path, dpi=220, bbox_inches="tight", facecolor="white"); plt.close(fig)


def megasale_playbook(path: Path):
    fig, ax = _canvas(9.0, 4.4)
    ax.text(0.5, 0.975, "QUY TRÌNH RA QUYẾT ĐỊNH CHO MỘT ĐỢT MEGA SALE (ĐỀ XUẤT TỪ KẾT QUẢ NGHIÊN CỨU)", ha="center", va="top", fontsize=10, fontweight="bold", color=NAVY)
    phases = [("TRƯỚC SỰ KIỆN\n(T−30 → T−1)", TEAL, ["Chẩn đoán ROAS vs ROAS hòa vốn theo ngành", "Dự báo cầu SKU (toàn cục) + phân vị P10–P90",
                                                      "Đặt hàng theo q* = Cu/(Cu + Co)", "Tối ưu ngân sách QC (vùng dữ liệu)", "Mô phỏng tiền mặt: lead time × trễ đối soát",
                                                      "Tác tử kiểm tra: chiết khấu ≤ 50%, CM P50 > 0"]),
              ("TRONG SỰ KIỆN\n(ngày T)", AMBER, ["Theo dõi GMV so với khoảng P10–P90", "Cảnh báo khi vượt khoảng (khoảng sự kiện\nhẹp hơn thực tế – kiểm tra LOO)",
                                                 "Chặn tăng ngân sách ngoài vùng dữ liệu\nkhi chưa có người duyệt", "Ghi nhật ký mọi điều chỉnh"]),
              ("SAU SỰ KIỆN\n(T+1 → T+30)", GREEN, ["Đối soát dòng tiền thực tế với mô phỏng", "Đo biên đóng góp thực theo giá vốn thực",
                                                    "So sánh nhóm thử nghiệm/đối chứng (A/B)\nđể tách hiệu ứng sự kiện và chiết khấu", "Cập nhật dữ liệu → huấn luyện lại pipeline"])]
    for i, (t, col, items) in enumerate(phases):
        x = 0.02 + i * 0.33
        _box(ax, x, 0.80, 0.30, 0.09, t, fc=col, ec=col, fs=7.6, bold=True, color="white")
        for j, it in enumerate(items):
            _box(ax, x, 0.69 - j * 0.105, 0.30, 0.085, it, fc=TINT["teal"] if col == TEAL else TINT["amber"] if col == AMBER else TINT["green"], ec=col, fs=6.4)
        if i < 2:
            _arrow(ax, (x + 0.30, 0.845), (x + 0.33, 0.845), color=NAVY, lw=1.4)
    _arrow(ax, (0.83, 0.07), (0.17, 0.07), color=GREY, ls="--", rad=0.08)
    ax.text(0.5, 0.0, "Vòng học liên tục: dữ liệu sau sự kiện trở thành dữ liệu huấn luyện cho đợt kế tiếp", ha="center", fontsize=6.4, color=GREY, style="italic")
    fig.savefig(path, dpi=220, bbox_inches="tight", facecolor="white"); plt.close(fig)


def build_all(folder: Path) -> list[str]:
    folder.mkdir(parents=True, exist_ok=True)
    out = []
    for fn, f in [("d01_khung_nghien_cuu.png", research_framework), ("d02_quy_trinh_nghien_cuu.png", research_process),
                  ("d03_kien_truc_project.png", software_architecture), ("d04_luong_tac_tu.png", agent_flow), ("d05_quy_trinh_megasale.png", megasale_playbook)]:
        f(folder / fn); out.append(fn)
    return out
