# HMI Dev Template — Machine Setup Script
# Futtatás: PowerShell (Admin NEM szükséges, kivéve a Firewall részt)
#
# Használat:
#   .\setup-machine.ps1                    # Teljes telepítés
#   .\setup-machine.ps1 -SkipTools        # Csak config, tool-ok nélkül
#   .\setup-machine.ps1 -ProjectPath "C:\MyProject"  # Projekt template másolás

param(
    [switch]$SkipTools,
    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n=== HMI Dev Template Setup ===" -ForegroundColor Cyan
Write-Host "Gep: $env:COMPUTERNAME" -ForegroundColor Gray
Write-Host "User: $env:USERNAME" -ForegroundColor Gray
Write-Host ""

# --- 1. Claude Code user config ---
Write-Host "[1/7] Claude Code user config (agents + commands)..." -ForegroundColor Yellow

$claudeDir = "$env:USERPROFILE\.claude"
$agentsDir = "$claudeDir\agents"
$commandsDir = "$claudeDir\commands"
$skillsDir = "$claudeDir\skills"

# Mappak letrehozasa
if (!(Test-Path $agentsDir)) { New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null }
if (!(Test-Path $commandsDir)) { New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null }
if (!(Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }

# Agent personak masolasa
$agentsSrc = Join-Path $ScriptDir "user-config\agents"
if (Test-Path $agentsSrc) {
    $agents = Get-ChildItem "$agentsSrc\*.md"
    foreach ($a in $agents) {
        Copy-Item $a.FullName "$agentsDir\$($a.Name)" -Force
        Write-Host "  Agent: $($a.BaseName)" -ForegroundColor Green
    }
    Write-Host "  $($agents.Count) agent persona telepitve" -ForegroundColor Green
} else {
    Write-Host "  SKIP: user-config\agents mappa nem talalhato" -ForegroundColor Red
}

# Impeccable commands masolasa
$cmdsSrc = Join-Path $ScriptDir "user-config\commands"
if (Test-Path $cmdsSrc) {
    if (Test-Path "$cmdsSrc\reference") {
        if (!(Test-Path "$commandsDir\reference")) {
            New-Item -ItemType Directory -Path "$commandsDir\reference" -Force | Out-Null
        }
        Copy-Item "$cmdsSrc\reference\*" "$commandsDir\reference\" -Force -Recurse
    }
    $cmds = Get-ChildItem "$cmdsSrc\*.md"
    foreach ($c in $cmds) {
        Copy-Item $c.FullName "$commandsDir\$($c.Name)" -Force
        Write-Host "  Skill: /$($c.BaseName)" -ForegroundColor Green
    }
    Write-Host "  $($cmds.Count) impeccable skill telepitve" -ForegroundColor Green
} else {
    Write-Host "  SKIP: user-config\commands mappa nem talalhato" -ForegroundColor Red
}

# --- 2. Superpowers skill framework ---
Write-Host "`n[2/7] Superpowers skill framework (14 agentic skill)..." -ForegroundColor Yellow

$spDir = "$skillsDir\superpowers"
if (Test-Path $spDir) {
    Write-Host "  superpowers: mar telepitve, pull..." -ForegroundColor Gray
    Push-Location $spDir
    git pull --ff-only 2>$null
    Pop-Location
    Write-Host "  superpowers: frissitve" -ForegroundColor Green
} else {
    Write-Host "  superpowers telepites..." -ForegroundColor Gray
    git clone --single-branch --depth 1 https://github.com/obra/superpowers.git $spDir 2>$null
    Write-Host "  superpowers: 14 skill telepitve (brainstorming, TDD, subagent, debug...)" -ForegroundColor Green
}

# --- 3. gstack skill pack ---
Write-Host "`n[3/7] gstack skill pack (28 skill: /qa, /cso, /ship, /review...)..." -ForegroundColor Yellow

$gsDir = "$skillsDir\gstack"
if (Test-Path $gsDir) {
    Write-Host "  gstack: mar telepitve, pull..." -ForegroundColor Gray
    Push-Location $gsDir
    git pull --ff-only 2>$null
    Pop-Location
    Write-Host "  gstack: frissitve" -ForegroundColor Green
} else {
    Write-Host "  gstack telepites..." -ForegroundColor Gray
    git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git $gsDir 2>$null
    Write-Host "  gstack: 28 skill telepitve (/qa, /cso, /ship, /review, /careful...)" -ForegroundColor Green
}

# Bun check (gstack browser daemonhoz kell, optional)
$bunExists = Get-Command bun -ErrorAction SilentlyContinue
if ($bunExists) {
    Write-Host "  Bun: $(bun --version) — gstack browser daemon elerheto" -ForegroundColor Green
    Push-Location $gsDir
    & ./setup 2>$null
    Pop-Location
} else {
    Write-Host "  Bun: nincs telepitve — gstack /browse skill nem fog mukodni (tobbi igen)" -ForegroundColor DarkYellow
    Write-Host "  Telepites: winget install Oven-sh.Bun" -ForegroundColor Gray
}

# --- 4. Settings.json + hooks ---
Write-Host "`n[4/7] Claude Code settings.json + hooks..." -ForegroundColor Yellow

$settingsPath = "$claudeDir\settings.json"
$settingsSrc = Join-Path $ScriptDir "user-config\settings.json"
if (Test-Path $settingsSrc) {
    if (Test-Path $settingsPath) {
        Write-Host "  settings.json: mar letezik — NEM felulirva (manual merge szukseges)" -ForegroundColor DarkYellow
        Write-Host "  Referencia: $settingsSrc" -ForegroundColor Gray
    } else {
        Copy-Item $settingsSrc $settingsPath -Force
        Write-Host "  settings.json: telepitve (hooks + superpowers session-start)" -ForegroundColor Green
    }
} else {
    Write-Host "  SKIP: user-config\settings.json nem talalhato" -ForegroundColor DarkGray
}

# --- 5. Global Tools ---
if (-not $SkipTools) {
    Write-Host "`n[5/7] Globalis eszkozok..." -ForegroundColor Yellow

    # Node.js
    $nodeExists = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeExists) {
        Write-Host "  Node.js: $(node --version)" -ForegroundColor Green
    } else {
        Write-Host "  HIBA: Node.js nincs telepitve! (nodejs.org)" -ForegroundColor Red
    }

    # promptfoo
    $pfExists = Get-Command promptfoo -ErrorAction SilentlyContinue
    if ($pfExists) {
        Write-Host "  promptfoo: mar telepitve" -ForegroundColor Green
    } else {
        Write-Host "  promptfoo telepites..." -ForegroundColor Gray
        npm install -g promptfoo
        Write-Host "  promptfoo: telepitve" -ForegroundColor Green
    }

    # GitHub CLI
    $ghExists = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghExists) {
        Write-Host "  GitHub CLI: $(gh --version | Select-Object -First 1)" -ForegroundColor Green
    } else {
        Write-Host "  FIGYELMEZTETES: GitHub CLI nincs telepitve (cli.github.com)" -ForegroundColor DarkYellow
    }

    # Python
    $pyExists = Get-Command python -ErrorAction SilentlyContinue
    if ($pyExists) {
        Write-Host "  Python: $(python --version 2>&1)" -ForegroundColor Green
    } else {
        Write-Host "  HIBA: Python nincs telepitve! (python.org)" -ForegroundColor Red
    }

    # Ollama
    $ollamaExists = Get-Command ollama -ErrorAction SilentlyContinue
    if ($ollamaExists) {
        Write-Host "  Ollama: telepitve" -ForegroundColor Green
    } else {
        Write-Host "  Ollama: nincs telepitve — winget install Ollama.Ollama" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "`n[5/7] SKIP: Eszkoz telepites kihagyva (-SkipTools)" -ForegroundColor DarkGray
}

# --- 6. Projekt template masolasa ---
if ($ProjectPath -ne "") {
    Write-Host "`n[6/7] Projekt template masolasa → $ProjectPath..." -ForegroundColor Yellow

    if (!(Test-Path $ProjectPath)) {
        New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    }

    $templateSrc = Join-Path $ScriptDir "project-template"
    $filesToCopy = @("CLAUDE.md", ".mcp.json", ".gitignore")

    foreach ($f in $filesToCopy) {
        $src = Join-Path $templateSrc $f
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $ProjectPath $f) -Force
            Write-Host "  $f" -ForegroundColor Green
        }
    }

    # .vscode mappa
    $vscodeSrc = Join-Path $templateSrc ".vscode"
    if (Test-Path $vscodeSrc) {
        $vscodeDst = Join-Path $ProjectPath ".vscode"
        if (!(Test-Path $vscodeDst)) { New-Item -ItemType Directory -Path $vscodeDst -Force | Out-Null }
        Copy-Item "$vscodeSrc\*" $vscodeDst -Force
        Write-Host "  .vscode/ (extensions.json)" -ForegroundColor Green
    }

    # scripts mappa
    $scriptsSrc = Join-Path $ScriptDir "scripts"
    if (Test-Path $scriptsSrc) {
        $scriptsDst = Join-Path $ProjectPath "scripts"
        if (!(Test-Path $scriptsDst)) { New-Item -ItemType Directory -Path $scriptsDst -Force | Out-Null }
        Copy-Item "$scriptsSrc\*" $scriptsDst -Force
        Write-Host "  scripts/ (chrome-debug.bat, start-dev.bat, start-claude.sh)" -ForegroundColor Green
    }

    Write-Host "  Projekt template masolva!" -ForegroundColor Green
} else {
    Write-Host "`n[6/7] SKIP: Nincs -ProjectPath megadva" -ForegroundColor DarkGray
}

