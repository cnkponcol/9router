# Hermes Next Stage

Status: ROUTING BASELINE READY

## Current architecture
`User/Telegram -> Hermes supervisor -> 9Router -> task-specific Combo -> provider/model fallback`

- Hermes main/default model: `FREE`.
- Hermes delegated subagents: `GENERAL_MEDIUM`.
- Memory: enabled in Hermes; store durable facts/decisions, not every chat.
- Skills: store reusable SOP/procedures; update existing skills instead of duplicating them.
- 9Router owns provider/model availability, quota-aware fallback and task pools.
- MCP remains deferred until a dedicated external capability is actually needed.

## Operating rule
1. Read `STATUS.md` / `ROUTING.md` and continue from last verified state.
2. Do not re-audit everything on every task.
3. Use targeted checks before normal changes; full audit only for faults, major changes or risky work.
4. Keep destructive/security changes behind explicit approval.
5. Update project markdown after meaningful routing/architecture changes.

## Next useful work
- User can reorder models inside each Combo from the 9Router Combos UI.
- Later improve Hermes task classification so it can deliberately select light/medium/strong/coding/vision routes instead of relying only on the default + delegation baseline.
- Add n8n only when deterministic scheduled/business workflows are ready.

## Completed: task-aware routing
Automatic Hermes -> 9Router task routing is now active. Parent `FREE` escalates reasoning/coding-heavy delegated work to `AUTO`, which selects a logical Combo while preserving the user's Combo model priorities.

Efficiency guardrails are now 60 child iterations, 3 concurrent children, and a 600-second child timeout.

## Next recommended step
Implement operational health/quota notification policy: let 9Router fallback silently during ordinary provider failures, and notify the Telegram owner only when continuity is materially affected or every suitable fallback fails. Avoid noisy per-request alerts.

## Monitoring baseline
Health/quota monitoring is now active and should be treated as the default operational baseline. Do not add LLM-based polling for routine health checks. Prefer local state/HTTP checks and notify the owner only on meaningful incident transitions or recovery.

Next major phase after monitoring: n8n/autopilot workflows. MCP remains postponed until a specific external-tool or coding need justifies it.
