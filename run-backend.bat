@echo off
title Smart Home - Backend (Spring Boot)

echo =======================================================
echo          KHOI DONG BACKEND (SPRING BOOT)
echo =======================================================
echo.

cd /d "%~dp0"
if exist "smart-home-backend\pom.xml" (
    cd /d "%~dp0smart-home-backend"
)

echo [1/3] Kiem tra thu muc: %CD%
if not exist "pom.xml" (
    echo [LOI] Khong tim thay pom.xml!
    echo Vui long dat file bat trong thu muc QLNTM hoac smart-home-backend.
    goto END
)

echo [2/3] Kiem tra Java...
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Khong tim thay Java trong PATH!
    echo Vui long cai dat JDK 17 tro len va cau hinh bien moi truong PATH.
    goto END
)
java -version 2>&1 | findstr /i "version"
echo.

echo [3/3] Dang khoi dong Spring Boot Server tren port 8080
echo -------------------------------------------------------
echo Server chay tai: http://localhost:8080
echo Nhan to hop phim Ctrl + C neu muon dung server.
echo -------------------------------------------------------
echo.

if exist "mvnw.cmd" (
    echo Dang su dung Maven Wrapper: mvnw.cmd
    call mvnw.cmd spring-boot:run
    goto FINISH
)

where mvn >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Dang su dung Maven trong PATH...
    call mvn spring-boot:run
    goto FINISH
)

set "IDEA_MAVEN=C:\Program Files\JetBrains\IntelliJ IDEA 2025.2.1\plugins\maven\lib\maven3\bin\mvn.cmd"
if exist "%IDEA_MAVEN%" (
    echo Dang su dung Maven tu IntelliJ IDEA...
    call "%IDEA_MAVEN%" spring-boot:run
    goto FINISH
)

set "NB_MAVEN=C:\Program Files\NetBeans-25\netbeans\java\maven\bin\mvn.cmd"
if exist "%NB_MAVEN%" (
    echo Dang su dung Maven tu NetBeans...
    call "%NB_MAVEN%" spring-boot:run
    goto FINISH
)

echo [LOI] Khong tim thay Maven hoac mvnw.cmd de chay du an.

:FINISH
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [THONG BAO] Server da dung - Exit Code: %ERRORLEVEL%
)

:END
echo.
echo Nhan phim bat ky de thoat...
pause >nul
