"""Dựng báo cáo .docx theo template Favorita (Report.docx): giữ styles, header/footer, khổ giấy, lề; thay toàn bộ nội dung.
Nội dung viết bằng markup nhẹ trong report/content/*.tm; bảng số liệu sinh tự động từ out/*.json qua tables.py."""
import re, sys, copy, json
from pathlib import Path
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))
import tables as TB

TPL = HERE / "template.docx"
doc = Document(TPL)
body = doc.element.body
sect = body[-1]
# Giữ nguyên trang bìa của template (13 đoạn đầu: tiêu đề trường, loại luận văn, tên đề tài, học viên, nơi – năm)
for el in list(body)[:-1]:
    body.remove(el)

# ---------- styles cho chú thích hình/bảng (để lập Danh mục bằng TOC \t) ----------
def mkstyle(name):
    st = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH); st.base_style = doc.styles["Normal"]
    st.font.name = "Times New Roman"; st.font.size = Pt(12); st.font.italic = False
    pf = st.paragraph_format; pf.alignment = WD_ALIGN_PARAGRAPH.CENTER; pf.first_line_indent = Cm(0); pf.space_before = Pt(4); pf.space_after = Pt(8)
    pf.line_spacing = 1.15
    return st
for nm in ["Chu thich Hinh", "Chu thich Bang"]:
    if nm not in [s.name for s in doc.styles]: mkstyle(nm)

def add_par(text="", style=None, align=None, bold=False, italic=False, size=None, first_indent=None, space_after=None, keep_next=False, line=None):
    p = doc.add_paragraph(style=style)
    if align is not None: p.alignment = align
    if first_indent is not None: p.paragraph_format.first_line_indent = first_indent
    if space_after is not None: p.paragraph_format.space_after = space_after
    if line is not None: p.paragraph_format.line_spacing = line
    if keep_next: p.paragraph_format.keep_with_next = True
    if text: add_runs(p, text, bold=bold, italic=italic, size=size)
    return p

TOK = re.compile(r"(\*\*[^*]+\*\*|(?<![\w*])\*(?=\S)[^*]+?(?<=\S)\*(?![\w*])|\^[^^]+\^|~[^~]{1,40}~)")
def add_runs(p, text, bold=False, italic=False, size=None):
    for part in TOK.split(text):
        if not part: continue
        b, i, sup, sub = bold, italic, False, False
        if part.startswith("**") and part.endswith("**"): part = part[2:-2]; b = True
        elif part.startswith("*") and part.endswith("*") and len(part) > 2: part = part[1:-1]; i = True
        elif part.startswith("^") and part.endswith("^"): part = part[1:-1]; sup = True
        elif part.startswith("~") and part.endswith("~") and len(part) > 2: part = part[1:-1]; sub = True
        r = p.add_run(part); r.bold = b or None; r.italic = i or None
        if sup: r.font.superscript = True
        if sub: r.font.subscript = True
        if size: r.font.size = Pt(size)
        tnr(r)

def tnr(r):
    """Ép font Times New Roman cho mọi bộ ký tự (Latin, Đông Á, phức hợp)."""
    r.font.name = "Times New Roman"
    rPr = r._r.get_or_add_rPr(); rf = rPr.find(qn("w:rFonts"))
    if rf is None:
        rf = OxmlElement("w:rFonts"); rPr.insert(0, rf)
    for k in ("w:ascii", "w:hAnsi", "w:eastAsia", "w:cs"):
        rf.set(qn(k), "Times New Roman")

def page_break():
    p = doc.add_paragraph(); p.add_run().add_break(WD_BREAK.PAGE)

def add_field(p, instr, placeholder="Nhấn chuột phải → Update Field để cập nhật."):
    r = p.add_run(); f = OxmlElement("w:fldChar"); f.set(qn("w:fldCharType"), "begin"); r._r.append(f)
    r = p.add_run(); t = OxmlElement("w:instrText"); t.set(qn("xml:space"), "preserve"); t.text = instr; r._r.append(t)
    r = p.add_run(); f = OxmlElement("w:fldChar"); f.set(qn("w:fldCharType"), "separate"); r._r.append(f)
    p.add_run(placeholder)
    r = p.add_run(); f = OxmlElement("w:fldChar"); f.set(qn("w:fldCharType"), "end"); r._r.append(f)

