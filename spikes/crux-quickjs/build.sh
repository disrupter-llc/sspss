#!/usr/bin/env bash
# Build the Crux-on-QuickJS test host for x86 (local) and armv7 (SSP).
#
#   CRUX_DIR=/path/to/crux ./build.sh
#
# Needs: node + npm, git, gcc, arm-linux-gnueabihf-gcc (for the SSP build).
# Output: build/crux_host_native, build/crux_host_armv7
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CRUX_DIR="${CRUX_DIR:?set CRUX_DIR to a crux checkout (disrupterbox/crux)}"
B="$HERE/build"; mkdir -p "$B"
QJS_REV=3d5e064   # QuickJS release 2026-06-04

# 1. QuickJS at a pinned release
[ -d "$B/quickjs" ] || git clone -q https://github.com/bellard/quickjs.git "$B/quickjs"
git -C "$B/quickjs" checkout -q "$QJS_REV"
make -C "$B/quickjs" -s qjsc >/dev/null

# 2. Crux sources, reseed patch, precompiled Ohm grammar
rm -rf "$B/crux"; mkdir -p "$B/crux"
cp -r "$CRUX_DIR/src" "$CRUX_DIR/examples" "$B/crux/"
(cd "$B" && patch -s -p1 < "$HERE/src/crux-reseed.patch")
cd "$B/crux"
[ -f package.json ] || echo "{\"type\":\"module\"}" > package.json
[ -d node_modules/ohm-js ] || npm i -s --no-audit --no-fund ohm-js@17 esbuild@0.25 >/dev/null
node --input-type=module -e "
import { g } from './src/grammar.js'; import fs from 'fs';
fs.writeFileSync('src/grammar.js', 'import * as ohm from \"ohm-js\";\nexport const g = ohm.makeRecipe(' + g.toRecipe() + ');\n');"
cp "$HERE/src/entry_ssp.js" .
sed -i.bak 's#./src_ssp/index.js#./src/index.js#' entry_ssp.js
npx esbuild entry_ssp.js --bundle --format=iife --target=es2020 --minify --log-level=warning --outfile=crux_ssp.bundle.js

# 3. Bytecode + embedded examples
cd "$B"
quickjs/qjsc -c -N crux_bc -o crux_bc.c crux/crux_ssp.bundle.js
node -e "
const fs=require('fs'),d='crux/examples',f=fs.readdirSync(d).filter(x=>x.endsWith('.crux')).sort();
fs.writeFileSync('examples.h','static const char *EX_NAMES[]={'+f.map(x=>JSON.stringify(x))+'};\n'+
'static const char *EX_SRC[]={'+f.map(x=>JSON.stringify(fs.readFileSync(d+'/'+x,'utf8')))+'};\n#define EX_COUNT '+f.length+'\n');"

# 4. Compile
Q=quickjs; SRCS="$Q/quickjs.c $Q/libregexp.c $Q/libunicode.c $Q/cutils.c $Q/dtoa.c"
FLAGS="-O2 -D_GNU_SOURCE -DCONFIG_VERSION=\"2026-06-04\" -I$Q -I."
cc $FLAGS -o crux_host_native "$HERE/src/crux_host.c" crux_bc.c $SRCS -lm -lpthread
if command -v arm-linux-gnueabihf-gcc >/dev/null; then
  arm-linux-gnueabihf-gcc $FLAGS -mcpu=cortex-a17 -mfpu=neon-vfpv4 -mfloat-abi=hard -static \
    -o crux_host_armv7 "$HERE/src/crux_host.c" crux_bc.c $SRCS -lm -lpthread
  arm-linux-gnueabihf-strip crux_host_armv7
fi

# 5. Parity check against the expected output
./crux_host_native --dump | cmp - "$HERE/src/expected_output.tsv" && echo "parity OK"
ls -la crux_host_*
