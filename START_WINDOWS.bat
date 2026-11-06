@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title Mega Sale - chay toan bo quy trinh (Stage 01-14)

if not exist ".venv\Scripts\python.exe" (
  echo Tao moi truong ao .venv ...
  py -3.12 -m venv .venv 2>nul || py -3.11 -m venv .venv 2>nul || python -m venv .venv
)
set "PY=.venv\Scripts\python.exe"
"%PY%" -m pip install --upgrade pip >nul
"%PY%" -m pip install -r requirements.txt || (echo [LOI] Cai thu vien that bai & pause & exit /b 1)

for %%F in (01_data_validation 02_marketing_diagnostics 03_decomposition_seasonality 04_feature_engineering 05_uplift_global_models 06_probabilistic_campaign 07_budget_allocation 08_genai_decision_support 09_build_research_summary 10_pipeline_smoke_test 11_forecast_diagnostics 12_case_studies 13_sensitivity_experiments 14_build_report_ready) do (
  echo.
  echo ===== %time% RUN %%F.py
  "%PY%" %%F.py || (echo [LOI] %%F.py that bai & pause & exit /b 1)
)
"%PY%" -m pytest -q tests\test_core.py
echo.
echo Hoan tat. Mo dashboard...
"%PY%" -m streamlit run app.py --server.headless false
endlocal
