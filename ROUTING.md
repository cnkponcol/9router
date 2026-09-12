# 9Router Routing Map

Updated: 2026-09-06

Default strategy: **ordered fallback**. `Combo Round Robin` remains off. Provider priority follows the owner policy below.

## Provider priority (owner policy)
- Active automatic routes are **availability-first inside the owner policy**: use currently verified healthy providers/models, keep TokenPortal trailing, and do not make a failing provider block every request. Provider connections may remain configured even when temporarily excluded from automatic Combos.
- TokenPortal is the paid safety net: every Combo must contain at least one `tp/*` fallback, and all `tp/*` entries stay after non-TokenPortal entries.
- Model order is changed only from explicit owner policy or verified health/capability evidence; `ROUTING.md` mirrors the live DB.
- `GENERAL_STRONG` is quality-first and currently starts with verified Codex GPT-5.6 Sol, followed by strong Antigravity/GitHub fallbacks and curated TokenPortal.

## General
- `GENERAL_LIGHT`: `gh/gpt-4o` -> `cx/gpt-5.4-mini` -> `ag/gemini-3.7-flash-medium` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash`
- `GENERAL_MEDIUM`: `gh/gpt-4.1` -> `cx/gpt-5.6-luna` -> `ag/claude-sonnet-4-6` -> `ag/gemini-3.7-flash-medium` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash` -> `tp/minimax-m3`
- `GENERAL_STRONG`: `cx/gpt-5.6-sol` -> `ag/claude-opus-4-6-thinking` -> `ag/claude-sonnet-4-6` -> `gh/gpt-4.1` -> `ag/gemini-3.7-flash-high` -> `tp/claude-sonnet-4-6` -> `tp/gpt-56-sol` -> `tp/kimi-k3`

## Coding
- `CODING_LIGHT`: `cx/gpt-5.4-mini` -> `gh/gpt-4.1` -> `ag/claude-sonnet-4-6` -> `ag/gemini-3.7-flash-medium` -> `tp/deepseek-v4-flash` -> `tp/minimax-m3`
- `CODING_MEDIUM`: `cx/gpt-5.6-luna` -> `ag/claude-sonnet-4-6` -> `gh/gpt-4.1` -> `ag/gemini-3.7-flash-medium` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash` -> `tp/gpt-56-sol`
- `CODING_STRONG`: `cx/gpt-5.6-sol` -> `ag/claude-opus-4-6-thinking` -> `ag/claude-sonnet-4-6` -> `gh/gpt-4.1` -> `ag/gemini-3.7-flash-high` -> `tp/claude-sonnet-4-6` -> `tp/gpt-56-sol` -> `tp/glm-53-flash` -> `tp/kimi-k3`

## Specialized
- `VISION`: `ag/gemini-3.7-flash-high` -> `gh/gpt-4o` -> `cx/gpt-5.6-sol` -> `ag/claude-sonnet-4-6` -> `tp/kimi-k3-fast` -> `tp/glm-53-flash` -> `tp/kimi-k3`
- `LONG_CONTEXT`: `ag/gemini-3.7-flash-medium` -> `ag/claude-sonnet-4-6` -> `gh/gpt-4.1` -> `cx/gpt-5.6-luna` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash` -> `tp/kimi-k3`
- `FAST_TOOLS`: `cx/gpt-5.4-mini` -> `gh/gpt-4.1` -> `ag/gemini-3.7-flash-medium` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash`
- `EMERGENCY_FALLBACK`: `gh/gpt-4o` -> `cx/gpt-5.4-mini` -> `ag/gemini-3.7-flash-medium` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash`

## Free/provider utility routes
- `FREE`: `gh/gpt-4o` -> `ag/gemini-3.7-flash-medium` -> `cx/gpt-5.4-mini` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash`
- `TPFREE`: `tp/minimax-m3` -> `tp/deepseek-v4-flash` -> `tp/glm-53-flash` -> `tp/kimi-k3-fast`
- `GROQFREE`: `groq/openai/gpt-oss-120b` -> `groq/qwen/qwen3-32b` -> `groq/llama-3.3-70b-versatile` -> `gh/gpt-4o` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash`
- `ORFREE`: `gh/gpt-4o` -> `cx/gpt-5.4-mini` -> `tp/minimax-m3` -> `tp/deepseek-v4-flash`

## Capacity adapters
- Vision: verified Antigravity Gemini 3.7 Flash High first, then GitHub GPT-4o, Codex GPT-5.6 Sol, Claude Sonnet, followed by curated TokenPortal Kimi K3 Fast / GLM-5.3 Flash / Kimi K3.
- Audio input: Hermes Telegram STT uses local faster-whisper for Indonesian voice notes; model-routing audio capability remains separate from chat Combo routing.
- Adapter round-robin is off; order is fallback priority.
- TokenPortal recommendations are curated from currently supported/reliable package models plus live endpoint tests; unavailable or unstable IDs are not kept merely because they appear in a catalog.

## Current provider-health routing note — 2026-09-06
- Codex GPT-5.6 Sol/Luna and GPT-5.4 Mini passed direct checks.
- GitHub GPT-4.1 and GPT-4o passed direct checks.
- Antigravity Gemini 3.7 Medium/High and Claude Sonnet/Opus passed direct checks; Gemini 3.7 Low was rate-limited during the audit and is not used in automatic routes.
- Tested NVIDIA chat candidates returned 410 Gone or 429, so NVIDIA remains configured but is excluded from automatic Combo paths until healthy.
- Groq exceeded its 8K TPM allowance with the normal Hermes prompt, so it is isolated to `GROQFREE` rather than delaying default `FREE`.
- OpenRouter returned an expired-key 401, so it is excluded from automatic Combo paths; `ORFREE` remains as a compatibility route using healthy non-OpenRouter fallbacks.
- TokenPortal remains last in mixed Combos and uses only curated healthy recommendations.

## Validation
- `/v1/models` returned 137 models during the 2026-09-06 catalog audit.
- All 14 combo names returned HTTP 200 in targeted chat smoke tests.
- All Combo model references match the live catalog; no stale model IDs remain, no duplicate refs remain, and TokenPortal entries are trailing in every mixed Combo.
- Hermes direct route returned `HERMES_OK` after the repair.
- Some reasoning models can consume a very small `max_tokens` budget before emitting visible text; HTTP 200 plus resolved upstream model confirmed routing.

## Hermes AUTO selection (active 2026-08-29)
- Parent/supervisor stays on `FREE` for chat, coordination, and simple direct operations.
- `delegate_task` uses logical model `AUTO` through `127.0.0.1:20130/v1`.
- Hermes may provide `[HERMES_ROUTE:<COMBO>]`; otherwise the local deterministic classifier selects the task Combo.
- Classification has no separate LLM/API call and does not alter model order inside Combos.
- 9Router remains authoritative for ordered model fallback, provider health/quota behavior, and model availability.
- Complexity uses the delegated goal rather than Hermes' large system prompt, preventing false escalation.
- Details and validated rules are in `AUTO_ROUTING.md`.
