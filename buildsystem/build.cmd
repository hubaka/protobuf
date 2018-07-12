@echo off

rem setting the path for python32 exe 
set PYTHON_EXE_PATH=C:\Python32
rem concatenating the python exe path with python exe
set PYTHON=%PYTHON_EXE_PATH%\python.exe
rem setting the path for python script which shall be used to start the build
set PYTHON_BUILD=buildpython\

rem get the current folder path to set as module path for cmake
set BUILD_SYSTEM_PATH=%cd%

rem
rem replacing the token \ with /
rem because cmake takes the path with token / as valid path.
rem 
set BUILD_SYSTEM_PATH=%BUILD_SYSTEM_PATH:\=/%

rem set path of cmake exectuable
set CMAKE_EXECUTABLE_PATH=.\cmake-3.10.0-rc4-win64-x64\bin\
set CMAKE_SOURCE_DIRECTORY=..\application
set CMAKE_BUILD_DIRECTORY=..\1_builds
set VISUAL_STUDIO_COMPILER_VERSION="Visual Studio 14"
set CMAKE_SEARCH_PATH=%BUILD_SYSTEM_PATH%/scripts

rem setting cmake command line flags
set CMAKE_SOURCE_DIR_FLAG=-H%CMAKE_SOURCE_DIRECTORY%
set CMAKE_BUILD_DIR_FLAG=-B%CMAKE_BUILD_DIRECTORY%
set CMAKE_MODULE_DIR_FLAG=-DCMAKE_MODULE_PATH=%CMAKE_SEARCH_PATH%
set CMAKE_RELEASE_BUILD_TYPE=-DCMAKE_BUILD_TYPE=Release
set CMAKE_DEBUG_BUILD_TYPE=-DCMAKE_BUILD_TYPE=Debug
set INSTALL_DIRECTORY=-DPROJECT_INSTALL_DIRECTORY=%BUILD_SYSTEM_PATH%/../1_builds/install
set CMAKE_GENERATOR_FLAG=-G %VISUAL_STUDIO_COMPILER_VERSION%
set CMAKE_RELEASE_COMPILE_FLAG=%CMAKE_SOURCE_DIR_FLAG% %CMAKE_BUILD_DIR_FLAG% %CMAKE_MODULE_DIR_FLAG% %CMAKE_RELEASE_BUILD_TYPE% %INSTALL_DIRECTORY% %CMAKE_GENERATOR_FLAG%
set CMAKE_DEBUG_COMPILE_FLAG=%CMAKE_SOURCE_DIR_FLAG% %CMAKE_BUILD_DIR_FLAG% %CMAKE_MODULE_DIR_FLAG% %CMAKE_DEBUG_BUILD_TYPE% %INSTALL_DIRECTORY% %CMAKE_GENERATOR_FLAG%
set CMAKE_BUILD_FLAG=--build %CMAKE_BUILD_DIRECTORY%

rem calling the python sript which shall be used to start the build
rem %PYTHON% %PYTHON_BUILD%build_python.py

FOR %%A IN (%*) DO (
    REM Now your batch file handles %%A instead of %1
    REM No need to use SHIFT anymore.
	
	IF "%%A" == "rel" (
		%CMAKE_EXECUTABLE_PATH%cmake.exe %CMAKE_RELEASE_COMPILE_FLAG%
		%CMAKE_EXECUTABLE_PATH%cmake.exe %CMAKE_BUILD_FLAG%
	)
	IF "%%A" == "deb" (
		%CMAKE_EXECUTABLE_PATH%cmake.exe %CMAKE_DEBUG_COMPILE_FLAG%
		%CMAKE_EXECUTABLE_PATH%cmake.exe %CMAKE_BUILD_FLAG%
	)
	IF "%%A" == "c" (
		RD /S /Q %CMAKE_BUILD_DIRECTORY%
	)
	
)