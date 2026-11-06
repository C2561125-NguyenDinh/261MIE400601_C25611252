@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" (
  echo Tao moi truong ao .venv ...
  py -3.12 -m venv .venv 2>nul || py -3.11 -m venv .venv 2>nul || python -m venv .venv
  ".venv\Scripts\python.exe" -m pip install --upgrade pip >nul
  ".venv\Scripts\python.exe" -m pip install -r requirements.txt
)
".venv\Scripts\python.exe" -c "import openpyxl, streamlit, plotly" 2>nul || ".venv\Scripts\python.exe" -m pip install -r requirements.txt
".venv\Scripts\python.exe" -m streamlit run app.py --server.headless false
endlocal
