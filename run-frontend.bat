@echo off
title Smart Home - Frontend (Flutter Web)

echo =======================================================
echo          KHOI DONG FRONTEND (FLUTTER WEB)
echo =======================================================
echo.

cd /d "%~dp0smart-home-frontend"

echo Dang chay Flutter Web tai: http://localhost:3000
echo Ban co the mo Chrome thuong ngay cua ban va truy cap vao:
echo http://localhost:3000
echo.
echo Nhan 'r' trong cua so nay de Hot Reload (cap nhat giao dien ngay lap tuc)
echo Nhan 'R' de Hot Restart
echo -------------------------------------------------------
echo.

flutter run -d web-server --web-port=3000

pause

