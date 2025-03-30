@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

::set /p git_root=<"git rev-parse --show-toplevel"
for /f "tokens=* delims=" %%a in ('git rev-parse --show-toplevel') do set "git_root=%%a"

for /d %%A in (%git_root%\*) do (
	if exist "%%A\CMakeCache.txt" (
		set "cmake_build_folder=%%A"
		goto :cmake_build
	)
)

if exist "%git_root%\build.bat" (
	set "build_folder=%git_root%"
	goto :batch_build
)

if /i "%~x1"==".odin" (
	goto :odin_build
)
if /i "%~x1"==".c" (
	goto :c_build
)
if /i "%~x1"==".cpp" (
	goto :cpp_build
)

echo ERROR: Don't know how to build "%1".
echo        Please modify me at "%0"
exit /B 1

:cmake_build
	:: We need some environment variables set here.
	call :find_msvc

	cmake --build "%cmake_build_folder%"
	if %ERRORLEVEL% NEQ 0 (
		exit /B %ERRORLEVEL%
	)

	if /i "%2"=="run" (
		if exist "%cmake_build_folder%\run.bat" (
			call "%cmake_build_folder%\run.bat"
			exit /B %ERRORLEVEL%
		) else if exist "%git_root%\run.bat" (
			call "%git_root%\run.bat"
			exit /B %ERRORLEVEL%
		) else (
			pushd "%git_root%"
			for /f "delims=" %%F in ("%git_root%") do set project_name=%%~nF
			if exist "%cmake_build_folder%\dst\!project_name!.exe" (
				"%cmake_build_folder%\dst\!project_name!.exe"
			) else if exist "%cmake_build_folder%\!project_name!.exe" (
				"%cmake_build_folder%\!project_name!.exe"
			)
			set exitcode=%ERRORLEVEL%
			popd
			exit /B %exitcode%
		)
		echo ERROR: Could not find an executable to run for this CMake project.
		exit /B 1
	)
	exit /B %ERRORLEVEL%

:get_basename
	set %2=%~n1
	exit /B

:batch_build
	pushd "%build_folder%"
	call build.bat
	set exitcode=%ERRORLEVEL%
	if %exitcode% NEQ 0 (
		popd
		exit /B %exitcode%
	)
	if /i "%2"=="run" (
		if exist ".\run.bat" (
			.\run.bat
			set exitcode=%ERRORLEVEL%
		) else (
			for %%I in (.) do set "project_name=%%~nxI"
			if exist ".\%project_name%.exe" (
				".\%project_name%.exe"
				set exitcode=%ERRORLEVEL%
			) else (
				echo ERROR: Don't know how to run this batch build.
				set exitcode=1
			)
		)
	)
	exit /B %exitcode%

:odin_build
	set odin_subcommand=build
	if /i "%2"=="run" (
		set odin_subcommand=run
	)
	odin %odin_subcommand% "%1" -strict-style -vet -collection:pkg=%~d0:\Repository\NotKyon\pkg
	exit /B %ERRORLEVEL%

:c_build
	call :find_msvc
	if %ERRORLEVEL%==0 (
		cl /nologo /fp:precise /std:clatest /analyze /W4 /sdl /I%~d0:\Repository\axia-sw\axlib\include "%1" "/Fe%~dpn1.exe"
		if errorlevel 1 (
			exit /B %ERRORLEVEL%
		)
		if /i "%2"=="run" (
			"%~dpn1.exe"
		)
		exit /B %ERRORLEVEL%
	)

	call :find_clang
	if %ERRORLEVEL%==0 (
		clang -frounding-math -fexceptions -std=gnu2x -Wall -I%~d0:/Repository/axia-sw/axlib/include "%1" -o "%~dpn1.exe
		if errorlevel 1 (
			exit /B %ERRORLEVEL%
		)
		if /i "%2"=="run" (
			"%~dpn1.exe"
		)
		exit /B %ERRORLEVEL%
	)

	echo ERROR: No suitable C compiler found.
	echo File: %1
	exit /B 1

