"""Cấu hình, đường dẫn và tiện ích dùng chung cho toàn bộ pipeline Mega Sale (Stage 01–14).

Mọi stage đọc cấu hình từ config/default.yaml, ghi kết quả vào outputs/<stage>/ và hình vào outputs/<stage>/figures/.
Dashboard (app.py) và bộ dựng báo cáo chỉ đọc lại các tệp này – không tự tạo số liệu.
"""
from __future__ import annotations

import hashlib
import json
import os
import random
import time
from pathlib import Path

import numpy as np
import pandas as pd
import yaml
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import matplotlib.ticker  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
RAW_GV = DATA / "raw" / "gv"      # 12 bộ dữ liệu của giảng viên (dữ liệu mô phỏng – slide Ch1 tr.11)
RAW_GSO = DATA / "raw" / "gso"    # số liệu thật: TMBL Việt Nam (Cục Thống kê)
INTERIM = DATA / "interim"
OUT = ROOT / "outputs"
KB = ROOT / "knowledge_base"
for _p in (INTERIM, OUT):
    _p.mkdir(parents=True, exist_ok=True)


def load_config(path: Path | None = None) -> dict:
    p = path or ROOT / "config" / "default.yaml"
    with open(p, encoding="utf-8") as f:
        return yaml.safe_load(f)


CFG = load_config()
SEED = int(CFG.get("seed", 42))


def set_seed(seed: int = SEED) -> None:
    random.seed(seed)
    np.random.seed(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)


set_seed()

# ------------------------------------------------------------------ đồ họa (hình cho báo cáo)
PAL = ["#1B8A8F", "#E8A33D", "#12505F", "#D05A4E", "#3C8D5A", "#7FC4C4", "#2E4A7A", "#9AAEB2", "#B54708"]
GREY = "#9AAEB2"
INK = "#1F2D33"
from cycler import cycler  # noqa: E402
from matplotlib import font_manager  # noqa: E402

_FONTS = [f for f in ("Inter", "Segoe UI", "Arial", "DejaVu Sans") if any(f == x.name for x in font_manager.fontManager.ttflist)] or ["DejaVu Sans"]
plt.rcParams.update({
    # chữ: Inter (có đủ dấu tiếng Việt), dự phòng Segoe UI / Arial / DejaVu Sans
    "font.family": "sans-serif", "font.sans-serif": _FONTS + ["DejaVu Sans"], "font.size": 9,
    "text.color": INK, "axes.labelcolor": "#3B4C52", "xtick.color": "#5B6B70", "ytick.color": "#5B6B70",
    "xtick.labelsize": 8, "ytick.labelsize": 8, "axes.labelsize": 8.5,
    # tiêu đề
    "axes.titlesize": 10, "axes.titleweight": "semibold", "axes.titlelocation": "left", "axes.titlepad": 9,
    "figure.titlesize": 11.5, "figure.titleweight": "bold",
    # khung, lưới
    "axes.spines.top": False, "axes.spines.right": False, "axes.edgecolor": "#C9D3D6", "axes.linewidth": 0.8,
    "axes.grid": True, "axes.grid.axis": "y", "grid.color": "#E9EEF0", "grid.linewidth": 0.7, "axes.axisbelow": True,
    "xtick.major.size": 0, "ytick.major.size": 0, "xtick.major.pad": 4, "ytick.major.pad": 4,
    "axes.facecolor": "white", "figure.facecolor": "white", "savefig.facecolor": "white",
    # màu, nét
    "axes.prop_cycle": cycler(color=PAL), "lines.linewidth": 1.7, "lines.solid_capstyle": "round",
    "patch.edgecolor": "white", "patch.linewidth": 0.6,
    # chú giải, xuất ảnh
    "legend.frameon": False, "legend.fontsize": 7.6, "legend.handlelength": 1.6, "legend.borderaxespad": 0.3,
    "figure.dpi": 120, "savefig.dpi": 240, "savefig.bbox": "tight", "savefig.pad_inches": 0.12,
    "figure.constrained_layout.use": False,
})


