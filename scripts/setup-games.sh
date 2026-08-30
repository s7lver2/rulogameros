#!/usr/bin/env bash
# Instala Steam + Proton + Lutris y deja accesos directos para instalar
# Assetto Corsa y Counter-Strike 2 con un clic (requiere que los tengas
# comprados/en tu biblioteca de Steam: los juegos NO se distribuyen aquí).
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script como root: sudo ./scripts/setup-games.sh" >&2
  exit 1
fi

# Assetto Corsa (appid 244210) y Counter-Strike 2 (appid 730) en Steam.
ASSETTO_CORSA_APPID=244210
CS2_APPID=730

echo "==> Habilitando repositorio multilib (necesario para Steam/Wine de 32 bits)..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
fi
pacman -Sy

echo "==> Instalando Steam, Proton (via Steam), Lutris, Wine, GameMode y MangoHud..."
pacman -S --needed --noconfirm \
  steam lutris wine winetricks \
  gamemode lib32-gamemode mangohud lib32-mangohud \
  vulkan-icd-loader lib32-vulkan-icd-loader

BUILD_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
DESKTOP_DIR="/home/$BUILD_USER/Desktop"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/Assetto Corsa.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Assetto Corsa
Comment=Instalar / jugar Assetto Corsa (RuloGamerOS)
Exec=steam steam://install/${ASSETTO_CORSA_APPID}
Icon=steam
Terminal=false
Categories=Game;
EOF

cat > "$DESKTOP_DIR/Counter-Strike 2.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Counter-Strike 2
Comment=Instalar / jugar Counter-Strike 2 (RuloGamerOS)
Exec=steam steam://install/${CS2_APPID}
Icon=steam
Terminal=false
Categories=Game;
EOF

chmod +x "$DESKTOP_DIR/Assetto Corsa.desktop" "$DESKTOP_DIR/Counter-Strike 2.desktop"
chown "$BUILD_USER":"$BUILD_USER" "$DESKTOP_DIR/Assetto Corsa.desktop" "$DESKTOP_DIR/Counter-Strike 2.desktop"

cat <<'EOF'

Listo. Pasos que faltan (requieren tu cuenta de Steam, no se pueden automatizar):
  1. Abre Steam y haz login con tu cuenta.
  2. Activa Proton para todos los títulos: Steam > Configuración > Compatibilidad
     > "Forzar el uso de una herramienta de compatibilidad específica" > Proton Experimental.
  3. Doble clic en los accesos "Assetto Corsa" y "Counter-Strike 2" del escritorio
     para instalarlos directamente si ya están en tu biblioteca.

Más detalles en docs/GAMES.md.
EOF
