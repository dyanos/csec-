param(
    [switch]$Child,
    [int]$TimeoutSeconds = 10
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$runtimeDir = Join-Path $repoRoot "x64\Debug"
$runtimeDll = Join-Path $runtimeDir "csec_native_runtime.dll"

if (-not (Test-Path $runtimeDll)) {
    Write-Error "Native runtime DLL not found: $runtimeDll"
}

if (-not $Child) {
    $powershell = Join-Path $PSHOME "powershell.exe"
    if (-not (Test-Path $powershell)) {
        $powershell = "powershell.exe"
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $powershell
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Child"
    $psi.WorkingDirectory = $runtimeDir
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.Environment["PATH"] = "$runtimeDir;$($psi.Environment["PATH"])"

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $null = $process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()

    $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
    if ($timedOut) {
        try { $process.Kill() } catch {}
    }
    $process.WaitForExit()

    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    if ($stdout) { Write-Host $stdout.TrimEnd() }
    if ($stderr) { Write-Host $stderr.TrimEnd() }

    if ($timedOut) {
        Write-Host "Timed out after $TimeoutSeconds seconds"
        exit 124
    }
    exit $process.ExitCode
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public static class CsecParallelRuntimeTest {
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void ParallelCallback(IntPtr context, int index);

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern int csec_parallel_get_num_threads();

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern void csec_parallel_set_num_threads(int count);

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern int csec_parallel_backend_available(string name);

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern int csec_parallel_backend_implemented(string name);

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "csec_parallel_for_i32")]
    public static extern void ParallelFor(int start, int end, IntPtr context, ParallelCallback callback);

    [DllImport("csec_native_runtime.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "csec_parallel_for_i32")]
    public static extern void ParallelForRaw(int start, int end, IntPtr context, IntPtr callback);

    static void Require(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }

    public static void MainTest() {
        csec_parallel_set_num_threads(0);
        Require(csec_parallel_get_num_threads() == 1, "thread count should clamp to 1");

        csec_parallel_set_num_threads(4);
        Require(csec_parallel_get_num_threads() == 4, "thread count should store requested value");
        Require(csec_parallel_backend_available("cpu") == 1, "cpu backend should be available");
        Require(csec_parallel_backend_available("simd") == 1, "simd backend should be available");
        Require(csec_parallel_backend_available("gpu") == 0, "gpu backend should not report available");
        Require(csec_parallel_backend_available("unknown") == 0, "unknown backend should not report available");
        Require(csec_parallel_backend_implemented("cpu") == 1, "cpu backend should be implemented");
        Require(csec_parallel_backend_implemented("simd") == 1, "simd backend should be implemented");
        Require(csec_parallel_backend_implemented("gpu") == 0, "gpu backend should not report implemented");

        ParallelForRaw(0, 100, IntPtr.Zero, IntPtr.Zero);

        int sequentialSum = 0;
        ParallelCallback sequential = (ctx, index) => { sequentialSum += index; };
        csec_parallel_set_num_threads(1);
        ParallelFor(0, 100, IntPtr.Zero, sequential);
        Require(sequentialSum == 4950, "single-thread parallel_for produced wrong sum");

        int parallelSum = 0;
        ParallelCallback parallel = (ctx, index) => { Interlocked.Add(ref parallelSum, index); };
        csec_parallel_set_num_threads(8);
        ParallelFor(0, 100, IntPtr.Zero, parallel);
        Require(parallelSum == 4950, "multi-thread parallel_for produced wrong sum");

        int emptyCount = 0;
        ParallelCallback empty = (ctx, index) => { Interlocked.Increment(ref emptyCount); };
        ParallelFor(10, 10, IntPtr.Zero, empty);
        Require(emptyCount == 0, "empty range should not invoke callback");

        int nestedCount = 0;
        ParallelCallback inner = (ctx, index) => { Interlocked.Increment(ref nestedCount); };
        ParallelCallback outer = (ctx, index) => { ParallelFor(0, 32, IntPtr.Zero, inner); };
        csec_parallel_set_num_threads(4);
        ParallelFor(0, 32, IntPtr.Zero, outer);
        Require(nestedCount == 1024, "nested parallel_for should complete without lost callbacks");
    }
}
"@

[CsecParallelRuntimeTest]::MainTest()
Write-Host "Parallel runtime tests passed"
