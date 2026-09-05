#!/usr/bin/env python3
import json
import os
import socket
import sqlite3
import subprocess
import sys
import urllib.request
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

BASE = Path('/home/openclaw/apps/9router')
DB = BASE / 'data/db/data.sqlite'
STATE = BASE / 'monitor/state.json'
LOG = BASE / 'logs/healthwatch.log'
HOST_FILE = BASE / 'run/host'
HERMES = Path('/home/openclaw/.hermes/hermes-agent/venv/bin/hermes')
CHECK_WINDOW_SECONDS = 600
FAIL_WINDOW_SECONDS = 300
REMINDER_SECONDS = 21600
def now_utc():
    return datetime.now(timezone.utc)


def parse_ts(value):
    if not value:
        return None
    try:
        return datetime.fromisoformat(str(value).replace('Z', '+00:00')).astimezone(timezone.utc)
    except Exception:
        return None


def age_seconds(value, now=None):
    dt = parse_ts(value)
    if not dt:
        return 10**12
    return ((now or now_utc()) - dt).total_seconds()


def log_event(kind, **fields):
    LOG.parent.mkdir(parents=True, exist_ok=True)
    record = {'ts': now_utc().isoformat(), 'kind': kind, **fields}
    with LOG.open('a', encoding='utf-8') as f:
        f.write(json.dumps(record, ensure_ascii=False, separators=(',', ':')) + '\n')
def load_state():
    try:
        data = json.loads(STATE.read_text(encoding='utf-8'))
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def save_state(state):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix('.tmp')
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding='utf-8')
    os.chmod(tmp, 0o600)
    os.replace(tmp, STATE)


def router_host():
    try:
        host = HOST_FILE.read_text(encoding='utf-8').strip()
        return host or '127.0.0.1'
    except Exception:
        return '127.0.0.1'


def http_health():
    try:
        with urllib.request.urlopen(f'http://{router_host()}:20128/api/health', timeout=5) as r:
            return r.status == 200 and json.load(r).get('ok') is True
    except Exception:
        return False
def port_open(host='127.0.0.1', port=20130):
    try:
        with socket.create_connection((host, port), timeout=3):
            return True
    except OSError:
        return False


def gateway_active():
    try:
        p = subprocess.run(
            ['systemctl', '--user', 'is-active', 'hermes-gateway.service'],
            text=True, capture_output=True, timeout=5,
        )
        if p.returncode == 0 and p.stdout.strip() == 'active':
            return True
    except Exception:
        pass
    try:
        p = subprocess.run(
            ['pgrep', '-f', 'hermes_cli.main gateway run'],
            text=True, capture_output=True, timeout=5,
        )
        return p.returncode == 0 and bool(p.stdout.strip())
    except Exception:
        return False


def safe_error_status(data):
    try:
        d = json.loads(data or '{}')
    except Exception:
        return None, ''
    response = d.get('response') if isinstance(d, dict) else None
    if not isinstance(response, dict):
        response = {}
    status = response.get('status')
    try:
        status = int(status)
    except Exception:
        status = None
    text = str(response.get('error') or '').lower()
    return status, text[:2000]
def collect_db_state():
    now = now_utc()
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    providers = list(con.execute(
        'select id,provider,name,isActive,data from providerConnections where isActive=1'
    ))
    errors = []
    for row in con.execute(
        "select timestamp,provider,model,data from requestDetails where status='error' order by timestamp desc limit 300"
    ):
        if age_seconds(row['timestamp'], now) > CHECK_WINDOW_SECONDS:
            continue
        status, text = safe_error_status(row['data'])
        category = 'other'
        if status == 429 or any(x in text for x in ('quota', 'rate limit', 'too many requests', 'insufficient_quota')):
            category = 'quota'
        elif status in (401, 403):
            category = 'auth'
        elif status is not None and status >= 500:
            category = 'upstream'
        errors.append({'ts': row['timestamp'], 'provider': row['provider'] or 'unknown', 'status': status, 'category': category})

    successes = []
    for row in con.execute(
        "select timestamp,provider from usageHistory where status='ok' order by timestamp desc limit 500"
    ):
        if age_seconds(row['timestamp'], now) <= CHECK_WINDOW_SECONDS:
            successes.append({'ts': row['timestamp'], 'provider': row['provider'] or 'unknown'})
    con.close()
    return providers, errors, successes
def latest_success_by_provider(successes):
    out = {}
    for item in successes:
        ts = parse_ts(item['ts'])
        if ts and (item['provider'] not in out or ts > out[item['provider']]):
            out[item['provider']] = ts
    return out


