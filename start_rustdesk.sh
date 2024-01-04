#!/usr/bin/env bash

nohup hbbs -r "${RUSTDESK_RELAY_IP}" -k _ >hbbs.log 2>&1 &

nohup hbbr -k _ >hbbr.log 2>&1 &

echo "[$(date +"%F %T.%6N %:z")] Running rustdesk server..."
echo ""

tail -F hbbs.log hbbr.log
