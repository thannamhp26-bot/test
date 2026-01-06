@echo off
pushd "%cd%"
cd /d "%~dp0"
mode con lines=30 cols=100
cls
call :checkwinversion
call :startpackage
exit /b 0

:startpackage
if "%usb%"=="true" (
	if %part% GEQ 1 (
		call :unhideusb
		call :scan.label USB-BOOT
		call :checksize X
		call :start
	)
	if %part%==0 (
		call :unhideusb
		call :scan.label USB-BOOT
		call :checksize X
		call :start1
	)
)
if "%externaldisk%"=="true" (
	call :unhidehdd X
	call :scan.label HDD-BOOT
	call :checksize X
	call :start
)
exit /b 0

:copyboot
call :sizefolder ISO_BOOT
if %sizei% LEQ %sizevol% (
	call :extractboot
	call :packageiso3 X:
	call :checksize X
	call :modulkali
	call :modulbootra1n
) else (
	call :notsize
)
exit /b

:packageextract
cls
cd /d "%~dp0ISO_BOOT"
if exist "%~1" (
	cls&echo.& echo %_lang0226_%& echo.
	call :%~2
)
exit /b 0


:packageiso3
cls&echo.& echo %_lang0226_%& echo.
cd /d "%~dp0bin"
for /f "delims=" %%f in (isoboot.list) do (
    cd /d "%~dp0ISO_BOOT"
        if exist "*%%f*.iso" (
            if not exist "%~1\ISO\%%f.iso" (
                xcopy "*%%f*.iso" "%~1\ISO\%%f.iso" /f /s
            )
        )
    cd /d "%~dp0bin"
)

cd /d "%~dp0ISO_BOOT"
exit /b


:extractboot
cd /d "%~dp0bin"
for /f "delims=" %%f in (extractboot.list) do (
    cd /d "%~dp0ISO_BOOT"
        if exist "*%%f*.iso" (
            if not exist "X:\ISO\%%f" (
				cls&echo.& echo %_lang0226_%& echo.
                mkdir "X:\ISO\%%f"
				"%~dp0bin\7z.exe" x "*%%f*.iso" -o"X:\ISO\%%f"  -aoa -y				
            )
        )
    cd /d "%~dp0bin"
)
exit /b 0

:modulkali
if %sizevol% GTR 2800 call :packageextract *kali*linux*.iso copykali
if %sizevol% LEQ 2800 goto :notsize
exit /b 0

:copykali
"%~dp0bin\7z.exe" x "%~dp0ISO_BOOT\*kali-linux*.iso" -o"X:" -x"![BOOT]" -x"!boot" -x"!efi" -x"!g2ldr" -x"!g2ldr.mbr" -x"!setup.exe" -x"!win32-loader.ini" -x"!md5sum.txt" -x"!autorun.inf" -x"!efi.img" -aoa -y
exit /b 0

:modulbootra1n
if %sizevol% GTR 500 call :packageextract *bootra1n*x86_64*.iso copybootra1n
if %sizevol% LEQ 500 goto :notsize
exit /b 0

:copybootra1n
"%~dp0bin\7z.exe" x "%~dp0ISO_BOOT\*bootra1n*x86_64*.iso" -o"X:" -x"![BOOT]" -x"!boot\grub\" -x"!boot\grub\isolinux" -aoa -y
exit /b 0


:start
call "%~dp0bin\colortool.bat"
if "%usb%"=="true" (
	cls& echo.& echo %_lang0221_%& echo.
	echo.& echo   %_lang0222_%& echo   %_lang0224_%& echo   %_lang0230_%& echo.
)
if "%externaldisk%"=="true" (
	cls& echo.& echo %_lang0231_%& echo.
	echo.& echo   %_lang0222_%& echo   %_lang0234_%& echo   %_lang0230_%& echo.
)
set Unhide=
echo.	
set /P Unhide= %_lang0211_%
echo.
IF %Unhide%==1 call :copyboot & goto :endmodul
IF %Unhide%==2 call :fixletteru & goto :end1
IF %Unhide%==e exit
IF %Unhide%==E exit
if not errorlevel 1 goto :start

:start1
call "%~dp0bin\colortool.bat"
if "%usb%"=="true" (
	cls& echo.& echo %_lang0221_%& echo.
	echo.& echo   %_lang0222_%& echo   %_lang0230_%& echo.
)
if "%externaldisk%"=="true" (
	cls& echo.& echo %_lang0231_%& echo.
	echo.& echo   %_lang0222_%& echo   %_lang0230_%& echo.
)
set Unhide=
echo.
set /P Unhide= %_lang0211_%
echo.
IF %Unhide%==1 call :copyboot & goto :endmodul
IF %Unhide%==e exit
IF %Unhide%==E exit
if not errorlevel 1 goto :start1

:unhidehdd
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:*
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:%~1
	exit /b 0

:unhideusb
call :checkwinversion
if "%winv%"=="true" call :win10 X
if "%winv%"=="false" call :win7 X
exit /b

:win7
if %part% GEQ 1 (
	"%~dp0bin\partassist.exe" /hd:%disk% /hide:1
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:%~1
)
if %part%==0 (
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:%~1
)
exit /b 0
:win10
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:%~1
exit /b 0

:fixletter
if "%winv%"=="true" goto :Fixletter10
if "%winv%"=="false" goto :fixwin7
exit /b

:fixletteru
if "%winv%"=="true" goto :Fixletter10
if "%winv%"=="false" goto :fixwin7u
exit /b

