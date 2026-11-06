"""Stage 08 – Tác tử AI hỗ trợ quyết định chiến dịch (slide Chương 5).

E8.1 Tái lập ví dụ RAG trên slide (4 tài liệu, TF-IDF + cosine, tr.22–26)
E8.2 RAG trên kho tri thức chiến dịch (pháp lý khuyến mại, đối soát sàn, bối cảnh thị trường, quy chế mẫu): P@1, MRR, ngưỡng từ chối
E8.3 Tác tử lập kế hoạch chiến dịch (ReAct + công cụ + kiểm tra chính sách + HITL) trên 12 đề xuất; nhật ký kiểm toán
E8.4 So sánh 'tác tử tối đa GMV' (không ràng buộc) với 'tác tử có công cụ và rào chắn' trên cùng lưới quyết định
E8.5 Đầu ra định chuẩn: chặn payload sai kiểu; phiếu khuyến nghị
"""
import json

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from src.common import CFG, KB, PAL, SEED, Timer, log_run, plt, savefig, stage_dir, write_csv, write_json
from src.data import io
from src.genai.agent import CampaignAgent, audit_record, validate_payloads
from src.genai.assistant import llm_explanation
from src.genai.rag import Retriever, load_kb
from src.scenarios.megasale import CampaignModel

ST = "08_genai"
RES = {}

with Timer("E8.1 Ví dụ RAG trên slide"):
    docs = [c.text.split(". ", 1)[1] for c in load_kb(KB) if c.doc_id.startswith("05_")]
    vr = TfidfVectorizer(); V = vr.fit_transform(docs)
    q = "Có sự cố đứt gãy cung ứng hay chậm trễ giao hàng nào liên quan đến linh kiện công nghệ không?"
    RES["E8_1"] = dict(scores=cosine_similarity(vr.transform([q]), V).ravel().round(4).tolist(), shape=list(V.shape), query=q)

with Timer("E8.2 RAG trên kho tri thức chiến dịch"):
    chunks = load_kb(KB)
    ids = [c.doc_id for c in chunks]
    queries = [("Mức giảm giá tối đa khi khuyến mại là bao nhiêu phần trăm?", "01_phap_ly_khuyen_mai#1"),
               ("Chương trình khuyến mại tập trung được giảm giá tới mức nào?", "01_phap_ly_khuyen_mai#2"),
               ("Giá trị quà tặng khuyến mại tối đa cho một đơn vị hàng?", "01_phap_ly_khuyen_mai#3"),
               ("Khi nào tiền đơn hàng được ghi nhận vào số dư người bán?", "02_chinh_sach_doi_soat_san#1"),
               ("Rút tiền về ngân hàng mất bao lâu?", "02_chinh_sach_doi_soat_san#2"),
               ("Quy mô thương mại điện tử Việt Nam năm 2024?", "03_boi_canh_thi_truong#1"),
               ("Doanh thu bốn sàn thương mại điện tử năm 2025 là bao nhiêu?", "03_boi_canh_thi_truong#2"),
               ("Dự báo doanh thu quý IV mùa 11.11 12.12?", "03_boi_canh_thi_truong#3"),
               ("Tổng mức bán lẻ năm 2025 tăng bao nhiêu?", "03_boi_canh_thi_truong#4"),
               ("Ngân sách quảng cáo ngày bao nhiêu thì cần trưởng phòng duyệt?", "04_quy_che_marketing_mau#1"),
               ("Chiết khấu 45% có cần giám đốc tài chính phê duyệt không?", "04_quy_che_marketing_mau#2"),
               ("Chiến dịch có biên đóng góp âm có được tự động duyệt không?", "04_quy_che_marketing_mau#3"),
               ("Cách tính ROAS hòa vốn của một ngành?", "04_quy_che_marketing_mau#4"),
               ("Đề xuất ngoài vùng dữ liệu lịch sử xử lý thế nào?", "04_quy_che_marketing_mau#5"),
               ("Cần dự trữ bao nhiêu tiền mặt trước Mega Sale?", "04_quy_che_marketing_mau#6"),
               ("Tàu hàng linh kiện có bị chậm trễ không?", "05_vi_du_slide_ch5#3")]
    ev = {}
    for name, kw in [("word", dict(analyzer="word")), ("char", dict(analyzer="char_wb", ngram=(2, 4)))]:
        r = Retriever(chunks, **kw)
        ranks = []
        for qq, gold in queries:
            order = np.argsort(-r.scores(qq))
            ranks.append(int(np.where(order == ids.index(gold))[0][0]) + 1)
        ev[name] = dict(P1=float(np.mean(np.array(ranks) == 1)), MRR=float(np.mean(1 / np.array(ranks))), ranks=ranks)
    retr = Retriever(chunks, analyzer="char_wb", ngram=(2, 4))
    tau = retr.calibrate([qq for qq, _ in queries], pct=5)
    ood = ["Giá vàng SJC hôm nay bao nhiêu?", "Thời tiết Hà Nội ngày mai thế nào?", "Lãi suất tiền gửi kỳ hạn 12 tháng?", "Tỷ số trận bóng đá tối qua?"]
    oods = [float(retr.scores(x).max()) for x in ood]
    RES["E8_2"] = dict(n_chunks=len(chunks), eval=ev, tau=tau, ood=[dict(q=x, score=s_, abstain=s_ < tau) for x, s_ in zip(ood, oods)],
                       in_domain_min=float(min(retr.scores(qq).max() for qq, _ in queries)))
    write_csv(pd.DataFrame([dict(doc_id=c.doc_id, title=c.title, source=c.source, text=c.text) for c in chunks]), ST, "knowledge_chunks.csv")

