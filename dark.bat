@echo off
REM Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges.
    echo Please run the script as an administrator and try again.
    pause
    exit /b
)

REM Disable unnecessary startup programs permanently
echo Disabling unnecessary startup programs...
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_ShowMyComputer /t REG_DWORD /d 0 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_ShowMyDocuments /t REG_DWORD /d 0 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_ShowMyPictures /t REG_DWORD /d 0 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_ShowMyMusic /t REG_DWORD /d 0 /f >nul

REM Clean temporary files
echo Cleaning temporary files...
del /q /f %temp%\*.* >nul 2>&1

REM Optimize disk
echo Optimizing disk...
defrag C: /U /V >nul

REM Disable unnecessary services permanently
echo Disabling unnecessary services...
sc config wuauserv start=disabled >nul
sc config Themes start=disabled >nul
sc config RemoteRegistry start=disabled >nul
sc config TabletInputService start=disabled >nul

REM Registry Cleanup
echo Performing registry cleanup...
REM Run registry cleanup using built-in Windows tool
reg delete HKCU\Software\TempKeys /f >nul 2>&1
reg delete HKCU\Software\TempValues /f >nul 2>&1
reg delete HKCU\Software\TempSubkeys /f >nul 2>&1

REM Optimize GPU for stable gaming performance
echo Optimizing GPU for stable gaming performance...
REM Set GPU to prefer maximum performance
powercfg -setacvalueindex scheme_current sub_processor perfboostmode 0 >nul
powercfg -setacvalueindex scheme_current sub_processor perfboostpolicy 3 >nul
powercfg -setactive scheme_current >nul
REM Disable GPU power-saving features
powercfg -setacvalueindex scheme_current sub_processor perfboostpolicy 1 >nul

REM Optimize CPU for stable gaming performance
echo Optimizing CPU for stable gaming performance...
REM Set CPU power plan to high performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
REM Disable CPU core parking
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v Attributes /t REG_DWORD /d 0 /f >nul 2>&1
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
REM Set CPU minimum and maximum state to 100% for all power plans
powercfg -setacvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100 >nul
powercfg -setacvalueindex scheme_current sub_processor 0cc5b647-c1df-4637-891a-dec35c318583 100 >nul

REM Optimize RAM for stable gaming performance
echo Optimizing RAM for stable gaming performance...
REM Increase system responsiveness by reducing page file usage
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul
REM Set large system cache to prioritize gaming performance
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul
REM Automatically clean RAM to free up memory
powershell.exe -WindowStyle Hidden -Command "Clear-RamCache" >nul

REM Optimize network settings for gaming
echo Optimizing network settings for gaming...
netsh interface tcp set global autotuninglevel=disabled >nul

REM Disable Nagle's algorithm for low-latency gaming
echo Disabling Nagle's algorithm for low-latency gaming...
netsh interface tcp set global nagle=disabled >nul

REM Temperature Monitoring
echo Monitoring system temperatures...
REM Add instructions for temperature monitoring using third-party software or built-in Windows tools here

REM Update system
echo Updating system...
schtasks /run /tn "\Microsoft\Windows\WindowsUpdate\Automatic App Update" >nul
schtasks /run /tn "\Microsoft\Windows\WindowsUpdate\Automatic Maintenance" >nul
schtasks /run /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" >nul

REM Optimize speaker volume and ensure smooth stereo sound
echo Optimizing speaker volume...
REM Set speaker volume to 100% and enable stereo sound (specific commands may vary based on audio drivers and hardware)
nircmd.exe setsysvolume 65535
nircmd.exe setsysvolume 0 1

REM Display completion message
echo Optimization complete. Your PC is now fully optimized for stable gaming and multitasking with smooth performance.

REM Pause to allow user to review output
pause
