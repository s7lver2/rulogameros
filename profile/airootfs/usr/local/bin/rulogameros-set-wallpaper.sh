#!/usr/bin/env bash
# Aplica o rota el fondo de pantalla entre el pack de fotos personalizado de
# RuloGamerOS (/usr/share/backgrounds/rulogameros/). No requiere root.
set -euo pipefail

WALLPAPER_DIR="/usr/share/backgrounds/rulogameros"
[[ -d "$WALLPAPER_DIR" ]] || WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../profile/airootfs/usr/share/backgrounds/rulogameros" && pwd)"

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort)
[[ ${#WALLPAPERS[@]} -gt 0 ]] || { echo "No hay fondos en $WALLPAPER_DIR" >&2; exit 1; }

if [[ "${1:-}" == "--pick" ]]; then
  command -v kdialog >/dev/null 2>&1 || {
    echo "Falta kdialog. Instálalo con: sudo pacman -S --needed kde-cli-tools" >&2
    exit 1
  }
  # kdialog abre el diálogo de KDE con vista previa de miniaturas, ya
  # colocado en la carpeta del pack de fondos.
  CHOSEN="$(kdialog --title "Elige un fondo de RuloGamerOS" \
    --getopenfilename "$WALLPAPER_DIR" "Imágenes (*.jpg *.jpeg *.png)" || true)"
  [[ -n "$CHOSEN" ]] || { echo "No se eligió ningún fondo."; exit 0; }
elif [[ "${1:-}" == "--random" ]]; then
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

echo "Listo. Usa '$0 --random' para una foto al azar, o '$0 --pick' para elegirla a mano."
