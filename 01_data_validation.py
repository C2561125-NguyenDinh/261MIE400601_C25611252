"""Stage 01 – Kiểm tra dữ liệu đầu vào (slide Ch1: chẩn đoán dữ liệu, dữ liệu khuyết, ngoại lai).

Đầu ra outputs/01_data/: data_inventory.csv, quality_checks.csv, dirty_cleaning.csv, gso_check.csv, summary.json, sha256.json
"""
import numpy as np
import pandas as pd

from src.common import RAW_GSO, RAW_GV, PAL, GREY, Timer, log_run, savefig, sha256, write_csv, write_json, plt
from src.data import io

ST = "01_data"

with Timer("Kiểm tra 12 bộ dữ liệu của giảng viên"):
    inv, qc = [], []
    for key, (fn, slide, desc) in io.GV_FILES.items():
        d = pd.read_csv(RAW_GV / fn)
        inv.append(dict(key=key, file=fn, rows=len(d), cols=d.shape[1], slide=slide, description=desc, sha256=sha256(RAW_GV / fn)))
        date_col = next((c for c in ("Date", "date", "ds", "OrderDate", "report_month") if c in d.columns), None)
        id_col = next((c for c in ("SKU", "Product_ID", "unique_id", "Category") if c in d.columns), None)
        num = d.select_dtypes("number")
        row = dict(key=key, missing_cells=int(d.isna().sum().sum()), duplicate_rows=int(d.duplicated().sum()),
                   negative_values=int((num < 0).sum().sum()), zero_values=int((num == 0).sum().sum()))
        if date_col and key != "fin100":
            ds = pd.to_datetime(d[date_col])
            row.update(start=str(ds.min().date()), end=str(ds.max().date()))
            keys = [date_col] + ([id_col] if id_col else [])
            row["duplicate_keys"] = int(d.duplicated(keys).sum())
            if id_col:
                per = d.groupby(id_col)[date_col].nunique()
                span = (ds.max() - ds.min()).days + 1 if key != "margin" else None
                row["n_series"] = int(per.size)
                row["min_dates_per_series"] = int(per.min())
                if span:
                    row["expected_dates"] = span
                    row["missing_dates_total"] = int(span * per.size - per.sum())
            else:
                row["n_series"] = 1
        qc.append(row)
    inv, qc = pd.DataFrame(inv), pd.DataFrame(qc)
    write_csv(inv, ST, "data_inventory.csv")
    write_csv(qc, ST, "quality_checks.csv")

with Timer("Làm sạch dữ liệu bẩn theo quy trình slide (khuyết → nội suy, IQR, phân loại lỗi/sự kiện)"):
    dd = io.gv("dirty").sort_values("Date").reset_index(drop=True)
    s = dd.GMV.copy()
    s[(s == 0)] = np.nan                                       # 0 do lỗi hệ thống = khuyết, không phải cầu bằng 0
    interp = s.interpolate("linear")
    q1, q3 = interp.quantile(.25), interp.quantile(.75)
    iqr = q3 - q1
    lo, hi = q1 - 1.5 * iqr, q3 + 1.5 * iqr
    med = interp.median(); mad = (interp - med).abs().median()
    rz = 0.6745 * (interp - med) / mad
    is_event = dd.Note.str.contains("Flash Sale|Sự kiện", case=False, regex=True)
    out_flag = (interp < lo) | (interp > hi)
    err = out_flag & ~is_event
    clean = interp.copy()
    clean[err] = np.nan
    clean = clean.interpolate("linear")
    dirty = pd.DataFrame(dict(Date=dd.Date.dt.date, GMV_raw=dd.GMV, Note=dd.Note, after_interp=interp.round(4), robust_z=rz.round(3),
                              iqr_outlier=out_flag, treated_as_error=err, event_kept=out_flag & is_event, GMV_clean=clean.round(4)))
    write_csv(dirty, ST, "dirty_cleaning.csv")
    dirty_info = dict(Q1=q1, Q3=q3, IQR=iqr, lower=lo, upper=hi, median=med, MAD=mad,
                      mean_raw=float(dd.GMV.mean()), mean_clean=float(clean.mean()),
                      errors=[str(x) for x in dirty.Date[err]], events=[str(x) for x in dirty.Date[out_flag & is_event]])
    fig, ax = plt.subplots(figsize=(7.6, 2.8))
    ax.plot(dirty.Date, dd.GMV, color=GREY, marker="o", ms=3, lw=1, label="GMV gốc (0 = lỗi hệ thống)")
    ax.plot(dirty.Date, clean, color=PAL[0], marker="o", ms=3, label="Sau làm sạch")
    ax.axhspan(lo, hi, color=PAL[5], alpha=.15, label="Hàng rào Tukey")
    for x, v in zip(dirty.Date[out_flag & is_event], interp[out_flag & is_event]):
        ax.annotate("Flash Sale (giữ)", (x, v), xytext=(-78, 2), textcoords="offset points", fontsize=7, color=PAL[1], fontweight="semibold")
    ax.set_title("GMV 20 ngày (triệu VNĐ): khuyết → nội suy; ngoại lai lỗi → thay; sự kiện → giữ và gắn cờ")
    ax.legend(fontsize=6.5); ax.tick_params(axis="x", labelrotation=45, labelsize=6.5)
    savefig(fig, ST, "s01_dirty_cleaning.png")

with Timer("Đối chiếu số liệu Cục Thống kê"):
    g = io.gso_monthly()
    a = io.gso_annual()
    g["year"] = g.ds.dt.year
    chk = g.groupby("year").value.agg(["sum", "count"]).reset_index().merge(a[["year", "value"]], on="year", how="inner")
    chk["gap_pct"] = (chk["sum"] / chk["value"] - 1) * 100
    chk = chk[chk["count"] == 12].reset_index(drop=True)                 # chỉ đối chiếu năm đủ 12 tháng (2019 chỉ có tháng 12)
    write_csv(chk, ST, "gso_check.csv")
    gso_info = dict(n_months=len(g), start=str(g.ds.min().date()), end=str(g.ds.max().date()),
                    derived=g[g.source_type.astype(str).str.startswith("suy")][["ym", "value"]].to_dict("records"),
                    max_abs_gap_pct=float(chk.gap_pct.abs().max()))

hashes = {f.name: sha256(f) for f in sorted(RAW_GV.glob("*.csv")) + sorted(RAW_GSO.glob("*.csv"))}
write_json(hashes, ST, "sha256.json")
summary = dict(n_gv_files=len(inv), gv_rows_total=int(inv.rows.sum()), dirty=dirty_info, gso=gso_info,
               quality=qc.to_dict("records"), note="Dữ liệu GV là dữ liệu mô phỏng; số liệu Cục Thống kê là ước tính lần đầu theo tháng.")
write_json(summary, ST, "summary.json")
log_run(ST, dict(n_files=len(hashes)))
print(qc.to_string())
