#!/usr/bin/env bash
set -euo pipefail
cd /home/openclaw/apps/9router
export DATA_DIR=/home/openclaw/apps/9router/data
export HOME=/home/openclaw
PROVIDER_ID='openai-compatible-chat-8f3d7efe-1b95-4587-9cc6-a6b17e2a7ace'

printf 'TokenPortal API key: ' >/dev/tty
IFS= read -r -s TP_KEY </dev/tty
printf '\n' >/dev/tty
if [ -z "$TP_KEY" ]; then
  echo 'ERROR: API key kosong.' >&2
  exit 1
fi

export TP_KEY PROVIDER_ID
node <<'NODE'
const api=require('./node_modules/9router/src/cli/api/client');
api.configure({host:'100.114.241.64',port:20128,protocol:'http:'});
(async()=>{
  const created=await api.createApiKeyProvider({provider:process.env.PROVIDER_ID,name:'TokenPortal Main',apiKey:process.env.TP_KEY});
  if(!created.success){ console.error('CREATE_FAILED:', created.error); process.exit(1); }
  const c=created.data.connection || created.data;
  console.log('Connection created:', c.name || 'TokenPortal Main');
  console.log('Connection ID:', c.id || 'unknown');
  if(c.id){ const test=await api.testProvider(c.id); console.log('Test:', JSON.stringify(test.data || {error:test.error})); }
})().catch(e=>{console.error(e.message); process.exit(1)});
NODE
unset TP_KEY PROVIDER_ID
