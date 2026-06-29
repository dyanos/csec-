param(
    [string]$Compiler = ".\x64\Debug\csec++.exe"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$compilerPath = Join-Path $repoRoot $Compiler
$selfhostSource = Join-Path $PSScriptRoot "csec_compiler.csec"
$specSmokeSource = Join-Path $PSScriptRoot "spec_smoke.csec"
$llvmSubsetSource = Join-Path $PSScriptRoot "llvm_subset.csec"
$irOutput = Join-Path $PSScriptRoot "csec_compiler.ll"
$inputIrOutput = Join-Path $PSScriptRoot "input.ll"
$llvmSubsetIrOutput = Join-Path $PSScriptRoot "llvm_subset.ll"
$selfhostSourceRoot = Join-Path $PSScriptRoot "src"
$selfhostImportEntry = Join-Path $selfhostSourceRoot "compiler.csec"
$selfhostImportEntryIrOutput = Join-Path $PSScriptRoot "tmp_import_entry.ll"

if (-not (Test-Path $compilerPath)) {
    Write-Error "Compiler not found: $compilerPath"
}

& (Join-Path $PSScriptRoot "assemble_selfhost.ps1") | Out-Host

$sourceParts = @(
    "compiler.csec",
    "lexer.csec",
    "parser.csec",
    "ir_generator.csec",
    "driver.csec"
)

foreach ($part in $sourceParts) {
    $partPath = Join-Path $selfhostSourceRoot $part
    if (-not (Test-Path $partPath)) {
        Write-Error "Missing split selfhost source: $partPath"
    }
}

function Invoke-CompilerChecked {
    param(
        [string[]]$CompilerArgs
    )

    $output = & $compilerPath @CompilerArgs 2>&1 | Out-String
    $exitCode = $LASTEXITCODE

    if ($output.Length -gt 0) {
        Write-Host $output.TrimEnd()
    }

    if ($exitCode -ne 0) {
        exit $exitCode
    }

    $fatalDiagnostics = @(
        "Error:",
        "Undefined variable",
        "Invalid function",
        "Assignment failed",
        "Return statement with no value"
    )

    foreach ($needle in $fatalDiagnostics) {
        if ($output.Contains($needle)) {
            Write-Error "Compiler output contained diagnostic: $needle"
        }
    }
}

Invoke-CompilerChecked @("--syntax-only", $selfhostSource)
Invoke-CompilerChecked @("--syntax-only", $selfhostImportEntry)
Invoke-CompilerChecked @("--syntax-only", $specSmokeSource)
Invoke-CompilerChecked @("--syntax-only", $llvmSubsetSource)
Invoke-CompilerChecked @("--emit-ir", $selfhostSource, "-o", $irOutput)
Invoke-CompilerChecked @("--emit-ir", $selfhostImportEntry, "-o", $selfhostImportEntryIrOutput)
Invoke-CompilerChecked @("--emit-ir", (Join-Path $PSScriptRoot "input.csec"), "-o", $inputIrOutput)
Invoke-CompilerChecked @("--emit-ir", $llvmSubsetSource, "-o", $llvmSubsetIrOutput)

$source = Get-Content $selfhostSource -Raw
$sourceContracts = @(
    "def tokenize(source: String): String",
    "appendTokenTo(builder, kindString(), slice(source, cursor + 1, end - 1))",
    "appendTokenTo(builder, kindChar(), slice(source, cursor + 1, end - 1))",
    "def lookupFunctionParamType(tokens: String, limit: Int, name: String): String",
    "def lookupFunctionReturnType(tokens: String, name: String): String",
    "val paramType: String = lookupFunctionParamType(tokens, limit, name)"
)

foreach ($needle in $sourceContracts) {
    if (-not $source.Contains($needle)) {
        Write-Error "Missing selfhost source contract: $needle"
    }
}

$ir = Get-Content $irOutput -Raw
$importEntryIr = Get-Content $selfhostImportEntryIrOutput -Raw
$required = @(
    "define ptr @_tokenize",
    "define i1 @_parseProgram",
    "define ptr @_generateBodyAST",
    "define ptr @_generateStatementAST",
    "define ptr @_generateExpressionAST",
    "define i32 @_findTopLevelOperator",
    "define i32 @_findTopLevelMatch",
    "define i32 @_findClosingToken",
    "define i32 @_findStatementParenStart",
    "define i32 @_findStatementBlockStart",
    "define i32 @_countMatchCases",
    "define i32 @_countCommaSeparated",
    "define i32 @_findLastTopLevelToken",
    "define ptr @_summarizePostfixExpression",
    "define i32 @_findLambdaArrow",
    "define ptr @_lambdaCaptureSummary",
    "define i32 @_lambdaParameterCount",
    "define ptr @_summarizeLambdaExpression",
    "define ptr @_typeSummary",
    "define ptr @_statementHeaderExpression",
    "define ptr @_inferExpressionType",
    "define ptr @_lookupFunctionReturnType",
    "define ptr @_localDeclarationType",
    "define ptr @_generateFunctionScopeSymbols",
    "define ptr @_generateFunctionParamSymbols",
    "define i32 @_classMemberStart",
    "define ptr @_classMemberKind",
    "define ptr @_classMemberName",
    "define ptr @_generateClassMemberSymbols",
    "define ptr @_generateClassMemberAST",
    "define ptr @_templateParameterSummary",
    "define ptr @_templateTargetKind",
    "define ptr @_attributeSummary",
    "define ptr @_externalSymbolKind",
    "define ptr @_generateSymbolTable",
    "define ptr @_generateAST",
    "define i32 @_parseReturnIntegerInRange",
    "define ptr @_appendCExpression",
    "define ptr @_cTypeName",
    "define ptr @_declaredLocalType",
    "define ptr @_generateCBody",
    "define ptr @_generateCStatement",
    "define ptr @_generateMainExecutionC",
    "define ptr @_irTypeName",
    "define ptr @_irOperatorName",
    "define i32 @_expressionTopLevelOperator",
    "define ptr @_generateIRExpression",
    "define ptr @_generateIRAssignment",
    "define ptr @_generateIRParamList",
    "define ptr @_generateIRFlatBody",
    "define ptr @_generateIRElseFlatBody",
    "define ptr @_generateIRIf",
    "define ptr @_generateIRWhile",
    "define ptr @_generateIRFor",
    "define ptr @_generateIRBody",
    "define ptr @_generateIRDeclarations",
    "define ptr @_generateIR",
    "define ptr @_generateLLVMMainBody",
    "define ptr @_generateLLVMExpressionI32",
    "define ptr @_generateLLVMExpressionI64",
    "define ptr @_llvmI32Value",
    "define ptr @_llvmI64Value",
    "define ptr @_generateLLVMLoadI64IfIdentifier",
    "define ptr @_lookupFunctionParamType",
    "define ptr @_lookupVisibleValueType",
    "define ptr @_llvmLoadForValueType",
    "define ptr @_llvmI1Value",
    "define ptr @_generateLLVMLocalI32",
    "define ptr @_generateLLVMLocalI64",
    "define ptr @_generateLLVMExpressionF64",
    "define ptr @_generateLLVMLocalF64",
    "define ptr @_generateLLVMLocalPtr",
    "define ptr @_generateLLVMLocalI8",
    "define ptr @_llvmCharI8Value",
    "define ptr @_generateLLVMAssignmentF64",
    "define ptr @_generateLLVMAssignmentPtr",
    "define ptr @_generateLLVMAssignmentI8",
    "define ptr @_generateLLVMLoadIfIdentifier",
    "define ptr @_generateLLVMLoadBoolIfIdentifier",
    "define ptr @_llvmI32CallArgumentValue",
    "define ptr @_generateLLVMCallArgumentLoadsI32",
    "define ptr @_generateLLVMCallArgumentListI32",
    "define ptr @_generateLLVMAssignmentI32",
    "define ptr @_generateLLVMAssignmentI64",
    "define ptr @_generateLLVMConditionI1",
    "define ptr @_generateLLVMExpressionI1",
    "define ptr @_generateLLVMLocalI1",
    "define ptr @_generateLLVMAssignmentI1",
    "define ptr @_generateLLVMFlatBodyI32",
    "define ptr @_generateLLVMIfI32",
    "define ptr @_generateLLVMWhileI32",
    "define ptr @_generateLLVMForI32",
    "define ptr @_generateLLVMReturnI32",
    "define ptr @_generateLLVMMainBodyFromRange",
    "define ptr @_generateLLVMBooleanBodyFromRange",
    "define ptr @_generateLLVMCharBodyFromRange",
    "define ptr @_generateLLVMDoubleBodyFromRange",
    "define ptr @_generateLLVMLongBodyFromRange",
    "define ptr @_generateLLVMPointerBodyFromRange",
    "define ptr @_generateLLVMVoidBodyFromRange",
    "define ptr @_llvmStringLiteralBytes",
    "define ptr @_generateLLVMStringLiteralGlobals",
    "define ptr @_generateLLVMParamList",
    "define ptr @_generateLLVMParamAllocas",
    "define ptr @_generateLLVMFunctionDefinition",
    "define ptr @_generateLLVMModule",
    "define ptr @_generateExecutionC",
    "define i32 @_compileFile"
)

foreach ($needle in $required) {
    if (-not $ir.Contains($needle)) {
        Write-Error "Missing selfhost phase in generated IR: $needle"
    }
    if (-not $importEntryIr.Contains($needle)) {
        Write-Error "Missing imported selfhost phase in generated IR: $needle"
    }
}

$requiredOutputContracts = @(
    "Program",
    "Decl ",
    "Symbol function ",
    "Symbol template ",
    "Symbol attribute ",
    "External function ",
    "Method ",
    "Field ",
    "Expr match cases=",
    "Expr call target=",
    "Expr index target=",
    "Expr array count=",
    "Expr lambda capture=",
    "FunctionType params=",
    "for (int ",
    "; ModuleID = 'csec.selfhost'",
    "define i32 @main()",
    "define i1 @",
    "define i8 @",
    "define double @",
    "define i64 @",
    "define ptr @",
    "@.str.",
    "getelementptr inbounds [",
    " x i8], ptr @.str.",
    "alloca i32",
    "alloca i64",
    "alloca i1",
    "alloca double",
    "alloca ptr",
    "alloca i8",
    "store i1 %",
    "store double %",
    "ret double",
    "store i64 %",
    "ret i64",
    "store ptr %",
    "store i8 ",
    "call i32 @",
    "call i1 @",
    "call i8 @",
    "call double @",
    "call i64 @",
    "call ptr @",
    "br i1",
    "while.cond.",
    "for.cond.",
    "for.body.",
    "for.end.",
    "icmp slt i32",
    "icmp sle i32",
    "ret i32"
)

foreach ($needle in $requiredOutputContracts) {
    if (-not $ir.Contains($needle)) {
        Write-Error "Missing selfhost output contract in generated IR: $needle"
    }
}

Write-Host "Selfhost compiler syntax and IR phase verification passed."
Remove-Item $selfhostImportEntryIrOutput -ErrorAction SilentlyContinue
