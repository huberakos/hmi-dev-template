# CLAUDE.md — [PROJEKT NÉV]

> Ez a fájl a Claude Code számára készült — a projekt kontextusa.
> A gyökér szintű kontextus: `C:\Antigravity\CLAUDE.md`
> Frissítve: [DÁTUM]

## Projekt

**Cég:** Hubi Metal Industry Kft. (HMI)
**Cél:** [Projekt célja egy mondatban]

## Architektúra

| Alrendszer | Technológia | Mappa |
|------------|-------------|-------|
| **[Alrendszer 1]** | [Tech stack] | `src/` |

## Fejlesztési Szabályok

- Magyar kommentek, angol kód/változónevek
- Komplex feladatnál: Plan mode először, majd implementáció
- Frontend módosítás előtt: `/audit` és `/harden`
- Böngésző tesztelés: gstack `/browse` + `/qa` (NEM chrome-devtools)

## Fontos Fájlok

| Fájl | Leírás |
|------|--------|
| `CLAUDE.md` | Ez a fájl |
| `.mcp.json` | MCP szerver konfigok |

## Böngésző Tesztelés

gstack `/browse` headless Chromium (~100ms per parancs):
- `/qa` — automatikus tesztelés + javítás
- `/browse` — kézi böngészés, screenshot, DOM inspect
- `/design-review` — vizuális audit
- `/benchmark` — Core Web Vitals
- `/canary` — post-deploy monitoring

## Deploy

1. [Deploy lépések...]
2. Tesztelés: [URL]
