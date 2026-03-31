@echo off
chcp 65001 >nul
title CleanMate 后端服务
echo ===================================
echo   CleanMate 后端启动中...
echo ===================================
echo.
cd /d "%~dp0cleanmate-backend"
call mvn spring-boot:run -q
pause
