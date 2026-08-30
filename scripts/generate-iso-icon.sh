#!/usr/bin/env bash
# Genera el icono de la ISO/USB de RuloGamerOS (multi-resolución .ico, usado
# en Explorador de Windows vía autorun.inf, e inyectado en la propia ISO
# por build.sh) a partir del logo ya generado por prepare-branding.sh.
set -euo pipefail

command -v convert >/dev/null 2>&1 || {
  echo "Falta ImageMagick. Instálalo con: sudo pacman -S --needed imagemagick" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGO="$REPO_ROOT/profile/airootfs/usr/share/sddm/themes/rulogameros/logo.png"
OUT_DIR="$REPO_ROOT/profile/iso_root"

[[ -f "$LOGO" ]] || {
  echo "No existe $LOGO. Ejecuta antes: ./scripts/prepare-branding.sh" >&2
  exit 1
}

mkdir -p "$OUT_DIR"

convert "$LOGO" -background none -define icon:auto-resize=256,128,64,48,32,16 "$OUT_DIR/rulogameros.ico"

cat > "$OUT_DIR/autorun.inf" <<'EOF'
[autorun]
icon=rulogameros.ico
label=RuloGamerOS
EOF

echo "Icono generado en $OUT_DIR/rulogameros.ico (+ autorun.inf para Windows)"
echo "build.sh lo inyecta en la raíz de la ISO automáticamente."
