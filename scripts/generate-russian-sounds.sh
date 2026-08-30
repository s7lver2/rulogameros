#!/usr/bin/env bash
# Genera un tema de sonidos de sistema "RuloGamerOS" con voz rusa (offline,
# vía espeak-ng, sin depender de ningún audio con copyright) para los eventos
# estándar de XDG/KDE: login, logout, error, aviso, notificación...
# Es un tema de coña: en vez de un "ding" educado, insulta (suave, sin
# groserías extremas ni nada dirigido a nadie en particular) en ruso.
set -euo pipefail

command -v espeak-ng >/dev/null 2>&1 || {
  echo "Falta espeak-ng. Instálalo con: sudo pacman -S --needed espeak-ng" >&2
  exit 1
}
command -v ffmpeg >/dev/null 2>&1 || {
  echo "Falta ffmpeg. Instálalo con: sudo pacman -S --needed ffmpeg" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOUND_DIR="$REPO_ROOT/profile/airootfs/usr/share/sounds/RuloGamerOS/stereo"
mkdir -p "$SOUND_DIR"

# evento -> insulto en ruso (coña, sin groserías extremas ni dirigido a nadie real)
declare -A PHRASES=(
  [desktop-login]="Ну наконец-то, тормоз"
  [desktop-logout]="Проваливай, неудачник"
  [dialog-error]="Ты идиот, всё сломал"
  [dialog-warning]="Осторожно, дурак"
  [message]="Эй, тупица, сообщение"
  [bell]="Придурок"
  [service-login]="Опять ты, кретин"
  [service-logout]="Наконец избавились от тебя"
  [complete]="Готово, балбес"
  [device-added]="Что за хлам ты подключил"
  [device-removed]="Слава богу, убрал этот хлам"
)

for event in "${!PHRASES[@]}"; do
  phrase="${PHRASES[$event]}"
  wav="$SOUND_DIR/${event}.wav"
  oga="$SOUND_DIR/${event}.oga"
  echo "==> $event: \"$phrase\""
  espeak-ng -v ru -s 150 -p 40 -w "$wav" "$phrase"
  ffmpeg -y -loglevel error -i "$wav" -c:a libvorbis "$oga"
  rm -f "$wav"
done

cat > "$REPO_ROOT/profile/airootfs/usr/share/sounds/RuloGamerOS/index.theme" <<'EOF'
[Sound Theme]
Name=RuloGamerOS
Comment=Sonidos de sistema de RuloGamerOS narrados en ruso (espeak-ng, offline)
Directories=stereo

[stereo]
OutputProfile=stereo
EOF

echo "Tema de sonidos generado en $SOUND_DIR"
echo "Se activa automáticamente en el chroot (customize_airootfs.sh) o con:"
echo "  sudo ./scripts/setup-branding.sh"
