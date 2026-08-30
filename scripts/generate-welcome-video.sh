#!/usr/bin/env bash
# Genera el vídeo de bienvenida del primer arranque: cada foto del pack pasa
# por un efecto ridículo distinto (ImageMagick) y se monta en un slideshow
# con zoom y un pitido de kazoo sintetizado (ffmpeg), sin usar ningún audio
# con copyright.
set -euo pipefail

command -v convert >/dev/null 2>&1 || {
  echo "Falta ImageMagick. Instálalo con: sudo pacman -S --needed imagemagick" >&2
  exit 1
}
command -v ffmpeg >/dev/null 2>&1 || {
  echo "Falta ffmpeg. Instálalo con: sudo pacman -S --needed ffmpeg" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPERS_DIR="$REPO_ROOT/profile/airootfs/usr/share/backgrounds/rulogameros"
OUT_DIR="$REPO_ROOT/profile/airootfs/usr/share/rulogameros/welcome"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$OUT_DIR"

# Un efecto "ridículo" de ImageMagick distinto para cada foto, en bucle.
EFFECTS=(
  '-swirl 180'
  '-implode 0.6'
  '-wave 30x120'
  '-spread 12'
  '-charcoal 2'
  '-solarize 50%'
  '-sepia-tone 80%'
  '-negate'
  '-rotate 8 -implode -0.4'
  '-fx "u*0.5+0.5*(1-u)" -modulate 120,200,100'
)

i=0
clips=()
for photo in "$WALLPAPERS_DIR"/*.jpg "$WALLPAPERS_DIR"/*.png; do
  [[ -f "$photo" ]] || continue
  effect="${EFFECTS[$((i % ${#EFFECTS[@]}))]}"
  frame="$TMP_DIR/frame_$(printf '%02d' "$i").png"
  clip="$TMP_DIR/clip_$(printf '%02d' "$i").mp4"

  echo "==> $(basename "$photo") con efecto: $effect"
  eval convert \"\$photo\" -resize 1280x720^ -gravity center -extent 1280x720 $effect \"\$frame\"

  # Zoom lento sobre la imagen ya deformada (efecto Ken Burns) + 1.5s por foto.
  ffmpeg -y -loglevel error -loop 1 -i "$frame" -t 1.5 \
    -vf "zoompan=z='min(zoom+0.0015,1.15)':d=38:s=1280x720,format=yuv420p" \
    -c:v libx264 -r 25 "$clip"

  clips+=("$clip")
  i=$((i + 1))
done

[[ ${#clips[@]} -gt 0 ]] || { echo "No hay fotos en $WALLPAPERS_DIR" >&2; exit 1; }

concat_list="$TMP_DIR/concat.txt"
: > "$concat_list"
for c in "${clips[@]}"; do echo "file '$c'" >> "$concat_list"; done

silly_video="$TMP_DIR/silly.mp4"
ffmpeg -y -loglevel error -f concat -safe 0 -i "$concat_list" -c copy "$silly_video"

# Pitido de "kazoo" ridículo sintetizado con ffmpeg (sin copyright), a modo
# de sintonía de bienvenida, recortado a la duración del vídeo.
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$silly_video")
ffmpeg -y -loglevel error -f lavfi -i \
  "sine=frequency=880:duration=$duration,vibrato=f=9:d=0.6,volume=0.5" \
  "$TMP_DIR/kazoo.wav"

ffmpeg -y -loglevel error -i "$silly_video" -i "$TMP_DIR/kazoo.wav" \
  -c:v copy -c:a aac -shortest "$OUT_DIR/welcome.mp4"

echo "Vídeo de bienvenida generado en $OUT_DIR/welcome.mp4 ($duration s)"
