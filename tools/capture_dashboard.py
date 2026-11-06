"""Chụp ảnh 12 trang dashboard (sau khi đã chạy pipeline) để đưa vào báo cáo.

Cách dùng:  streamlit run app.py --server.headless true --server.port 8599   (cửa sổ 1)
            python tools/capture_dashboard.py                                 (cửa sổ 2)
Cần: pip install playwright && playwright install chromium.
Ảnh được ghi vào outputs/15_dashboard/figures/dashNN_*.png; chạy lại Stage 14 để gom vào REPORT_READY/figures.
"""
import asyncio
import re
import sys
import unicodedata
from pathlib import Path

from playwright.async_api import async_playwright

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
OUT = ROOT / "outputs" / "15_dashboard" / "figures"
URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8599"
PAGES = ["Tổng quan điều hành", "01 · Dữ liệu & chẩn đoán", "02 · Hiệu quả quảng cáo & khuyến mãi", "03 · Chuỗi thời gian & mùa vụ",
         "04 · Mô hình toàn cục & uplift", "05 · Dự báo xác suất & rủi ro", "06 · Mô phỏng Mega Sale", "07 · Phân bổ ngân sách",
         "08 · Trung tâm quyết định AI", "09 · Dòng tiền chiến dịch", "10 · Kết quả nghiên cứu", "11 · Xuất báo cáo"]


def slug(s: str) -> str:
    s = unicodedata.normalize("NFD", s.replace("đ", "d").replace("Đ", "D"))
    s = "".join(c for c in s if unicodedata.category(c) != "Mn").lower()
    return re.sub(r"[^a-z0-9]+", "_", re.sub(r"^\d+\s*·\s*", "", s)).strip("_")


async def main():
    OUT.mkdir(parents=True, exist_ok=True)
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 1600, "height": 1000}, device_scale_factor=1.25)
        await pg.goto(URL)
        await pg.wait_for_selector('[data-testid="stSidebar"]', timeout=60000)
        await pg.wait_for_timeout(6000)
        for i, name in enumerate(PAGES):
            await pg.locator('[data-testid="stSidebar"] label').filter(has_text=name).first.click()
            await pg.wait_for_timeout(2500)
            for _ in range(60):
                if await pg.locator('[data-testid="stStatusWidget"]').count() == 0:
                    break
                await pg.wait_for_timeout(500)
            await pg.wait_for_timeout(3500)
            f = OUT / f"dash{i:02d}_{slug(name)}.png"
            await pg.screenshot(path=str(f))
            print("✓", f.name, flush=True)
        await b.close()


if __name__ == "__main__":
    asyncio.run(main())
