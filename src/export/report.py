"""Xuất báo cáo 1 trang (HTML) và mẫu ra quyết định chiến dịch (Excel) từ đầu ra pipeline."""
from __future__ import annotations

import io as _io
import json
from pathlib import Path

import pandas as pd


def _j(out: Path, rel: str) -> dict:
    p = out / rel
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}


def build_html(out: Path) -> str:
    s = _j(out, "09_summary/research_summary.json")
    kf = pd.read_csv(out / "09_summary/key_findings.csv") if (out / "09_summary/key_findings.csv").exists() else pd.DataFrame()
    plans = pd.read_csv(out / "08_genai/campaign_plans.csv") if (out / "08_genai/campaign_plans.csv").exists() else pd.DataFrame()
    rows = "".join(f"<tr><td>{r.RQ}</td><td>{r['Chỉ tiêu']}</td><td style='text-align:right'>{r['Giá trị']}</td></tr>" for _, r in kf.iterrows())
    prow = "".join(f"<tr><td>{r.request_id}</td><td>{r.campaign}</td><td>{r.ads_per_day:.1f}</td><td>{r.discount:.0%}</td><td>{r.gmv_p50:.1f}</td>"
                   f"<td>{r.cm_p50:.1f}</td><td>{r.status}</td></tr>" for _, r in plans.iterrows())
    return f"""<!doctype html><html lang="vi"><head><meta charset="utf-8"><title>Báo cáo 1 trang – Mega Sale</title>
<style>body{{font-family:Segoe UI,Arial,sans-serif;margin:28px;color:#0E2A33}}h1{{font-size:20px}}table{{border-collapse:collapse;width:100%;font-size:12px;margin:10px 0}}
td,th{{border:1px solid #DDE6E8;padding:4px 6px}}th{{background:#E3F2F2}}.note{{color:#5B6B70;font-size:11px}}</style></head><body>
<h1>Hiệu quả quảng cáo – khuyến mãi &amp; dự báo GMV mùa Mega Sale: tóm tắt kết quả</h1>
<p class="note">Dữ liệu doanh nghiệp là dữ liệu mô phỏng của học phần (slide Ch1 tr.11); số liệu vĩ mô từ Cục Thống kê. Mọi con số đọc từ outputs/.</p>
<h2>Phát hiện chính</h2><table><tr><th>RQ</th><th>Chỉ tiêu</th><th>Giá trị</th></tr>{rows}</table>
<h2>Kế hoạch chiến dịch do tác tử đề xuất</h2><table><tr><th>ID</th><th>Chiến dịch</th><th>QC/ngày (tr)</th><th>Chiết khấu</th><th>GMV P50</th><th>CM P50</th><th>Trạng thái</th></tr>{prow}</table>
<p class="note">Lợi nhuận/ngày sau tối ưu ngân sách (trong vùng dữ liệu): {s.get('RQ5', {}).get('profit_opt_in', float('nan')):.2f} triệu VNĐ so với hiện trạng {s.get('RQ5', {}).get('profit_now', float('nan')):.2f}.</p>
</body></html>"""


def build_decision_template(out: Path) -> bytes:
    plans = pd.read_csv(out / "08_genai/campaign_plans.csv")
    bud = pd.read_csv(out / "07_budget/policy_comparison.csv")
    tpl = plans[["request_id", "campaign", "ads_per_day", "discount", "gmv_p10", "gmv_p50", "gmv_p90", "cm_p50", "p_cm_negative", "status", "reasons"]].copy()
    tpl["Quyết định của người duyệt (DUYỆT/TỪ CHỐI/SỬA)"] = ""
    tpl["Ngân sách điều chỉnh"] = ""
    tpl["Chiết khấu điều chỉnh"] = ""
    tpl["Người duyệt"] = ""
    tpl["Ghi chú"] = ""
    buf = _io.BytesIO()
    with pd.ExcelWriter(buf, engine="openpyxl") as xw:
        pd.DataFrame({"Hướng dẫn": [
            "1. Mỗi dòng là một đề xuất chiến dịch đã qua tác tử (Stage 08).",
            "2. Cột status: AUTO_APPROVED / NEEDS_HUMAN_REVIEW / REJECTED; cột reasons nêu lý do.",
            "3. Người duyệt điền quyết định và điều chỉnh (nếu có); không sửa các cột dự báo.",
            "4. Chiết khấu > 50% chỉ hợp lệ với chương trình khuyến mại tập trung (NĐ 81/2018, sửa đổi bởi NĐ 128/2024).",
            "5. Dự báo là dự báo có điều kiện trên dữ liệu mô phỏng; kiểm chứng lại bằng dữ liệu thật của doanh nghiệp."]}).to_excel(xw, sheet_name="HUONG_DAN", index=False)
        tpl.to_excel(xw, sheet_name="DE_XUAT", index=False)
        bud.to_excel(xw, sheet_name="NGAN_SACH", index=False)
    return buf.getvalue()