def stage_dir(name: str) -> Path:
    d = OUT / name
    (d / "figures").mkdir(parents=True, exist_ok=True)
    return d


def _vn_tick(x, pos=None):
    if abs(x) >= 1000:
        return f"{x:,.0f}".replace(",", ".")
    s_ = f"{x:.10g}"
    if "e" in s_:
        return s_
    return s_.replace(".", ",")


def savefig(fig, stage: str, name: str) -> Path:
    p = stage_dir(stage) / "figures" / name
    for ax in fig.axes:                       # nhãn trục số kiểu Việt Nam (1.234,5) cho trục tuyến tính
        for axis in (ax.xaxis, ax.yaxis):
            if axis.get_scale() == "linear" and isinstance(axis.get_major_formatter(), matplotlib.ticker.ScalarFormatter):
                locs = np.asarray(axis.get_majorticklocs(), float)
                is_year = len(locs) > 0 and np.all((locs >= 1900) & (locs <= 2100)) and np.allclose(locs, np.round(locs))
                axis.set_major_formatter(matplotlib.ticker.FuncFormatter((lambda x, p=None: f"{x:.0f}") if is_year else _vn_tick))
    if not getattr(fig, "_keep_layout", False):
        fig.tight_layout()
    fig.savefig(p, bbox_inches="tight")
    plt.close(fig)
    return p


def _jsonable(o):
    if isinstance(o, dict):
        return {str(k) if not isinstance(k, (str, int, float, bool)) or k is None else k: _jsonable(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [_jsonable(v) for v in o]
    if isinstance(o, (np.integer,)):
        return int(o)
    if isinstance(o, (np.floating,)):
        v = float(o)
        return None if not np.isfinite(v) else v
    if isinstance(o, float):
        return None if not np.isfinite(o) else o
    if isinstance(o, np.ndarray):
        return _jsonable(o.tolist())
    if isinstance(o, (pd.Timestamp,)):
        return str(o.date()) if o == o.normalize() else str(o)
    if isinstance(o, (np.bool_,)):
        return bool(o)
    return o


def write_json(obj, stage: str, name: str) -> Path:
    p = stage_dir(stage) / name
    p.write_text(json.dumps(_jsonable(obj), ensure_ascii=False, indent=1, default=str), encoding="utf-8")
    return p


def read_json(stage: str, name: str, default=None):
    p = OUT / stage / name
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else default


def write_csv(df: pd.DataFrame, stage: str, name: str) -> Path:
    p = stage_dir(stage) / name
    df.to_csv(p, index=False, encoding="utf-8-sig")
    return p


def read_csv(stage: str, name: str, **kw) -> pd.DataFrame | None:
    p = OUT / stage / name
    return pd.read_csv(p, **kw) if p.exists() else None


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def vn(x, d: int = 2) -> str:
    """Định dạng số kiểu Việt Nam (1.234,56)."""
    if x is None or (isinstance(x, float) and not np.isfinite(x)):
        return "–"
    s = f"{x:,.{d}f}"
    return s.replace(",", "§").replace(".", ",").replace("§", ".")


class Timer:
    def __init__(self, label: str):
        self.label = label

    def __enter__(self):
        self.t0 = time.time()
        print(f"[{time.strftime('%H:%M:%S')}] ▶ {self.label}", flush=True)
        return self

    def __exit__(self, *a):
        print(f"[{time.strftime('%H:%M:%S')}] ✓ {self.label} ({time.time() - self.t0:.1f}s)", flush=True)


def log_run(stage: str, info: dict) -> None:
    write_json({"stage": stage, "finished": time.strftime("%Y-%m-%d %H:%M:%S"), "seed": SEED, **info}, stage, "run_info.json")
