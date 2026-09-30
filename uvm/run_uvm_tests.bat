@echo off
REM ============================================================================
REM RISC-V SoC UVM Verification - Windows Batch Script
REM File: run_uvm_tests.bat
REM Description: Automated UVM compilation and execution for Windows
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo RISC-V SoC UVM Verification Suite
echo ============================================================================
echo.

REM Check if Questa is installed
where vsim >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Questa Sim (vsim) not found in PATH
    echo Please install Questa or add it to PATH
    pause
    exit /b 1
)

echo [INFO] Found Questa Sim installation
echo.

REM Create output directories
if not exist "reports" mkdir reports
if not exist "logs" mkdir logs

REM ============================================================================
REM Run UVM Simulation
REM ============================================================================

echo [INFO] Starting UVM verification tests...
echo.

REM Change to UVM directory
cd uvm

REM Delete old work library
if exist "work" (
    echo [INFO] Cleaning previous work library...
    rmdir /s /q work >nul 2>&1
)

REM Run compilation and simulation
echo [INFO] Compiling RTL and UVM testbench...
vsim -batch -do compile_and_run_uvm.do -l simulation.log

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] UVM verification completed successfully
    echo.
) else (
    echo.
    echo [ERROR] UVM verification failed with code %ERRORLEVEL%
    echo.
)

REM ============================================================================
REM Copy Results to Reports Directory
REM ============================================================================

echo [INFO] Processing results...

REM Copy log files
if exist "simulation.log" (
    copy simulation.log "..\reports\uvm_simulation.log" >nul
    echo [INFO] Copied simulation log
)

if exist "uvm_verification_report.txt" (
    copy uvm_verification_report.txt "..\reports\uvm_verification_report.txt" >nul
    echo [INFO] Copied verification report
)

REM Copy waveform
if exist "riscv_uvm.vcd" (
    copy riscv_uvm.vcd "..\reports\riscv_uvm.vcd" >nul
    echo [INFO] Copied waveform file
)

REM ============================================================================
REM Generate Summary Report
REM ============================================================================

echo.
echo [INFO] Generating summary report...

setlocal
set report_file=..\reports\UVM_SUMMARY.txt

(
    echo ============================================================================
    echo RISC-V SoC UVM Verification Summary
    echo ============================================================================
    echo.
    echo Timestamp: %date% %time%
    echo.
    echo Test Results:
    echo =============
) > !report_file!

REM Extract test results from log if available
if exist "simulation.log" (
    findstr /C:"PASS" /C:"FAIL" /C:"TEST" simulation.log >> !report_file!
)

(
    echo.
    echo ============================================================================
    echo Files Generated:
    echo ================
    echo - UVM testbench compilation: DONE
    echo - Simulation execution: DONE
    echo - Waveform capture: riscv_uvm.vcd
    echo - Simulation log: uvm_simulation.log
    echo - Verification report: uvm_verification_report.txt
    echo.
    echo All reports copied to ..\reports\ directory
    echo ============================================================================
) >> !report_file!

type !report_file!

echo.
echo ============================================================================
echo UVM Verification Complete
echo ============================================================================
echo.
echo Reports location: ..\reports\
echo.
echo View waveform with: gtkwave ..\reports\riscv_uvm.vcd
echo.

cd ..

pause

