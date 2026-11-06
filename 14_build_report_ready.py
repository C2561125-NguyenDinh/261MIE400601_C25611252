"""Stage 14 – Gom hình và bảng cho báo cáo: REPORT_READY/figures/*.png, REPORT_READY/tables/*.csv và REPORT_READY/tables_all.xlsx."""
import shutil

import pandas as pd

from src.common import OUT, ROOT, Timer, log_run, write_json

RR = ROOT / "REPORT_READY"
(RR / "figures").mkdir(parents=True, exist_ok=True); (RR / "tables").mkdir(parents=True, exist_ok=True)
with Timer("Vẽ sơ đồ khung nghiên cứu, quy trình, kiến trúc, luồng tác tử"):
    from src.export.diagrams import build_all
    diags = build_all(OUT / "14_report_ready" / "figures")
with Timer("Gom hình và bảng"):
    figs, tabs = [], []
    for st in sorted(p for p in OUT.iterdir() if p.is_dir()):
        for f in sorted((st / "figures").glob("*.png")) if (st / "figures").exists() else []:
            shutil.copy2(f, RR / "figures" / f.name); figs.append(f"{st.name}/{f.name}")
        for f in sorted(st.glob("*.csv")):
            name = f"{st.name}__{f.name}"
            shutil.copy2(f, RR / "tables" / name); tabs.append(name)
    with pd.ExcelWriter(RR / "tables_all.xlsx", engine="openpyxl") as xw:
        idx = []
        for i, name in enumerate(tabs, 1):
            df = pd.read_csv(RR / "tables" / name)
            sheet = f"T{i:02d}"
            df.head(5000).to_excel(xw, sheet_name=sheet, index=False)
            idx.append(dict(sheet=sheet, table=name, rows=len(df)))
        pd.DataFrame(idx).to_excel(xw, sheet_name="INDEX", index=False)
    write_json(dict(figures=figs, tables=tabs), "14_report_ready", "manifest.json")
log_run("14_report_ready", dict(n_figures=len(figs), n_tables=len(tabs)))
print(len(figs), "hình;", len(tabs), "bảng")
