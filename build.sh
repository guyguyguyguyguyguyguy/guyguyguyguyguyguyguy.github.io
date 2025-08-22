#!/usr/bin/env bash
set -euo pipefail

# Resolve OUT DIR from env (Makefile sets WEBSITE_OUT_DIR)
: "${WEBSITE_OUT_DIR:?WEBSITE_OUT_DIR must be set}"

# Set CLEAN=1 to force a clean build (see Makefile tweak below)
CLEAN_FLAG=${CLEAN:-0}

EMACS_CMD='
  (load-file "lisp/project.el")
  ;; Ensure our link type is registered in batch
  (require '\''org)
'

if [ "$CLEAN_FLAG" = "1" ]; then
  EMACS_CMD="$EMACS_CMD
  (org-publish-remove-all-timestamps)"
fi

EMACS_CMD="$EMACS_CMD
  (org-publish \"website\" t)
"

emacs --batch --eval "$EMACS_CMD"
