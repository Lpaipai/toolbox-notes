@echo off
setlocal

rem This script is intended to sit beside configureMosaic.exe and restore.bat.
rem Run it from an elevated CMD / as Administrator.

if not exist "%~dp0configureMosaic.exe" (
    echo [ERROR] configureMosaic.exe was not found in:
    echo         %~dp0
    pause
    exit /b 2
)

if not exist "%~dp0restore.bat" (
    echo [ERROR] restore.bat was not found.
    echo Run export-config.bat first, after Mosaic has been configured correctly.
    pause
    exit /b 2
)

pushd "%~dp0"
call restore.bat
set "RC=%ERRORLEVEL%"
popd

if "%RC%"=="0" (
    echo [OK] Mosaic restore command completed.
) else (
    echo [WARN] Restore command returned exit code %RC%. Check the output above.
)

pause
exit /b %RC%
