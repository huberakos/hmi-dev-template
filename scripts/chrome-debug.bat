@echo off
REM ============================================================================
REM  Chrome DevTools Debug Mode — ERPNext / Frappe fejlesztéshez
REM  Használat: scripts\chrome-debug.bat [URL]
REM  Alapértelmezett URL: http://localhost:8000
REM
REM  BIZTONSÁGI SZABÁLYOK:
REM  - Port 9222 CSAK localhost-ra kötve (127.0.0.1)
REM  - Dedikált debug profil (nem a fő Chrome profil)
REM  - Session végén automatikusan bezáródik
REM  - Soha ne böngéssz érzékeny oldalakat (bank, email) ebben a profilban
REM ============================================================================

setlocal

REM --- Konfiguráció ---
set CDP_PORT=9222
set CDP_ADDRESS=127.0.0.1
set DEBUG_PROFILE=%USERPROFILE%\chrome-debug-profile
set CHROME_EXE=C:\Program Files\Google\Chrome\Application\chrome.exe
set DEFAULT_URL=http://localhost:8000

REM --- URL paraméter (opcionális) ---
if "%~1"=="" (
    set TARGET_URL=%DEFAULT_URL%
) else (
    set TARGET_URL=%~1
)

REM --- Ellenőrzés: nincs-e már valami a 9222-es porton ---
echo [CHECK] Port %CDP_PORT% ellenőrzés...
netstat -ano | findstr ":%CDP_PORT%" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [HIBA] Port %CDP_PORT% már foglalt! Ellenőrizd:
    echo        netstat -ano ^| findstr :%CDP_PORT%
    echo        Zárd be a másik Chrome debug session-t, vagy használj másik portot.
    pause
    exit /b 1
)

REM --- Chrome indítása debug módban ---
echo [START] Chrome debug mód indul...
echo         Port: %CDP_ADDRESS%:%CDP_PORT%
echo         Profil: %DEBUG_PROFILE%
echo         URL: %TARGET_URL%
echo.

start "" "%CHROME_EXE%" ^
    --remote-debugging-port=%CDP_PORT% ^
    --remote-debugging-address=%CDP_ADDRESS% ^
    --user-data-dir="%DEBUG_PROFILE%" ^
    "%TARGET_URL%"

echo ============================================================================
echo  Chrome debug módban fut (CDP port: %CDP_ADDRESS%:%CDP_PORT%)
echo.
echo  Claude Code MCP: chrome-devtools szerver automatikusan csatlakozik
echo  Kézi teszt: curl http://127.0.0.1:%CDP_PORT%/json/version
echo.
echo  Nyomj ENTER-t a Chrome BEZÁRÁSÁHOZ és a debug session LEÁLLÍTÁSÁHOZ.
echo ============================================================================
pause

REM --- Chrome leállítása ---
echo [STOP] Chrome bezárás...
taskkill /IM chrome.exe /F >nul 2>&1

echo [DONE] Debug session lezárva.
echo.
echo [TIP] Profil törlése (cookie-k, session-ök eltávolítása):
echo       rmdir /S /Q "%DEBUG_PROFILE%"

endlocal
