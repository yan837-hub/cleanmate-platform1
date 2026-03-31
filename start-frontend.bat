@echo off
chcp 65001 >nul
title CleanMate 前端服务
echo ===================================
echo   CleanMate 前端启动中...
echo ===================================
echo.
cd /d "%~dp0cleanmate-frontend"
call npm run dev
pause
