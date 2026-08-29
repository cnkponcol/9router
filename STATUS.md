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
