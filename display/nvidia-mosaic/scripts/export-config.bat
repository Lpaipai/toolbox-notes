@echo off
setlocal

rem This script is intended to sit beside configureMosaic.exe.
rem Run it from an elevated CMD / as Administrator.

if not exist "%~dp0configureMosaic.exe" (
    echo [ERROR] configureMosaic.exe was not found in:
    echo         %~dp0
    echo Copy this script into the folder containing configureMosaic.exe.
    pause
    exit /b 2
)

pushd "%~dp0"
configureMosaic.exe listconfigcmd > restore.bat
set "RC=%ERRORLEVEL%"

if %RC% GEQ 2 (
    echo [ERROR] configureMosaic returned exit code %RC%.
    if exist restore.bat type restore.bat
    popd
    pause
    exit /b %RC%
)

for %%F in (restore.bat) do if %%~zF EQU 0 (
    echo [ERROR] restore.bat is empty. No restore command was exported.
    popd
    pause
    exit /b 2
)

echo [OK] Current Mosaic restore command exported to:
echo      %CD%\restore.bat
if "%RC%"=="1" echo [WARN] configureMosaic reported success with warnings. Review the generated file.
popd
pause
exit /b %RC%
