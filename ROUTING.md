# 9Router Routing Map

Updated: 2026-08-29

Default strategy: **ordered fallback**. `Combo Round Robin` remains off. User may reorder models from the Combos UI.

## General
- `GENERAL_LIGHT`: `tp/longcat-2` -> `tp/nemotron-lightning` -> `tp/gpt-oss-20b` -> `tp/qwen-35b-fast` -> `tp/mimo-v25-free` -> `ag/gemini-3.5-flash-extra-low` -> `gh/gpt-5.4-mini-free-auto`
- `GENERAL_MEDIUM`: `tp/qwen-3.8-27b` -> `tp/qwen-35b` -> `tp/deepseek-v4-flash` -> `tp/kimi-k3-fast` -> `ag/gemini-3.7-flash-medium` -> `ag/gpt-oss-120b-medium` -> `tp/minimax-m3`
- `GENERAL_STRONG`: `tp/deepseek-v4-pro` -> `tp/glm-52` -> `tp/kimi-k3` -> `ag/claude-sonnet-4-6` -> `ag/claude-opus-4-6-thinking` -> `ag/gemini-3.7-flash-high` -> `cx/gpt-5.6-sol` -> `cx/gpt-5.6-terra`

## Coding
- `CODING_LIGHT`: `tp/codestral-free` -> `tp/kimi-k27-code-fast` -> `tp/north-mini-code` -> `tp/mimo-v25-free` -> `gh/mai-code-1.1-flash` -> `tp/longcat-2` -> `cx/gpt-5.3-codex-spark`
- `CODING_MEDIUM`: `tp/kimi-k27-code` -> `tp/deepseek-v4-flash` -> `tp/qwen-3.8-27b` -> `tp/glm-52-fast` -> `gh/gpt-5.6-luna-free-auto` -> `ag/claude-sonnet-4-6` -> `cx/gpt-5.6-luna` -> `tp/longcat-2`
- `CODING_STRONG`: `tp/deepseek-v4-pro` -> `tp/glm-52` -> `tp/kimi-k3` -> `ag/claude-sonnet-4-6` -> `ag/claude-opus-4-6-thinking` -> `cx/gpt-5.6-sol` -> `cx/gpt-5.6-terra` -> `cx/gpt-5.5` -> `gh/gpt-5.6-luna` -> `tp/minimax-m3`

## Specialized
- `VISION`: vision-capable models across Antigravity, TokenPortal, Codex, GitHub and OpenRouter.
- `LONG_CONTEXT`: 1M-class context models where available, with cross-provider fallbacks.
- `FAST_TOOLS`: low-latency tool-capable models, favoring `*-fast` routes.
- `EMERGENCY_FALLBACK`: intentionally crosses TokenPortal, Antigravity, GitHub, Groq and OpenRouter.
## Free/provider utility routes
- `FREE`: LongCat first, then TokenPortal free coding/general models, then OpenRouter and Groq fallbacks.
- `TPFREE`: TokenPortal free pool.
- `GROQFREE`: Groq OSS/Qwen/Llama pool; keep away from large Hermes prompts when TPM is restrictive.
- `ORFREE`: current OpenRouter free model from live catalog.

## Capacity adapters
- Vision: Gemini 3.7 Flash High, Claude Sonnet 4.6, Kimi K3 Fast, Kimi K2.7 Code Fast, MiniMax M3, GitHub GPT-5.6 Luna Free Auto.
- Audio input: Gemini 3.7/3.6/3.5 Flash low-cost tiers from Antigravity.
- Adapter round-robin is off; order is fallback priority.

## Validation
- `/v1/models` returned 102 models during the repair audit.
- All 14 combo names returned HTTP 200 in targeted chat smoke tests.
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
