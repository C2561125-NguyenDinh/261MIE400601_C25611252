import subprocess, time, uno, sys, os
from com.sun.star.beans import PropertyValue
src = os.path.abspath(sys.argv[1]); dst = os.path.abspath(sys.argv[2])
p = subprocess.Popen(["soffice", "--headless", "--invisible", "--norestore",
                      '--accept=socket,host=localhost,port=2002;urp;'])
ctx = None
for _ in range(60):
    try:
        local = uno.getComponentContext()
        res = local.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local)
        ctx = res.resolve("uno:socket,host=localhost,port=2002;urp;StarOffice.ComponentContext"); break
    except Exception: time.sleep(1)
desk = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
def pv(n, v):
    x = PropertyValue(); x.Name = n; x.Value = v; return x
doc = desk.loadComponentFromURL(uno.systemPathToFileUrl(src), "_blank", 0, (pv("Hidden", True),))
idx = doc.getDocumentIndexes()
for i in range(idx.getCount()): idx.getByIndex(i).update()
doc.refresh()
for i in range(idx.getCount()): idx.getByIndex(i).update()
doc.storeToURL(uno.systemPathToFileUrl(dst), (pv("FilterName", "writer_pdf_Export"),))
if len(sys.argv) > 3: doc.storeToURL(uno.systemPathToFileUrl(os.path.abspath(sys.argv[3])), (pv("FilterName", "MS Word 2007 XML"),))
doc.close(True); p.terminate()
print("PDF", dst)