def shade(cell, fill):
    tcPr = cell._tc.get_or_add_tcPr(); sh = OxmlElement("w:shd"); sh.set(qn("w:val"), "clear"); sh.set(qn("w:color"), "auto"); sh.set(qn("w:fill"), fill); tcPr.append(sh)

def set_borders(tbl):
    tblPr = tbl._tbl.tblPr; b = OxmlElement("w:tblBorders")
    for e in ["top", "left", "bottom", "right", "insideH", "insideV"]:
        x = OxmlElement(f"w:{e}"); x.set(qn("w:val"), "single"); x.set(qn("w:sz"), "4"); x.set(qn("w:space"), "0"); x.set(qn("w:color"), "808080"); b.append(x)
    tblPr.append(b)

STATE = dict(chap="0", fig=0, tab=0, eq=0)
FIGS, TABS = [], []

def caption(kind, text):
    if kind == "Hình":
        STATE["fig"] += 1; n = f"{STATE['chap']}.{STATE['fig']}"; FIGS.append(n)
        p = add_par(f"Hình {n}. {text}", style="Chu thich Hinh")
    else:
        STATE["tab"] += 1; n = f"{STATE['chap']}.{STATE['tab']}"; TABS.append(n)
        p = add_par(f"Bảng {n}. {text}", style="Chu thich Bang", keep_next=True)
    return n

def note(text):
    add_par(text, italic=True, size=11, align=WD_ALIGN_PARAGRAPH.LEFT, first_indent=Cm(0), space_after=Pt(8), line=1.1)

def add_table(cap, header, rows, src=None, widths=None, font=10):
    if STATE["chap"] != "0": caption("Bảng", cap)
    ncol = len(header)
    t = doc.add_table(rows=1 + len(rows), cols=ncol); t.style = doc.styles["Table Grid"]; t.alignment = 1
    set_borders(t)
    total = 16.0
    if widths is None:
        lens = [max([len(str(header[j]))] + [min(len(str(r[j])), 60) for r in rows]) for j in range(ncol)]
        lens = [max(4, l) for l in lens]; sm = sum(lens); widths = [total * l / sm for l in lens]
    for j, h in enumerate(header):
        c = t.rows[0].cells[j]; c.width = Cm(widths[j])
        p = c.paragraphs[0]; p.alignment = 1; p.paragraph_format.first_line_indent = Cm(0); p.paragraph_format.line_spacing = 1.05
        p.paragraph_format.space_after = Pt(1); add_runs(p, str(h), bold=True, size=font)
    trPr = t.rows[0]._tr.get_or_add_trPr(); x = OxmlElement("w:tblHeader"); trPr.append(x)
    for i, r in enumerate(rows, 1):
        for j, v in enumerate(r):
            c = t.rows[i].cells[j]; c.width = Cm(widths[j])
            p = c.paragraphs[0]; p.paragraph_format.first_line_indent = Cm(0); p.paragraph_format.line_spacing = 1.05; p.paragraph_format.space_after = Pt(1)
            s = str(v)
            p.alignment = 2 if re.fullmatch(r"[−\-+]?[\d.,%]+[%]?", s.strip()) else 0
            add_runs(p, s, size=font)
    if src: note(src)
    else: add_par("", space_after=Pt(4))

def add_figure(fn, cap, src=None, width=15.5):
    p = add_par(align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=Cm(0), keep_next=True)
    p.add_run().add_picture(str(ROOT / "REPORT_READY" / "figures" / fn), width=Cm(width))
    caption("Hình", cap)
    if src: note(src)

def heading(level, text):
    if level == 1:
        if STATE.get("nobreak"):
            STATE["nobreak"] = False
        else:
            page_break()
        m = re.match(r"CHƯƠNG (\d+)", text)
        if m: STATE.update(chap=m.group(1), fig=0, tab=0, eq=0)
        m = re.match(r"PHỤ LỤC ([A-Z])", text)
        if m: STATE.update(chap=m.group(1), fig=0, tab=0, eq=0)
    doc.add_paragraph(text, style=f"Heading {level}")

def equation(text):
    STATE["eq"] += 1
    p = add_par(align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=Cm(0))
    add_runs(p, text, italic=False)
    p.add_run(f"\t\t({STATE['chap']}.{STATE['eq']})")

