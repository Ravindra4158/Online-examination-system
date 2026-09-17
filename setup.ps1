# ==========================================================
# Online Examination System - Automated Setup Script
# ==========================================================
# Prerequisites: Windows 10+, JDK 17+, MySQL Server 8.0
# This script will:
#   1. Add MySQL to PATH
#   2. Find an existing Apache Tomcat 10 installation (or install one)
#   3. Create the database + dedicated user
#   4. Compile Java sources and build WAR
#   5. Deploy WAR to Tomcat and start the server
# ==========================================================

param(
    [string]$MySqlRootUser = "root",
    [string]$MySqlRootPass = "Aj@#1234",
    [string]$DbName = "exam_system",
    [string]$AppDbUser = "exam_user",
    [string]$AppDbPass = "exam_pass_2024"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Helper: safely set a system env var (falls back to user-level if not admin)
function Set-EnvPersistent {
    param([string]$Name, [string]$Value)
    try {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Machine)
    } catch {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::User)
        Write-Host "  (Set at user-level; run as Admin for system-wide)" -ForegroundColor DarkYellow
    }
}

# Helper: safely append to persistent PATH
function Add-ToPathPersistent {
    param([string]$Dir)
    # Always add to current session
    if (-not ($env:Path -split ";" | Where-Object { $_ -eq $Dir })) {
        $env:Path = "$env:Path;$Dir"
    }
    # Try system, fall back to user
    try {
        $sysPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        if (-not ($sysPath -split ";" | Where-Object { $_ -eq $Dir })) {
            [System.Environment]::SetEnvironmentVariable("Path", "$sysPath;$Dir", [System.EnvironmentVariableTarget]::Machine)
        }
    } catch {
        $usrPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
        if (-not ($usrPath -split ";" | Where-Object { $_ -eq $Dir })) {
            [System.Environment]::SetEnvironmentVariable("Path", "$usrPath;$Dir", [System.EnvironmentVariableTarget]::User)
        }
        Write-Host "  (Added to user PATH; run as Admin for system-wide)" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Online Examination System - Setup Script  " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------
# STEP 1: Verify Java JDK
# ----------------------------------------------------------
Write-Host "[1/7] Checking Java JDK..." -ForegroundColor Yellow
try {
    $javacOut = & javac -version 2>&1
    Write-Host "  OK: $javacOut" -ForegroundColor Green
} catch {
    Write-Host "  FAILED: javac not found. Install JDK 11+ and add to PATH." -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------
# STEP 2: Add MySQL bin to PATH (if not already)
# ----------------------------------------------------------
Write-Host "[2/7] Configuring MySQL PATH..." -ForegroundColor Yellow
$mysqlBinDir = "C:\Program Files\MySQL\MySQL Server 8.0\bin"
if (Test-Path $mysqlBinDir) {
    Add-ToPathPersistent -Dir $mysqlBinDir
    Write-Host "  OK: MySQL bin at $mysqlBinDir" -ForegroundColor Green
} else {
    Write-Host "  WARNING: MySQL not found at expected location." -ForegroundColor Red
    Write-Host "  Searching for mysql.exe..." -ForegroundColor Yellow
    $mysqlExe = Get-ChildItem "C:\Program Files\MySQL" -Recurse -Filter "mysql.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($mysqlExe) {
        $mysqlBinDir = $mysqlExe.DirectoryName
        $env:Path = "$env:Path;$mysqlBinDir"
        Write-Host "  Found at: $mysqlBinDir" -ForegroundColor Green
    } else {
        Write-Host "  FAILED: Cannot find MySQL. Install MySQL Server 8.0 and re-run." -ForegroundColor Red
        exit 1
    }
}

# Verify mysql client works
try {
    $mysqlVer = & mysql --version 2>&1
    Write-Host "  OK: $mysqlVer" -ForegroundColor Green
} catch {
    Write-Host "  FAILED: mysql client not working." -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------
# STEP 3: Find or install Apache Tomcat 10
# ----------------------------------------------------------
Write-Host "[3/7] Setting up Apache Tomcat 10..." -ForegroundColor Yellow
$tomcatVersion = "10.1.34"
$tomcatDirName = "apache-tomcat-$tomcatVersion"
$tomcatInstallBase = "$env:USERPROFILE\tomcat"

# Prefer the Tomcat used by the current shell/runtime. This keeps the
# compile-time Servlet API matched with the server that will run the WAR.
$tomcatCandidates = @()
if ($env:CATALINA_HOME) { $tomcatCandidates += $env:CATALINA_HOME }
$tomcatCandidates += (Join-Path $tomcatInstallBase $tomcatDirName)
$tomcatCandidates += Get-ChildItem $tomcatInstallBase -Directory -Filter "apache-tomcat-*" -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending |
    ForEach-Object { $_.FullName }
$tomcatCandidates += "C:\Program Files\Apache Software Foundation\Tomcat 10.1"
$tomcatCandidates = $tomcatCandidates | Select-Object -Unique

$tomcatHome = $tomcatCandidates |
    Where-Object { Test-Path (Join-Path $_ "lib\servlet-api.jar") } |
    Select-Object -First 1

if ($tomcatHome) {
    Write-Host "  OK: Tomcat already installed at $tomcatHome" -ForegroundColor Green
} else {
    $tomcatHome = Join-Path $tomcatInstallBase $tomcatDirName
    $tomcatZipName = "apache-tomcat-$tomcatVersion-windows-x64.zip"
    $tomcatUrl = "https://dlcdn.apache.org/tomcat/tomcat-10/v$tomcatVersion/bin/$tomcatZipName"
    $tomcatZipPath = Join-Path $env:TEMP $tomcatZipName

    Write-Host "  Downloading Tomcat $tomcatVersion from Apache..."
    Write-Host "  URL: $tomcatUrl"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZipPath -UseBasicParsing
    } catch {
        Write-Host "  Primary URL failed, trying archive URL..." -ForegroundColor Yellow
        $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-10/v$tomcatVersion/bin/$tomcatZipName"
        try {
            Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZipPath -UseBasicParsing
        } catch {
            Write-Host "  FAILED: Could not download Tomcat. Please download manually:" -ForegroundColor Red
            Write-Host "  https://tomcat.apache.org/download-10.cgi" -ForegroundColor Yellow
            Write-Host "  Extract to: $tomcatInstallBase" -ForegroundColor Yellow
            exit 1
        }
    }

    Write-Host "  Extracting..."
    if (-not (Test-Path $tomcatInstallBase)) {
        New-Item -ItemType Directory -Path $tomcatInstallBase -Force | Out-Null
    }
    Expand-Archive -Path $tomcatZipPath -DestinationPath $tomcatInstallBase -Force
    Remove-Item $tomcatZipPath -Force
    if (-not (Test-Path (Join-Path $tomcatHome "lib\servlet-api.jar"))) {
        Write-Host "  FAILED: Installed Tomcat is missing lib\servlet-api.jar." -ForegroundColor Red
        exit 1
    }
    Write-Host "  OK: Tomcat installed to $tomcatHome" -ForegroundColor Green
}

# Set CATALINA_HOME
Set-EnvPersistent -Name "CATALINA_HOME" -Value $tomcatHome
$env:CATALINA_HOME = $tomcatHome
Write-Host "  Set CATALINA_HOME = $tomcatHome" -ForegroundColor Green

# Add Tomcat bin to PATH
$tomcatBin = Join-Path $tomcatHome "bin"
Add-ToPathPersistent -Dir $tomcatBin

$startupBat = Join-Path $tomcatBin "startup.bat"

# ----------------------------------------------------------
# STEP 4: Prompt for MySQL root password & setup database
# ----------------------------------------------------------
Write-Host "[4/7] Setting up MySQL database..." -ForegroundColor Yellow
if ([string]::IsNullOrWhiteSpace($MySqlRootPass)) {
    $securePass = Read-Host "  Enter MySQL root password" -AsSecureString
    $MySqlRootPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    )
}

# Write temporary MySQL credentials file (avoids password quoting issues)
$mysqlCnf = Join-Path $env:TEMP "mysql_setup.cnf"
@"
[client]
user=$MySqlRootUser
password=$MySqlRootPass
"@ | Set-Content $mysqlCnf -Encoding ASCII

# Create database
Write-Host "  Creating database '$DbName'..."
$createDbSql = "CREATE DATABASE IF NOT EXISTS $DbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
$result = & mysql --defaults-extra-file="$mysqlCnf" -e $createDbSql 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Remove-Item $mysqlCnf -Force -ErrorAction SilentlyContinue
    Write-Host "  FAILED: Could not create database. Check MySQL root credentials." -ForegroundColor Red
    Write-Host "  $result" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: Database '$DbName' created" -ForegroundColor Green

# Import schema
Write-Host "  Importing schema.sql..."
$schemaPath = Join-Path $ProjectRoot "schema.sql"
$result = Get-Content $schemaPath -Raw | & mysql --defaults-extra-file="$mysqlCnf" 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARNING: Schema import had issues (tables may already exist)" -ForegroundColor Yellow
} else {
    Write-Host "  OK: Schema imported successfully" -ForegroundColor Green
}

