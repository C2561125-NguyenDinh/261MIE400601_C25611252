"""Tác tử lập kế hoạch chiến dịch (ReAct: Quan sát – Suy luận – Hành động, slide Ch5 tr.6–16) với công cụ tất định,
đầu ra định chuẩn (pydantic, tr.41–52), đồ thị trạng thái (LangGraph nếu có, tr.53–58), hàm ngắt rủi ro HITL và nhật ký kiểm toán (tr.59–63).

Lớp 'suy luận' được hiện thực bằng quy tắc + công cụ tính toán để có thể kiểm tra và tái lập; LLM (tùy chọn) chỉ dùng để diễn giải.
"""
from __future__ import annotations

import json
import time
from typing import Literal, Optional, TypedDict

import numpy as np
from pydantic import BaseModel, Field, ValidationError

from src.common import CFG


class CampaignRequest(BaseModel):
    request_id: str
    campaign: str = Field(min_length=3)
    ads_per_day: float = Field(ge=0)
    discount: float = Field(ge=0, le=1)
    mega_day: bool = True
    central_program: bool = False          # chương trình khuyến mại tập trung (được phép giảm tới 100%)
    note: str = ""


class CampaignPlan(BaseModel):
    request_id: str
    campaign: str
    ads_per_day: float = Field(ge=0)
    discount: float = Field(ge=0, le=1)
    gmv_p10: float
    gmv_p50: float
    gmv_p90: float
    cm_p50: float
    p_cm_negative: float = Field(ge=0, le=1)
    extrapolation: bool
    status: Literal["AUTO_APPROVED", "NEEDS_HUMAN_REVIEW", "REJECTED"]
    reasons: list[str]
    citations: list[str]


class AgentState(TypedDict, total=False):
    request: dict
    context: list
    sim: dict
    checks: dict
    plan: Optional[dict]
    trace: list


