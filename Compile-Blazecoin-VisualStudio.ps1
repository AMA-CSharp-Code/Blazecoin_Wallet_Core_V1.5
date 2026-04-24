# Compile-Blazecoin-VisualStudio.ps1
# Creates Visual Studio project files and compiles Blazecoin V1.5 using MSVC

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Blazecoin V1.5 Visual Studio Compilation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$srcDir = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\src"
$projectDir = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5"
$vcpkgRoot = "C:\vcpkg"

# Step 1: Verify vcpkg integration
Write-Host "[1/6] Verifying vcpkg integration..." -ForegroundColor Yellow
if (-not (Test-Path "$vcpkgRoot\vcpkg.exe")) {
    Write-Host "[ERROR] vcpkg not found at $vcpkgRoot" -ForegroundColor Red
    exit 1
}

Write-Host "  [OK] vcpkg found" -ForegroundColor Green

# Step 2: Check Visual Studio installation
Write-Host "[2/6] Checking Visual Studio installation..." -ForegroundColor Yellow
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsWhere) {
    $vsPath = & $vsWhere -latest -property installationPath
    Write-Host "  [OK] Visual Studio found at: $vsPath" -ForegroundColor Green
} else {
    Write-Host "  [WARNING] vswhere not found, assuming Visual Studio is installed" -ForegroundColor Yellow
    $vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community"
}

# Step 3: Gather source files
Write-Host "[3/6] Gathering source files..." -ForegroundColor Yellow
$cppFiles = Get-ChildItem "$srcDir" -Filter "*.cpp" | 
    Where-Object { $_.Name -notmatch 'test' -and $_.Name -notmatch 'qt' } |
    Select-Object -ExpandProperty Name

$jsonCppFiles = Get-ChildItem "$srcDir\json" -Filter "*.cpp" -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Name

Write-Host "  Found $($cppFiles.Count) main source files" -ForegroundColor Green
Write-Host "  Found $($jsonCppFiles.Count) JSON source files" -ForegroundColor Green

# Step 4: Create project file (.vcxproj)
Write-Host "[4/6] Creating Visual Studio project file..." -ForegroundColor Yellow

$projectFile = @"
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}</ProjectGuid>
    <Keyword>Win32Proj</Keyword>
    <RootNamespace>Blazecoin</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
    <Import Project="`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props" Condition="exists('`$(UserRootDir)\Microsoft.Cpp.`$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
    <LinkIncremental>false</LinkIncremental>
    <OutDir>`$(SolutionDir)bin\`$(Platform)\`$(Configuration)\</OutDir>
    <IntDir>`$(SolutionDir)obj\`$(Platform)\`$(Configuration)\</IntDir>
    <TargetName>blazecoind</TargetName>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <Optimization>MaxSpeed</Optimization>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <PreprocessorDefinitions>WIN32;_WINDOWS;NDEBUG;_CRT_SECURE_NO_WARNINGS;BOOST_THREAD_USE_LIB;BOOST_SPIRIT_THREADSAFE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <AdditionalIncludeDirectories>$srcDir;$srcDir\json;$srcDir\leveldb\include;$srcDir\leveldb\helpers\memenv;$vcpkgRoot\installed\x64-windows\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <MultiProcessorCompilation>true</MultiProcessorCompilation>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <AdditionalLibraryDirectories>$vcpkgRoot\installed\x64-windows\lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <AdditionalDependencies>ws2_32.lib;shlwapi.lib;mswsock.lib;iphlpapi.lib;libboost_system-vc143-mt.lib;libboost_filesystem-vc143-mt.lib;libboost_program_options-vc143-mt.lib;libboost_thread-vc143-mt.lib;libboost_chrono-vc143-mt.lib;libssl.lib;libcrypto.lib;libdb48.lib;miniupnpc.lib;leveldb.lib;memenv.lib;%(AdditionalDependencies)</AdditionalDependencies>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <LargeAddressAware>true</LargeAddressAware>
    </Link>
  </ItemDefinitionGroup>
  <ItemGroup>
"@

# Add main source files
foreach ($file in $cppFiles) {
    $projectFile += @"

    <ClCompile Include="src\$file" />
"@
}

# Add JSON source files
foreach ($file in $jsonCppFiles) {
    $projectFile += @"

    <ClCompile Include="src\json\$file" />
"@
}

$projectFile += @"

  </ItemGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>
"@

# Save project file
$vcxprojPath = Join-Path $projectDir "Blazecoin.vcxproj"
$projectFile | Out-File -FilePath $vcxprojPath -Encoding utf8
Write-Host "  [OK] Created: $vcxprojPath" -ForegroundColor Green

# Step 5: Create solution file (.sln)
Write-Host "[5/6] Creating Visual Studio solution file..." -ForegroundColor Yellow

$solutionFile = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "Blazecoin", "Blazecoin.vcxproj", "{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Release|x64 = Release|x64
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}.Release|x64.ActiveCfg = Release|x64
		{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}.Release|x64.Build.0 = Release|x64
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
"@

$slnPath = Join-Path $projectDir "Blazecoin.sln"
$solutionFile | Out-File -FilePath $slnPath -Encoding utf8
Write-Host "  [OK] Created: $slnPath" -ForegroundColor Green

# Step 6: Build LevelDB first (required dependency)
Write-Host "[6/6] Building LevelDB dependency..." -ForegroundColor Yellow
Write-Host "  [INFO] LevelDB needs to be built separately first" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Next Steps:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Build LevelDB:" -ForegroundColor Yellow
Write-Host "   cd `"$srcDir\leveldb`"" -ForegroundColor White
Write-Host "   Follow LevelDB build instructions for Windows" -ForegroundColor White
Write-Host ""
Write-Host "2. Open solution in Visual Studio:" -ForegroundColor Yellow
Write-Host "   Start-Process `"$slnPath`"" -ForegroundColor White
Write-Host ""
Write-Host "3. Build in Visual Studio:" -ForegroundColor Yellow
Write-Host "   - Select Release x64 configuration" -ForegroundColor White
Write-Host "   - Build > Build Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "   - Output: bin\x64\Release\blazecoind.exe" -ForegroundColor White
Write-Host ""
Write-Host "OR compile from command line using MSBuild:" -ForegroundColor Yellow
Write-Host "   msbuild `"$slnPath`" /p:Configuration=Release /p:Platform=x64" -ForegroundColor White
Write-Host ""
Write-Host "[OK] Project files created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Would you like me to open the solution in Visual Studio now? (Y/N)" -ForegroundColor Cyan
$response = Read-Host
if ($response -eq 'Y' -or $response -eq 'y') {
    Start-Process $slnPath
    Write-Host "[OK] Opening Visual Studio..." -ForegroundColor Green
}
