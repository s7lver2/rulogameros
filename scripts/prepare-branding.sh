#!/usr/bin/env bash
# Genera todos los assets de imagen de marca (logo, splash de arranque, fondo de
# GRUB, fondo de SDDM/pantalla de bloqueo) a partir del pack de fotos en
# profile/airootfs/usr/share/backgrounds/rulogameros/.
# Se ejecuta en la máquina que construye la ISO, antes de mkarchiso, y también
# la puede volver a ejecutar el usuario para regenerar el branding con otras fotos.
set -euo pipefail

command -v convert >/dev/null 2>&1 || {
  echo "Falta ImageMagick. Instálalo con: sudo pacman -S --needed imagemagick" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPERS_DIR="$REPO_ROOT/profile/airootfs/usr/share/backgrounds/rulogameros"
PLYMOUTH_DIR="$REPO_ROOT/profile/airootfs/usr/share/plymouth/themes/rulogameros"
SDDM_DIR="$REPO_ROOT/profile/airootfs/usr/share/sddm/themes/rulogameros"
GRUB_DIR="$REPO_ROOT/profile/airootfs/boot/grub/themes/rulogameros"

# Foto para el logo (retrato) y foto para los fondos de pantalla completa
# (login/bloqueo/GRUB). Se pueden pasar por parámetro para regenerar con otras fotos:
#   ./prepare-branding.sh <foto-logo> <foto-fondo>
LOGO_PHOTO="${1:-$WALLPAPERS_DIR/rulogameros-01.jpg}"
BG_PHOTO="${2:-$WALLPAPERS_DIR/rulogameros-02.jpg}"

mkdir -p "$PLYMOUTH_DIR" "$SDDM_DIR" "$GRUB_DIR"

echo "==> Generando logo circular desde $(basename "$LOGO_PHOTO")..."
gen_round_logo() {
  local size="$1" out="$2"
  convert "$LOGO_PHOTO" -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    \( +clone -alpha extract -draw "fill black polygon 0,0 0,$size $size,0 fill white circle $((size/2)),$((size/2)) $((size/2)),0" \
       \( +clone -flip \) -compose Multiply -composite \) \
    -alpha off -compose CopyOpacity -composite \
    -bordercolor none -border 4 \
    \( -clone 0 -fill none -stroke '#e01b24' -strokewidth 4 -draw "circle $((size/2+4)),$((size/2+4)) $((size/2+4)),4" \) \
    -compose over -composite "$out"
}

gen_round_logo 220 "$PLYMOUTH_DIR/logo.png"
gen_round_logo 140 "$SDDM_DIR/logo.png"
gen_round_logo 140 "$GRUB_DIR/logo.png"

# Caja y barra de progreso del splash de arranque (rectángulos planos de marca).
convert -size 320x14 xc:'#1a1a1a' "$PLYMOUTH_DIR/progress_box.png"
convert -size 320x14 xc:'#e01b24' "$PLYMOUTH_DIR/progress_bar.png"

echo "==> Generando fondo de login/bloqueo (SDDM) desde $(basename "$BG_PHOTO")..."
convert "$BG_PHOTO" -resize 1920x1080^ -gravity center -extent 1920x1080 \
  -fill black -colorize 25% "$SDDM_DIR/background.jpg"

echo "==> Generando fondo de GRUB desde $(basename "$BG_PHOTO")..."
convert "$BG_PHOTO" -resize 1920x1080^ -gravity center -extent 1920x1080 \
  -fill black -colorize 55% -blur 0x6 "$GRUB_DIR/background.png"

echo "Assets de branding generados:"
echo "  - $PLYMOUTH_DIR (splash de arranque)"
echo "  - $SDDM_DIR (login + pantalla de bloqueo)"
echo "  - $GRUB_DIR (menú de arranque GRUB)"
