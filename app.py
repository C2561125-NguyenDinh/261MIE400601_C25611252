"""Mega Sale Marketing Intelligence — dashboard trình bày kết quả pipeline (Streamlit).

Dashboard đọc đầu ra thật của Stage 01–14 trong outputs/. Các trang mô phỏng (Mega Sale, ngân sách, dòng tiền, tác tử)
gọi lại đúng các mô hình trong src/ trên dữ liệu gốc – không tự đặt ra số liệu.
Chạy:  streamlit run app.py
"""
import json
from datetime import datetime

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
import streamlit as st

from src.common import CFG, KB, OUT, ROOT

st.set_page_config(page_title="Mega Sale Marketing Intelligence", page_icon="◈", layout="wide", initial_sidebar_state="expanded")

# =============================================================================== DESIGN SYSTEM
C = dict(navy="#0E2A33", ink="#0E2A33", muted="#5B6B70", blue="#1B8A8F", sky="#7FC4C4", green="#3C8D5A", amber="#E8A33D",
         red="#D05A4E", violet="#12505F", slate="#9AAEB2", teal="#2FA39A")
STATUS_COLOR = {"AUTO_APPROVED": C["green"], "NEEDS_HUMAN_REVIEW": C["amber"], "REJECTED": C["red"]}
STATUS_VN = {"AUTO_APPROVED": "Tự động duyệt", "NEEDS_HUMAN_REVIEW": "Cần người duyệt", "REJECTED": "Từ chối"}
pio.templates["mk"] = go.layout.Template(layout=go.Layout(
    font=dict(family="Be Vietnam Pro, Segoe UI, Arial", color="#2B3F45", size=13),
    colorway=[C["blue"], C["amber"], C["violet"], C["red"], C["green"], C["sky"], C["teal"], C["slate"]],
    paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
    xaxis=dict(showgrid=False, linecolor="#EAECF0", ticks="outside", tickcolor="#EAECF0"), yaxis=dict(gridcolor="#F2F4F7", zeroline=False),
    hoverlabel=dict(bgcolor="white", bordercolor="#E4E7EC", font=dict(color="#101828")),
    legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1, bgcolor="rgba(0,0,0,0)"),
    margin=dict(l=10, r=10, t=56, b=10), title=dict(font=dict(size=15, color="#101828"), x=0, xanchor="left")))
pio.templates.default = "plotly_white+mk"

