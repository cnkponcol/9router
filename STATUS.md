# 9Router Current Status

Updated: 2026-09-06
Host: `mcp.kuskuskuy.com`
Canonical path: `/home/openclaw/apps/9router`

## Runtime
- 9Router `0.5.69` runs privately on Tailscale at `100.114.241.64:20128`.
- Hermes compatibility endpoint is `http://127.0.0.1:20130/v1`.
- Runtime is managed by user systemd services `9router.service` and `9router-compat.service` with restart persistence.
- Do not expose private routing services publicly for convenience.

## Routing source of truth
- `ROUTING.md` mirrors the live Combo database and is the human-readable routing reference.
- 14 Combos are active and use ordered fallback; round-robin remains off.
- Live `/v1/models` catalog audit on 2026-09-06 returned 137 model IDs.
- All Combo references currently match that live catalog: zero stale IDs, zero duplicate refs, and every Combo retains TokenPortal fallback.
- In mixed-provider Combos all `tp/*` entries remain after non-TokenPortal providers.
- `GENERAL_STRONG` is quality-first and currently starts with verified `cx/gpt-5.6-sol`, then strong Antigravity/GitHub fallbacks, with TokenPortal trailing.
- `CODING_*` uses verified Codex, Antigravity and GitHub models first, then curated TokenPortal. NVIDIA remains configured but is excluded from automatic coding routes while its tested candidates are unhealthy.
- TokenPortal is the paid safety net and remains the trailing provider tier in mixed Combos.
- Routing Combo policy hash: `92f7201343583f9ecf4dd5f4a13b7140832c990f11c9e6cb7d157b373cf636d4`. It covers Combo names and ordered model lists only.
- Manual coding override `pakai Codex` resolves to `cx/gpt-5.6-sol`; `pakai Token Portal` resolves to the healthy recommended TokenPortal coding model `tp/gpt-56-sol`. Both were verified end-to-end through the compatibility shim.
- Default `FREE` no longer starts with Groq because the normal Hermes prompt exceeded the observed Groq 8K TPM allowance. Groq is retained in dedicated `GROQFREE`; OpenRouter and unhealthy NVIDIA chat candidates are excluded from automatic routes until healthy.

## Hermes integration
- Hermes Agent is on `0.21.0`; parent/default route remains `FREE`.
- Delegated work uses `AUTO` through the local compatibility shim and selects task Combos deterministically.
- Delegation guardrails: max 60 child iterations, max 3 concurrent children, child timeout `600s`, subagent auto-approve off.
- Telegram vision uses logical route `VISION` through the same private compatibility endpoint.
- Native browser verification is available through the Hermes browser tool; exact responsive viewport checks can use the local Chromium runtime fallback.

## Verified capability baseline
- SQLite `PRAGMA quick_check` is `ok` after the 2026-09-06 routing cleanup.
- All 14 logical Combo routes passed bounded chat smoke tests after catalog cleanup.
- Direct Codex route `cx/gpt-5.6-sol` returned `CODEX_OK`.
- Recommended TokenPortal fallbacks are curated by task from live healthy models such as `tp/deepseek-v4-flash`, `tp/minimax-m3`, `tp/glm-53-flash`, `tp/gpt-56-sol`, `tp/claude-sonnet-4-6`, `tp/kimi-k3`, and `tp/kimi-k3-fast`; selected models passed direct endpoint checks during this audit.
- Retired TokenPortal IDs that returned `Model not found` were removed/replaced from Combo chains.
- TokenPortal `deepseek-v4-pro`, retired stale IDs, temporarily disabled Kimi K2.7 Code variants, and other unreliable candidates are excluded from active fallback chains; healthy alternatives are used instead.

## Tooling and code intelligence
- `codebase-memory-mcp` is enabled for Hermes and the indexed production projects are `9router`, `autokuy-pay`, `kuskuskuy-website`, `kuysender`, and `license-manager`.
- Use the graph for structural orientation, then verify material claims against current source/runtime; a stale graph never overrides live files.
- Web search, browser, vision, video analysis, terminal/file/code execution, delegation, memory, cron, TTS, and local Indonesian STT are available to Hermes on Telegram. Image generation and computer-use stay disabled until their real backends are available.

## Automation reliability
- Blogger Pagi/Siang/Malam jobs are pinned to `LONG_CONTEXT` on the custom 9Router endpoint with medium reasoning.
- Blogger failures are delivered to the owner Telegram channel.
- The previous Malam timeout on 2026-09-05 remains historical until the next scheduled run replaces the last-run state; the new `LONG_CONTEXT` route itself passed a smoke test.

## Security baseline
- Telegram/Gateway remain owner-only; allow-all is disabled.
- Dangerous commands stay behind manual approval; delegated agents cannot auto-approve.
- Tirith is enabled fail-closed, checkpoints are enabled, and Hermes update backup policy is `quick`.
- Secrets must never be copied into docs, workstate, logs, Memory, or Skills.

## Resume rule
Read this file plus `ROUTING.md` and the Hermes workstate before material changes. Re-check only affected routes unless an incident or high-risk change requires a broader audit.

## Routing stabilization / monitor correction — 2026-09-06 07:37 WIB
- The synchronized Combo `updatedAt=2026-09-06T00:17:54Z` was traced to the intentional canonical routing restore during final acceptance, not to an autonomous 9Router/health-monitor rewrite.
- Evidence: the accepted/final routing state and live DB share policy hash `92f7201343583f9ecf4dd5f4a13b7140832c990f11c9e6cb7d157b373cf636d4`; an 80-second watch plus a direct health-monitor run left the hash and timestamps unchanged.
- `monitor/healthwatch.py` now aggregates degradation by provider actually referenced by live Combos and treats a multi-connection provider as healthy when at least one active connection is healthy. Unused configured providers no longer trigger a false `provider_major_degradation`; model-lock logging and route/auth/fallback incident checks remain active.
- Post-fix health evaluation returned no incidents; `FREE` and `CODING_MEDIUM` bounded smoke tests passed.
- Recovery files intentionally retained: `data/db/data.sqlite.rollback-pre-final-20260906-071341` and transaction-consistent `data/db/data.sqlite.snapshot-stable-20260906-073650`. Both passed SQLite `quick_check`.
