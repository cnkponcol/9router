# 9Router Routing Map

Updated: 2026-08-30

Default strategy: **ordered fallback**. `Combo Round Robin` remains off. Provider priority follows the owner policy below.

## Provider priority (owner policy)
- Global priority: **Groq -> Antigravity/Google -> OpenAI Codex -> other existing providers -> TokenPortal**.
- TokenPortal is paid, so `tp/*` stays below every non-TokenPortal model in mixed-provider Combos.
- Relative model order inside the same provider is preserved unless explicitly changed.

## General
- `GENERAL_LIGHT`: `ag/gemini-3.5-flash-extra-low` -> `gh/gpt-5.4-mini-free-auto` -> `tp/longcat-2` -> `tp/nemotron-lightning` -> `tp/gpt-oss-20b` -> `tp/qwen-35b-fast` -> `tp/mimo-v25-free`
- `GENERAL_MEDIUM`: `ag/gemini-3.7-flash-medium` -> `ag/gpt-oss-120b-medium` -> `tp/qwen-3.8-27b` -> `tp/qwen-35b` -> `tp/deepseek-v4-flash` -> `tp/kimi-k3-fast` -> `tp/minimax-m3`
- `GENERAL_STRONG`: `ag/claude-sonnet-4-6` -> `ag/claude-opus-4-6-thinking` -> `ag/gemini-3.7-flash-high` -> `cx/gpt-5.6-sol` -> `cx/gpt-5.6-terra` -> `tp/deepseek-v4-pro` -> `tp/glm-52` -> `tp/kimi-k3`

## Coding
- `CODING_LIGHT`: `cx/gpt-5.3-codex-spark` -> `gh/mai-code-1.1-flash` -> `tp/codestral-free` -> `tp/kimi-k27-code-fast` -> `tp/north-mini-code` -> `tp/mimo-v25-free` -> `tp/longcat-2`
- `CODING_MEDIUM`: `ag/claude-sonnet-4-6` -> `cx/gpt-5.6-luna` -> `gh/gpt-5.6-luna-free-auto` -> `tp/kimi-k27-code` -> `tp/deepseek-v4-flash` -> `tp/qwen-3.8-27b` -> `tp/glm-52-fast` -> `tp/longcat-2`
- `CODING_STRONG`: `ag/claude-sonnet-4-6` -> `ag/claude-opus-4-6-thinking` -> `cx/gpt-5.6-sol` -> `cx/gpt-5.6-terra` -> `cx/gpt-5.5` -> `gh/gpt-5.6-luna` -> `tp/deepseek-v4-pro` -> `tp/glm-52` -> `tp/kimi-k3` -> `tp/minimax-m3`

## Specialized
- `VISION`: `ag/gemini-3.7-flash-high` -> `ag/claude-sonnet-4-6` -> `cx/gpt-5.6-sol` -> `gh/gpt-5.6-luna-free-auto` -> `openrouter/minimax/minimax-m3:free` -> `tp/kimi-k3-fast` -> `tp/kimi-k27-code-fast` -> `tp/minimax-m3`
- `LONG_CONTEXT`: `ag/gemini-3.7-flash-medium` -> `ag/claude-sonnet-4-6` -> `gh/gpt-4.1` -> `openrouter/minimax/minimax-m3:free` -> `tp/deepseek-v4-pro` -> `tp/kimi-k3` -> `tp/minimax-m3`
- `FAST_TOOLS`: `ag/gemini-3.7-flash-low` -> `gh/mai-code-1.1-flash` -> `tp/qwen-35b-fast` -> `tp/glm-52-short-fast` -> `tp/kimi-k27-code-fast` -> `tp/deepseek-v4-flash` -> `tp/nemotron-lightning`
- `EMERGENCY_FALLBACK`: `groq/openai/gpt-oss-120b` -> `ag/gemini-3.5-flash-extra-low` -> `gh/gpt-5.4-mini-free-auto` -> `openrouter/minimax/minimax-m3:free` -> `tp/longcat-2` -> `tp/codestral-free` -> `tp/mimo-v25-free`

## Free/provider utility routes
- `FREE`: `groq/openai/gpt-oss-120b` -> `openrouter/minimax/minimax-m3:free` -> `tp/longcat-2` -> `tp/codestral-free` -> `tp/mimo-v25-free` -> `tp/big-pickle-free` -> `tp/north-mini-code`
- `TPFREE`: `tp/longcat-2` -> `tp/codestral-free` -> `tp/mimo-v25-free` -> `tp/big-pickle-free` -> `tp/ds-v4-flash-free` -> `tp/minimax-m27-free` -> `tp/nemotron-ultra-free`
- `GROQFREE`: `groq/openai/gpt-oss-120b` -> `groq/qwen/qwen3-32b` -> `groq/llama-3.3-70b-versatile`
- `ORFREE`: `openrouter/minimax/minimax-m3:free`

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
