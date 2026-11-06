import json, re, glob, sys, pickle
import pandas as pd, numpy as np
sys.path.insert(0,'/home/claude/mkt/reports/builder'); import tables as TB
R='/home/claude/mkt/'
pool=set()
def addnum(v):
    try: v=float(v)
    except: return
    if not np.isfinite(v): return
    for x in {v, abs(v), v*100, abs(v*100)}:
        for d in range(0,5):
            s=f"{x:,.{d}f}".replace(",","§").replace(".",",").replace("§",".")
            pool.add(s); pool.add(s.replace(".",""))
def walk(o):
    if isinstance(o,dict):
        for k,v in o.items(): walk(k); walk(v)
    elif isinstance(o,(list,tuple)):
        for v in o: walk(v)
    elif isinstance(o,(int,float)): addnum(o)
    elif isinstance(o,str):
        for m in re.findall(r"-?\d+(?:\.\d+)?",o): addnum(m)
for f in glob.glob(R+'outputs/*/*.json'): walk(json.load(open(f)))
for f in glob.glob(R+'data/raw/**/*.csv',recursive=True)+glob.glob(R+'outputs/*/*.csv'):
    d=pd.read_csv(f)
    for c in d.columns:
        if d[c].dtype.kind in 'if': [addnum(x) for x in d[c].dropna().unique()[:20000]]
        else: [walk(x) for x in d[c].dropna().astype(str).unique()[:5000]]
for k in TB.T:
    t=TB.get(k)
    for r in t['rows']+[t['header'],[t['cap'],t.get('src') or '']]:
        for c in r:
            for m in re.findall(r"\d[\d.]*,\d+|\d[\d.]*",str(c)): pool.add(m); pool.add(m.replace(".",""))
for f in glob.glob('/home/claude/vnproj/slides/*.txt')+glob.glob(R+'knowledge_base/*.md')+[R+'outputs/08_genai/audit_log.jsonl']:
    for m in re.findall(r"\d[\d.,]*\d|\d",open(f).read()): pool.add(m); pool.add(m.replace(".",",")); pool.add(m.replace(",","."))
num=re.compile(r"(?<![\w.,])(\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+,\d+)(?![\w])")
out=[]
for f in sorted(glob.glob(R+'reports/builder/content/*.tm')):
    if f.endswith('refs.tm'): continue
    for i,ln in enumerate(open(f).read().split("\n"),1):
        if ln.startswith('$ '): continue
        for m in num.finditer(ln):
            s=m.group(1)
            if s in pool or s.replace(".","") in pool: continue
            # tolerate rounding: try one fewer decimals
            ok=False
            if "," in s:
                a,b=s.split(","); 
                for d in range(len(b)+1,5):
                    pass
            out.append((f.split('/')[-1],i,s,ln[max(0,m.start()-70):m.end()+40]))
print(len(out))
for o in out: print(o[0],o[1],o[2],'|',o[3].replace('\n',' '))
