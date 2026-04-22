@echo off
chcp 65001 >nul
title CleanMate 后端服务
echo ===================================
echo   CleanMate 后端启动中...
echo ===================================
echo.

:: 启动 Redis（如果还没在运行）
echo [1/2] 检查 Redis...
"F:\dev_soft\redis-6.2.1\bin\redis-cli.exe" ping >nul 2>&1
if %errorlevel% neq 0 (
    echo     Redis 未运行，正在启动...
    start /B "Redis" "F:\dev_soft\redis-6.2.1\bin\redis-server.exe"
    timeout /t 2 /nobreak >nul
    echo     Redis 已启动
) else (
    echo     Redis 已在运行
)

:: 启动 Spring Boot
echo [2/2] 启动 Spring Boot...
cd /d "%~dp0cleanmate-backend"
call mvn spring-boot:run -q
pause
