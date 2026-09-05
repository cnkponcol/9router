# Hermes -> 9Router Automatic Routing

Status: active and verified on 2026-08-29.

## Flow
`Telegram/User -> Hermes parent (FREE) -> delegate_task (AUTO) -> local classifier -> 9Router Combo -> ordered model fallback`

The classifier runs inside `/home/openclaw/apps/9router/compat/compat_shim.py` on `127.0.0.1:20130`. It does not call another LLM, so task classification adds no model-token cost.

## Automatic routes
- GENERAL_LIGHT: simple summary/format/straightforward reasoning.
- GENERAL_MEDIUM: normal general delegated work.
- GENERAL_STRONG: difficult architecture/security/deep analysis.
- CODING_LIGHT: tiny edit/syntax/simple one-file fix.
- CODING_MEDIUM: normal feature/debug/test/repository work.
- CODING_STRONG: complex multi-file/refactor/security-sensitive coding.
- VISION: image/screenshot input.
- LONG_CONTEXT: unusually large task/context.
- FAST_TOOLS: simple operational checks dominated by tools.

`EMERGENCY_FALLBACK` remains continuity infrastructure, not a semantic task class.

## Decision contract
Hermes may prefix a delegated goal with `[HERMES_ROUTE:COMBO]` when confident. If no valid hint is present, the shim classifies the last user/subagent goal deterministically. Individual provider/model IDs are never selected here; their priority remains controlled inside each 9Router Combo.

Complexity is based primarily on the delegated goal (`task_chars`), not Hermes' large system/tool prompt. This prevents ordinary tasks from being incorrectly escalated merely because Hermes has a large system context.

## Efficiency limits
- `delegation.model: AUTO`
- `delegation.max_iterations: 60`
- `delegation.max_concurrent_children: 3`
- `delegation.child_timeout_seconds: 600`
- `delegation.subagent_auto_approve: false`

## Audit
Routing metadata is written to `logs/auto-route.log` without prompt content. Fields contain timestamp, selected route, reason, task character count, and request character count. The file is private (`0600`).

The user controls model order inside Combos. Do not reorder models automatically.