REFMAP = {}
def prepass(files):
    chap = "0"; nf = nt = 0
    for f in files:
        for ln in Path(f).read_text(encoding="utf-8").split("\n"):
            m = re.match(r"# (?:CHƯƠNG (\d+)|PHỤ LỤC ([A-Z]))", ln)
            if m: chap = m.group(1) or m.group(2); nf = nt = 0; continue
            m = re.match(r"\[\[FIG:([^|]+)\|", ln)
            if m: nf += 1; REFMAP["F:" + m.group(1).strip()] = f"Hình {chap}.{nf}"; continue
            m = re.match(r"\[\[TAB:([\w.]+)\]\]", ln)
            if m: nt += 1; REFMAP["T:" + m.group(1)] = f"Bảng {chap}.{nt}"; continue
            if ln.startswith("[[T:") and chap != "0":
                nt += 1; m = re.match(r"\[\[T:(@\S+)", ln)
                if m: REFMAP["T:" + m.group(1)] = f"Bảng {chap}.{nt}"
MISSING = set()
def subrefs(t):
    def rep(m):
        pre, key = m.group(1) or "", m.group(2)
        v = REFMAP.get(key)
        if v is None: MISSING.add(key); return pre + "[??" + key + "]"
        if pre:
            w = pre.strip()
            return (w + " " + v.split(" ", 1)[1]) + pre[len(pre.rstrip()):] if False else w + " " + v.split(" ", 1)[1]
        return v
    return re.sub(r"((?:Bảng|bảng|Hình|hình) )?\{([TF]:[^}]+)\}", rep, t)

def render(path):
    lines = [subrefs(x) for x in Path(path).read_text(encoding="utf-8").split("\n")]
    i = 0; buf = []
    def flush():
        if buf:
            add_par(" ".join(x.strip() for x in buf)); buf.clear()
    while i < len(lines):
        ln = lines[i].rstrip()
        if not ln.strip(): flush(); i += 1; continue
        if ln.startswith("%%"): i += 1; continue
        if ln.startswith("### "): flush(); heading(3, ln[4:]); i += 1; continue
        if ln.startswith("## "): flush(); heading(2, ln[3:]); i += 1; continue
        if ln.startswith("# "): flush(); heading(1, ln[2:]); i += 1; continue
        if ln.startswith("$ "): flush(); equation(ln[2:]); i += 1; continue
        if ln.startswith("- "):
            flush(); p = add_par(); p.paragraph_format.left_indent = Cm(0.6); p.paragraph_format.first_line_indent = Cm(-0.4)
            add_runs(p, "– " + ln[2:].strip()); i += 1; continue
        m = re.match(r"\[\[FIG:([^|]+)\|([^|\]]+)(?:\|([^\]]+))?\]\]", ln)
        if m: flush(); add_figure(m.group(1).strip(), m.group(2).strip(), m.group(3)); i += 1; continue
        m = re.match(r"\[\[TAB:([\w.]+)\]\]", ln)
        if m:
            flush(); spec = TB.get(m.group(1)); add_table(**spec); i += 1; continue
        if ln.startswith("[[T:"):
            flush(); cap = re.sub(r"^@\S+\s*", "", ln[4:].strip()); rows = []; src = None; i += 1
            while not lines[i].startswith("]]"):
                if lines[i].startswith("Nguồn:") or lines[i].startswith("Ghi chú:"): src = lines[i].strip()
                elif lines[i].strip(): rows.append([c.strip() for c in lines[i].split("|")])
                i += 1
            add_table(cap, rows[0], rows[1:], src=src); i += 1; continue
        if ln.startswith("[[PAGEBREAK]]"): flush(); page_break(); i += 1; continue
        buf.append(ln); i += 1
    flush()

# ================== Trang bìa & phần đầu ==================
meta = json.load(open(HERE / "meta.json", encoding="utf-8"))
from lxml import etree
COVER_IMG = HERE / "assets" / "uel_cover.jpg"
def cpar(text="", size=13, bold=False, align=WD_ALIGN_PARAGRAPH.CENTER, after=0, color=None, right_indent=None, line=None):
    p = doc.add_paragraph(); pf = p.paragraph_format
    p.alignment = align; pf.first_line_indent = Cm(0); pf.space_after = Pt(after); pf.space_before = Pt(0)
    if right_indent is not None: pf.right_indent = right_indent
    if line is not None: pf.line_spacing = line
    if text:
        r = p.add_run(text); r.font.size = Pt(size); r.bold = bold or None; tnr(r)
        if color: r.font.color.rgb = RGBColor.from_string(color)
    return p