with Timer("E8.3 Tác tử lập kế hoạch chiến dịch"):
    d90 = io.ecommerce_90days(); u = io.unit_econ()
    cogs_ratio = float(u.COGS.sum() / u.GMV.sum())
    cmod = CampaignModel(d90, cogs_ratio, seed=SEED)
    p95 = float(np.quantile(d90.Ad_Spend, CFG["hitl"]["budget_quantile"]))
    agent = CampaignAgent(cmod, retr, p95)
    reqs = [dict(request_id="R01", campaign="Ngày thường – duy trì", ads_per_day=12.0, discount=0.15, mega_day=False),
            dict(request_id="R02", campaign="Ngày thường – tăng quảng cáo", ads_per_day=20.0, discount=0.15, mega_day=False),
            dict(request_id="R03", campaign="Mega Sale 9.9 – chiết khấu vừa", ads_per_day=15.0, discount=0.20, mega_day=True),
            dict(request_id="R04", campaign="Mega Sale 10.10 – chiết khấu 30%", ads_per_day=18.0, discount=0.30, mega_day=True),
            dict(request_id="R05", campaign="Mega Sale 11.11 – chiết khấu 40%", ads_per_day=25.0, discount=0.40, mega_day=True),
            dict(request_id="R06", campaign="Mega Sale 11.11 – chiết khấu 50%", ads_per_day=30.0, discount=0.50, mega_day=True),
            dict(request_id="R07", campaign="Mega Sale 12.12 – chiết khấu 60%", ads_per_day=30.0, discount=0.60, mega_day=True),
            dict(request_id="R08", campaign="Khuyến mại tập trung – 70%", ads_per_day=30.0, discount=0.70, mega_day=True, central_program=True),
            dict(request_id="R09", campaign="Mega Sale – ngân sách lớn", ads_per_day=40.0, discount=0.30, mega_day=True),
            dict(request_id="R10", campaign="Flash sale cuối tuần", ads_per_day=10.0, discount=0.25, mega_day=False),
            dict(request_id="R11", campaign="Payday 25 – chiết khấu 20%", ads_per_day=14.0, discount=0.20, mega_day=False),
            dict(request_id="R12", campaign="Mega Sale 9.9 – ngân sách thấp", ads_per_day=8.0, discount=0.20, mega_day=True)]
    outs = [agent.run(r) for r in reqs]
    plans = pd.DataFrame([o["plan"] for o in outs])
    plans["reasons"] = plans.reasons.apply("; ".join); plans["citations"] = plans.citations.apply(", ".join)
    expl = [llm_explanation(o["plan"]) for o in outs]
    plans["explanation"] = [e[0] for e in expl]; plans["explainer"] = [e[1] for e in expl]
    write_csv(plans, ST, "campaign_plans.csv")
    with open(stage_dir(ST) / "audit_log.jsonl", "w", encoding="utf-8") as f:
        for o in outs:
            f.write(json.dumps(audit_record(o), ensure_ascii=False) + "\n")
    RES["E8_3"] = dict(ads_p95=p95, engine=outs[0]["engine"], status_counts=plans.status.value_counts().to_dict(),
                       plans=plans.drop(columns=["explanation"]).to_dict("records"), trace_example=outs[5]["trace"])