class CampaignAgent:
    def __init__(self, campaign_model, retriever, ads_hist_p95: float):
        self.cm = campaign_model
        self.rag = retriever
        self.ads_p95 = float(ads_hist_p95)
        self.legal = CFG["marketing"]["legal_max_discount"]
        self.legal_central = CFG["marketing"]["legal_max_discount_central"]
        self.disc_review = CFG["hitl"]["discount_review"]

    # ----- các nút của đồ thị -----
    def observe(self, s: AgentState) -> AgentState:
        r = s["request"]
        q = f"giảm giá {int(r['discount'] * 100)}% khuyến mại mức giảm giá tối đa ngân sách quảng cáo phê duyệt biên đóng góp"
        ctx = [dict(doc_id=c.doc_id, score=sc, title=c.title) for c, sc in self.rag.search(q, k=3)]
        return {**s, "context": ctx, "trace": s.get("trace", []) + [dict(step="OBSERVE", tool="rag.search", out=[c["doc_id"] for c in ctx])]}

    def simulate(self, s: AgentState) -> AgentState:
        r = s["request"]
        sim = self.cm.predict(r["ads_per_day"], r["discount"], int(r["mega_day"]))
        return {**s, "sim": sim, "trace": s["trace"] + [dict(step="REASON", tool="campaign_model.predict",
                                                               out=dict(gmv_p50=round(sim["gmv_p50"], 2), cm_p50=round(sim["cm_p50"], 2), p_cm_negative=round(sim["p_cm_negative"], 3)))]}

    def check(self, s: AgentState) -> AgentState:
        r, sim = s["request"], s["sim"]
        cap = self.legal_central if r.get("central_program") else self.legal
        ck = dict(legal_ok=r["discount"] <= cap + 1e-12, legal_cap=cap, discount_review=r["discount"] >= self.disc_review,
                  budget_review=r["ads_per_day"] > self.ads_p95, cm_negative=sim["cm_p50"] < 0,
                  cm_risk=sim["p_cm_negative"] > 0.2, extrapolation=sim["extrapolation"])
        return {**s, "checks": ck, "trace": s["trace"] + [dict(step="REASON", tool="policy_check", out=ck)]}

    def decide(self, s: AgentState) -> AgentState:
        r, sim, ck = s["request"], s["sim"], s["checks"]
        reasons = []
        if not ck["legal_ok"]:
            status = "REJECTED"; reasons.append(f"Chiết khấu {r['discount']:.0%} vượt mức tối đa {ck['legal_cap']:.0%} (NĐ 81/2018, sửa đổi bởi NĐ 128/2024)")
        else:
            flags = [("discount_review", f"Chiết khấu ≥ {self.disc_review:.0%} cần Giám đốc Tài chính duyệt"),
                     ("budget_review", f"Ngân sách {r['ads_per_day']:.1f} triệu/ngày vượt P95 lịch sử ({self.ads_p95:.1f})"),
                     ("cm_negative", "Biên đóng góp kỳ vọng (P50) âm"), ("cm_risk", "Xác suất biên đóng góp âm > 20%"),
                     ("extrapolation", "Đề xuất nằm ngoài vùng dữ liệu lịch sử (ngoại suy)")]
            reasons = [msg for k, msg in flags if ck[k]]
            status = "NEEDS_HUMAN_REVIEW" if reasons else "AUTO_APPROVED"
            if not reasons:
                reasons = ["Mọi kiểm tra đạt: hợp pháp, trong vùng dữ liệu, biên đóng góp dương"]
        plan = CampaignPlan(request_id=r["request_id"], campaign=r["campaign"], ads_per_day=r["ads_per_day"], discount=r["discount"],
                            gmv_p10=sim["gmv_p10"], gmv_p50=sim["gmv_p50"], gmv_p90=sim["gmv_p90"], cm_p50=sim["cm_p50"],
                            p_cm_negative=sim["p_cm_negative"], extrapolation=sim["extrapolation"], status=status, reasons=reasons,
                            citations=[c["doc_id"] for c in s["context"]])
        return {**s, "plan": plan.model_dump(), "trace": s["trace"] + [dict(step="ACT", tool="emit_plan", out=dict(status=status))]}

    # ----- chạy -----
    def build_graph(self):
        try:
            from langgraph.graph import END, StateGraph
        except Exception:  # noqa: BLE001
            return None
        g = StateGraph(AgentState)
        for name, fn in [("observe", self.observe), ("simulate", self.simulate), ("check", self.check), ("decide", self.decide)]:
            g.add_node(name, fn)
        g.set_entry_point("observe")
        g.add_edge("observe", "simulate"); g.add_edge("simulate", "check"); g.add_edge("check", "decide"); g.add_edge("decide", END)
        return g.compile()

    def run(self, req: dict) -> dict:
        CampaignRequest(**req)                                # kiểm tra đầu vào
        graph = self.build_graph()
        s0: AgentState = {"request": req, "trace": []}
        if graph is not None:
            out = graph.invoke(s0)
            out["engine"] = "langgraph"
        else:
            out = self.decide(self.check(self.simulate(self.observe(s0))))
            out["engine"] = "sequential"
        return out


def audit_record(out: dict) -> dict:
    p = out["plan"]
    return dict(timestamp=time.strftime("%Y-%m-%dT%H:%M:%S"), request_id=p["request_id"], campaign=p["campaign"],
                proposal=dict(ads_per_day=p["ads_per_day"], discount=p["discount"]),
                forecast=dict(gmv_p10=round(p["gmv_p10"], 3), gmv_p50=round(p["gmv_p50"], 3), gmv_p90=round(p["gmv_p90"], 3), cm_p50=round(p["cm_p50"], 3),
                              p_cm_negative=round(p["p_cm_negative"], 4)),
                status=p["status"], reasons=p["reasons"], citations=p["citations"], engine=out.get("engine"),
                trace=[t["tool"] for t in out["trace"]])


def validate_payloads(payloads: list[dict]) -> list[str]:
    res = []
    for pl in payloads:
        try:
            CampaignRequest(**pl); res.append("hợp lệ")
        except ValidationError as ex:
            res.append(f"bị chặn ({ex.errors()[0]['type']})")
    return res