# ảnh nền phủ toàn trang, nằm sau chữ
bg = cpar(); run = bg.add_run()
run.add_picture(str(COVER_IMG), width=Cm(21.0), height=Cm(29.7))
inline = run._r.find(".//" + qn("wp:inline")); graphic = inline.find(qn("a:graphic"))
cx, cy = inline.find(qn("wp:extent")).get("cx"), inline.find(qn("wp:extent")).get("cy")
ns = ('xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
      'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"')
anchor = etree.fromstring(
    f'<wp:anchor {ns} distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="0" behindDoc="1" locked="1" '
    f'layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionH>'
    f'<wp:positionV relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionV><wp:extent cx="{cx}" cy="{cy}"/>'
    f'<wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="9001" name="Cover background"/><wp:cNvGraphicFramePr/></wp:anchor>')
anchor.append(graphic); inline.getparent().replace(inline, anchor)
cpar("KHOA HỆ THỐNG THÔNG TIN", size=20, bold=True)
cpar(after=175)
cpar(meta["doc_type"], size=14, bold=True, after=14)
cpar(meta["title"], size=15, bold=True, after=24, line=1.2)
cpar(meta["cover_course"], size=15, bold=True, after=20)
for lab, val, a in (("GVHD:", meta["teacher"], 12), ("HVTH:", meta["student"], 0)):
    cpar(lab, size=14, bold=True, align=WD_ALIGN_PARAGRAPH.RIGHT, right_indent=Cm(2.9), line=1.2)
    cpar(val, size=14, align=WD_ALIGN_PARAGRAPH.RIGHT, after=a, right_indent=Cm(2.9), line=1.2)
# dòng nơi – thời gian đặt tuyệt đối trên dải màu xanh của ảnh bìa
fp = cpar(meta["cover_date"], size=11, bold=True, color="FFFFFF")
fr = OxmlElement("w:framePr"); tw = lambda c: str(int(round(c / 2.54 * 1440)))
for k, v in (("w:w", tw(21.0)), ("w:hSpace", "0"), ("w:wrap", "around"), ("w:vAnchor", "page"), ("w:hAnchor", "page"), ("w:x", "0"), ("w:y", tw(26.8))):
    fr.set(qn(k), v)
fp._p.get_or_add_pPr().insert(0, fr)
# kết thúc section bìa: lề riêng, không số trang ở bìa
endp = doc.add_paragraph(); spr = OxmlElement("w:sectPr")
for tag, attrs in (("w:pgSz", {"w:w": "11906", "w:h": "16838"}),
                   ("w:pgMar", {"w:top": tw(2.9), "w:right": tw(2.6), "w:bottom": tw(2.0), "w:left": tw(2.6), "w:header": "720", "w:footer": "720", "w:gutter": "0"}),
                   ("w:titlePg", {})):
    e = OxmlElement(tag)
    for k, v in attrs.items(): e.set(qn(k), v)
    spr.append(e)
endp._p.get_or_add_pPr().append(spr)
STATE["nobreak"] = True

prepass([HERE / "content" / f for f in meta["front"] + meta["chapters"]])
for fn in meta["front"]:
    render(HERE / "content" / fn)
# Danh mục hình, bảng, mục lục
page_break(); doc.add_paragraph("DANH MỤC HÌNH ẢNH", style="Heading 1")
add_field(add_par(first_indent=Cm(0)), ' TOC \\h \\z \\t "Chu thich Hinh,1" ')
page_break(); doc.add_paragraph("DANH MỤC BẢNG BIỂU", style="Heading 1")
add_field(add_par(first_indent=Cm(0)), ' TOC \\h \\z \\t "Chu thich Bang,1" ')
page_break(); doc.add_paragraph("MỤC LỤC", style="Heading 1")
add_field(add_par(first_indent=Cm(0)), ' TOC \\o "1-3" \\h \\z \\u ')
for fn in meta["chapters"]:
    render(HERE / "content" / fn)

out = ROOT / "reports" / meta["out"]
_u = OxmlElement("w:updateFields"); _u.set(qn("w:val"), "true"); doc.settings.element.append(_u)
doc.save(out)
print("missing refs", sorted(MISSING)); print("saved", out, "figs", len(FIGS), "tabs", len(TABS))
