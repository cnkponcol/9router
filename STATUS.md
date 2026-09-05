# 9Router Current Status

Date: 2026-08-29
Host: `mcp.kuskuskuy.com`
Path: `/home/openclaw/dev/9router`

## Runtime
- 9Router **0.5.55** is running privately on `100.114.241.64:20128` via Tailscale.
- Hermes compatibility endpoint remains `http://127.0.0.1:20130/v1`.
- API-key protection remains enabled; no intentional public exposure.
- SQLite `quick_check`: **ok**, journal mode: WAL.
- Hermes Gateway is active and direct smoke test returned `HERMES_OK`.

## Combo/UI repair
- Root cause of empty Combos page: all LLM combos were incorrectly stored with `kind=fallback`.
- Dashboard only renders combos whose `kind` is empty or `llm`; fallback is a strategy, not a combo kind.
- All 14 LLM combos were normalized to `kind=NULL` and remain ordered-fallback by default.
- Dashboard visibility rule now matches **14/14** combos.
- Stale model IDs were replaced with IDs from the current 9Router `/v1/models` catalog.
## Adapters and Hermes
- Vision Adapter now contains only catalog models with `vision=true`.
- Audio Input Adapter uses Antigravity Gemini models with `audioInput=true`.
- Hermes default route remains `FREE`.
- Hermes delegated/subagent route remains `GENERAL_MEDIUM`.
- Hermes memory is enabled and local routing skill remains active.

## Safety checkpoint
- Pre-fix DB backup: `data/db/data.sqlite.backup-combo-fix-20260829-020207`.
- Do not repeat a full audit unless state changes, an error appears, or a risky change requires it.

## Hermes security hardening — 2026-08-29
- Owner-only Telegram allowlist retained; gateway allow-all explicitly disabled.
- Sensitive Hermes files locked to `600`; core state directories locked to `700`.
- Flagged terminal commands use manual approval with 300s fail-closed timeout plus explicit hard deny rules.
- Secret redaction and checkpoints are enabled; delegated subagent auto-approval is explicitly disabled.
- Hermes file-write tools are restricted to `/home/openclaw`.
- Always-on `SOUL.md` now treats external content as untrusted data and protects Memory/Skills from prompt-injection, secret storage, and unverified third-party instructions.
- Detailed posture: `HERMES_SECURITY.md`.

## 2026-08-29 — Hermes AUTO routing
- Hermes parent remains `FREE`; delegated work now uses logical model `AUTO`.
- Local compatibility shim classifies `AUTO` into task Combos without another LLM call.
- Verified direct routes: GENERAL_LIGHT, CODING_MEDIUM, CODING_STRONG; offline tests also cover CODING_LIGHT, GENERAL_STRONG, FAST_TOOLS, LONG_CONTEXT and explicit route hints.
- Real Hermes delegation confirmed normal PHP debugging routes to `CODING_MEDIUM` after fixing system-prompt-size bias.
- 9Router still owns model order/quota/fallback inside each Combo; model priorities are user-controlled.
- Delegation guardrails: max 60 iterations, max 3 concurrent children, 600s child timeout, subagent auto-approve off.
- Route audit contains metadata only; prompt bodies are not logged.
- Reference: `AUTO_ROUTING.md`.

## 2026-08-29 - Health + quota monitoring
- Added `monitor/healthwatch.py`; routine checks use zero LLM calls.
- Added systemd user timer `hermes-9router-monitor.timer` every 2 minutes.
- Monitor checks 9Router health, AUTO shim, Hermes Gateway, provider state, auth failures, 429/quota events, upstream failures, and cross-provider fallback failure bursts.
- Telegram notifications are transition-based and owner-only; single-provider quota events stay silent while fallback remains available.
- Recovery alerts are sent once; persistent incident reminders are capped at 6 hours.
- Codex AutoPing remains disabled intentionally to avoid spending quota for monitoring.
- Current validation: healthy; 6 active provider connections; synthetic all-route failure detection passed.

## 2026-08-30 - Provider priority reordered
- All mixed-provider Combos now keep TokenPortal (`tp/*`) below every non-TokenPortal model.
- Global preference: Groq -> Antigravity -> Codex -> other existing providers -> TokenPortal.
- Same-provider model ordering preserved. SQLite backup: `data.sqlite.backup-reorder-20260830-001241`.
- Validation: 14 Combos, zero TokenPortal-last violations, SQLite quick_check OK.

## 2026-08-30 — Hermes cost-priority routing
- `FREE` expanded to: Groq -> Antigravity -> Codex -> GitHub/OpenRouter -> TokenPortal last.
- Direct parent `FREE` coding requests are now deterministically rerouted by the local shim to `CODING_LIGHT|MEDIUM|STRONG` even if Hermes does not call `delegate_task`.
- Groq `openai/gpt-oss-120b` was added first to the six main GENERAL/CODING combos; TokenPortal remains after all non-TP models.
- Live test: normal chat resolved Groq; normal coding was classified `CODING_MEDIUM` and resolved Antigravity Claude after Groq could not handle the large request budget.
- Known Groq free constraint: observed TPM limit 8,000 versus a historical Hermes request of 68,554 tokens, so large Hermes contexts will normally fall through to Antigravity.

## 2026-09-01 — Recovery + boot persistence
- Incident: VPS recovery left stale PID files while 9Router (`:20128`) and AUTO compat (`127.0.0.1:20130`) were not running; Hermes Gateway itself stayed active.
- Stale PID files were cleaned and both routing layers were restored; `/api/health` returned `{"ok":true}`.
- Added persistent systemd user services: `9router.service` and `9router-compat.service`.
- Both services are enabled under `default.target`; user lingering is enabled, so they start without an interactive login after reboot.
- Both services use `Restart=always`; Tailscale readiness is waited for up to 120 seconds before launch.
- Controlled restart validation passed: 9Router and compat returned active, ports `20128`/`20130` reopened, monitor reported zero incidents.
- Current health-monitor provider count: 7 active provider connections.

## 2026-09-01 — reboot persistence + Gemini routing repair
- Desktop Commander Remote now has a persistent user systemd service: `desktop-commander-remote.service`.
- Service is enabled, active, `Restart=always`, and user `openclaw` has `Linger=yes`, so it starts again after VPS reboot without an interactive login.
- Startup wrapper prefers the cached Desktop Commander binary and only falls back to `npx` if the cache is missing.
- Removed retired `ag/gemini-3.5-flash-extra-low` references from `EMERGENCY_FALLBACK`, `FREE`, and `GENERAL_LIGHT`.
- Existing `ag/gemini-3.7-flash-low` is preserved/used as the replacement without duplicating entries.
- Pre-change DB backup: `data/db/data.sqlite.backup-gemini37-20260901-140614`.
- SQLite `quick_check`: `ok`; remaining Gemini 3.5 combo refs: `0`.
- 9Router and AUTO compatibility services are active; 9Router health returns `{"ok":true}`.
- Health watcher reports 7 providers and zero incidents.
- Live Hermes routing smoke returned exactly `ROUTE_OK` with no retired Gemini warning.
- Hermes cron gateway is active with 4 jobs; next run is the 18:30 WIB publisher job.
