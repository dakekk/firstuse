rem cd /d E:\EISOOPEMaker\
rem ultraiso -input E:\EISOOPEMaker\PE\EISOO_DR_PE.iso -extract E:\EISOOPEMaker\winPE7
rem ultraiso -input E:\EISOOPEMaker\PE\EISOO_DR_PE(WIN8.1_X64).iso -extract E:\EISOOPEMaker\win8PE
rem cd WimTool-V1.30
rem WimTool.EXE E:\EISOOPEMaker\winPE7\BOOT\BOOT.WIM /ExtrFile ,E:\EISOOPEMaker\wim7
rem WimTool.EXE E:\EISOOPEMaker\win8PE\AHPE\81PE\81UP2x64.WIM /ExtrFile ,E:\EISOOPEMaker\wim8


if "%PLATFORM%"=="ALL" (
    set PLATFORM=Windows_All_i386
    set LANG=zh-CN
    call:PEmake

    rd /s/q app
    del /Q *.zip
    del /Q VersionDetails
    set PLATFORM=Windows_All_i386
    set LANG=en-US
    call:PEmake

    rd /s/q app
    del /Q *.zip
    del /Q VersionDetails
    set PLATFORM=Windows_All_x64
    set LANG=zh-CN
    call:PEmake

    rd /s/q app
    del /Q *.zip
    del /Q VersionDetails
    set PLATFORM=Windows_All_x64
    set LANG=en-US
    call:PEmake

) else (
    call:PEmake
)

GOTO:EOF




:PEmake
if "%PLATFORM%"=="Windows_All_i386" (
    set OS_type=wim7
    set WIM=BOOT.WIM
) else (
    set OS_type=wim8
    set WIM=81UP2x64.WIM
)
set PKG="AnyBackupClient_%PLATFORM%-%LANG%-LASTEST.zip"
set PKG_URL="ftp://192.168.123.46/ci-jobs/%ABPREFIX%/package/AnyBackup/client/%PLATFORM%/%PKG%"

"C:\Program Files (x86)\GnuWin32\bin\wget.exe" %PKG_URL%

"C:\Program Files\WinRAR\WinRAR.exe" x %PKG%

Xcopy app "E:\EISOOPEMaker\%OS_type%\Program Files\AB6.0.5.0_Win_i386-zh-CN\app" /s /e /y /k

if "%OS_type%"=="wim8" (
echo 'wim8,remove some file.'
rd /s/q "E:\EISOOPEMaker\wim8\Program Files\AB6.0.5.0_Win_i386-zh-CN\app\bin\bcloudsafedrivers"
rd /s/q "E:\EISOOPEMaker\wim8\Program Files\AB6.0.5.0_Win_i386-zh-CN\app\bin\vddk5.5.5"
del /Q "E:\EISOOPEMaker\wim8\Program Files\AB6.0.5.0_Win_i386-zh-CN\app\bin\*.pdb"
del /Q "E:\EISOOPEMaker\wim8\Program Files\AB6.0.5.0_Win_i386-zh-CN\app\bin\*.lib"
del /Q "E:\EISOOPEMaker\wim8\Program Files\AB6.0.5.0_Win_i386-zh-CN\app\bin\components\*.pdb"
)

type "E:\EISOOPEMaker\VersionDetails" > "E:\EISOOPEMaker\%OS_type%\Program Files\AB6.0.5.0_Win_i386-zh-CN\VersionDetails"

type VersionDetails >> "E:\EISOOPEMaker\%OS_type%\Program Files\AB6.0.5.0_Win_i386-zh-CN\VersionDetails"

del /Q E:\EISOOPEMaker\%WIM%

"E:\EISOOPEMaker\WimTool-V1.30\WimTool.EXE" /BOOT /Compress Fast /Capture "E:\EISOOPEMaker\%OS_type%" "E:\EISOOPEMaker\%WIM%"

if "%OS_type%"=="wim7" (
echo 'wim7 iso'
"E:\EISOOPEMaker\UltraISO.EXE" -input "E:\EISOOPEMaker\PE\EISOO_DR_PE.iso" -rm "/BOOT/BOOT.WIM" -chdir "/BOOT" -f "E:\EISOOPEMaker\BOOT.WIM" -output ".\EISOO_DR_PE_%LANG%.iso"
) else (
echo 'wim8 iso'
"E:\EISOOPEMaker\UltraISO.EXE" -input "E:\EISOOPEMaker\PE\EISOO_DR_PE(WIN8.1_X64).iso" -rm "/AHPE/81PE/81UP2x64.WIM" -chdir "/AHPE/81PE" -f "E:\EISOOPEMaker\81UP2x64.WIM" -output ".\EISOO_DR_WIN8.1PE_%LANG%.iso"
)
GOTO:EOF