# --- 7. Chrome DevTools Firewall ---
Write-Host "`n[7/7] Chrome DevTools biztonsag..." -ForegroundColor Yellow

$fwRule = Get-NetFirewallRule -DisplayName "Block CDP External" -ErrorAction SilentlyContinue
if ($fwRule) {
    Write-Host "  Firewall szabaly: mar letezik" -ForegroundColor Green
} else {
    Write-Host "  Firewall szabaly hianyzik — admin PowerShell-ben futtasd:" -ForegroundColor DarkYellow
    Write-Host '  New-NetFirewallRule -DisplayName "Block CDP External" -Direction In -LocalPort 9222 -Protocol TCP -RemoteAddress Any -Action Block' -ForegroundColor Gray
}

# --- Summary ---
Write-Host "`n=== Kesz! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Telepitett skill framework-ok:" -ForegroundColor White
Write-Host "  superpowers: brainstorming, writing-plans, subagent-dispatch, TDD, debug..." -ForegroundColor Gray
Write-Host "  gstack:      /qa, /cso, /ship, /review, /careful, /freeze, /retro, /investigate..." -ForegroundColor Gray
Write-Host "  impeccable:  /audit, /polish, /harden, /frontend-design, /teach-impeccable" -ForegroundColor Gray
Write-Host "  agents:      9 persona (Backend Architect, Security Engineer, UI Designer...)" -ForegroundColor Gray
Write-Host ""
Write-Host "Kovetkezo lepesek:" -ForegroundColor White
Write-Host "  1. Uj Claude Code session inditasa → superpowers automatikusan betolt" -ForegroundColor Gray
Write-Host "  2. /teach-impeccable (design kontextus beallitas)" -ForegroundColor Gray
Write-Host "  3. /office-hours (projekt reframe — superpowers)" -ForegroundColor Gray
Write-Host "  4. GitHub PAT: github.com → Settings → Developer settings" -ForegroundColor Gray
Write-Host ""
