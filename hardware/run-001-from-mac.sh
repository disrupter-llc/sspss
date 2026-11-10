#!/usr/bin/env bash
# Run checklist 001 on the SSP from a normal Terminal (not Cursor).
# Cursor stays off Local Network; this script does the SSH/scp.
#
# Usage:
#   ./hardware/run-001-from-mac.sh /path/to/crux_host_armv7
#   SSP_HOST=192.168.1.6 NOTE="synthor running, patch X" ./hardware/run-001-from-mac.sh ./crux_host_armv7
set -euo pipefail

HOST="${SSP_HOST:-192.168.1.6}"
NOTE="${NOTE:-}"
BIN="${1:?usage: $0 /path/to/crux_host_armv7}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
EXPECT="$HERE/spikes/crux-quickjs/src/expected_output.tsv"
OUT="$HERE/hardware/results/001-crux-quickjs-timing"
STAMP="$(date +%Y%m%d-%H%M%S)"
RUN="$OUT/run-$STAMP"
REMOTE="/tmp/crux_host_armv7_001"

[[ -x "$BIN" || -f "$BIN" ]] || { echo "missing binary: $BIN" >&2; exit 1; }
[[ -f "$EXPECT" ]] || { echo "missing $EXPECT" >&2; exit 1; }

mkdir -p "$RUN"
{
  echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "host: $HOST"
  echo "binary: $BIN"
  echo "note: ${NOTE:-"(none — set NOTE=... for what else was running)"}"
} > "$RUN/meta.txt"

echo "== probe $HOST =="
ssh -o BatchMode=yes -o ConnectTimeout=5 "root@$HOST" 'uname -a; echo ---; cat /etc/issue 2>/dev/null; echo ---; df -h /media/BOOT 2>/dev/null | tail -1' \
  | tee "$RUN/firmware.txt"

echo "== upload =="
scp -O -q "$BIN" "root@$HOST:$REMOTE"
scp -O -q "$EXPECT" "root@$HOST:/tmp/expected_output.tsv"

echo "== run (timings + dump + cmp) =="
ssh -o BatchMode=yes "root@$HOST" "chmod +x '$REMOTE' && \
  '$REMOTE' > /tmp/timings.txt && \
  '$REMOTE' --dump > /tmp/output.tsv && \
  (cmp /tmp/output.tsv /tmp/expected_output.tsv > /tmp/cmp.txt 2>&1; echo cmp_exit=\$? >> /tmp/cmp.txt) && \
  cat /tmp/timings.txt && echo ---CMP--- && cat /tmp/cmp.txt"

scp -O -q "root@$HOST:/tmp/timings.txt" "$RUN/timings.txt"
scp -O -q "root@$HOST:/tmp/output.tsv" "$RUN/output.tsv"
scp -O -q "root@$HOST:/tmp/cmp.txt" "$RUN/cmp.txt"

ssh -o BatchMode=yes "root@$HOST" "rm -f '$REMOTE' /tmp/expected_output.tsv /tmp/timings.txt /tmp/output.tsv /tmp/cmp.txt" || true

echo "== saved $RUN =="
ls -la "$RUN"
echo "Set NOTE and run again with synthor stopped if you can (checklist asks for both)."
