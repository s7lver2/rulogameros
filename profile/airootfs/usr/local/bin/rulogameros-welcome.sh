#!/usr/bin/env bash
# Reproduce el vídeo de bienvenida (fotos con efectos ridículos, ver
# generate-welcome-video.sh) a pantalla completa la primera vez que el
# usuario inicia sesión, y no vuelve a molestar después.
set -euo pipefail

MARKER="$HOME/.config/.rulogameros-welcome-shown"
VIDEO="/usr/share/rulogameros/welcome/welcome.mp4"

[[ -f "$MARKER" ]] && exit 0
[[ -f "$VIDEO" ]] || exit 0
command -v mpv >/dev/null 2>&1 || exit 0

mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"

mpv --fs --really-quiet --no-osc --no-input-default-bindings --osd-level=0 "$VIDEO" || true
