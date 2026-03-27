# HMI Dev Template

Fejlesztői környezet sablon — új gépek és projektek gyors beüzemeléséhez.

## Mit tartalmaz?

| Mappa | Tartalom |
|-------|----------|
| `project-template/` | Alap projekt fájlok (CLAUDE.md, .mcp.json, .gitignore, .vscode) |
| `user-config/agents/` | 9 Claude Code agent persona (~/.claude/agents/) |
| `user-config/commands/` | 5 Impeccable Design skill + 7 referencia (~/.claude/commands/) |
| `scripts/` | Chrome DevTools debug indító (chrome-debug.bat) |
| `tools-config/promptfoo/` | promptfoo eval sablon (LiteLLM lokális modellekkel) |
| `setup-machine.ps1` | Automatikus telepítő script |

## Gyors Telepítés

### 1. Teljes telepítés (új gép)

```powershell
git clone https://github.com/huberakos/hmi-dev-template.git
cd hmi-dev-template
.\setup-machine.ps1
```

Ez telepíti:
- Agent personákat → `~/.claude/agents/`
- Impeccable skilleket → `~/.claude/commands/`
- Ellenőrzi: Node.js, Python, promptfoo, GitHub CLI

### 2. Új projekt létrehozása

```powershell
.\setup-machine.ps1 -ProjectPath "C:\Antigravity\UjProjekt"
```

Ez átmásolja a projekt template-et:
- `CLAUDE.md` — szerkeszd a projekt specifikus adatokkal
- `.mcp.json` — Chrome DevTools MCP (bővítsd projekt MCP-kkel)
- `.gitignore` — standard kizárások
- `.vscode/extensions.json` — ajánlott VS Code bővítmények
- `scripts/chrome-debug.bat` — Chrome debug mód

### 3. Csak config (tool-ok nélkül)

```powershell
.\setup-machine.ps1 -SkipTools
```

## Agent Personák

| Persona | Leírás |
|---------|--------|
| Backend Architect | Frappe modul tervezés, API architektúra |
| DevOps Automator | Docker, deploy pipeline, nginx konfig |
| Security Engineer | Biztonsági audit, kódellenőrzés |
| Frontend Developer | Custom page fejlesztés, JS/CSS |
| AI Engineer | AI service fejlesztés, ML pipeline |
| SRE | Szerver monitoring, incident response |
| Database Optimizer | MariaDB tuning, lekérdezés optimalizálás |
| UI Designer | UI/UX tervezés, design döntések |
| Evidence Collector | QA teszt dokumentáció |

Aktiválás Claude Code-ban: `"Használd a Backend Architect agentet"`

## Impeccable Design Skills

| Skill | Leírás |
|-------|--------|
| `/audit [terület]` | Frontend minőség audit (0-20 pont) |
| `/polish` | Utolsó simítás deploy előtt |
| `/harden` | Error handling, edge case-ek kezelése |
| `/frontend-design` | UI implementáció design elvekkel |
| `/teach-impeccable` | Első futtatás: projekt design kontextus beállítás |

## Chrome DevTools Debug

```cmd
scripts\chrome-debug.bat                          # localhost:8000
scripts\chrome-debug.bat http://192.168.3.110:8080  # ERPNext szerver
```

A Chrome debug módban indul (CDP 9222), a `chrome-devtools` MCP automatikusan csatlakozik.

## Promptfoo

```bash
cd tools-config/promptfoo
# LiteLLM proxy-n keresztül (lokális Ollama modellek):
LITELLM_URL=http://10.0.20.100:4000 promptfoo eval
promptfoo view   # Dashboard
```

## Firewall (Chrome DevTools)

A `setup-machine.ps1` ellenőrzi a tűzfal szabályt. Ha hiányzik, admin PowerShell-ben:

```powershell
New-NetFirewallRule -DisplayName "Block CDP External" -Direction In -LocalPort 9222 -Protocol TCP -RemoteAddress Any -Action Block
```

## Gépek

| Gép | Használat |
|-----|-----------|
| **Laptop** | Fejlesztés, Claude Code, Inventor 2026 |
| **HW1** | Napi fejlesztés, éjszakai batch, Unsloth |
| **HW2** | Docker stack, Ollama, 24/7 szerver |

Minden gépre: `git clone` + `.\setup-machine.ps1` → kész.
