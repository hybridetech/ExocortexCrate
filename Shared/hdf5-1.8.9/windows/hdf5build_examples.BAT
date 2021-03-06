@echo OFF
rem Copyright by The HDF Group.
rem Copyright by the Board of Trustees of the University of Illinois.
rem All rights reserved.
rem
rem This file is part of HDF5.  The full HDF5 copyright notice, including
rem terms governing use, modification, and redistribution, is contained in
rem the files COPYING and Copyright.html.  COPYING can be found at the root
rem of the source code distribution tree; Copyright.html can be found at the
rem root level of an installed copy of the electronic HDF5 document set and
rem is linked from the top-level documents page.  It can also be found at
rem http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have
rem access to either file, you may request a copy from helphdfgroup.org.


rem File Name: hdf5build_examples.bat
rem This batch file is used to build HDF5 C/C++/Fortran examples.
rem This batch file takes the following options:
rem .  /fort             Build HDF5 examples, including Fortran
rem .  /useenv           Build HDF5 examples using compiler settings defined
rem .  /nodebug          Note: Default is to build debug and release versions
rem .                    in the environment, rather than the IDE.
rem .  /?                Help information
rem By Scott Wegner
rem Created: April 1st, 2008
rem Last Updated: April 14, 2008

rem This batch file makes the following assumptions:
rem    - The appropriate version of Visual Studio is installed and setup
rem    - The directory structure is setup from a fresh source copy
rem    - copy_hdf.bat has already been run from the ./windows directory
rem    - HDF5 has already been built using standard settings
rem    - Visual Studio already contains the required paths for external libraries
rem    - szip and zlib DLLs are already placed in an accessible directory
rem    - hdf5_ext_szip or hdf5_ext_zlib have been set accordingly
rem    - if building with the /useenv option, szip and zlib paths have been added
rem      to %include% and %libpath% as necessary.

rem By default, only C and C++ examples are built.

setlocal enabledelayedexpansion
pushd %~dp0

set nerrors=0
if "%1"=="/?" goto help
set blddebug=
set bldrelease=release
goto main

rem Print a help message
:help

    echo.Builds HDF5 example projects.
    echo.
    echo.Usage: %~nx0 [OPTION]
    echo.
    echo.   /fort             Build HDF5 examples, including Fortran
    echo.   /debug            Note: Default is to build release only versions
    echo.   /useenv           Build HDF5 examples using compiler settings defined
    echo.                     in the environment, rather than the IDE.
    echo.   /?                Help information

    exit /b 0


rem Parse through the parameters sent to file, and set appropriate variables
:parse_params

    for %%a in (%*) do (
        if "%%a"=="/fort" (
            rem Enable Fortran
            set hdf5_enablefortran=true
            
        ) else if "%%a"=="/debug" (
            rem Enable Fortran
            set blddebug=debug
            
        ) else if "%%a"=="/useenv" (
            rem Pass /useenv flag to devenv
            set hdf5_useenv=true
            
        ) else (
            rem Set errorlevel 2 to send to help if we receive a bad parameter
            echo.Unknown option: %%a
            call :help
            exit /b 1
        )
    )
    
    exit /b 0


