#!/usr/bin/env bash
# Instalador guiado de RuloGamerOS. Pensado para ejecutarse desde el propio
# live USB de RuloGamerOS (o cualquier Arch Linux live), instala el sistema
# base en un disco real y reutiliza el resto del repo (customize_airootfs.sh,
# setup-wheel.sh, setup-games.sh, setup-branding.sh) dentro del chroot para
# que el sistema instalado quede idéntico al de la ISO.
#
# ATENCIÓN: este script BORRA TODO el contenido del disco que elijas.
# Uso: sudo ./installer/rulogameros-install.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta el instalador como root: sudo ./installer/rulogameros-install.sh" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MNT=/mnt

command -v pacstrap >/dev/null 2>&1 || {
  echo "Falta arch-install-scripts (pacstrap/genfstab). Instálalo con: pacman -S --needed arch-install-scripts" >&2
  exit 1
}

echo "=================================================="
echo "   Instalador de RuloGamerOS"
echo "=================================================="
echo
echo "Discos disponibles:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E 'disk$'
echo
read -rp "Disco donde instalar RuloGamerOS (ej. sda, nvme0n1): " DISK_NAME
DISK="/dev/$DISK_NAME"
[[ -b "$DISK" ]] || { echo "No existe el disco $DISK" >&2; exit 1; }

echo
echo "!!! ESTO BORRARÁ TODOS LOS DATOS DE $DISK !!!"
read -rp "Escribe exactamente \"$DISK_NAME\" para confirmar y continuar: " CONFIRM
[[ "$CONFIRM" == "$DISK_NAME" ]] || { echo "Confirmación incorrecta, abortando. No se ha tocado el disco."; exit 1; }

read -rp "Hostname [rulogameros]: " HOSTNAME_INPUT
HOSTNAME_INPUT="${HOSTNAME_INPUT:-rulogameros}"
read -rp "Nombre de usuario a crear [rulogamer]: " USERNAME_INPUT
USERNAME_INPUT="${USERNAME_INPUT:-rulogamer}"
read -rsp "Contraseña para $USERNAME_INPUT (y para root): " USER_PASSWORD
echo
read -rp "Zona horaria [Europe/Madrid]: " TIMEZONE
TIMEZONE="${TIMEZONE:-Europe/Madrid}"

if [[ -d /sys/firmware/efi ]]; then BOOT_MODE=uefi; else BOOT_MODE=bios; fi
echo "==> Modo de arranque detectado: $BOOT_MODE"

echo "==> Particionando $DISK (GPT: ESP 512MiB + raíz con el resto)..."
sgdisk --zap-all "$DISK"
if [[ "$BOOT_MODE" == uefi ]]; then
  sgdisk -n1:0:+512MiB -t1:ef00 -c1:ESP "$DISK"
  sgdisk -n2:0:0       -t2:8300 -c2:root "$DISK"
  PART_BOOT="${DISK}1"; [[ "$DISK" == *nvme* ]] && PART_BOOT="${DISK}p1"
  PART_ROOT="${DISK}2"; [[ "$DISK" == *nvme* ]] && PART_ROOT="${DISK}p2"
else
  sgdisk -n1:0:+2MiB   -t1:ef02 -c1:bios_grub "$DISK"
  sgdisk -n2:0:0       -t2:8300 -c2:root "$DISK"
  PART_ROOT="${DISK}2"; [[ "$DISK" == *nvme* ]] && PART_ROOT="${DISK}p2"
  PART_BOOT=""
fi

echo "==> Formateando particiones..."
[[ "$BOOT_MODE" == uefi ]] && mkfs.fat -F32 "$PART_BOOT"
mkfs.ext4 -F "$PART_ROOT"

echo "==> Montando..."
mount "$PART_ROOT" "$MNT"
if [[ "$BOOT_MODE" == uefi ]]; then
  mkdir -p "$MNT/boot"
  mount "$PART_BOOT" "$MNT/boot"
fi

echo "==> Instalando el sistema base (esto tarda bastante, descarga paquetes)..."
BASE_PKGS=(base linux linux-firmware sudo networkmanager grub efibootmgr base-devel git)
EXTRA_PKGS=()
if [[ -f "$REPO_ROOT/profile/packages.x86_64" ]]; then
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    EXTRA_PKGS+=("$pkg")
  done < "$REPO_ROOT/profile/packages.x86_64"
fi
pacstrap -K "$MNT" "${BASE_PKGS[@]}" "${EXTRA_PKGS[@]}"

echo "==> Generando fstab..."
genfstab -U "$MNT" >> "$MNT/etc/fstab"

echo "==> Copiando el repo de RuloGamerOS al sistema instalado (para el branding)..."
mkdir -p "$MNT/opt/rulogameros"
cp -r "$REPO_ROOT/." "$MNT/opt/rulogameros/"

echo "==> Configurando el sistema dentro del chroot..."
# El heredoc va con delimitador entre comillas ('CHROOT_EOF_Q') para que bash
# NO expanda aquí las variables (evita que una contraseña con $, comillas o
# backticks rompa o inyecte comandos en el script). En su lugar se pasan como
# variables de entorno reales al bash que corre dentro del chroot.
arch-chroot "$MNT" env \
  HOSTNAME_INPUT="$HOSTNAME_INPUT" \
  USERNAME_INPUT="$USERNAME_INPUT" \
  USER_PASSWORD="$USER_PASSWORD" \
  TIMEZONE="$TIMEZONE" \
  BOOT_MODE="$BOOT_MODE" \
  DISK="$DISK" \
  /bin/bash <<'CHROOT_EOF_Q'
set -e
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "$HOSTNAME_INPUT" > /etc/hostname
cat > /etc/hosts <<HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME_INPUT.localdomain $HOSTNAME_INPUT
HOSTS_EOF

printf 'root:%s\n' "$USER_PASSWORD" | chpasswd
useradd -m -G wheel,input -s /bin/bash "$USERNAME_INPUT"
printf '%s:%s\n' "$USERNAME_INPUT" "$USER_PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

if [[ "$BOOT_MODE" == uefi ]]; then
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=RuloGamerOS
else
  grub-install --target=i386-pc "$DISK"
fi

chmod +x /opt/rulogameros/profile/airootfs/root/customize_airootfs.sh
/opt/rulogameros/profile/airootfs/root/customize_airootfs.sh

chmod +x /opt/rulogameros/scripts/*.sh
/opt/rulogameros/scripts/setup-wheel.sh || echo "AVISO: setup-wheel.sh falló, revisa docs/WHEELS.md más tarde."
SUDO_USER="$USERNAME_INPUT" /opt/rulogameros/scripts/setup-games.sh || echo "AVISO: setup-games.sh falló, revisa docs/GAMES.md más tarde."
SUDO_USER="$USERNAME_INPUT" /opt/rulogameros/scripts/setup-branding.sh || echo "AVISO: setup-branding.sh falló, revisa docs/CUSTOMIZE.md más tarde."
CHROOT_EOF_Q

echo "==> Desmontando..."
umount -R "$MNT"

cat <<EOF

=================================================
  RuloGamerOS instalado en $DISK
=================================================
Usuario: $USERNAME_INPUT
Reinicia y quita el USB para arrancar tu nuevo sistema:
  reboot
EOF
