# verify-setup.ps1
# DSC650 TOT Workshop - environment verification
# Run from inside the bigdata-hadoop-hive-lab folder:
#     .\verify-setup.ps1
# Then copy ALL output and send it to the facilitator.

$fail = 0
$warn = 0

function Ok  ($m) { Write-Host "[PASS] $m" -ForegroundColor Green }
function Bad ($m) {
    Write-Host "[FAIL] $m" -ForegroundColor Red
    $script:fail++
}
function Meh ($m) {
    Write-Host "[WARN] $m" -ForegroundColor Yellow
    $script:warn++
}

# wsl.exe emits UTF-16LE, which arrives with null bytes between
# characters. Strip them or no regex will ever match.
function WslText ($cmdArgs) {
    try {
        $raw = & wsl.exe @cmdArgs 2>&1 | Out-String
        return ($raw -replace "`0", "")
    } catch {
        return ""
    }
}

Write-Host ""
Write-Host "=== DSC650 Workshop Environment Check ===" -ForegroundColor Cyan
Write-Host ""

# ---- 1. Windows build ------------------------------------------------
$build = [System.Environment]::OSVersion.Version.Build
if ($build -ge 19041) { Ok "Windows build $build" }
else { Bad "Windows build $build - need 19041 or later" }

# ---- 2. WSL installed ------------------------------------------------
# Note: newer WSL builds no longer print "Default Version" in --status,
# so we check the version banner and the per-distro table instead.
$wslOk = $false

$wslVer = WslText @("--version")
if ($wslVer -match "WSL version:\s*([\d\.]+)") {
    $v = $Matches[1]
    if ([int]($v -split "\.")[0] -ge 2) {
        Ok "WSL version $v installed"
        $wslOk = $true
    } else {
        Bad "WSL version $v - run: wsl --set-default-version 2"
    }
}

if (-not $wslOk) {
    $st = WslText @("--status")
    if ($st -match "not installed" -or $st -eq "") {
        Bad "WSL not installed - run: wsl --install --no-distribution"
    }
    elseif ($st -match "Default Version:\s*2") {
        Ok "WSL 2 is the default version"
        $wslOk = $true
    }
    elseif ($st -match "Default Version:\s*1") {
        Bad "WSL on version 1 - run: wsl --set-default-version 2"
    }
    else {
        Meh "WSL present but version could not be confirmed"
    }
}

# ---- 3. Any WSL 1 distros still around? ------------------------------
$distros = WslText @("-l", "-v")
if ($distros -match "(?m)\s1\s*$") {
    Meh "A WSL 1 distro exists - Docker needs WSL 2 distros"
}

# ---- 4. Docker CLI ---------------------------------------------------
$dockerCli = $false
try {
    $dv = (docker --version 2>&1 | Out-String).Trim()
    if ($dv -match "Docker version") { Ok $dv; $dockerCli = $true }
    else { Bad "Docker not installed" }
} catch { Bad "Docker not installed" }

# ---- 5. Docker engine actually responding ----------------------------
if ($dockerCli) {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Ok "Docker engine is running"
    } else {
        Bad "Docker engine NOT running - start Docker Desktop"
    }
} else {
    Bad "Docker engine NOT running - Docker CLI missing"
}

# ---- 6. docker compose available -------------------------------------
try {
    $cv = (docker compose version 2>&1 | Out-String).Trim()
    if ($cv -match "version") { Ok $cv }
    else { Meh "docker compose not detected" }
} catch { Meh "docker compose not detected" }

# ---- 7. Git ----------------------------------------------------------
try {
    $gv = (git --version 2>&1 | Out-String).Trim()
    if ($gv -match "git version") { Ok $gv }
    else { Bad "Git not installed" }
} catch { Bad "Git not installed" }

# ---- 8. RAM ----------------------------------------------------------
$ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$ram = [math]::Round($ramBytes / 1GB, 1)
if ($ram -ge 8) { Ok "RAM $ram GB" }
else { Meh "RAM $ram GB - pairing recommended" }

# ---- 9. Free disk ----------------------------------------------------
$free = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
if ($free -ge 20) { Ok "Free disk $free GB" }
else { Bad "Free disk $free GB - need at least 20 GB" }

# ---- 10. Repository files --------------------------------------------
$needed = @(
    ".env",
    "lib\postgresql-42.7.4.jar",
    "training\data\ratings.csv"
)
foreach ($f in $needed) {
    if (Test-Path $f) { Ok "Found $f" }
    else { Bad "Missing $f" }
}

# ---- 11. Line endings ------------------------------------------------
if (Test-Path ".\hive-entrypoint.sh") {
    $raw = Get-Content .\hive-entrypoint.sh -Raw
    if ($raw -match "`r") { Bad "CRLF line endings in hive-entrypoint.sh" }
    else { Ok "Line endings OK" }
} else {
    Meh "hive-entrypoint.sh not found - are you in the repo folder?"
}

# ---- 12. Images cached -----------------------------------------------
if ($dockerCli) {
    $imgs = (docker images --format "{{.Repository}}" 2>&1 | Out-String)
    if ($imgs -match "hadoop-namenode") { Ok "Lab images are cached" }
    else { Bad "Images not pulled - run: docker-compose pull" }
}

# ---- Summary ---------------------------------------------------------
Write-Host ""
if ($fail -eq 0) {
    Write-Host "RESULT: PASS - ready for the workshop" -ForegroundColor Green
    if ($warn -gt 0) {
        $msg = "         ($warn warning(s) - review above)"
        Write-Host $msg -ForegroundColor Yellow
    }
} else {
    Write-Host "RESULT: FAIL - $fail issue(s)" -ForegroundColor Red
    $msg = "Copy this whole output and send to the facilitator."
    Write-Host $msg -ForegroundColor Red
}
Write-Host ""
