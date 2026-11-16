#!/bin/bash
# Compiles popover.lcb with the HyperXTalk lc-compile and zips the extension.
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
rm -f "$OUT/$KIND.lce"
(cd "$PKG" && zip -qr "../../$KIND.lce" manifest.xml module.lcm popover.lcb)
echo "built $OUT/$KIND.lce"