:cpp_build
	call :find_msvc
	if %ERRORLEVEL%==0 (
		cl /nologo /fp:precise /EHc /EHa /Ge /std:c++latest /await /analyze /W4 /sdl /I%~d0:\Repository\axia-sw\axlib\include "%1" "/Fe%~dpn1.exe"
		if errorlevel 1 (
			exit /B %ERRORLEVEL%
		)
		if /i "%2"=="run" (
			"%~dpn1.exe"
		)
		exit /B %ERRORLEVEL%
	)

	call :find_clang
	if %ERRORLEVEL%==0 (
		clang++ -frounding-math -fexceptions -std=c++latest -fcoroutines -Wall -I%~d0:/Repository/axia-sw/axlib/include "%1" -o "%~dpn1.exe"
		if errorlevel 1 (
			exit /B %ERRORLEVEL%
		)
		if /i "%2"=="run" (
			"%~dpn1.exe"
		)
		exit /B %ERRORLEVEL%
	)

	echo ERROR: No suitable C++ compiler found.
	echo File: %1
	exit /B 1

:find_msvc
	where cl 1>NUL 2>NUL
	if %ERRORLEVEL%==0 (
		exit /B 0
	)

	set "vswhere_path=%~dp0\vswhere.exe"

	if "%PROCESSOR_ARCHITECTURE%"=="" (
		set PROCESSOR_ARCHITECTURE=AMD64
		echo WARNING: PROCESSOR_ARCHITECTURE not set. Defaulting to %PROCESSOR_ARCHITECTURE%.
	)

	if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
		set vc_arch=x64
		set vc_tools_arch=x86.x64
		set vc_host_path=HostX64\x64
	) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
		:: lol idk
		set vc_arch=ARM64
		set vc_tools_arch=ARM.ARM64
		set vc_host_path=HostARM64\ARM64
	) else (
		echo ERROR: Unsupported architecture '%PROCESSOR_ARCHITECTURE%'.
		echo Please provide an implementation in "%0".
		exit /B 1
	)

	for /f "usebackq tokens=*" %%i in (`%vswhere_path% -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.%vc_tools_arch% -property installationPath`) do (
		set vc_install_dir=%%i
	)

	if exist "%vc_install_dir%\VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt" (
		set /p vc_version=<"%vc_install_dir%\VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
		set vc_version=!vc_version: =!
	) else (
		set vc_version=14.43.34808
	)

	set "vc_tools_dir=%vc_install_dir%\VC\Tools\MSVC\%vc_version%"

	set "cl_path=%vc_tools_dir%\bin\%vc_host_path%"
	if not exist "%cl_path%\cl.exe" (
		exit /B 1
	)

	set "VSCMD_ARG_HOST_ARCH=%vc_arch%"
	set "VSCMD_ARG_TGT_ARCH=%vc_arch%"
	call "%vc_install_dir%\Common7\Tools\vsdevcmd\core\winsdk.bat"

	set INCLUDE=%__VSCMD_WINSDK_INCLUDE%;%vc_tools_dir%\include;%INCLUDE%
	set LIB=%vc_tools_dir%\lib\%vc_arch%;%LIB%

	::echo WindowsSDKVersion=%WindowsSDKVersion%
	::echo WindowsSDKLibVersion=%WindowsSDKLibVersion%
	::echo UCRTVersion=%UCRTVersion%
	::echo WindowsSdkDir=%WindowsSdkDir%
	::echo UniversalCRTSdkDir=%UniversalCRTSdkDir%
	::echo WindowsSdkBinPath=%WindowsSdkBinPath%
	::echo WindowsSdkVerBinPath=%WindowsSdkVerBinPath%
	::echo WindowsLibPath=%WindowsLibPath%

	set "PATH=%cl_path%;%PATH%"
	exit /B 0

:find_clang
	where clang 1>NUL 2>NUL
	exit /B %ERRORLEVEL%
