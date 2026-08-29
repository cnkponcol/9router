# Hermes + 9Router Health Monitoring

Status: ACTIVE

## Design
- Local watcher: `monitor/healthwatch.py`
- Runs every 2 minutes via systemd user timer.
- No LLM/model call is used for routine checks.
- Reads 9Router health endpoint and local SQLite state.
- Telegram delivery uses `hermes send`, not the agent loop.
- State transitions prevent repeated alert spam.

## What is monitored
- 9Router `/api/health` availability.
- Hermes AUTO compatibility router on `127.0.0.1:20130`.
- Hermes Gateway process/service.
- Active provider connection health state.
- Repeated 401/403 authentication failures.
- 429/quota/rate-limit events.
- Provider 5xx/upstream failures.
- Cross-provider fallback failure bursts.
## Notification policy
- Single-provider quota/rate-limit events are logged silently while fallback is available.
- Telegram alerts are reserved for critical service failures, repeated active auth failures, major provider degradation, or all-route failure detection.
- Recovery is notified once when a previously active critical incident clears.
- Persistent incidents may remind at most once every 6 hours.

## Files and services
- State: `monitor/state.json` (0600)
- Log: `logs/healthwatch.log` (0600)
- Service: `hermes-9router-monitor.service`
- Timer: `hermes-9router-monitor.timer`

## Efficiency policy
9Router's Codex AutoPing remains disabled intentionally. Exact dashboard quota percentages are on-demand; the watcher detects operational quota exhaustion/rate limiting from real 429/backoff events without burning model quota just to monitor quota.

## Validation
- Current check: healthy, 6 active provider connections.
- Synthetic cross-provider failure test correctly raised `all_routes_failed`.
- Telegram owner target resolved successfully without sending a test alert.
- Timer enabled and running every 2 minutes.
