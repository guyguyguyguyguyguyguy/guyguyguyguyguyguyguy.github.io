#!/bin/bash
BASEDIR=$(cd $(dirname "$0"); pwd)
OUTDIR="${WEBSITE_OUT_DIR:-$BASEDIR/www}"

echo "Building website to $OUTDIR"

cd "$BASEDIR/lisp"
WEBSITE_OUT_DIR="$OUTDIR" \
emacs --batch -l "./project.el" --eval="(build-site t)"

echo "Build complete. Output in $OUTDIR"
