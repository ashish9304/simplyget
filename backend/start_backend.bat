@echo off
cd /d "%~dp0"
title Backend Server

echo Killing any existing backend processes...
taskkill /F /IM python.exe /T >nul 2>&1
taskkill /F /IM uvicorn.exe /T >nul 2>&1

echo Starting Server (FastAPI)...

if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
    echo Activating virtual environment...
    call .venv\Scripts\activate
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    echo Activating virtual environment...
    call .venv\Scripts\activate
)

echo Checking for dependency updates...
pip install -r requirements.txt >nul 2>&1

echo Starting Uvicorn...
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

