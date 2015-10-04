@echo off
setlocal
set vpkexe="c:\Program Files (x86)\Steam\SteamApps\common\nmrih\sdk\bin\vpk.exe"
set destDir="c:\Program Files (x86)\Steam\SteamApps\common\nmrih\nmrih\custom"

if "%~1" == "" goto :usage
pushd %~dp1
if "%~x1" == ".vpk" (
	%vpkexe% l %1
) else (
	%vpkexe% %1
	if errorlevel 1 goto :error_
	move %~n1.vpk %destDir%
)
pause
goto :end_

:usage
echo ugage: %~nx0 xxx.vpk        -^> display vpk information.
echo        %~nx0 file/directory -^> make .vpk
echo.
pause
goto :end_

:error_
echo vpk.exe error
pause
goto :end_

:end_
popd
