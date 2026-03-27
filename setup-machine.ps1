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
Write-Host "[1/5] Claude Code user config (agents + commands)..." -ForegroundColor Yellow

$claudeDir = "$env:USERPROFILE\.claude"
$agentsDir = "$claudeDir\agents"
$commandsDir = "$claudeDir\commands"

# Mappak letrehozasa
if (!(Test-Path $agentsDir)) { New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null }
if (!(Test-Path $commandsDir)) { New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null }

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
    # reference mappa is kell
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

# --- 2. Global Tools ---
if (-not $SkipTools) {
    Write-Host "`n[2/5] Globalis eszkozok telepitese..." -ForegroundColor Yellow

    # Node.js ellenorzes
    $nodeExists = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeExists) {
        Write-Host "  Node.js: $(node --version)" -ForegroundColor Green
    } else {
        Write-Host "  HIBA: Node.js nincs telepitve! (nodejs.org)" -ForegroundColor Red
        Write-Host "  A promptfoo-hoz es MCP szerverekhez szukseges" -ForegroundColor Red
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

    # Python ellenorzes
    $pyExists = Get-Command python -ErrorAction SilentlyContinue
    if ($pyExists) {
        Write-Host "  Python: $(python --version 2>&1)" -ForegroundColor Green
    } else {
        Write-Host "  HIBA: Python nincs telepitve! (python.org)" -ForegroundColor Red
    }
} else {
    Write-Host "`n[2/5] SKIP: Eszkoz telepites kihagyva (-SkipTools)" -ForegroundColor DarkGray
}

# --- 3. MCP Servers (user-level) ---
Write-Host "`n[3/5] MCP szerverek ellenorzese..." -ForegroundColor Yellow

# User-level MCP-k listaja (ezek a claude settings-ben vannak, nem projekt szinten)
$userMcps = @(
    @{ Name = "context-mode"; Package = "context-mode" },
    @{ Name = "github"; Package = "@anthropic-ai/mcp-server-github" }
)

foreach ($mcp in $userMcps) {
    Write-Host "  MCP: $($mcp.Name) — user-level, Claude Code settings-ben konfiguralandod" -ForegroundColor Gray
}

Write-Host "  TIP: Claude Code-ban '/settings' → MCP servers → Add" -ForegroundColor DarkCyan

# --- 4. Projekt template masolasa ---
if ($ProjectPath -ne "") {
    Write-Host "`n[4/5] Projekt template masolasa → $ProjectPath..." -ForegroundColor Yellow

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
        Write-Host "  scripts/ (chrome-debug.bat)" -ForegroundColor Green
    }

    Write-Host "  Projekt template atkopiaolva!" -ForegroundColor Green
    Write-Host "  TIP: Szerkeszd a CLAUDE.md-t a projekt specifikus adatokkal" -ForegroundColor DarkCyan
} else {
    Write-Host "`n[4/5] SKIP: Nincs -ProjectPath megadva" -ForegroundColor DarkGray
    Write-Host "  Hasznalat: .\setup-machine.ps1 -ProjectPath 'C:\Uj\Projekt'" -ForegroundColor DarkGray
}

# --- 5. Chrome DevTools Firewall ---
Write-Host "`n[5/5] Chrome DevTools biztonsag..." -ForegroundColor Yellow

$fwRule = Get-NetFirewallRule -DisplayName "Block CDP External" -ErrorAction SilentlyContinue
if ($fwRule) {
    Write-Host "  Firewall szabaly: mar letezik" -ForegroundColor Green
} else {
    Write-Host "  Firewall szabaly hiányzik — admin PowerShell-ben futtasd:" -ForegroundColor DarkYellow
    Write-Host '  New-NetFirewallRule -DisplayName "Block CDP External" -Direction In -LocalPort 9222 -Protocol TCP -RemoteAddress Any -Action Block' -ForegroundColor Gray
}

# --- Summary ---
Write-Host "`n=== Kesz! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Kovetkezo lepesek:" -ForegroundColor White
Write-Host "  1. Claude Code session-ben: /teach-impeccable  (design kontextus)" -ForegroundColor Gray
Write-Host "  2. GitHub PAT letrehozasa (github.com → Settings → Developer settings)" -ForegroundColor Gray
Write-Host "  3. promptfoo teszt: cd tools-config\promptfoo && promptfoo eval" -ForegroundColor Gray
Write-Host ""