:checkwinversion
for %%v in (20,19,18,17,16) do (ver|findstr "10.0.%%v" >NUL&&set "winv=true")
ver|findstr "5.1" >NUL&&set winver="Windows XP"
ver|findstr "6.0" >NUL&&set winver="Windows Vista"
ver|findstr "6.1" >NUL&&set winver="Windows 7"
ver|findstr "6.2" >NUL&&set winver="Windows 8"
ver|findstr "6.3" >NUL&&set winver="Windows 8.1"
ver|findstr "10.0.15" >NUL&&set winver="Windows 10 Version 1703"
ver|findstr "10.0.14" >NUL&&set winver="Windows 10 Version 1607"
ver|findstr "10.0.10" >NUL&&set winver="Windows 10 Version 1511"
if not defined winv set "winv=false"
exit /b

:fixwin7u
call :scan.label USB-BOOT
if %part% GEQ 1 (
	if exist "X:\efi\boot\anhdvboot" (
		"%~dp0bin\partassist.exe" /hd:%disk% /hide:0
		"%~dp0bin\partassist.exe" /hd:%disk% /unhide:1
		"%~dp0bin\bootice.exe" /Device=%disk%:1 /partitions /assign_letter
	) else (
		"%~dp0bin\partassist.exe" /hd:%disk% /unhide:1
		"%~dp0bin\bootice.exe" /Device=%disk%:1 /partitions /assign_letter
	)
)

if %part%==0 (
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
)
exit /b

:Fixletter10
if %part% GEQ 1 (
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:*
	"%~dp0bin\partassist.exe" /hd:%disk% /hide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:1
	"%~dp0bin\bootice.exe" /Device=%disk%:0 /partitions /delete_letter
)
if %part%==0 (
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:Auto
)
exit /b

:fixletterhdd
if %part% GEQ 1 (
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:*
	"%~dp0bin\partassist.exe" /hd:%disk% /hide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:1 /letter:Auto
)
if %part%==0 (
	"%~dp0bin\partassist.exe" /hd:%disk% /unhide:0
	"%~dp0bin\partassist.exe" /hd:%disk% /setletter:0 /letter:Auto
)
exit /b

:notfound
	cls& echo.& echo %_lang0203_%& echo %_lang0204_%& echo %_lang0019_%& color 4f& pause >nul
	goto :endmodul

:notsize
	cls& echo.& echo %_lang0228_%& echo %_lang0019_%& color 4f& pause >nul
	goto :endmodul

:scan.label
for /f %%b in ('wmic volume get driveletter^, label ^| findstr /i "%~1"') do set "ducky=%%b"
if not defined ducky set "restart=true"
exit /b

:check.partitiontable
for /f "tokens=2" %%b in ('wmic path win32_diskpartition get type ^, diskindex ^| find /i "%disk%"') do set "GPT=%%b"
exit /b

:Fixletterrun
if "%usb%"=="true" call :fixletter
if "%externaldisk%"=="true" call :fixletterhdd
exit /b

:checksize
	for /f "tokens=1-3" %%a in ('WMIC LOGICALDISK GET FreeSpace ^,Name ^,Size ^|FINDSTR /I "%~1"') do set "sizevol=%%a"
    set /a "sizevol=(%sizevol%/1024/1024)"
	exit /b

:checksizefile
for /f "tokens=*" %%x in ('dir /s /a /b "%~1"') do set /a "size=%%~zx"
set /a "size=%size%/1024/1024"
exit /b

:sizefolder
    cd /d "%~dp0"
    set /a "sizei=0"
    for /f "tokens=*" %%x in ('dir /s /a /b "%~1"') do set /a "sizei+=%%~zx"
    set /a "sizei=%sizei%/1024/1024"
	exit /b

:endmodul
if "%usb%"=="true" (
	if %part% GEQ 1	call :start
	if %part%==0 call :start1
)

if "%externaldisk%"=="true" (
	if %part% GEQ 1	call :start
	if %part%==0 call :start1
)

:GPTU
cls
echo.& echo %_lang0036_%&echo %_lang0021_% & color 4f & pause >nul
exit

:GPTH
cls
echo.& echo %_lang0037_%&echo %_lang0021_% & color 4f & pause >nul
exit

:end1
cls
if "%winv%"=="true" (
	echo.& echo %_lang0016_%& echo %_lang0011_%& echo %_lang0013_%& echo.
	echo.& echo %_lang0015_%& echo %_lang0014_%& echo.
)
if "%winv%"=="false" (
	echo.& echo %_lang0016_%& echo %_lang0011_%& echo.
	echo.& echo %_lang0027_% %winver%. %_lang0028_%& echo %_lang0029_%& echo %_lang0030_%& echo.
)
echo.
if "%usb%"=="true" (set /P usbok= %_lang0020_%)
if "%externaldisk%"=="true" (goto :end2) 
echo.
IF /I '%usbok%'=='' (
	cls& goto :Hide
)
echo.
IF %usbok%==n exit
IF %usbok%==N exit
IF %usbok%==y call :fixletteru & goto :end1
IF %usbok%==Y call :fixletteru & goto :end1
if not errorlevel 1 call :fixletteru & goto :end1	

:end2
if "%usb%"=="true" (cls& echo.& echo %_lang0016_%& echo %_lang0011_%& echo %_lang0021_%& pause >nul)
if "%externaldisk%"=="true" (cls& echo.& echo %_lang0024_%& echo %_lang0011_%& echo %_lang0021_%& pause >nul)
exit