rem Setup our environment
:setup

    rem Constants
    
    echo.Setting up environment
    
    rem Setup Visual Studio environment.  By default, use the Visual Studio 
    rem 2008 environment.
    
    rem Make sure PROCESSOR_ARCHITECURE is set to either x86 or AMD64
    if "%PROCESSOR_ARCHITECTURE%"=="x86" (
        set hdf5_platform=Win32
    ) else if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        set hdf5_platform=x64
    ) else (
        echo.Error: Environment variable PROCESSOR_ARCHITECTURE should contain
        echo.either x86 or AMD64
        exit /b 1
    )
    
    set ccflags=
    
    rem Currently VS2008 is the only compiler supported.
    echo.Using Visual Studio 2008
    
    if not defined hdf5_enablefortran (
        if defined vs90comntools (
            rem This sets the Visual Studio 2008 path and environment variables
            if %hdf5_platform%==Win32 (
                call "%vs90comntools%\..\..\VC\vcvarsall.bat" x86
            ) else (
                call "%vs90comntools%\..\..\VC\vcvarsall.bat" x86_amd64
            )

        ) else (
            echo.Error: Cannot setup Visual Studio 2008 environment.  Please
            echo.make sure VS90COMNTOOLS is defined in the environment.
            exit /b 1
        )
        
    ) else (
        echo.with Intel Visual Fortran 10.1
        
        if defined ifort_compiler10 (
            rem This sets the Intel Fortran 10.1 environment, as well as
            rem setting the appropriate Visual Studio environment
            
            if %hdf5_platform%==Win32 (
                call "%ifort_compiler10%\IA32\Bin\ifortvars.bat"
            ) else (
                call "%ifort_compiler10%\em64t\Bin\ifortvars.bat"
            )
        ) else (
            echo.Error: Cannot setup Intel Fortran 10.1 environment.  Please
            echo.make sure IFORT_COMPILER10 is defined in the environment.
            exit /b 1
        )
    )
    
    rem Setup variables for our SLN files
    set C_SLN=%CD%\windows\examples\allexamples\allexamples.sln
    set CPP_SLN=%CD%\windows\c++\examples\allcppexamples\allcppexamples.sln
    set HL_SLN=%CD%\windows\hl\examples\allhlcexamples\allhlcexamples.sln
    rem We currently don't have HL C++ project files
    if defined hdf5_enablefortran (
        set FORT_SLN=%CD%\windows\fortran\examples\allf90examples\allf90examples.sln
        set HLFORT_SLN=%CD%\windows\hl\fortran\examples\allhlf90examples\allhlf90examples.sln
    ) else (
        set FORT_SLN=
        set HLFORT_SLN=
    )
    
    if defined hdf5_useenv (
        rem This will tell Visual Studio to use include, library, etc. paths
        rem defined by %INCLUDE% %LIBPATH%, etc.  Assume the user has already
        rem added external library paths to these variables.
        set ccflags=%ccflags% /useenv
    )

    exit /b 0


rem Build the HDF5 libraries.  By default, C and C++ libraries are built.
:build

    echo.Building HDF5

    echo.*****************************************************************************
    echo.                        Build HDF5 Examples
    echo.*****************************************************************************
    echo.

    rem TODO: Write code for each of these example sets
    rem Build both debug and release versions
    for %%a in (C CPP HL FORT HLFORT) do (
        if defined %%a_SLN (
            echo.**************************
            echo. Building %%a Examples
            echo.**************************
            for %%b in (%blddebug% %bldrelease%) do (
                echo.Building %%a %%b examples...
                devenv !%%a_SLN! %ccflags% /rebuild %%b
                if !errorlevel! neq 0 (
                    echo.HDF5 %%b %%a examples build failed
                    exit /b
                )
            )
        )
    )

    exit /b


rem Handle errors
:error

    rem For now, our error handling consists of setting nerrors and quitting
    echo.HDF5 examples build failed.
    set /a nerrors=%nerrors%+1
    goto end
    
    rem We'll never really get here, but we keep this line for consistency.
    exit /b


rem This is where the magic happens
:main

    call :parse_params %*
    if %errorlevel% neq 0 (
        rem Error case.
        echo.Error parsing parameters!
        goto error
    )
    
    call :setup
    if %errorlevel% neq 0 (
        echo.Error setting up examples build environment.
        goto error
    )

    call :build
    if %errorlevel% neq 0 (
        echo.Error building HDF5 examples!
        goto error
    )

    if "%nerrors%"=="0" (
        echo. All HDF5 example projects built successfully!
    )
    rem Fall through to end

:end
    popd
    endlocal & exit /b %nerrors%