# Create dedicated app user
Write-Host "  Creating dedicated MySQL user '$AppDbUser'..."
$userSql = "CREATE USER IF NOT EXISTS '$AppDbUser'@'localhost' IDENTIFIED BY '$AppDbPass'; GRANT ALL PRIVILEGES ON $DbName.* TO '$AppDbUser'@'localhost'; FLUSH PRIVILEGES;"
$result = & mysql --defaults-extra-file="$mysqlCnf" -e $userSql 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARNING: Could not create dedicated user. App will use root." -ForegroundColor Yellow
} else {
    Write-Host "  OK: User '$AppDbUser' created with full access to '$DbName'" -ForegroundColor Green
    Write-Host "  NOTE: To use this user, update DBConnection.java:" -ForegroundColor Cyan
    Write-Host "    DB_USER = `"$AppDbUser`"" -ForegroundColor Cyan
    Write-Host "    DB_PASSWORD = `"$AppDbPass`"" -ForegroundColor Cyan
}

# Clean up credentials file
Remove-Item $mysqlCnf -Force -ErrorAction SilentlyContinue

# ----------------------------------------------------------
# STEP 5: Compile Java sources
# ----------------------------------------------------------
Write-Host "[5/7] Compiling Java sources..." -ForegroundColor Yellow
$srcDir = Join-Path $ProjectRoot "src"
$buildDir = Join-Path $ProjectRoot "build"
$classesDir = Join-Path $buildDir "WEB-INF\classes"

