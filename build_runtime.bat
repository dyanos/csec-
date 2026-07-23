@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul
cd /d C:\Users\dyano\Projects\csec-
if not exist build_runtime mkdir build_runtime
cl /nologo /c /EHsc /MDd /std:c++17 /Zi /permissive- /utf-8 /openmp ^
   /DCSEC_NATIVE_RUNTIME_BUILD /D_CRT_SECURE_NO_WARNINGS /D_WINSOCK_DEPRECATED_NO_WARNINGS /D_DEBUG ^
   /Isrc /Fobuild_runtime\NativeRuntime.obj /Fdbuild_runtime\ src\NativeRuntime.cpp
if errorlevel 1 exit /b 1
link /nologo /DLL /DEBUG /OUT:build_runtime\System.Native.dll /IMPLIB:build_runtime\System.Native.lib ^
   build_runtime\NativeRuntime.obj ws2_32.lib
if errorlevel 1 exit /b 1
copy /y build_runtime\System.Native.dll x64\Debug\System.Native.dll >nul
if errorlevel 1 exit /b 1
copy /y build_runtime\System.Native.lib x64\Debug\System.Native.lib >nul
if errorlevel 1 exit /b 1
echo BUILD_OK
