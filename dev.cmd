@echo off
REM One command to start the full local development environment.
REM Double-click, or run `dev` from a terminal at the repo root.
REM Any arguments are forwarded, e.g. `dev -WindowsOnly`.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start-dev.ps1" %*
