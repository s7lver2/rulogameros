#!/usr/bin/env bash
# Aplica el branding completo de RuloGamerOS (fondo de pantalla, cursor,
# pantalla de bloqueo/login y tema de GRUB) sobre un Arch/Manjaro ya instalado.
# Requiere que profile/airootfs/... exista en este repo (usa ./scripts/prepare-branding.sh
# antes si quieres regenerar los assets con otras fotos).
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script como root: sudo ./scripts/setup-branding.sh" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AIROOTFS="$REPO_ROOT/profile/airootfs"

command -v convert >/dev/null 2>&1 || pacman -S --needed --noconfirm imagemagick
[[ -f "$AIROOTFS/usr/share/sddm/themes/rulogameros/background.jpg" ]] \
  || "$REPO_ROOT/scripts/prepare-branding.sh"

echo "==> Instalando SDDM, GRUB y cursor base..."
pacman -S --needed --noconfirm sddm grub qt5-graphicaleffects qt5-quickcontrols2
if ! command -v yay >/dev/null 2>&1; then
  BUILD_USER="${SUDO_USER:-root}"
  su - "$BUILD_USER" -c '
    set -e
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmp"
    cd "$tmp" && makepkg -si --noconfirm
  '
fi
BUILD_USER="${SUDO_USER:-root}"
su - "$BUILD_USER" -c 'yay -S --needed --noconfirm bibata-cursor-theme-bin'

echo "==> Copiando fondos, logo, tema de login/bloqueo y tema de GRUB..."
cp -r "$AIROOTFS/usr/share/backgrounds/rulogameros" /usr/share/backgrounds/
cp -r "$AIROOTFS/usr/share/sddm/themes/rulogameros" /usr/share/sddm/themes/
cp -r "$AIROOTFS/usr/share/plymouth/themes/rulogameros" /usr/share/plymouth/themes/ 2>/dev/null || true
mkdir -p /usr/share/icons/RuloGamerOS-Cursor
cp "$AIROOTFS/usr/share/icons/RuloGamerOS-Cursor/index.theme" /usr/share/icons/RuloGamerOS-Cursor/
mkdir -p /boot/grub/themes
cp -r "$AIROOTFS/boot/grub/themes/rulogameros" /boot/grub/themes/

echo "==> Configurando SDDM (login) y cursor..."
mkdir -p /etc/sddm.conf.d
cp "$AIROOTFS/etc/sddm.conf.d/rulogameros.conf" /etc/sddm.conf.d/
systemctl enable sddm >/dev/null 2>&1 || true

echo "==> Configurando pantalla de bloqueo de KDE para el usuario actual..."
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
if [[ -n "$TARGET_HOME" ]]; then
  mkdir -p "$TARGET_HOME/.config" "$TARGET_HOME/.icons/default"
  cat > "$TARGET_HOME/.icons/default/index.theme" <<'EOF'
[Icon Theme]
Inherits=RuloGamerOS-Cursor
EOF
  cat >> "$TARGET_HOME/.config/kcminputrc" <<'EOF'

[Mouse]
cursorTheme=RuloGamerOS-Cursor
EOF
  cat > "$TARGET_HOME/.config/kscreenlockerrc" <<'EOF'
[Greeter][Wallpaper][org.kde.image][General]
Image=/usr/share/sddm/themes/rulogameros/background.jpg
FillMode=2
EOF
  chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.icons"
fi

echo "==> Configurando tema de GRUB..."
if [[ -f /etc/default/grub ]]; then
  grep -q '^GRUB_THEME=' /etc/default/grub \
    && sed -i 's#^GRUB_THEME=.*#GRUB_THEME="/boot/grub/themes/rulogameros/theme.txt"#' /etc/default/grub \
    || echo 'GRUB_THEME="/boot/grub/themes/rulogameros/theme.txt"' >> /etc/default/grub
  grep -q '^GRUB_GFXMODE=' /etc/default/grub \
    && sed -i 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080,auto/' /etc/default/grub \
    || echo 'GRUB_GFXMODE=1920x1080,auto' >> /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "AVISO: no se encontró /etc/default/grub (¿usas GRUB como bootloader?). Se omite el tema de arranque."
fi

echo "==> Aplicando fondo de escritorio..."
sudo -u "$TARGET_USER" "$REPO_ROOT/scripts/set-wallpaper.sh" || true

cat <<'EOF'

Listo:
  - Login y pantalla de bloqueo: reinicia sesión o bloquea la pantalla para verlo.
  - Cursor: cierra sesión y vuelve a entrar para que se aplique del todo.
  - GRUB: se verá en el próximo reinicio.
  - Fondo de escritorio: ya aplicado. Cámbialo con ./scripts/set-wallpaper.sh --random
EOF
