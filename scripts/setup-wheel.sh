#!/usr/bin/env bash
# Instala y configura drivers de force-feedback para volantes de simracing
# (Logitech G25/G27/G29/G920/G923, Thrustmaster, Fanatec) en Arch Linux.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script como root: sudo ./scripts/setup-wheel.sh" >&2
  exit 1
fi

pacman -Sy --needed --noconfirm base-devel dkms linux-headers python-evdev sdl2 joyutils

if ! command -v yay >/dev/null 2>&1; then
  echo "==> Instalando yay (AUR helper)..."
  BUILD_USER="${SUDO_USER:-root}"
  su - "$BUILD_USER" -c '
    set -e
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp"
    cd "$tmp" && makepkg -si --noconfirm
  '
fi

echo "==> Instalando driver new-lg4ff (force feedback mejorado para Logitech) y oversteer..."
BUILD_USER="${SUDO_USER:-root}"
su - "$BUILD_USER" -c 'yay -S --needed --noconfirm new-lg4ff-dkms-git oversteer'

echo "==> Cargando el módulo..."
modprobe -r hid-logitech-hidpp hid-logitech 2>/dev/null || true
modprobe lg4ff 2>/dev/null || true

cat <<'EOF'

Listo. Conecta el volante por USB y comprueba:
  - Ejecuta "oversteer" para calibrar sensibilidad, force feedback y combinar pedales/palanca.
  - Prueba el force feedback y los ejes con: sdl2-jstest --list  /  jstest /dev/input/js0
  - Assetto Corsa y CS2 detectarán el volante como joystick/mando automáticamente vía Steam Input.

Si el volante no aparece, revisa docs/WHEELS.md.
EOF
