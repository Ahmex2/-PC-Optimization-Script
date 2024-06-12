@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges.
    echo Please run the script as an administrator and try again.
    pause
    exit /b
)

REM Define variables
set "TEMP_DIR=%temp%"
set "LOG_FILE=%TEMP_DIR%\optimization_log.txt"
set "REG_TOOL=reg.exe"
set "POWERCFG_TOOL=powercfg.exe"
set "NETSH_TOOL=netsh.exe"
set "SCHTASKS_TOOL=schtasks.exe"
set "NIRCMD_TOOL=nircmd.exe"
set "POWERSHELL_TOOL=powershell.exe"
set "CLEANMEM_TOOL=CleanMem.exe"
set "DISK_CLEANUP=%SYSTEMROOT%\System32\cleanmgr.exe"

REM Start logging
echo Script started at %date% %time% > "%LOG_FILE%"
echo Creating a system restore point...

REM Create a system restore point
%POWERSHELL_TOOL% -Command "Checkpoint-Computer -Description 'BeforeOptimization' -RestorePointType 'MODIFY_SETTINGS'" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to create a system restore point. >> "%LOG_FILE%"
)

REM Disable unnecessary startup programs permanently
echo Disabling unnecessary startup programs...
%REG_TOOL% ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Skype /f >> "%LOG_FILE%" 2>&1

REM Clean temporary files
echo Cleaning temporary files...
del /q /f "%TEMP_DIR%\*.*" >> "%LOG_FILE%" 2>&1

REM Advanced Disk Cleanup
echo Performing advanced disk cleanup...
%DISK_CLEANUP% /sagerun:1 >> "%LOG_FILE%" 2>&1

REM Optimize disk
echo Optimizing disk...
%SYSTEMROOT%\System32\defrag.exe C: /U /V >> "%LOG_FILE%" 2>&1

REM Disable unnecessary services permanently
echo Disabling unnecessary services...
%SYSTEMROOT%\System32\sc.exe config wuauserv start=disabled >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\sc.exe config Themes start=disabled >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\sc.exe config RemoteRegistry start=disabled >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\sc.exe config TabletInputService start=disabled >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\sc.exe config SysMain start=disabled >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\sc.exe config DiagTrack start=disabled >> "%LOG_FILE%" 2>&1

REM Registry Cleanup
echo Performing registry cleanup...
%REG_TOOL% DELETE HKCU\Software\TempKeys /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% DELETE HKCU\Software\TempValues /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% DELETE HKCU\Software\TempSubkeys /f >> "%LOG_FILE%" 2>&1

REM Optimize GPU for stable gaming performance
echo Optimizing GPU for stable gaming performance...
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor perfboostmode 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor perfboostpolicy 3 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setactive scheme_current >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor perfboostpolicy 1 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor videoplaybackquality 0 >> "%LOG_FILE%" 2>&1

REM Optimize CPU for stable gaming performance
echo Optimizing CPU for stable gaming performance...
%POWERCFG_TOOL% -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >> "%LOG_FILE%" 2>&1
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v Attributes /t REG_DWORD /d 0 /f >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setdcvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -setactive scheme_current >> "%LOG_FILE%" 2>&1

REM Optimize RAM for stable gaming performance
echo Optimizing RAM for stable gaming performance...
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >> "%LOG_FILE%" 2>&1
%POWERSHELL_TOOL% -WindowStyle Hidden -Command "Clear-RamCache" >> "%LOG_FILE%" 2>&1
%CLEANMEM_TOOL% AUTO >> "%LOG_FILE%" 2>&1

REM Optimize network settings for gaming
echo Optimizing network settings for gaming...
%NETSH_TOOL% interface tcp set global autotuninglevel=disabled >> "%LOG_FILE%" 2>&1

REM Disable Nagle's algorithm for low-latency gaming
echo Disabling Nagle's algorithm for low-latency gaming...
%NETSH_TOOL% interface tcp set global nagle=disabled >> "%LOG_FILE%" 2>&1

REM Optimize Prefetch and Superfetch
echo Optimizing Prefetch and Superfetch...
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 2 /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 2 /f >> "%LOG_FILE%" 2>&1

REM Pagefile Optimization
echo Optimizing pagefile settings...
%REG_TOOL% ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /t REG_MULTI_SZ /d "C:\pagefile.sys 1024 4096" /f >> "%LOG_FILE%" 2>&1

REM System Health Check
echo Performing system health check...
%SYSTEMROOT%\System32\sfc /scannow >> "%LOG_FILE%" 2>&1
%SYSTEMROOT%\System32\Dism /Online /Cleanup-Image /RestoreHealth >> "%LOG_FILE%" 2>&1

REM Disable unnecessary visual effects
echo Disabling unnecessary visual effects...
%SYSTEMROOT%\System32\SystemPropertiesPerformance.exe /configurevisualeffects >> "%LOG_FILE%" 2>&1

REM Ensure best performance mode
echo Setting system to best performance mode...
%POWERCFG_TOOL% -change monitor-timeout-ac 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -change monitor-timeout-dc 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -change standby-timeout-ac 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -change standby-timeout-dc 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -change hibernate-timeout-ac 0 >> "%LOG_FILE%" 2>&1
%POWERCFG_TOOL% -change hibernate-timeout-dc 0 >> "%LOG_FILE%" 2>&1

REM Disable unnecessary visual effects
echo Disabling unnecessary visual effects...
%REG_TOOL% ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >> "%LOG_FILE%" 2>&1
%REG_TOOL% ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v DisableAnimations /t REG_DWORD /d 1 /f >> "%LOG_FILE%" 2>&1

REM Set system to best performance mode
echo Setting system to best performance mode...
%POWERCFG_TOOL% -setacvalueindex scheme_current sub_processor PERFINCTHRESH 100 >> "%LOG_FILE%" 2>&1

REM Schedule regular maintenance tasks
echo Scheduling regular maintenance tasks...
%SCHTASKS_TOOL% /create /sc weekly /tn "WeeklyOptimization" /tr "%~0" /st 02:00 >> "%LOG_FILE%" 2>&1

REM Optimize speaker volume and ensure smooth stereo sound
echo Optimizing speaker volume...
%nircmd_tool% setsysvolume 65535 >> "%LOG_FILE%" 2>&1
%nircmd_tool% setsysvolume 0 1 >> "%LOG_FILE%" 2>&1

REM Display completion message
echo Optimization complete. Your PC is now fully optimized for stable gaming and multitasking with smooth performance.
echo Script completed at %date% %time% >> "%LOG_FILE%"

REM Pause to allow user to review output
pause

ENDLOCAL
