#!/usr/bin/env bash
# Se ejecuta dentro del chroot durante "mkarchiso" (archiso llama a este script
# automáticamente si existe en airootfs/root/). Configura branding, servicios
# y paquetes AUR (que no están en los repos oficiales) para RuloGamerOS.
set -e -u

# --- Identidad del sistema ---
echo "rulogameros" > /etc/hostname
sed -i 's/^NAME=.*/NAME="RuloGamerOS"/' /etc/os-release || true
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="RuloGamerOS"/' /etc/os-release || true

# --- Servicios base ---
systemctl enable NetworkManager
systemctl enable sddm

# --- Habilitar multilib (necesario para Steam/Wine 32 bits) ---
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
fi

# --- Usuario temporal para compilar paquetes AUR (makepkg no corre como root) ---
useradd -m -G wheel builder
echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

pacman -Sy --noconfirm --needed base-devel git

su - builder -c '
  set -e
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin && makepkg -si --noconfirm
  # Drivers de force-feedback para volantes Logitech (G25/G27/G29/G920, etc.)
  yay -S --noconfirm new-lg4ff-dkms-git || echo "AVISO: no se pudo compilar new-lg4ff, revisa docs/WHEELS.md"
  # Cursor base sobre el que se rebrandea RuloGamerOS-Cursor (ver index.theme).
  yay -S --noconfirm bibata-cursor-theme-bin || echo "AVISO: no se pudo instalar el cursor base, revisa docs/CUSTOMIZE.md"
'

userdel -r builder
rm -f /etc/sudoers.d/builder

# --- Plymouth theme de arranque personalizado ---
# El paquete y el tema no bastan: sin el hook "plymouth" en mkinitcpio.conf,
# plymouthd nunca arranca en el initramfs y no se ve nada en el boot.
if [[ -f /etc/mkinitcpio.conf ]] && ! grep -q 'plymouth' /etc/mkinitcpio.conf; then
  sed -i '/^HOOKS=/ s/\budev\b/udev plymouth/' /etc/mkinitcpio.conf
fi
plymouth-set-default-theme -R rulogameros || true

# --- Tema de GRUB personalizado ---
if [[ -f /etc/default/grub ]]; then
  grep -q '^GRUB_THEME=' /etc/default/grub \
    && sed -i 's#^GRUB_THEME=.*#GRUB_THEME="/boot/grub/themes/rulogameros/theme.txt"#' /etc/default/grub \
    || echo 'GRUB_THEME="/boot/grub/themes/rulogameros/theme.txt"' >> /etc/default/grub
  grep -q '^GRUB_GFXMODE=' /etc/default/grub \
    && sed -i 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080,auto/' /etc/default/grub \
    || echo 'GRUB_GFXMODE=1920x1080,auto' >> /etc/default/grub
  command -v grub-mkconfig >/dev/null 2>&1 && grub-mkconfig -o /boot/grub/grub.cfg || true
fi

# --- Cursor y pantalla de bloqueo por defecto para nuevos usuarios ---
mkdir -p /etc/skel/.config /etc/skel/.icons/default
cat > /etc/skel/.icons/default/index.theme <<'EOF'
[Icon Theme]
Inherits=RuloGamerOS-Cursor
EOF

cat > /etc/skel/.config/kcminputrc <<'EOF'
[Mouse]
cursorTheme=RuloGamerOS-Cursor
EOF

cat > /etc/skel/.config/kscreenlockerrc <<'EOF'
[Greeter][Wallpaper][org.kde.image][General]
Image=/usr/share/sddm/themes/rulogameros/background.jpg
FillMode=2
EOF

cat > /etc/skel/.config/rulogameros-wallpaper <<'EOF'
/usr/share/backgrounds/rulogameros/rulogameros-01.jpg
EOF

# --- Kitty como terminal por defecto (fastfetch necesita su protocolo gráfico) ---
mkdir -p /etc/skel/.config
echo "kitty.desktop" > /etc/skel/.config/xdg-terminals.list
cat >> /etc/skel/.config/kdeglobals <<'EOF'

[General]
TerminalApplication=kitty
TerminalService=kitty.desktop
EOF

# --- Tema de sonidos en ruso (generado por scripts/generate-russian-sounds.sh) ---
if [[ -d /usr/share/sounds/RuloGamerOS ]]; then
  mkdir -p /usr/share/sounds/default
  cat > /usr/share/sounds/default/index.theme <<'EOF'
[Sound Theme]
Name=Default
Inherits=RuloGamerOS
Directories=stereo
[stereo]
OutputProfile=stereo
EOF
  cat >> /etc/skel/.config/kdeglobals <<'EOF'

[Sounds]
Theme=RuloGamerOS
EOF
fi

# --- Animación de bienvenida en el primer login (ver generate-welcome-video.sh) ---
chmod +x /usr/local/bin/rulogameros-welcome.sh 2>/dev/null || true
chmod +x /usr/local/bin/fastfetch 2>/dev/null || true
chmod +x /usr/local/bin/rulogameros-set-wallpaper.sh 2>/dev/null || true
