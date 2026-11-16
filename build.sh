#!/bin/bash
# Compiles popover.lcb with the HyperXTalk lc-compile, generates its
# dictionary entry (api.lcdoc) and zips the extension.
#   ./build.sh        build/pkg/com.hyperxtalk.widget.popover/ and build/com.hyperxtalk.widget.popover.lce
# HXT points at a HyperXTalk checkout with a built lc-compile.
set -e
cd "$(dirname "$0")"
HXT=${HXT:-$HOME/Developer/HyperXTalk}
LCC="$HXT/_build/mac/Release/lc-compile"
LCI="$HXT/_build/mac/Release/modules/lci"
KIND=com.hyperxtalk.widget.popover
OUT=build
PKG=$OUT/pkg/$KIND

mkdir -p "$PKG" "$OUT/lci"
# lc-compile writes the widget's own interface file into the first module path.
"$LCC" --modulepath "$OUT/lci" --modulepath "$LCI" \
  --manifest "$PKG/manifest.xml" --output "$PKG/module.lcm" popover.lcb
cp popover.lcb "$PKG/"

# The dictionary entry: api.lcdoc, generated from the doc comments by the
# HyperXTalk docs parser in a headless engine. A script error hangs a -ui
# engine, so it is killed if it runs too long.
ENGINE="$HXT/_build/mac/Release/HyperXTalk.app/Contents/MacOS/HyperXTalk"
rm -f "$PKG/api.lcdoc" "$OUT/gendocs.log"
HXT="$HXT" GENDOCS_SOURCE="$PWD/popover.lcb" GENDOCS_OUT="$PWD/$PKG/api.lcdoc" GENDOCS_LOG="$PWD/$OUT/gendocs.log" \
  "$ENGINE" -ui tools/gendocs.hyperxtalkscript > /dev/null 2>&1 &
pid=$!
( sleep 40; kill -9 $pid 2>/dev/null ) &
guard=$!
wait $pid 2>/dev/null || true
kill $guard 2>/dev/null; wait $guard 2>/dev/null || true
[ -s "$OUT/gendocs.log" ] && cat "$OUT/gendocs.log"
if [ ! -s "$PKG/api.lcdoc" ] || grep -q "^error:" "$OUT/gendocs.log" 2>/dev/null; then
  echo "api.lcdoc was not generated" >&2
  exit 1
fi

rm -f "$OUT/$KIND.lce"
(cd "$PKG" && zip -qr "../../$KIND.lce" manifest.xml module.lcm popover.lcb api.lcdoc)
echo "built $OUT/$KIND.lce"