def provider_connection_summary(providers):
    degraded = []
    for row in providers:
        try:
            d = json.loads(row['data'] or '{}')
        except Exception:
            d = {}
        test_status = str(d.get('testStatus') or '').lower()
        error_code = d.get('errorCode')
        try:
            error_code = int(error_code) if error_code is not None else None
        except Exception:
            error_code = None
        locks = sum(1 for k, v in d.items() if str(k).startswith('modelLock_') and v not in (None, '', False))
        if test_status and test_status != 'active':
            degraded.append((row['provider'], 'test_status'))
        if error_code in (401, 403):
            degraded.append((row['provider'], 'auth'))
        if locks:
            log_event('provider_model_locks', provider=row['provider'], count=locks)
    return degraded
def build_incidents(providers, errors, successes):
    incidents = {}
    if not http_health():
        incidents['router_down'] = '9Router health endpoint tidak merespons.'
    if not port_open():
        incidents['compat_down'] = 'Hermes AUTO router di 127.0.0.1:20130 tidak aktif.'
    if not gateway_active():
        incidents['hermes_gateway_down'] = 'Hermes Gateway tidak aktif.'

    latest_ok = latest_success_by_provider(successes)
    grouped = defaultdict(list)
    for e in errors:
        grouped[e['provider']].append(e)

    for provider, items in grouped.items():
        auth = [e for e in items if e['category'] == 'auth']
        if len(auth) >= 3:
            latest_err = max(parse_ts(e['ts']) for e in auth if parse_ts(e['ts']))
            if latest_ok.get(provider) is None or latest_ok[provider] < latest_err:
                incidents[f'auth:{provider}'] = f'Provider {provider} mengalami kegagalan autentikasi berulang.'
        quota = [e for e in items if e['category'] == 'quota']
        if quota:
            log_event('quota_or_rate_limit', provider=provider, count=len(quota))

    recent_fail = [e for e in errors if age_seconds(e['ts']) <= FAIL_WINDOW_SECONDS]
    recent_ok = [s for s in successes if age_seconds(s['ts']) <= FAIL_WINDOW_SECONDS]
    failed_providers = {e['provider'] for e in recent_fail if e['category'] in ('quota', 'auth', 'upstream')}
    if (len(failed_providers) >= 3 or (len(failed_providers) >= 2 and len(recent_fail) >= 5)) and not recent_ok:
        incidents['all_routes_failed'] = (
            f'Terdeteksi kegagalan fallback lintas {len(failed_providers)} provider tanpa request sukses dalam 5 menit terakhir.'
        )

    degraded = provider_connection_summary(providers)
    if len(degraded) >= max(3, (len(providers) + 1) // 2):
        incidents['provider_major_degradation'] = f'{len(degraded)} koneksi provider berada dalam kondisi degraded.'
    return incidents
def send_telegram(message):
    if '--no-send' in sys.argv:
        print('WOULD_SEND:', message)
        return True
    try:
        p = subprocess.run(
            [str(HERMES), 'send', '--to', 'telegram', '--quiet', message],
            text=True, capture_output=True, timeout=25,
        )
        if p.returncode != 0:
            log_event('notify_failed', returncode=p.returncode)
            return False
        return True
    except Exception as e:
        log_event('notify_failed', error=type(e).__name__)
        return False


def notify_transitions(incidents, state):
    previous = set(state.get('active_incidents') or [])
    current = set(incidents)
    notified = state.get('notified_at') or {}
    now = now_utc()

    for key in sorted(current):
        last = parse_ts(notified.get(key))
        due = key not in previous or last is None or (now - last).total_seconds() >= REMINDER_SECONDS
        if not due:
            continue
        text = f'⚠️ Hermes/9Router Monitor\n{incidents[key]}\nFallback otomatis tetap dicoba jika tersedia.'
        if send_telegram(text):
            notified[key] = now.isoformat()
            log_event('alert_sent', incident=key)

    recovered = sorted(previous - current)
    if recovered:
        text = '✅ Hermes/9Router pulih\n' + '\n'.join(f'- {key}' for key in recovered)
        if send_telegram(text):
            for key in recovered:
                notified.pop(key, None)
            log_event('recovery_sent', incidents=recovered)

    state['active_incidents'] = sorted(current)
    state['notified_at'] = notified
    state['last_check_at'] = now.isoformat()
def main():
    try:
        providers, errors, successes = collect_db_state()
        incidents = build_incidents(providers, errors, successes)
        state = load_state()
        notify_transitions(incidents, state)
        state['provider_count'] = len(providers)
        state['recent_error_count'] = len(errors)
        state['recent_success_count'] = len(successes)
        save_state(state)
        log_event('check', healthy=not bool(incidents), incidents=sorted(incidents),
                  providers=len(providers), errors=len(errors), successes=len(successes))
        if '--json' in sys.argv:
            print(json.dumps({'ok': not bool(incidents), 'incidents': incidents,
                              'providers': len(providers), 'errors': len(errors),
                              'successes': len(successes)}, ensure_ascii=False))
        return 0 if not incidents else 2
    except Exception as e:
        log_event('watcher_error', error=type(e).__name__)
        if '--json' in sys.argv:
            print(json.dumps({'ok': False, 'watcher_error': type(e).__name__}))
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
