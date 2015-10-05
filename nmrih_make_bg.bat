@echo off
setlocal

if "%~1" == "" goto :usage

set vpkexe="c:\Program Files (x86)\Steam\SteamApps\common\nmrih\sdk\bin\vpk.exe"
set imagemagick_convert=convert
set vtfcmd=vtfcmd.exe
set destDir=c:\Program Files (x86)\Steam\SteamApps\common\nmrih\nmrih\custom
set tmpdir=source_tmp
set tmpfn=tmp_%~n0

if not exist %vpkexe% call :error_ not_exist_vpkexe
convert -version >nul
if errorlevel 1 call :error_ not_exist_imagemagick_convert
if not exist "%destDir%" call :error_ not_exist_NMRiH_Directory & goto :end_
if not exist "%~1" call :error_ not_exist_input_file & goto :end_

if exist %tmpdir% rmdir /s /q %tmpdir%	

if not exist %tmpdir%\materials\console\background_linux mkdir %tmpdir%\materials\console\background_linux
if errorlevel 1 call :error_ cant_make_directory & goto :end_

rem make .png for VTFcmd
rem   aspect ratio 4:3
%imagemagick_convert% -resize 2048x2048 -gravity center -background black -extent 2048x2048! "%~1" "%tmpfn%_%~n1.png"
if not exist "%tmpfn%_%~n1.png" call :error_ "resize by Imagemagick's convert %tmpfn%_%~n1.png" & goto :end_

rem   aspect ratio 16:9
%imagemagick_convert% -resize 3640x2048 -gravity center -background black -extent 3640x2048 "%~1" "%tmpfn%_%~n1_169tmp.png"
if not exist "%tmpfn%_%~n1_169tmp.png" call :error_ "resize by Imagemagick's convert %tmpfn%_%~n1_169tmp.png" & goto :end_
%imagemagick_convert% -resize 2048!x2048! "%tmpfn%_%~n1_169tmp.png" "%tmpfn%_%~n1_169.png"
if not exist "%tmpfn%_%~n1_169.png" call :error_ "resize by Imagemagick's convert %tmpfn%_%~n1_169.png" & goto :end_

rem make vtf
%vtfcmd% -file "%tmpfn%_%~n1.png" -format "dxt1" -nomipmaps
if not exist "%tmpfn%_%~n1.vtf" call :error_ "convert png to vtf by %vtfcmd% %tmpfn%_%~n1.vtf" & goto :end_
%vtfcmd% -file "%tmpfn%_%~n1_169.png" -format "dxt1" -nomipmaps
if not exist "%tmpfn%_%~n1_169.vtf" call :error_ "convert png to vtf by %vtfcmd% %tmpfn%_%~n1_169.vtf" & goto :end_

copy "%tmpfn%_%~n1.vtf" %tmpdir%\materials\console\background01.vtf
if errorlevel 1 call :error_ file_copy & goto :end_
copy "%tmpfn%_%~n1_169.vtf" %tmpdir%\materials\console\background01_widescreen.vtf
if errorlevel 1 call :error_ file_copy & goto :end_
copy "%tmpfn%_%~n1.vtf" %tmpdir%\materials\console\background_linux\background01.vtf
if errorlevel 1 call :error_ file_copy & goto :end_
copy "%tmpfn%_%~n1_169.vtf" %tmpdir%\materials\console\background_linux\background01_widescreen.vtf
if errorlevel 1 call :error_ file_copy & goto :end_

rem make .vpk
%vpkexe% %tmpdir%
if errorlevel 1 call :error_ vpk_compile & goto :end_

rem move .vpk to nmrih/custom/ and rename it.
move %tmpdir%.vpk "%destDir%\background01_%username%.vpk"
if errorlevel 1 call :error_ "move %tmpdir%.vpk %destDir%\background01_%username%.vpk" & goto :end_
if exist "%destDir%\background01_%username%.vpk.sound.cache" del "%destDir%\background01_%username%.vpk.sound.cache"

rem delte temp files
if exist %tmpdir% rmdir /s /q %tmpdir%	
if exist "%tmpfn%_%~n1.png" del "%tmpfn%_%~n1.png"
if exist "%tmpfn%_%~n1_169tmp.png" del "%tmpfn%_%~n1_169tmp.png"
if exist "%tmpfn%_%~n1_169.png" del "%tmpfn%_%~n1_169.png"
if exist "%tmpfn%_%~n1.vtf" del "%tmpfn%_%~n1.vtf"

echo %destDir%\background01_%username%.vpk

goto :end_

:usage
echo usage : %~nx0 Imagefile^(jpg/png/etc...^)
pause
goto :end_

:error_
if "%~1" == "" (
	echo error unknown.
) else (
	echo error %~1
)
pause
exit /b 0

:end_
