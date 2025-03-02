#!/usr/bin/env bash
set -euo pipefail

python3 \
    -m sglang.launch_server \
    --model-path "$MODEL_PATH" \
    --host 127.0.0.1 \
    --port 8080 \
    --disable-overlap \
    --context-length 2048 \
    --enable-metrics \
    --enable-torch-compile \
    --torch-compile-max-bs 1 \
    --mem-fraction-static 0.9 &

curl \
    --fail \
    --retry 100 \
    --retry-delay 5 \
    --retry-max-time 300 \
    --retry-all-errors \
    http://127.0.0.1:8080/health

exec python3 \
    -u /sakura_share/src/sakura_share_cli.py \
    --port 8080 \
    --tg-token "$TG_TOKEN" \
    --action start \
    --mode ws
