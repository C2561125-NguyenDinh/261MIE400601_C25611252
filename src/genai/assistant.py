"""Lớp diễn giải (tùy chọn) bằng mô hình ngôn ngữ. Mặc định tắt: dùng bộ máy quy tắc tạo phiếu khuyến nghị.
Muốn bật: đặt OPENAI_API_KEY và genai.enabled: true trong config/default.yaml. LLM chỉ được diễn giải kế hoạch đã duyệt bởi
công cụ – không được thay đổi con số (nguyên tắc 'glass-box' của slide Ch5)."""
from __future__ import annotations

import os

from src.common import CFG


def rule_explanation(plan: dict) -> str:
    st = {"AUTO_APPROVED": "được tự động phê duyệt", "NEEDS_HUMAN_REVIEW": "cần người phê duyệt", "REJECTED": "bị từ chối"}[plan["status"]]
    return (f"Đề xuất {plan['request_id']} ({plan['campaign']}): quảng cáo {plan['ads_per_day']:.1f} triệu VNĐ/ngày, chiết khấu {plan['discount']:.0%}. "
            f"GMV dự báo P10–P50–P90 = {plan['gmv_p10']:.1f} – {plan['gmv_p50']:.1f} – {plan['gmv_p90']:.1f} triệu VNĐ; biên đóng góp P50 = {plan['cm_p50']:.1f} triệu VNĐ, "
            f"xác suất biên âm {plan['p_cm_negative']:.0%}. Kế hoạch {st}. Lý do: " + "; ".join(plan["reasons"]) + ". Căn cứ: " + ", ".join(plan["citations"]) + ".")


def llm_explanation(plan: dict) -> tuple[str, str]:
    if not (CFG["genai"].get("enabled") and os.getenv("OPENAI_API_KEY")):
        return rule_explanation(plan), "rule"
    try:
        from openai import OpenAI
        client = OpenAI()
        msg = ("Bạn là trợ lý phân tích marketing. Diễn giải ngắn gọn bằng tiếng Việt kế hoạch sau cho Giám đốc Marketing. "
               "Không được thay đổi hay bịa thêm số liệu; chỉ dùng số trong JSON.\n" + str(plan))
        r = client.chat.completions.create(model=CFG["genai"]["model"], messages=[{"role": "user", "content": msg}])
        return r.choices[0].message.content, "llm"
    except Exception as ex:  # noqa: BLE001
        return rule_explanation(plan) + f" (LLM lỗi: {ex.__class__.__name__})", "rule"
