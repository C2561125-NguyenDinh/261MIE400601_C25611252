"""Mô phỏng kịch bản chiến dịch Mega Sale: từ (quảng cáo, chiết khấu) → đơn, GMV, biên đóng góp, kèm bất định.

Mô hình phản hồi được ước lượng từ dữ liệu 90 ngày (Orders ~ Ad_Spend + Discount + Mega) và AOV theo mức chiết khấu.
Đây là dự báo có điều kiện trong vùng dữ liệu quan sát, KHÔNG phải ước lượng nhân quả (dữ liệu mô phỏng, chỉ 2 ngày Mega Sale).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


class CampaignModel:
    def __init__(self, d: pd.DataFrame, cogs_ratio: float, seed: int = 42):
        self.d = d.copy()
        self.cogs_ratio = float(cogs_ratio)              # giá vốn / GMV bình quân (ước từ unit economics)
        # Giả định "giá vốn theo giá niêm yết": giá vốn = κ × GMV/(1 − chiết khấu); κ hiệu chỉnh để tổng giá vốn 90 ngày = cogs_ratio × tổng GMV
        self.kappa = float(cogs_ratio * d.GMV.sum() / (d.GMV / (1 - d.Discount)).sum())
        self.m_orders = smf.ols("Orders ~ Ad_Spend + Discount + Mega", self.d).fit()
        # AOV (sau chiết khấu) theo mức chiết khấu – ước lượng tuyến tính trên 90 ngày
        self.m_aov = smf.ols("AOV ~ Discount", self.d).fit()
        self.resid_sd = float(np.std(self.m_orders.resid, ddof=3))
        self.rng = np.random.default_rng(seed)
        self.range = dict(ads=(float(d.Ad_Spend.min()), float(d.Ad_Spend.max())), disc=(float(d.Discount.min()), float(d.Discount.max())))
        # Trong dữ liệu, mọi ngày Mega Sale đều có chiết khấu 50% → biến Mega và mức chiết khấu sâu trùng nhau (không tách được);
        # kịch bản Mega Sale với chiết khấu khác các mức đã quan sát là ngoại suy về mặt nhận dạng.
        md = d[d.Mega == 1]
        self.mega_disc = sorted(md.Discount.unique().tolist()) if len(md) else []

    def predict(self, ads: float, disc: float, mega: int, n_sim: int = 4000, platform_fee: float = 0.0, cost_basis: str = "list") -> dict:
        """cost_basis = "gmv": giá vốn tỷ lệ cố định theo GMV (lạc quan – bỏ qua việc chiết khấu ăn vào biên);
        cost_basis = "list": giá vốn tỷ lệ với giá trị trước chiết khấu (thận trọng – mặc định)."""
        X = pd.DataFrame({"Ad_Spend": [ads], "Discount": [disc], "Mega": [mega]})
        pr = self.m_orders.get_prediction(X)
        mu = float(pr.predicted_mean[0]); se_mean = float(pr.se_mean[0])
        aov = float(self.m_aov.predict(pd.DataFrame({"Discount": [disc]}))[0])
        # bất định = bất định tham số (se_mean) + nhiễu ngày (resid_sd)
        orders = np.maximum(0, self.rng.normal(mu, np.sqrt(se_mean ** 2 + self.resid_sd ** 2), n_sim))
        gmv = orders * aov
        cost_share = self.cogs_ratio if cost_basis == "gmv" else self.kappa / (1 - disc)
        cm = gmv * (1 - cost_share - platform_fee) - ads
        q = lambda a, p: float(np.quantile(a, p))
        extrap = not (self.range["ads"][0] <= ads <= self.range["ads"][1] and self.range["disc"][0] <= disc <= self.range["disc"][1])
        if mega and self.mega_disc and not any(abs(disc - x) < 1e-9 for x in self.mega_disc):
            extrap = True
        return dict(ads=ads, disc=disc, mega=mega, cost_basis=cost_basis, cost_share=cost_share, orders_mean=mu, orders_se_mean=se_mean, aov=aov,
                    orders_p10=q(orders, .1), orders_p50=q(orders, .5), orders_p90=q(orders, .9),
                    gmv_p10=q(gmv, .1), gmv_p50=q(gmv, .5), gmv_p90=q(gmv, .9),
                    cm_p10=q(cm, .1), cm_p50=q(cm, .5), cm_p90=q(cm, .9), p_cm_negative=float((cm < 0).mean()), extrapolation=bool(extrap))

    def grid(self, ads_list, disc_list, mega: int = 1, platform_fee: float = 0.0, cost_basis: str = "list") -> pd.DataFrame:
        return pd.DataFrame([self.predict(a, dd, mega, platform_fee=platform_fee, cost_basis=cost_basis) for a in ads_list for dd in disc_list])