# Clean previous build
if (Test-Path $buildDir) { Remove-Item $buildDir -Recurse -Force }
New-Item -ItemType Directory -Path $classesDir -Force | Out-Null

# Build classpath: Tomcat servlet API + project libs
$tomcatLib = Join-Path $tomcatHome "lib"

# Find the servlet API jar in Tomcat lib
$servletApi = $null
$candidates = @("servlet-api.jar", "jakarta.servlet-api-*.jar")
foreach ($pattern in $candidates) {
    $found = Get-ChildItem $tomcatLib -Filter $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $servletApi = $found.FullName; break }
}
if (-not $servletApi) {
    # Broad search for any servlet jar
    $servletApi = Get-ChildItem $tomcatLib -Filter "*.jar" | Where-Object { $_.Name -match "servlet" } | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $servletApi) {
    Write-Host "  FAILED: Cannot find servlet-api.jar in Tomcat lib." -ForegroundColor Red
    exit 1
}
Write-Host "  Using Servlet API: $(Split-Path $servletApi -Leaf)" -ForegroundColor DarkGray

# Also need JSP API for compilation
$jspApi = Get-ChildItem $tomcatLib -Filter "*.jar" | Where-Object { $_.Name -match "jsp-api|jakarta.servlet.jsp-api" } | Select-Object -First 1 -ExpandProperty FullName

$mysqlJar = Join-Path $ProjectRoot "lib\mysql-connector-j-9.7.0.jar"

$classpath = $servletApi
if ($jspApi) { $classpath = "$classpath;$jspApi" }
$classpath = "$classpath;$mysqlJar"

# Find all .java files
$javaFiles = Get-ChildItem -Path $srcDir -Recurse -Filter "*.java" | ForEach-Object { $_.FullName }
$javaFileCount = $javaFiles.Count
Write-Host "  Found $javaFileCount Java source files"