with Timer("E8.4 Tác tử tối đa GMV vs tác tử có công cụ và rào chắn"):
    ads_grid = np.round(np.arange(6, 34, 2.0), 1); disc_grid = [0.1, 0.2, 0.3, 0.4, 0.5]
    rows = []
    for mega in [0, 1]:
        g = cmod.grid(ads_grid, disc_grid, mega=mega)
        g_in = g[~g.extrapolation]
        naive = g.sort_values("gmv_p50").iloc[-1]                                     # chỉ tối đa GMV
        feas = g_in[(g_in.disc <= CFG["marketing"]["legal_max_discount"]) & (g_in.p_cm_negative <= .2)]
        guarded = feas.sort_values("cm_p50").iloc[-1] if len(feas) else None
        cm_gmv = cmod.grid(ads_grid, disc_grid, mega=mega, cost_basis="gmv")
        naive_gmvbasis = cm_gmv.sort_values("gmv_p50").iloc[-1]
        if guarded is None:
            rows.append(dict(day="Mega Sale" if mega else "Ngày thường", agent="Tối đa biên đóng góp có rào chắn", ads=np.nan, disc=np.nan, gmv_p50=np.nan,
                             cm_p50=np.nan, cm_p10=np.nan, p_cm_negative=np.nan, cost_share=np.nan,
                             note=f"Không có phương án trong vùng dữ liệu đạt rào chắn ({len(g_in)} phương án trong vùng dữ liệu)"))
        for lab, r in [("Tối đa GMV (không rào chắn)", naive)] + ([("Tối đa biên đóng góp có rào chắn", guarded)] if guarded is not None else []):
            rows.append(dict(day="Mega Sale" if mega else "Ngày thường", agent=lab, ads=r.ads, disc=r.disc, gmv_p50=r.gmv_p50, cm_p50=r.cm_p50,
                             cm_p10=r.cm_p10, p_cm_negative=r.p_cm_negative, cost_share=r.cost_share))
        rows.append(dict(day="Mega Sale" if mega else "Ngày thường", agent="Tối đa GMV – nếu giá vốn tính trên GMV (lạc quan)", ads=naive_gmvbasis.ads,
                         disc=naive_gmvbasis.disc, gmv_p50=naive_gmvbasis.gmv_p50, cm_p50=naive_gmvbasis.cm_p50, cm_p10=naive_gmvbasis.cm_p10,
                         p_cm_negative=naive_gmvbasis.p_cm_negative, cost_share=naive_gmvbasis.cost_share))
    cmp_ = pd.DataFrame(rows)
    write_csv(cmp_, ST, "agent_comparison.csv")
    RES["E8_4"] = cmp_.to_dict("records")

with Timer("E8.5 Đầu ra định chuẩn"):
    bad = [dict(request_id="X1", campaign="Mega", ads_per_day=10, discount=0.3),
           dict(request_id="X2", campaign="Mega Sale", ads_per_day=-5, discount=0.3),
           dict(request_id="X3", campaign="Mega Sale", ads_per_day=10, discount=1.5),
           dict(request_id="X4", campaign="Mega Sale", ads_per_day="nhiều", discount=0.3)]
    RES["E8_5"] = dict(payload_checks=dict(zip([b["request_id"] for b in bad], validate_payloads(bad))))

fig, ax = plt.subplots(1, 2, figsize=(7.8, 2.9))
col = {"AUTO_APPROVED": PAL[4], "NEEDS_HUMAN_REVIEW": PAL[1], "REJECTED": PAL[3]}
ax[0].scatter(plans.discount * 100, plans.cm_p50, s=plans.ads_per_day * 4, c=[col[s_] for s_ in plans.status], alpha=.85)
_seen = {}
for r in plans.sort_values(["discount", "cm_p50"]).itertuples():
    k_ = (round(r.discount * 100), round(r.cm_p50 / 12))
    n_ = _seen.get(k_, 0); _seen[k_] = n_ + 1
    ax[0].annotate(r.request_id, (r.discount * 100, r.cm_p50), xytext=(6, -10 + 11 * n_ if n_ else 5), textcoords="offset points", fontsize=6.2, color="#3B4C52")
ax[0].axhline(0, color="k", lw=.6); ax[0].axvline(50, color=PAL[3], ls="--", lw=.8)
ax[0].set_xlabel("Chiết khấu (%)"); ax[0].set_ylabel("Biên đóng góp P50 (triệu VNĐ)"); ax[0].set_title("(a) 12 đề xuất – xanh: tự duyệt, cam: người duyệt, đỏ: từ chối")
m = cmp_[cmp_.day == "Mega Sale"]
m = cmp_[cmp_.day == "Ngày thường"].dropna(subset=["cm_p50"])
ax[1].barh(m.agent, m.cm_p50, color=[PAL[3], PAL[0], "#9AAEB2"][:len(m)])
ax[1].axvline(0, color="k", lw=.6)
ax[1].set_title("(b) Ngày thường: biên đóng góp P50 (triệu VNĐ)"); ax[1].tick_params(labelsize=6)
savefig(fig, ST, "s08_agent.png")

write_json(RES, ST, "results.json")
log_run(ST, dict(engine=RES["E8_3"]["engine"]))
print(RES["E8_1"]); print(RES["E8_2"]["eval"]["word"]["P1"], RES["E8_2"]["eval"]["char"]["P1"], RES["E8_2"]["eval"]["char"]["MRR"], RES["E8_2"]["tau"], RES["E8_2"]["ood"])
print(plans[["request_id", "ads_per_day", "discount", "gmv_p50", "cm_p50", "p_cm_negative", "extrapolation", "status", "reasons"]].round(2).to_string())
print(cmp_.round(2).to_string()); print(RES["E8_5"]); print(RES["E8_3"]["engine"])
