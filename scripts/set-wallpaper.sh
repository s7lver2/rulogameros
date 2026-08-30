#!/usr/bin/env bash
# Aplica o rota el fondo de pantalla entre el pack de fotos personalizado de
# RuloGamerOS (/usr/share/backgrounds/rulogameros/). No requiere root.
set -euo pipefail

WALLPAPER_DIR="/usr/share/backgrounds/rulogameros"
[[ -d "$WALLPAPER_DIR" ]] || WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../profile/airootfs/usr/share/backgrounds/rulogameros" && pwd)"

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort)
[[ ${#WALLPAPERS[@]} -gt 0 ]] || { echo "No hay fondos en $WALLPAPER_DIR" >&2; exit 1; }

if [[ "${1:-}" == "--random" ]]; then
  CHOSEN="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"
elif [[ -n "${1:-}" && -f "$1" ]]; then
  CHOSEN="$1"
else
  CHOSEN="${WALLPAPERS[0]}"
fi

echo "==> Aplicando fondo: $CHOSEN"

if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
  plasma-apply-wallpaperimage "$CHOSEN"
elif command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.desktop.background; then
  gsettings set org.gnome.desktop.background picture-uri "file://$CHOSEN"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$CHOSEN"
elif command -v feh >/dev/null 2>&1; then
  feh --bg-fill "$CHOSEN"
else
  echo "No se encontró un método soportado para fijar el fondo (KDE, GNOME o feh)." >&2
  exit 1
fi

echo "Listo. Usa '$0 --random' para cambiarlo por otra foto del pack."
