"""RAG tối giản: chia kho tri thức Markdown thành đoạn theo tiêu đề '##', truy xuất TF-IDF + cosine (slide Ch5 tr.21–26),
có ngưỡng từ chối khi ngữ cảnh không đủ liên quan."""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


@dataclass
class Chunk:
    doc_id: str
    source: str
    title: str
    text: str


def load_kb(folder: Path) -> list[Chunk]:
    chunks = []
    for f in sorted(folder.glob("*.md")):
        txt = f.read_text(encoding="utf-8")
        head = re.search(r"^# (.+)$", txt, re.M)
        src = re.findall(r"https?://\S+", txt)
        parts = re.split(r"^## ", txt, flags=re.M)
        for i, part in enumerate(parts[1:], 1):
            title, _, body = part.partition("\n")
            body = " ".join(body.split())
            chunks.append(Chunk(doc_id=f"{f.stem}#{i}", source=src[0] if src else f.name, title=f"{head.group(1) if head else f.stem} – {title.strip()}",
                                text=f"{title.strip()}. {body}"))
    return chunks


class Retriever:
    def __init__(self, chunks: list[Chunk], analyzer: str = "char_wb", ngram=(2, 4)):
        self.chunks = chunks
        kw = dict(analyzer=analyzer, ngram_range=ngram) if analyzer != "word" else {}
        self.vec = TfidfVectorizer(**kw)
        self.M = self.vec.fit_transform([c.text for c in chunks])
        self.tau = 0.0

    def scores(self, q: str) -> np.ndarray:
        return cosine_similarity(self.vec.transform([q]), self.M).ravel()

    def search(self, q: str, k: int = 3) -> list[tuple[Chunk, float]]:
        s = self.scores(q)
        idx = np.argsort(-s)[:k]
        return [(self.chunks[i], float(s[i])) for i in idx]

    def calibrate(self, in_domain_queries: list[str], pct: float = 5) -> float:
        self.tau = float(np.percentile([self.scores(q).max() for q in in_domain_queries], pct))
        return self.tau

    def answerable(self, q: str) -> bool:
        return float(self.scores(q).max()) >= self.tau