# Write file list to a temp file (avoid command line length limits)
$fileListPath = Join-Path $env:TEMP "java_sources.txt"
$javaFiles | ForEach-Object { "`"$_`"" } | Set-Content $fileListPath

# Compile
$compileOutput = & javac -d "$classesDir" -classpath "$classpath" "@$fileListPath" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  FAILED: Compilation errors:" -ForegroundColor Red
    Write-Host $compileOutput -ForegroundColor Red
    exit 1
}
Remove-Item $fileListPath -Force -ErrorAction SilentlyContinue
Write-Host "  OK: Compiled $javaFileCount files successfully" -ForegroundColor Green

# ----------------------------------------------------------
# STEP 6: Build WAR and deploy
# ----------------------------------------------------------
Write-Host "[6/7] Building WAR and deploying to Tomcat..." -ForegroundColor Yellow

# Copy WEB-INF (web.xml + lib)
$webInfSrc = Join-Path $ProjectRoot "WebContent\WEB-INF"
$webInfDest = Join-Path $buildDir "WEB-INF"

# Copy web.xml
Copy-Item -Path (Join-Path $webInfSrc "web.xml") -Destination (Join-Path $webInfDest "web.xml") -Force

# Copy lib (MySQL connector)
$libDest = Join-Path $webInfDest "lib"
if (-not (Test-Path $libDest)) { New-Item -ItemType Directory -Path $libDest -Force | Out-Null }
Copy-Item -Path (Join-Path $webInfSrc "lib\*") -Destination $libDest -Recurse -Force

# Copy JSP files
$webContentDir = Join-Path $ProjectRoot "WebContent"
Get-ChildItem $webContentDir -Filter "*.jsp" | ForEach-Object {
    Copy-Item $_.FullName -Destination $buildDir -Force
}

# Copy css/ and js/ directories
$cssDir = Join-Path $webContentDir "css"
if (Test-Path $cssDir) {
    $cssDest = Join-Path $buildDir "css"
    if (-not (Test-Path $cssDest)) { New-Item -ItemType Directory -Path $cssDest -Force | Out-Null }
    Copy-Item -Path "$cssDir\*" -Destination $cssDest -Recurse -Force
}
$jsDir = Join-Path $webContentDir "js"
if (Test-Path $jsDir) {
    $jsDest = Join-Path $buildDir "js"
    if (-not (Test-Path $jsDest)) { New-Item -ItemType Directory -Path $jsDest -Force | Out-Null }
    Copy-Item -Path "$jsDir\*" -Destination $jsDest -Recurse -Force
}

# Create WAR file
$warName = "online_exam.war"
$warPath = Join-Path $ProjectRoot $warName
Write-Host "  Creating $warName..."
Push-Location $buildDir
& jar cf "$warPath" *
Pop-Location
if (-not (Test-Path $warPath)) {
    Write-Host "  FAILED: WAR file not created." -ForegroundColor Red
    exit 1
}
$warSize = [math]::Round((Get-Item $warPath).Length / 1KB, 1)
Write-Host "  OK: WAR created ($warSize KB)" -ForegroundColor Green

# Deploy to Tomcat webapps
$webappsDir = Join-Path $tomcatHome "webapps"
Copy-Item -Path $warPath -Destination $webappsDir -Force
Write-Host "  OK: Deployed to $webappsDir" -ForegroundColor Green

# ----------------------------------------------------------
# STEP 7: Start Tomcat & open browser
# ----------------------------------------------------------
Write-Host "[7/7] Starting Tomcat..." -ForegroundColor Yellow

# Stop any existing Tomcat instance
$shutdownBat = Join-Path $tomcatBin "shutdown.bat"
if (Test-Path $shutdownBat) {
    try { & cmd /c "$shutdownBat" 2>$null } catch { }
    Start-Sleep -Seconds 2
}

# Set JAVA_HOME if not set
if (-not $env:JAVA_HOME) {
    $javaPath = (Get-Command java).Source
    $javaBin = Split-Path $javaPath -Parent
    $env:JAVA_HOME = Split-Path $javaBin -Parent
    Set-EnvPersistent -Name "JAVA_HOME" -Value $env:JAVA_HOME
    Write-Host "  Set JAVA_HOME = $env:JAVA_HOME" -ForegroundColor Green
}

# Start Tomcat
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$startupBat`"" -WindowStyle Normal
Start-Sleep -Seconds 5

$appUrl = "http://localhost:8080/online_exam/"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Application URL: $appUrl" -ForegroundColor White
Write-Host ""
Write-Host "  Default Credentials:" -ForegroundColor White
Write-Host "    Admin:   admin@exam.com / admin123" -ForegroundColor White
Write-Host "    Student: rahul@student.com / student123" -ForegroundColor White
Write-Host ""
Write-Host "  Database: $DbName" -ForegroundColor White
Write-Host "  App DB User: $AppDbUser / $AppDbPass" -ForegroundColor White
Write-Host "  Tomcat: $tomcatHome" -ForegroundColor White
Write-Host ""

# Launch browser
Write-Host "  Opening browser..." -ForegroundColor Yellow
Start-Process $appUrl
