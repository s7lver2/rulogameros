#!/usr/bin/env bash
# Genera el cursor de RuloGamerOS a partir de una foto real, sin recortarla en
# círculo ni suavizarla ni nada: se ve exactamente como una foto cuadrada
# metida a la fuerza como puntero del ratón. Es intencionadamente feo.
set -euo pipefail

command -v convert >/dev/null 2>&1 || {
  echo "Falta ImageMagick. Instálalo con: sudo pacman -S --needed imagemagick" >&2
  exit 1
}
command -v xcursorgen >/dev/null 2>&1 || {
  echo "Falta xcursorgen. Instálalo con: sudo pacman -S --needed xorg-xcursorgen" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPERS_DIR="$REPO_ROOT/profile/airootfs/usr/share/backgrounds/rulogameros"
THEME_DIR="$REPO_ROOT/profile/airootfs/usr/share/icons/RuloGamerOS-Cursor"
CURSORS_DIR="$THEME_DIR/cursors"

# Foto a usar de cursor. Por defecto la del selfie con la pantalla rota
# (rulogameros-03.jpg): ya tiene pinta de mierda de por sí, perfecta para esto.
# Pásale otra ruta como argumento si quieres cambiarla.
PHOTO="${1:-$WALLPAPERS_DIR/rulogameros-03.jpg}"
[[ -f "$PHOTO" ]] || { echo "No existe la foto: $PHOTO" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$CURSORS_DIR"

echo "==> Generando cursor de mierda a partir de $(basename "$PHOTO")..."

# Varios tamaños para que se vea igual de cutre a cualquier escala/DPI.
SIZES=(24 32 48 64 96)
CFG="$TMP_DIR/cursor.cfg"
: > "$CFG"

for size in "${SIZES[@]}"; do
  frame="$TMP_DIR/${size}.png"
  # Recorte cuadrado tal cual, sin máscara circular ni suavizado: se ve la
  # foto entera "a lo bruto" en el tamaño del cursor.
  convert "$PHOTO" -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" "$frame"
  # Hotspot en la esquina superior izquierda, como un cursor de verdad
  # (si no, hacer click apuntaría al centro de la foto y sería inutilizable).
  echo "$size 0 0 $frame" >> "$CFG"
done

xcursorgen "$CFG" "$CURSORS_DIR/default"

# Nombres alternativos que usan las distintas apps/tookits para el mismo
# puntero normal: todos apuntan al mismo archivo cutre.
ALIASES=(
  left_ptr left_ptr_watch X_cursor arrow top_left_arrow
  hand1 hand2 pointer pointing_hand
  xterm text ibeam
  wait watch progress
  crosshair cross
  move fleur all-scroll
  help question_arrow
  size_all size_ver size_hor size_fdiag size_bdiag
  sb_h_double_arrow sb_v_double_arrow
  ns-resize ew-resize nesw-resize nwse-resize
  not-allowed no-drop dnd-no-drop grabbing closedhand openhand
)
for alias in "${ALIASES[@]}"; do
  ln -sf default "$CURSORS_DIR/$alias"
done

cat > "$THEME_DIR/index.theme" <<'EOF'
[Icon Theme]
Name=RuloGamerOS-Cursor
Comment=El cursor es literalmente una foto recortada. Se ve fatal a propósito.
EOF

cat > "$THEME_DIR/cursor.theme" <<'EOF'
[Icon Theme]
Name=RuloGamerOS-Cursor
EOF

echo "Cursor generado en $CURSORS_DIR (foto: $(basename "$PHOTO"))"
