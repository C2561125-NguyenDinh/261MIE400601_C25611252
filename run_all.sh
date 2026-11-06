#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
for s in 01_data_validation 02_marketing_diagnostics 03_decomposition_seasonality 04_feature_engineering 05_uplift_global_models 06_probabilistic_campaign 07_budget_allocation 08_genai_decision_support 09_build_research_summary 10_pipeline_smoke_test 11_forecast_diagnostics 12_case_studies 13_sensitivity_experiments 14_build_report_ready; do echo "===== $s"; python $s.py; done
python -m pytest -q tests/test_core.py
