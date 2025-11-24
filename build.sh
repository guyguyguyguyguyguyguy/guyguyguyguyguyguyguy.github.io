#!/bin/bash
BASEDIR=$(cd $(dirname "$0"); pwd)
OUTDIR="${WEBSITE_OUT_DIR:-$BASEDIR/www}"

echo "Building website to $OUTDIR"

cd "$BASEDIR/lisp"

# Build TS → JS
if command -v npx >/dev/null 2>&1; then
  echo "Compiling TypeScript..."
  npx tsc --project tsconfig.json
else
  echo "npx not found; skipping TypeScript compile."
fi

WEBSITE_OUT_DIR="$OUTDIR" \
emacs --batch -l "./project.el" --eval="(build-site t)"

echo "Build complete. Output in $OUTDIR"