st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap');
html,body,[class*="css"],.stMarkdown{font-family:"Be Vietnam Pro",ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif}
.stApp{background:radial-gradient(1200px 520px at 92% -12%,#FBE9CC 0%,rgba(251,233,204,0) 60%),#F4F8F8}
header[data-testid="stHeader"]{background:transparent}
.block-container{padding-top:2.4rem;padding-bottom:3rem;max-width:1520px}
[data-testid="stSidebar"]{background:linear-gradient(180deg,#0B2229 0%,#0E2A33 55%,#12505F 100%)}
[data-testid="stSidebar"] *{color:#E6EAF2}
[data-testid="stSidebar"] [role="radiogroup"] label{border-radius:10px;padding:7px 10px;margin:1px 0}
[data-testid="stSidebar"] [role="radiogroup"] label:hover{background:rgba(255,255,255,.07)}
.brand{font-weight:800;font-size:1.25rem;letter-spacing:.02em}.brand span{color:#E8A33D}
.hero{position:relative;overflow:hidden;background:linear-gradient(115deg,#0E2A33 0%,#12505F 58%,#1B8A8F 125%);border-radius:22px;padding:26px 30px;color:#fff;margin-bottom:16px;box-shadow:0 18px 40px rgba(15,23,42,.16)}
.hero:after{content:"";position:absolute;right:-60px;top:-80px;width:320px;height:320px;border-radius:50%;background:radial-gradient(circle,rgba(232,163,61,.35),rgba(232,163,61,0) 70%)}
.hero h1{font-size:1.85rem;margin:0 0 6px;font-weight:800;letter-spacing:-.03em;color:#fff}
.hero p{margin:0;color:#CFE8E8;font-size:.98rem}
.eyebrow{font-size:.72rem;text-transform:uppercase;letter-spacing:.14em;font-weight:700;color:#F2C27A;margin-bottom:6px}
.sec{margin:22px 0 8px}.sec-t{font-size:1.15rem;font-weight:750;color:#101828}.sec-s{color:#667085;font-size:.88rem;margin-top:2px}
.card{background:#fff;border:1px solid #E4E7EC;border-radius:16px;padding:16px 18px;box-shadow:0 2px 10px rgba(16,24,40,.04);height:100%}
.card h4{margin:0 0 6px;font-size:.98rem;color:#101828}.card p{color:#667085;margin:0;font-size:.88rem;line-height:1.45}
.insight{border-left:4px solid var(--tone,#1B8A8F)}
.kpi{min-height:112px;background:#fff;border:1px solid #E4E7EC;border-radius:16px;padding:14px 16px;box-shadow:0 2px 10px rgba(16,24,40,.04);position:relative;overflow:hidden}
.kpi:before{content:"";position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--tone,#1B8A8F)}
.kpi-l{color:#667085;font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em}
.kpi-v{font-size:1.5rem;font-weight:800;color:#101828;margin-top:2px;letter-spacing:-.03em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.kpi-n{font-size:.75rem;color:#98A2B3;margin-top:1px}
.pill{display:inline-block;padding:3px 10px;border-radius:999px;font-size:.72rem;font-weight:700;margin:2px 4px 2px 0;border:1px solid transparent}
.p-red{background:#FEF3F2;color:#B42318;border-color:#FECDCA}.p-amber{background:#FFFAEB;color:#B54708;border-color:#FEDF89}
.p-green{background:#ECFDF3;color:#027A48;border-color:#ABEFC6}.p-gray{background:#F2F4F7;color:#344054;border-color:#E4E7EC}
.steps{display:flex;flex-wrap:wrap;gap:8px}.step{background:#fff;border:1px solid #E4E7EC;border-radius:12px;padding:8px 12px;font-size:.82rem;font-weight:600;color:#344054}
.step b{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;background:#FBE9CC;color:#B54708;margin-right:6px;font-size:.72rem}
.dc{background:linear-gradient(135deg,#0E2A33 0%,#12505F 70%,#1B6F75 100%);color:#fff;border-radius:22px;padding:22px 24px;box-shadow:0 16px 36px rgba(15,23,42,.18)}
.dc .id{font-size:.75rem;color:#F2C27A;font-weight:700;letter-spacing:.12em}.dc h2{margin:4px 0 6px;font-size:1.35rem;color:#fff}
.dc .qty{font-size:2.0rem;font-weight:800;color:#fff;line-height:1.1}.dc .sub{color:#CFE8E8;font-size:.85rem}.dc p{color:#E6F4F4;font-size:.92rem;line-height:1.5;margin:10px 0 0}
.reason{background:#F8FAFC;border:1px dashed #D0D5DD;border-radius:12px;padding:8px 12px;margin-bottom:6px;font-size:.86rem;color:#344054}
.foot{color:#98A2B3;font-size:.76rem;margin-top:26px;text-align:center}
div[data-testid="stDataFrame"]{border:1px solid #E4E7EC;border-radius:14px;overflow:hidden;background:#fff}
.stTabs [data-baseweb="tab-list"]{gap:6px;background:#fff;padding:6px;border:1px solid #E4E7EC;border-radius:14px}
.stTabs [data-baseweb="tab"]{border-radius:10px;padding:8px 14px;font-weight:600}
.stTabs [aria-selected="true"]{background:#E3F2F2!important;color:#12505F!important}
.stButton>button,.stDownloadButton>button,.stFormSubmitButton>button{border-radius:11px;font-weight:650;min-height:42px}
</style>""", unsafe_allow_html=True)


# =============================================================================== HELPERS
@st.cache_data(show_spinner=False)
def _csv(p, mtime):
    return pd.read_csv(p)


def csv(rel):
    p = OUT / rel
    return _csv(str(p), p.stat().st_mtime) if p.exists() else None


def jsonf(rel, default=None):
    p = OUT / rel
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else (default or {})


def vn(x, d=0):
    if x is None or (isinstance(x, float) and not np.isfinite(x)) or pd.isna(x):
        return "—"
    return f"{float(x):,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".").replace("-", "−")


def vp(x, d=1):
    return "—" if x is None or pd.isna(x) else vn(100 * x, d) + "%"


def kpi(label, value, note="", tone=C["blue"]):
    st.markdown(f'<div class="kpi" style="--tone:{tone}"><div class="kpi-l">{label}</div><div class="kpi-v">{value}</div><div class="kpi-n">{note}</div></div>', unsafe_allow_html=True)


def sec(title, sub=""):
    st.markdown(f'<div class="sec"><div class="sec-t">{title}</div><div class="sec-s">{sub}</div></div>', unsafe_allow_html=True)


def card(title, body, tone=None):
    stl = f' style="--tone:{tone}"' if tone else ""
    st.markdown(f'<div class="card{" insight" if tone else ""}"{stl}><h4>{title}</h4><p>{body}</p></div>', unsafe_allow_html=True)


def pill(text, kind="gray"):
    return f'<span class="pill p-{kind}">{text}</span>'


def chart(fig, h=380):
    fig.update_layout(height=h)
    st.plotly_chart(fig, width="stretch", config={"displaylogo": False})


def empty():
    card("Chưa có kết quả pipeline", "Chạy <b>START_WINDOWS.bat</b> (hoặc lần lượt Stage 01 → 14) để tạo đầu ra. Dashboard chỉ hiển thị kết quả thật do pipeline tạo ra.")


def table(df, **kw):
    st.dataframe(df, hide_index=True, width="stretch", **kw)


@st.cache_resource(show_spinner=False)
def campaign_model():
    from src.data import io
    from src.scenarios.megasale import CampaignModel
    d = io.ecommerce_90days(); u = io.unit_econ()
    return CampaignModel(d, float(u.COGS.sum() / u.GMV.sum()), seed=42), d


@st.cache_resource(show_spinner=False)
def budget_model():
    from src.budget.allocate import fit_log_response
    from src.data import io
    p = io.panel(); u = io.unit_econ()
    return fit_log_response(p, u), p


@st.cache_resource(show_spinner=False)
def retriever():
    from src.genai.rag import Retriever, load_kb
    r = Retriever(load_kb(KB), analyzer="char_wb", ngram=(2, 4))
    r.tau = jsonf("08_genai/results.json").get("E8_2", {}).get("tau", 0.3)
    return r


S1, S2, S3 = jsonf("01_data/summary.json"), jsonf("02_marketing/results.json"), jsonf("03_decomposition/results.json")
S5, S6, S7, S8 = jsonf("05_models/results.json"), jsonf("06_probabilistic/results.json"), jsonf("07_budget/results.json"), jsonf("08_genai/results.json")
SUM = jsonf("09_summary/research_summary.json")

# =============================================================================== SIDEBAR
st.sidebar.markdown('<div class="brand">◈ MEGA SALE <span>MI</span></div>', unsafe_allow_html=True)
st.sidebar.caption("MARKETING INTELLIGENCE · QUẢNG CÁO · KHUYẾN MÃI · DÒNG TIỀN")
PAGES = ["Tổng quan điều hành", "01 · Dữ liệu & chẩn đoán", "02 · Hiệu quả quảng cáo & khuyến mãi", "03 · Chuỗi thời gian & mùa vụ",
         "04 · Mô hình toàn cục & uplift", "05 · Dự báo xác suất & rủi ro", "06 · Mô phỏng Mega Sale", "07 · Phân bổ ngân sách",
         "08 · Trung tâm quyết định AI", "09 · Dòng tiền chiến dịch", "10 · Kết quả nghiên cứu", "11 · Xuất báo cáo"]
page = st.sidebar.radio("KHÔNG GIAN PHÂN TÍCH", PAGES, label_visibility="collapsed")
st.sidebar.markdown("---")
st.sidebar.caption("Dữ liệu doanh nghiệp: bộ dữ liệu mô phỏng của học phần (slide Ch1 tr.11). Dữ liệu vĩ mô: Tổng mức bán lẻ – Cục Thống kê.")
st.sidebar.markdown(f"**Lớp GenAI**  \n{'🟢 LLM (OPENAI_API_KEY)' if CFG['genai'].get('enabled') else '🟡 Bộ máy quy tắc tất định'}")

HERO = {"Tổng quan điều hành": ("TỔNG QUAN", "Hiệu quả quảng cáo – khuyến mãi & dự báo GMV mùa Mega Sale",
                                "Chẩn đoán → phân rã → học máy toàn cục → dự báo xác suất → tác tử AI phân bổ ngân sách, có người phê duyệt."),
        "06 · Mô phỏng Mega Sale": ("MÔ PHỎNG", "Kịch bản Mega Sale: quảng cáo × chiết khấu → GMV & biên đóng góp", "Mô hình ước lượng trên 90 ngày; cảnh báo khi kịch bản nằm ngoài vùng dữ liệu."),
        "08 · Trung tâm quyết định AI": ("TRUNG TÂM QUYẾT ĐỊNH", "Tác tử lập kế hoạch chiến dịch · RAG · Human-in-the-loop",
                                         "Con số do công cụ tính; tác tử kiểm tra pháp lý & quy chế; người phê duyệt có ghi nhật ký.")}
eb, h1, sub = HERO.get(page, ("PHÂN TÍCH", page.split("·")[-1].strip(), "Kết quả đọc trực tiếp từ đầu ra của pipeline."))
st.markdown(f'<div class="hero"><div class="eyebrow">{eb}</div><h1>{h1}</h1><p>{sub}</p></div>', unsafe_allow_html=True)

# =============================================================================== 00
if page == "Tổng quan điều hành":
    if not SUM:
        empty()
    else:
        e1 = S2["E2_1"]; ue = {r["Category"]: r for r in S2["E2_4"]["by_cat"]}
        c = st.columns(6)
        with c[0]: kpi("GMV 90 ngày", vn(e1["totals"]["GMV"], 1) + " tr", f"{vn(e1['totals']['Orders'])} đơn", C["blue"])
        with c[1]: kpi("ROAS trung bình", vn(S2["E2_2"]["roas_avg"], 2), f"ROAS biên {vn(S2['E2_2']['roas_marginal'], 2)}", C["violet"])
        with c[2]: kpi("Tỷ trọng 2 ngày Mega", vp(e1["mega_share_gmv"]), "trong GMV 90 ngày", C["amber"])
        with c[3]: kpi("WAPE toàn cục (100 SKU)", vp(SUM["RQ3"]["global_wape"] / 100, 2), f"Holt-Winters {vp(SUM['RQ3']['hw_wape'] / 100, 2)}", C["teal"])
        with c[4]: kpi("Lợi nhuận q* / Oracle", vp(SUM["RQ4"]["nv_oracle_pct"] / 100), "chuẩn bị hàng Newsvendor", C["green"])
        with c[5]: kpi("Lợi nhuận/ngày sau tối ưu NS", vn(SUM["RQ5"]["profit_opt_in"], 1) + " tr", f"hiện trạng {vn(SUM['RQ5']['profit_now'], 1)} tr", C["red"])
        sec("Quy trình 14 bước", "Mỗi bước ghi đầu ra riêng trong outputs/ và có thể kiểm tra độc lập (Stage 10).")
        steps = [("01", "Kiểm tra dữ liệu"), ("02", "Chẩn đoán marketing"), ("03", "Phân rã & mùa vụ"), ("04", "Đặc trưng"), ("05", "Toàn cục & uplift"),
                 ("06", "Dự báo xác suất"), ("07", "Phân bổ ngân sách"), ("08", "Tác tử AI + RAG"), ("09", "Tổng hợp"), ("10", "Kiểm thử"),
                 ("11", "Chẩn đoán sai số"), ("12", "Case study"), ("13", "Độ nhạy"), ("14", "REPORT_READY")]
        st.markdown('<div class="steps">' + "".join(f'<div class="step"><b>{i}</b>{s}</div>' for i, s in steps) + "</div>", unsafe_allow_html=True)
        l, r = st.columns([1.2, 1])
        with l:
            sec("ROAS thực tế so với ROAS hòa vốn", "Ngành nằm dưới đường hòa vốn đang lỗ trên mỗi đơn dù doanh thu cao.")
            u = pd.DataFrame(S2["E2_4"]["by_cat"])
            fig = go.Figure([go.Bar(x=u.Category, y=u.ROAS, name="ROAS thực tế", marker_color=C["blue"], text=[vn(v, 2) for v in u.ROAS], textposition="outside"),
                             go.Bar(x=u.Category, y=u.ROAS_breakeven, name="ROAS hòa vốn", marker_color=C["amber"], text=[vn(v, 2) for v in u.ROAS_breakeven], textposition="outside")])
            fig.update_traces(cliponaxis=False); fig.update_layout(barmode="group")
            chart(fig, 360)
        with r:
            sec("Phát hiện chính", "Tính trực tiếp từ các tệp kết quả.")
            k1 = SUM["RQ1"]
            card("Quảng cáo bị thổi phồng khi bỏ qua chiết khấu", f"Hệ số quảng cáo lên số đơn giảm từ {vn(k1['ovb_ads_simple'], 2)} xuống {vn(k1['ovb_ads_full'], 2)} khi kiểm soát chiết khấu (thiên lệch {vn(k1['ovb_bias_pct'], 1)}%).", C["red"])
            st.write("")
            card("FMCG bán nhiều nhưng lỗ", f"ROAS {vn(k1['fmcg_roas'], 2)} thấp hơn ROAS hòa vốn {vn(k1['fmcg_roas_be'], 2)}; lỗ lũy kế {vn(k1['fmcg_total'], 2)} triệu VNĐ.", C["amber"])
            st.write("")
            k3 = SUM["RQ3"]
            card("'Ngày đôi' – hiệu ứng giả", f"So sánh thô cho ngày đôi cao hơn {vp(k3['double_day_naive_rel'] - 1)} so với trung bình tuần; sau kiểm soát thứ trong tuần chỉ còn {vp(k3['double_day_fe_pct'], 2)} (p = {vn(k3['double_day_fe_p'], 3)}).", C["violet"])
        kf = csv("09_summary/key_findings.csv")
        if kf is not None:
            sec("Bảng phát hiện theo câu hỏi nghiên cứu")
            table(kf)

# =============================================================================== 01
elif page == "01 · Dữ liệu & chẩn đoán":
    inv, qc, dirty, gc = csv("01_data/data_inventory.csv"), csv("01_data/quality_checks.csv"), csv("01_data/dirty_cleaning.csv"), csv("01_data/gso_check.csv")
    if inv is None:
        empty()
    else:
        c = st.columns(4)
        with c[0]: kpi("Bộ dữ liệu GV", vn(len(inv)), f"{vn(inv.rows.sum())} dòng", C["blue"])
        with c[1]: kpi("Tháng số liệu TMBL", vn(S1["gso"]["n_months"]), f"{S1['gso']['start'][:7]} → {S1['gso']['end'][:7]}", C["violet"])
        with c[2]: kpi("Lệch tổng tháng – năm", vp(S1["gso"]["max_abs_gap_pct"] / 100, 2), "lớn nhất 2020–2025", C["amber"])
        with c[3]: kpi("TB GMV bẩn → sạch", f"{vn(S1['dirty']['mean_raw'], 2)} → {vn(S1['dirty']['mean_clean'], 2)}", "triệu VNĐ/ngày", C["green"])
        t1, t2, t3 = st.tabs(["Danh mục dữ liệu", "Làm sạch dữ liệu bẩn", "Đối chiếu Cục Thống kê"])
        with t1:
            table(inv); sec("Kiểm tra chất lượng"); table(qc)
        with t2:
            fig = go.Figure()
            fig.add_trace(go.Scatter(x=dirty.Date, y=dirty.GMV_raw, name="GMV gốc", mode="lines+markers", line=dict(color=C["slate"])))
            fig.add_trace(go.Scatter(x=dirty.Date, y=dirty.GMV_clean, name="Sau làm sạch", mode="lines+markers", line=dict(color=C["blue"], width=3)))
            fig.add_hrect(y0=S1["dirty"]["lower"], y1=S1["dirty"]["upper"], fillcolor=C["sky"], opacity=.15, line_width=0)
            chart(fig, 360); table(dirty)
        with t3:
            table(gc)
            g = pd.read_csv(ROOT / "data/raw/gso/tmbl_monthly_2019_12_2026_09.csv")
            chart(px.line(g, x="ym", y="value", markers=True, title="Tổng mức bán lẻ hàng hóa & doanh thu dịch vụ tiêu dùng (nghìn tỷ đồng/tháng)"), 360)

# =============================================================================== 02
elif page == "02 · Hiệu quả quảng cáo & khuyến mãi":
    if not S2:
        empty()
    else:
        cm, d = campaign_model()
        t1, t2, t3, t4 = st.tabs(["EDA 90 ngày", "Thiên lệch bỏ sót biến", "Panel 3 ngành", "Unit Economics"])
        with t1:
            fig = go.Figure()
            fig.add_trace(go.Scatter(x=d.Date, y=d.GMV, name="GMV", line=dict(color=C["slate"])))
            fig.add_trace(go.Scatter(x=d.Date, y=d.GMV.rolling(7).mean(), name="SMA 7", line=dict(color=C["blue"], width=3)))
            m = d[d.Mega == 1]
            fig.add_trace(go.Scatter(x=m.Date, y=m.GMV, mode="markers", name="Mega Sale", marker=dict(color=C["red"], size=12)))
            chart(fig, 340)
            l, r = st.columns(2)
            with l:
                chart(px.scatter(d, x="Ad_Spend", y="Orders", color="Discount", color_continuous_scale="Viridis", title="Quảng cáo – đơn hàng (màu = chiết khấu)"), 340)
            with r:
                table(csv("02_marketing/eda_descriptive.csv").round(3))
                win = csv("02_marketing/mega_window.csv")
                chart(px.line(win, x="k", y="rel", color="mega_day", markers=True, title="GMV quanh ngày Mega Sale / TB ngày thường"), 280)
        with t2:
            o = S2["E2_2"]["ovb"]
            c = st.columns(4)
            with c[0]: kpi("β Ads – chỉ Ads", vn(o["m1"]["b_ads"], 3), f"R² {vn(o['m1']['r2'], 3)}")
            with c[1]: kpi("β Ads – có Discount", vn(o["m2"]["b_ads"], 3), f"R² {vn(o['m2']['r2'], 3)}", C["green"])
            with c[2]: kpi("Độ co giãn log-log", vn(o["m3"]["elast_ads"], 3), "đơn theo quảng cáo", C["violet"])
            with c[3]: kpi("Breusch–Pagan p", vn(o["bp_p"], 5), "phương sai thay đổi", C["amber"])
            ct = csv("02_marketing/orders_contribution.csv")
            fig = go.Figure()
            for k, col, lab in [("base", C["slate"], "Nền"), ("ads", C["blue"], "Quảng cáo"), ("discount", C["amber"], "Chiết khấu")]:
                fig.add_trace(go.Bar(x=ct.Date, y=ct[k], name=lab, marker_color=col))
            fig.add_trace(go.Scatter(x=ct.Date, y=ct.Orders, name="Thực tế", line=dict(color=C["ink"])))
            fig.update_layout(barmode="relative", title="Phân rã số đơn theo mô hình Orders ~ Ads + Discount")
            chart(fig, 380)
        with t3:
            pm = S2["E2_3"]["models"]
            c = st.columns(3)
            with c[0]: kpi("β gộp (pooled)", vn(pm["pooled"]["b"], 3), f"R² {vn(pm['pooled']['r2'], 3)}", C["red"])
            with c[1]: kpi("β hiệu ứng cố định", vn(pm["fe"]["b"], 3), f"R² {vn(pm['fe']['r2'], 3)}", C["green"])
            with c[2]: kpi("Kiểm định khác biệt độ dốc", "p " + vn(pm["F_heterog_p"], 6), "F-test", C["violet"])
            p = budget_model()[1]
            chart(px.scatter(p, x="Ad_Spend", y="Orders", color="Category", trendline="ols", title="Đơn theo quảng cáo, từng ngành"), 380)
            l, r = st.columns(2)
            with l: table(csv("02_marketing/panel_by_category.csv").round(3))
            with r: table(csv("02_marketing/aggregation_fallacy.csv").round(4))
        with t4:
            table(csv("02_marketing/unit_economics.csv").round(4))
            table(csv("02_marketing/marginal_ad_profit.csv").round(4))
            s = csv("02_marketing/unit_econ_sensitivity.csv")
            cat = st.selectbox("Ngành", s.Category.unique())
            pv = s[s.Category == cat].pivot(index="dAOV", columns="dCOGS", values="CM")
            chart(px.imshow(pv, text_auto=".4f", color_continuous_scale="RdYlGn", aspect="auto", title=f"CM/đơn – {cat} (triệu VNĐ)"), 340)

# =============================================================================== 03
elif page == "03 · Chuỗi thời gian & mùa vụ":
    if not S3:
        empty()
    else:
        t1, t2, t3, t4 = st.tabs(["MSTL & hiệu ứng marketing", "GMV 48 tháng", "Biên lợi nhuận", "Tổng mức bán lẻ Việt Nam"])
        with t1:
            comp = csv("03_decomposition/mstl_components.csv")
            fig = go.Figure()
            for k, col in [("Y", C["slate"]), ("T", C["blue"]), ("S365", C["green"]), ("S7", C["amber"])]:
                fig.add_trace(go.Scatter(x=comp.date, y=comp[k], name=k, line=dict(color=col, width=1.2)))
            chart(fig, 360)
            e = S3["E3_2"]
            c = st.columns(4)
            with c[0]: kpi("r(chi marketing, phần dư)", vn(e["corr_resid"], 3), "MSTL", C["violet"])
            with c[1]: kpi("Độ trễ 0–14: p chung", vn(e["dl_joint_p"], 3), "F-test HAC", C["amber"])
            with c[2]: kpi("Prophet MAE", vn(e["prophet_cv"]["base"]["mae"], 3), "không biến marketing", C["blue"])
            with c[3]: kpi("Prophet + marketing", vn(e["prophet_cv"]["mkt"]["mae"], 3), "MAE", C["red"])
            l, r = st.columns(2)
            with l: chart(px.bar(csv("03_decomposition/adstock_scan.csv"), x="decay", y="beta", error_y=1.96 * csv("03_decomposition/adstock_scan.csv").se, title="β adstock theo λ"), 300)
            with r: table(pd.DataFrame(e["power_check"]).round(4))
        with t2:
            m = csv("03_decomposition/m48_decomposition.csv")
            chart(px.line(m, x="Month", y=["GMV", "GMV_deseason", "T_hp"], title="GMV thô, khử mùa vụ và xu hướng HP"), 340)
            chart(px.bar(m, x="Month", y=["mom_raw", "mom_core"], barmode="group", title="Tăng trưởng tháng thô vs lõi"), 300)
            table(csv("03_decomposition/m48_stl_sensitivity.csv").round(3))
        with t3:
            st.image(str(OUT / "03_decomposition/figures/s03_margin.png"))
        with t4:
            g = csv("03_decomposition/gso_decomposition.csv")
            chart(px.line(g, x="ds", y=["value", "T_hp"], title="TMBL và xu hướng lõi (nghìn tỷ đồng)"), 320)
            g["month"] = pd.to_datetime(g.ds).dt.month; g["year"] = pd.to_datetime(g.ds).dt.year
            chart(px.line(g[g.month.isin([1, 11, 12])], x="year", y="S_mul", color="month", markers=True, title="Độ trôi hệ số mùa vụ tháng 1, 11, 12"), 300)
            table(csv("03_decomposition/gso_q4_share.csv").round(4))

# =============================================================================== 04
elif page == "04 · Mô hình toàn cục & uplift":
    if not S5:
        empty()
    else:
        from src.models.train import MODEL_LABEL
        t1, t2, t3, t4 = st.tabs(["Toàn cục vs cục bộ", "Uplift khuyến mãi", "Sản phẩm mới", "Ngày đôi"])
        with t1:
            s = csv("05_models/global_vs_local_100_summary.csv"); s["Mô hình"] = s.model.map(MODEL_LABEL)
            fig = px.bar(s.sort_values("WAPE"), x="WAPE", y="Mô hình", orientation="h", text=s.sort_values("WAPE").WAPE.round(3), title="WAPE (%) – 100 SKU, 3 gốc, H = 14")
            fig.update_layout(yaxis=dict(autorange="reversed")); chart(fig, 340)
            dm = S5["E5_3"]["dm_global_vs_hw"]
            st.markdown(pill(f"DM gộp điểm: t = {vn(dm['pooled']['t'], 2)}, p = {vn(dm['pooled']['p'], 3)}") + pill(f"DM gộp chéo (HAC): t = {vn(dm['aggregated']['t'], 2)}, p = {vn(dm['aggregated']['p'], 5)}", "amber"), unsafe_allow_html=True)
            l, r = st.columns(2)
            with l: table(csv("05_models/global_vs_local_100_bycat.csv").pivot(index="cat", columns="model", values="WAPE").round(3).reset_index())
            with r: table(csv("05_models/feature_importance_100.csv").round(4))
            sec("15 SKU", "Bộ dữ liệu nhỏ – mô hình cục bộ cạnh tranh hơn.")
            table(pd.DataFrame(S5["E5_4"]["summary"]).round(3))
        with t2:
            u = csv("05_models/promo_uplift_by_product.csv")
            fig = go.Figure()
            for k, col, lab in [("promo_obs", C["slate"], "Quan sát"), ("promo_S", C["blue"], "S-learner toàn cục"), ("promo_T", C["amber"], "T-learner cục bộ")]:
                fig.add_trace(go.Bar(x=u["product"], y=u[k], name=lab, marker_color=col))
            fig.add_hline(y=u.promo_pooled_naive.iloc[0], line_dash="dash", line_color=C["red"], annotation_text="uplift gộp")
            chart(fig, 340); table(u.round(3))
            l, r = st.columns(2)
            with l: table(pd.DataFrame(S5["E5_2"]["walk_forward"]).round(3))
            with r: table(pd.DataFrame(S5["E5_2"]["kfold_shuffled"]).round(3))
        with t3:
            cs = pd.DataFrame(S5["E5_5"]["results"]).T.reset_index().rename(columns={"index": "Phương án"})
            chart(px.bar(cs, x="Phương án", y="WAPE", text=cs.WAPE.round(2), title="10 SKU mới (giữ lại khỏi huấn luyện)"), 320)
            e = S5["E5_1"]
            card("Sản phẩm mới có khuyến mãi", f"Mô hình trên số thô dự báo {vn(e['pred_new_raw'], 1)} đơn vị cho sản phẩm có baseline 500; mô hình uplift chuẩn hóa dự báo {vn(e['pred_new_scaled'], 1)}.", C["amber"])
        with t4:
            e = S5["E5_6"]
            c = st.columns(3)
            with c[0]: kpi("So sánh thô", vp(e["naive_rel"]["1"] - 1), f"p = {e['naive_p']:.1e}", C["red"])
            with c[1]: kpi("Sau kiểm soát thứ", vp(e["fe"]["dd"]["pct"], 2), f"p = {vn(e['fe']['dd']['p'], 3)}", C["green"])
            with c[2]: kpi("Ngày đôi rơi vào cuối tuần", vp(e["weekend_share_double"]), "5 ngày đôi", C["violet"])
            table(pd.DataFrame(e["double_dates"]))

# =============================================================================== 05
elif page == "05 · Dự báo xác suất & rủi ro":
    if not S6:
        empty()
    else:
        t1, t2, t3, t4 = st.tabs(["Đánh giá phân vị", "Fan chart SKU", "Chuẩn bị hàng (Newsvendor)", "Rủi ro quảng cáo"])
        with t1:
            s = csv("06_probabilistic/prob_eval_summary.csv")
            c = st.columns(len(s))
            for i, r in enumerate(s.itertuples()):
                with c[i]: kpi(r.model, vn(r.mean_pinball, 3), f"phủ 80%: {vp(r.cov80)}", [C["green"], C["blue"], C["violet"], C["amber"], C["red"]][i % 5])
            cal = csv("06_probabilistic/calibration.csv")
            fig = go.Figure([go.Scatter(x=cal.q, y=cal[m], name=m, mode="lines+markers") for m in cal.columns if m != "q"])
            fig.add_trace(go.Scatter(x=[0, 1], y=[0, 1], name="Lý tưởng", line=dict(dash="dash", color="black")))
            chart(fig, 340)
            cone = csv("06_probabilistic/uncertainty_cone.csv")
            chart(px.line(cone, x="h", y="rel_w", color="model", markers=True, title="Phễu bất định (P90 − P10)/m28"), 300)
        with t2:
            q = csv("06_probabilistic/quantile_forecasts_last_origin.csv")
            sid = st.selectbox("SKU", sorted(q.sid.unique()), index=sorted(q.sid.unique()).index("TECH_PHONE_003") if "TECH_PHONE_003" in set(q.sid) else 0)
            m = st.radio("Mô hình", [c.split("_P")[0] for c in q.columns if c.endswith("_P50")], horizontal=True)
            g = q[q.sid == sid].sort_values("h")
            fig = go.Figure()
            fig.add_trace(go.Scatter(x=g.date, y=g[f"{m}_P90"], line=dict(width=0), showlegend=False))
            fig.add_trace(go.Scatter(x=g.date, y=g[f"{m}_P10"], fill="tonexty", fillcolor="rgba(27,138,143,.18)", line=dict(width=0), name="P10–P90"))
            fig.add_trace(go.Scatter(x=g.date, y=g[f"{m}_P50"], name="P50", line=dict(color=C["blue"], width=3)))
            fig.add_trace(go.Scatter(x=g.date, y=g.y, name="Thực tế", line=dict(color=C["ink"], dash="dot")))
            chart(fig, 380)
        with t3:
            nv = csv("06_probabilistic/newsvendor_policies.csv")
            cat = st.selectbox("Phạm vi", nv.cat.unique())
            x = nv[nv.cat == cat].sort_values("profit", ascending=False)
            chart(px.bar(x, x="profit_pct_oracle", y="policy", orientation="h", text=x.profit_pct_oracle.round(2), title="Lợi nhuận (% Oracle)"), 360)
            table(x.round(2))
            table(csv("06_probabilistic/reorder_point.csv").round(3))
        with t4:
            table(csv("06_probabilistic/ad_risk_category.csv").round(4))
            table(csv("06_probabilistic/ad_risk_shop.csv").round(4))

# =============================================================================== 06
elif page == "06 · Mô phỏng Mega Sale":
    cm, d = campaign_model()
    l, r = st.columns([1, 2])
    with l:
        ads = st.slider("Quảng cáo/ngày (triệu VNĐ)", 2.0, 45.0, 20.0, 0.5)
        disc = st.slider("Chiết khấu", 0.0, 0.7, 0.3, 0.05)
        mega = st.toggle("Ngày Mega Sale (sự kiện sàn)", True)
        basis = st.radio("Giả định giá vốn", ["list", "gmv"], format_func=lambda x: "Theo giá niêm yết (thận trọng)" if x == "list" else "Tỷ lệ cố định theo GMV (lạc quan)")
        fee = st.slider("Phí sàn (% GMV)", 0.0, 0.2, 0.0, 0.01)
    pr = cm.predict(ads, disc, int(mega), platform_fee=fee, cost_basis=basis)
    with r:
        c = st.columns(4)
        with c[0]: kpi("Đơn P50", vn(pr["orders_p50"]), f"P10–P90: {vn(pr['orders_p10'])}–{vn(pr['orders_p90'])}")
        with c[1]: kpi("GMV P50", vn(pr["gmv_p50"], 1) + " tr", f"{vn(pr['gmv_p10'], 1)}–{vn(pr['gmv_p90'], 1)}", C["violet"])
        with c[2]: kpi("Biên đóng góp P50", vn(pr["cm_p50"], 1) + " tr", f"P(âm) = {vp(pr['p_cm_negative'])}", C["green"] if pr["cm_p50"] > 0 else C["red"])
        with c[3]: kpi("Giá vốn/GMV", vp(pr["cost_share"]), "theo giả định đã chọn", C["amber"])
        if pr["extrapolation"]:
            st.warning("Kịch bản nằm ngoài vùng dữ liệu (quảng cáo/chiết khấu chưa từng quan sát, hoặc Mega Sale với chiết khấu khác 50%). Dự báo chỉ mang tính tham khảo.")
        if disc > CFG["marketing"]["legal_max_discount"]:
            st.error("Chiết khấu vượt 50% – vượt mức tối đa theo NĐ 81/2018 (sửa đổi bởi NĐ 128/2024), trừ chương trình khuyến mại tập trung.")
        g = cm.grid([5, 10, 15, 20, 25, 30, 35, 40], [0.1, 0.2, 0.3, 0.4, 0.5], mega=int(mega), platform_fee=fee, cost_basis=basis)
        pv = g.pivot(index="ads", columns="disc", values="cm_p50")
        chart(px.imshow(pv, text_auto=".1f", color_continuous_scale="RdYlGn", aspect="auto", title="Biên đóng góp P50 (triệu VNĐ) theo quảng cáo × chiết khấu"), 380)
    sec("Kiểm tra bỏ-một-ngày trên 2 ngày Mega Sale", "Khoảng 80% của mô hình có phủ được GMV thực tế không?")
    table(csv("06_probabilistic/megasale_loo.csv").round(2))

# =============================================================================== 07
elif page == "07 · Phân bổ ngân sách":
    from src.budget.allocate import evaluate, optimize_allocation
    resp, p = budget_model()
    cats = list(resp); R = [resp[c] for c in cats]
    B0 = float(p.groupby("Category").Ad_Spend.mean().sum())
    l, r = st.columns([1, 2])
    with l:
        lev = st.slider("Ngân sách/ngày (% hiện tại)", 50, 150, 100, 5)
        w2 = st.slider("Trọng số chi phí w2 (w1 = 1)", 0.0, 1.5, 1.0, 0.05)
        ms = st.slider("Tỷ trọng tối thiểu mỗi ngành", 0.0, 0.3, CFG["budget"]["min_share"], 0.01)
        within = st.toggle("Chỉ trong vùng dữ liệu đã quan sát", True)
    B = B0 * lev / 100
    a = optimize_allocation(R, B, 1.0, w2, ms, within_data=within)
    with r:
        if np.isnan(a).any():
            st.warning("Không có phân bổ khả thi trong vùng dữ liệu với mức ngân sách này – bỏ chọn 'trong vùng dữ liệu' hoặc đổi ngân sách.")
        else:
            ev = evaluate(a, R); cur = p.groupby("Category").Ad_Spend.mean().reindex(cats).values; ec = evaluate(cur, R)
            c = st.columns(3)
            with c[0]: kpi("Ngân sách/ngày", vn(B, 2) + " tr", f"hiện tại {vn(B0, 2)} tr")
            with c[1]: kpi("Lợi nhuận gộp sau QC", vn(ev["profit"], 2) + " tr", f"hiện trạng {vn(ec['profit'], 2)} tr", C["green"])
            with c[2]: kpi("GMV/ngày", vn(ev["gmv"], 1) + " tr", f"hiện trạng {vn(ec['gmv'], 1)} tr", C["violet"])
            df = pd.DataFrame({"Ngành": cats, "Hiện trạng": cur, "Đề xuất": a})
            chart(px.bar(df.melt("Ngành", var_name="Phương án", value_name="Quảng cáo/ngày"), x="Ngành", y="Quảng cáo/ngày", color="Phương án", barmode="group"), 340)
    sec("Kết quả pipeline (Stage 07)")
    table(csv("07_budget/policy_comparison.csv").round(3)); table(csv("07_budget/budget_levels.csv").round(3)); table(csv("07_budget/bootstrap_policy_profit.csv").round(2))

# =============================================================================== 08
elif page == "08 · Trung tâm quyết định AI":
    plans = csv("08_genai/campaign_plans.csv")
    if plans is None:
        empty()
    else:
        c = st.columns(3)
        for i, sname in enumerate(["AUTO_APPROVED", "NEEDS_HUMAN_REVIEW", "REJECTED"]):
            with c[i]: kpi(STATUS_VN[sname], vn((plans.status == sname).sum()), "đề xuất", STATUS_COLOR[sname])
        t1, t2, t3, t4 = st.tabs(["Hàng đợi phê duyệt", "Gửi đề xuất mới", "Hỏi kho tri thức (RAG)", "Nhật ký kiểm toán"])
        with t1:
            rid = st.selectbox("Đề xuất", plans.request_id, format_func=lambda x: f"{x} – {plans.set_index('request_id').loc[x, 'campaign']}")
            pr = plans.set_index("request_id").loc[rid]
            l, r = st.columns([1.2, 1])
            with l:
                st.markdown(f'<div class="dc"><div class="id">{rid} · {STATUS_VN[pr.status].upper()}</div><h2>{pr.campaign}</h2>'
                            f'<div class="qty">{vn(pr.cm_p50, 1)} tr</div><div class="sub">biên đóng góp P50 · GMV P50 {vn(pr.gmv_p50, 1)} tr '
                            f'(P10–P90 {vn(pr.gmv_p10, 1)}–{vn(pr.gmv_p90, 1)})</div><p>{pr.explanation}</p></div>', unsafe_allow_html=True)
            with r:
                for reason in str(pr.reasons).split("; "):
                    st.markdown(f'<div class="reason">• {reason}</div>', unsafe_allow_html=True)
                st.caption("Căn cứ: " + str(pr.citations))
                if pr.status == "NEEDS_HUMAN_REVIEW":
                    note = st.text_input("Ghi chú của người duyệt", key=f"n_{rid}")
                    b1, b2 = st.columns(2)
                    dec = None
                    if b1.button("✅ Phê duyệt", key=f"a_{rid}"): dec = "APPROVED_BY_HUMAN"
                    if b2.button("⛔ Từ chối", key=f"r_{rid}"): dec = "REJECTED_BY_HUMAN"
                    if dec:
                        f = OUT / "08_genai" / "hitl_decisions.csv"
                        row = pd.DataFrame([dict(timestamp=datetime.now().isoformat(timespec="seconds"), request_id=rid, decision=dec, note=note)])
                        row.to_csv(f, mode="a", header=not f.exists(), index=False, encoding="utf-8-sig")
                        st.success(f"Đã ghi {dec} vào outputs/08_genai/hitl_decisions.csv")
            table(plans[["request_id", "campaign", "ads_per_day", "discount", "gmv_p50", "cm_p50", "p_cm_negative", "extrapolation", "status"]].round(3))
        with t2:
            from src.genai.agent import CampaignAgent
            from src.genai.assistant import rule_explanation
            cm, d = campaign_model()
            with st.form("req"):
                camp = st.text_input("Tên chiến dịch", "Mega Sale 12.12 – thử nghiệm")
                a1, a2, a3 = st.columns(3)
                ads = a1.number_input("Quảng cáo/ngày (triệu VNĐ)", 0.0, 100.0, 18.0, 0.5)
                disc = a2.number_input("Chiết khấu (0–1)", 0.0, 1.0, 0.5, 0.05)
                mega = a3.checkbox("Ngày Mega Sale", True)
                central = st.checkbox("Thuộc chương trình khuyến mại tập trung", False)
                go_ = st.form_submit_button("Chạy tác tử")
            if go_:
                ag = CampaignAgent(cm, retriever(), float(np.quantile(d.Ad_Spend, CFG["hitl"]["budget_quantile"])))
                out = ag.run(dict(request_id="NEW", campaign=camp, ads_per_day=ads, discount=disc, mega_day=mega, central_program=central))
                p_ = out["plan"]
                st.markdown(pill(STATUS_VN[p_["status"]], {"AUTO_APPROVED": "green", "NEEDS_HUMAN_REVIEW": "amber", "REJECTED": "red"}[p_["status"]]), unsafe_allow_html=True)
                st.write(rule_explanation(p_))
                st.json(out["trace"])
        with t3:
            qq = st.text_input("Câu hỏi", "Mức giảm giá tối đa khi khuyến mại là bao nhiêu?")
            rt = retriever()
            if qq:
                sc = float(rt.scores(qq).max())
                if sc < rt.tau:
                    st.warning(f"Điểm tương đồng {vn(sc, 3)} < ngưỡng {vn(rt.tau, 3)} – tác tử từ chối trả lời (thiếu căn cứ trong kho tri thức).")
                for ch, s in rt.search(qq, 3):
                    card(f"{ch.doc_id} · {vn(s, 3)}", f"<b>{ch.title}</b><br>{ch.text}<br><i>{ch.source}</i>")
                    st.write("")
        with t4:
            p = OUT / "08_genai" / "audit_log.jsonl"
            if p.exists():
                st.dataframe(pd.json_normalize([json.loads(z) for z in open(p, encoding="utf-8")]), width="stretch")
            h = csv("08_genai/hitl_decisions.csv")
            if h is not None:
                sec("Quyết định của người duyệt"); table(h)

# =============================================================================== 09
elif page == "09 · Dòng tiền chiến dịch":
    from src.cashflow.sim import simulate
    cm, d = campaign_model()
    l, r = st.columns([1, 2])
    with l:
        lag = st.slider("Độ trễ đối soát (ngày)", 0, 21, 10)
        lead = st.slider("Lead time nhập hàng (ngày)", 0, 45, 30)
        fee = st.slider("Phí sàn", 0.0, 0.2, 0.0, 0.01)
        card("Căn cứ độ trễ", "Tiền đơn hàng được ghi nhận khi người mua xác nhận hoặc sau 4 ngày kể từ khi giao thành công; rút tiền mất thêm 24 giờ – 4 ngày làm việc (MISA eShop).")
    s = simulate(d.set_index("Date")[["GMV", "Ad_Spend"]], cm.cogs_ratio, lag, lead, fee)
    with r:
        c = st.columns(3)
        with c[0]: kpi("Tiền mặt tối thiểu", vn(s["cash_need"], 1) + " tr", f"đáy ngày {s['date_min']}", C["red"])
        with c[1]: kpi("Tiền lũy kế cuối kỳ", vn(s["end"], 1) + " tr", "sau 90 ngày", C["green"])
        with c[2]: kpi("Giá vốn/GMV", vp(cm.cogs_ratio), "từ unit economics", C["amber"])
        ser = s["series"].reset_index(); ser.columns = ["Ngày", "Tiền lũy kế"]
        fig = px.area(ser, x="Ngày", y="Tiền lũy kế"); fig.add_hline(y=0, line_color="black")
        chart(fig, 360)
    table(csv("12_cases/c3_cash_grid.csv").round(2)); table(csv("12_cases/c3_mega_increment.csv").round(2))

# =============================================================================== 10
elif page == "10 · Kết quả nghiên cứu":
    if not SUM:
        empty()
    else:
        st.json(SUM, expanded=False)
        sm = csv("10_smoke/smoke_test.csv")
        if sm is not None:
            sec("Kiểm thử pipeline", f"{int(sm.passed.sum())}/{len(sm)} kiểm tra đạt"); table(sm)
        t1, t2 = st.tabs(["Chẩn đoán sai số", "Độ nhạy"])
        with t1:
            for k in ["h", "dow", "cat", "double_day"]:
                x = csv(f"11_diagnostics/wape_by_{k}.csv")
                if x is not None: table(x.round(3))
        with t2:
            for f in ["s1_cost_basis", "s2_min_share", "s3_hitl_thresholds", "s4_hyperparams", "s5_margin_allocation"]:
                x = csv(f"13_sensitivity/{f}.csv")
                if x is not None:
                    sec(f); table(x.round(4))

# =============================================================================== 11
elif page == "11 · Xuất báo cáo":
    xl = ROOT / "REPORT_READY" / "tables_all.xlsx"
    if xl.exists():
        st.download_button("📦 Tải toàn bộ bảng kết quả (Excel)", xl.read_bytes(), "MegaSale_tables_all.xlsx")
    from src.export.report import build_html, build_decision_template
    st.download_button("📄 Tải báo cáo 1 trang (HTML)", build_html(OUT).encode("utf-8"), "MegaSale_bao_cao_1_trang.html", mime="text/html")
    st.download_button("📝 Tải mẫu ra quyết định chiến dịch (Excel)", build_decision_template(OUT), "MegaSale_mau_quyet_dinh.xlsx")
    sec("Hình cho báo cáo (REPORT_READY/figures)")
    figs = sorted((ROOT / "REPORT_READY" / "figures").glob("*.png"))
    cols = st.columns(3)
    for i, f in enumerate(figs):
        with cols[i % 3]:
            st.image(str(f), caption=f.name)

st.markdown('<div class="foot">Mega Sale Marketing Intelligence · Học phần Các mô hình dự báo trong kinh doanh (MIE4006) · Dữ liệu doanh nghiệp là dữ liệu mô phỏng của học phần; số liệu vĩ mô từ Cục Thống kê.</div>', unsafe_allow_html=True)
