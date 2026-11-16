#!/bin/bash
# Runs the headless widget test. Output (steps.log, PNG snapshots) goes to
# the folder given as $1, default build/test.
#   ./build.sh && test/run.sh
cd "$(dirname "$0")/.."
HXT=${HXT:-$HOME/Developer/HyperXTalk}
ENGINE="$HXT/_build/mac/Release/HyperXTalk.app/Contents/MacOS/HyperXTalk"
OUT=${1:-$PWD/build/test}
rm -rf "$OUT"; mkdir -p "$OUT"
status=0
for phase in build reload; do
  HXTPOPOVER_ROOT="$PWD" HXTPOPOVER_OUT="$OUT" HXTPOPOVER_PHASE=$phase \
    "$ENGINE" -ui test/headless.hyperxtalkscript >> "$OUT/stdout.txt" 2>&1 &
  pid=$!
  # A script error hangs a -ui engine, so kill it if it runs too long.
  ( sleep 40; kill -9 $pid 2>/dev/null ) &
  guard=$!
  wait $pid || status=1
  kill $guard 2>/dev/null; wait $guard 2>/dev/null
done
cat "$OUT/steps.log" "$OUT/stdout.txt"
exit $status
