#!/bin/bash
# Xcode Command Line Tools provide git, clang and make.
set -euo pipefail
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools (accept the dialog)..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi
