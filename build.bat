@echo off
setlocal enabledelayedexpansion
@rem ==============================
@rem = Don't edit this batch file! =
@rem = If you don't have Python 3.9.13, just install it! =
@rem ==============================

@rem Collecting all installed Python versions
set "pythonVersions="
for /f "tokens=*" %%i in ('where python') do (
    for /f "tokens=2 delims= " %%j in ('"%%i" --version') do (
        set "version=%%j"
        set "pythonVersions=!pythonVersions! %%j"
    )
)

@rem Check if any Python versions were found
if not defined pythonVersions (
    echo Python is not installed!
    pause
    exit /b
)

@rem Count the number of Python versions found
set count=0
for %%v in (!pythonVersions!) do (
    set /a count+=1
)

@rem Handle the case where there's only one Python version
if !count! equ 1 (
    for %%v in (!pythonVersions!) do (
        set "selectedPython=%%v"
    )
    @rem Check the version of the single found Python installation
    if "!selectedPython!" neq "3.9.13" (
        echo This script requires Python version 3.9.13, but found version !selectedPython!.
    )
) else (
    @rem Display found Python versions
    echo Found multiple Python versions:
    set count=0
    for %%v in (!pythonVersions!) do (
        set /a count+=1
        echo !count!: %%v
    )

    @rem Ask user to choose a version
    set /p choice="Which version to use (enter number): "
    set "selectedPython="
    set current=0
    for %%v in (!pythonVersions!) do (
        set /a current+=1
        if "!current!"=="!choice!" set "selectedPython=%%v"
    )

    @rem Validate selected version
    if not defined selectedPython (
        echo Invalid choice.
        pause
        exit /b
    )
)

@rem Find the full path of the selected or single Python version
for /f "tokens=1 delims= " %%i in ('where python') do (
    for /f "tokens=2 delims= " %%j in ('"%%i" --version') do (
        if "%%j"=="!selectedPython!" set "pythonExe=%%i"
    )
)

@rem Check python version
set "version="
for /f "tokens=2 delims= " %%a in ('"%pythonExe% --version" 2^>nul') do (
    set "version=%%a"
)

@rem Check python 3.9.13
if "!version!" neq "3.9.13" (
    echo This script requires Python version 3.9.13, but found version !version!.
)

@rem Checking for the presence of libs.txt
if not exist libs.txt (
    echo libs.txt not found!
    pause
    exit /b
)

@rem Reading libs.txt and download libs
(for /f "delims=" %%i in (libs.txt) do (
    set "line=%%i"
    set "line=!line:~0!"
    if "!line!" neq "" (
        echo !line! | find "=" >nul
        if !errorlevel! equ 0 (
            for /f "tokens=1,2 delims==" %%a in ("!line!") do (
                set "name=%%a"
                set "version=%%b"
                set "package=!name!==!version!"
                echo Installing !package!...
                "%pythonExe%" -m pip install !package!
                if !errorlevel! equ 0 (
                    echo !package! installed successfully.
                ) else (
                    echo Error installing !package!
                )
            )
        ) else (
            echo Invalid format for line: !line!
        )
    )
))

@rem Running PyInstaller
echo Running PyInstaller...
"%pythonExe%" -m PyInstaller build.spec --distpath ".EXE"
if !errorlevel! equ 0 (
    echo Build completed successfully.
) else (
    echo Error during build.
)

endlocal
