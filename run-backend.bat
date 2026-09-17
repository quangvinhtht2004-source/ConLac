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

echo [1/5] Kiem tra thu muc: %CD%
if not exist "pom.xml" (
    echo [LOI] Khong tim thay pom.xml!
    echo Vui long dat file bat trong thu muc QLNTM hoac smart-home-backend.
    goto END
)

echo [2/5] Kiem tra moi truong Java...
if exist "C:\Program Files\Java\jdk-17" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-17"
    set "PATH=C:\Program Files\Java\jdk-17\bin;%PATH%"
)
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [LOI] Khong tim thay Java trong PATH!
    echo Vui long cai dat JDK 17 tro len va cau hinh bien moi truong PATH.
    goto END
)
java -version 2>&1 | findstr /i "version"
echo.

set "MVN_CMD="
if exist "mvnw.cmd" (
    set "MVN_CMD=mvnw.cmd"
) else (
    where mvn >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "MVN_CMD=mvn"
    ) else if exist "C:\Program Files\JetBrains\IntelliJ IDEA 2025.2.1\plugins\maven\lib\maven3\bin\mvn.cmd" (
        set "MVN_CMD=C:\Program Files\JetBrains\IntelliJ IDEA 2025.2.1\plugins\maven\lib\maven3\bin\mvn.cmd"
    ) else if exist "C:\Program Files\NetBeans-25\netbeans\java\maven\bin\mvn.cmd" (
        set "MVN_CMD=C:\Program Files\NetBeans-25\netbeans\java\maven\bin\mvn.cmd"
    )
)

if "%MVN_CMD%"=="" (
    echo [LOI] Khong tim thay Maven hoac mvnw.cmd de chay du an.
    goto END
)

echo [3/5] Kiem tra file cau hinh .env...
if exist ".env" (
    echo   [OK] Da tim thay file .env tai: %CD%\.env
    echo        Cac bien moi truong (DB_PASSWORD, JWT_SECRET, DEVICE_API_KEY...) se duoc tu dong nap boi spring-dotenv.
) else (
    echo   [CANH BAO] Khong tim thay file .env tai: %CD%\.env
    echo   Luu y: Neu chua set bien moi truong he thong, Spring Boot se bao loi
    echo          thieu cac placeholder: DB_PASSWORD, JWT_SECRET, DEVICE_API_KEY...
    if exist ".env.example" (
        echo   Goi y: Ban co the copy file .env.example thanh .env va dien thong tin that.
    )
)
echo.

echo [4/5] Kiem tra va dong bo thu vien (Maven dependencies)...
echo Dang kiem tra / tai cac dependency neu co thay doi moi (nhu spring-dotenv)...
call "%MVN_CMD%" compile -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [CANH BAO] Qua trinh compile / tai dependency chua thanh cong.
    echo Ban co the chon muc [3] trong Menu ben duoi de Clean va Install lai toan bo.
    goto MENU
)
echo   [OK] Cac thu vien da duoc kiem tra va san sang.
echo.

:CHECK_PORT_INIT
netstat -aon | findstr :8080 | findstr LISTENING >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [CANH BAO] Phat hien port 8080 dang duoc su dung boi tien trinh khac!
    echo Dang tu dong giai phong port 8080 truoc khi khoi dong...
    call :KILL_PORT_8080
    timeout /t 1 /nobreak >nul
)

:RUN_SERVER
echo.
echo [5/5] Dang khoi dong Spring Boot Server tren port 8080
echo -------------------------------------------------------
echo Server chay tai: http://localhost:8080
echo.
echo HUONG DAN DIEU KHIEN:
echo   - De RESTART: Nhan Ctrl + C, khi hoi "Terminate batch job (Y/N)?"
echo     -> Nhap N roi nhan Enter de hien menu Restart!
echo   - De THOAT:   Nhan Ctrl + C -> Nhap Y
echo -------------------------------------------------------
echo Dang su dung: %MVN_CMD%
echo.

call "%MVN_CMD%" spring-boot:run

echo.
echo =======================================================
echo [THONG BAO] Backend da dung (Exit Code: %ERRORLEVEL%)
echo =======================================================

:MENU
echo.
echo =======================================================
echo                   MENU DIEU KHIEN
echo =======================================================
echo   [1] / [R] : Khoi dong lai Backend (Restart)
echo   [2] / [K] : Giai phong Port 8080 va Khoi dong lai
echo   [3] / [I] : Clean & Tai lai toan bo Dependencies (mvn clean install)
echo   [4] / [E] : Thoat (Exit)
echo =======================================================
set "USER_OPT="
set /p "USER_OPT=Nhap lua chon cua ban [1-4 / R/K/I/E] (Mac dinh: Restart): "

if not defined USER_OPT goto DO_RESTART
if /i "%USER_OPT%"=="1" goto DO_RESTART
if /i "%USER_OPT%"=="R" goto DO_RESTART
if /i "%USER_OPT%"=="2" goto DO_KILL_AND_RESTART
if /i "%USER_OPT%"=="K" goto DO_KILL_AND_RESTART
if /i "%USER_OPT%"=="3" goto DO_CLEAN_INSTALL
if /i "%USER_OPT%"=="I" goto DO_CLEAN_INSTALL
if /i "%USER_OPT%"=="C" goto DO_CLEAN_INSTALL
if /i "%USER_OPT%"=="4" goto END
if /i "%USER_OPT%"=="E" goto END
if /i "%USER_OPT%"=="Q" goto END

echo [!] Lua chon khong hop le, mac dinh khoi dong lai...
goto DO_RESTART

:DO_KILL_AND_RESTART
call :KILL_PORT_8080
timeout /t 1 /nobreak >nul
goto DO_RESTART

:DO_RESTART
echo.
echo =======================================================
echo             DANG KHOI DONG LAI BACKEND...
echo =======================================================
goto RUN_SERVER

:DO_CLEAN_INSTALL
echo.
echo =======================================================
echo     DANG CLEAN VA TAI LAI TOAN BO DEPENDENCIES...
echo =======================================================
call "%MVN_CMD%" clean install -DskipTests
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Da tai va cai dat dependencies thanh cong!
    echo Dang khoi dong lai Backend...
    timeout /t 2 /nobreak >nul
    goto RUN_SERVER
) else (
    echo.
    echo [LOI] Clean install that bai! Vui long kiem tra ket noi mang hoac pom.xml.
    goto MENU
)

:KILL_PORT_8080
echo [*] Kiem tra va giai phong port 8080...
set "FOUND_PORT="
for /f "tokens=5" %%p in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    set "FOUND_PORT=1"
    echo   - Dang tat tien trinh PID: %%p dang chiem port 8080...
    taskkill /f /pid %%p >nul 2>&1
)
if not defined FOUND_PORT (
    echo   - Port 8080 dang trong.
) else (
    echo   - Da giai phong port 8080 thanh cong.
)
exit /b 0

:END
echo.
echo Nhan phim bat ky de thoat...
pause >nul
