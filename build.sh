#!/usr/bin/env bash
# Construye la ISO de RuloGamerOS a partir del perfil "releng" oficial de archiso,
# con el overlay de profile/ (paquetes extra + branding + scripts de personalización).
#
# Requisitos: Arch Linux con `archiso`, `imagemagick` y `git` instalados.
# Uso:
#   sudo ./build.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Este script necesita root (mkarchiso lo requiere). Ejecuta: sudo ./build.sh" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d)"
OUT_DIR="$REPO_ROOT/out"
RELENG_PROFILE="/usr/share/archiso/configs/releng"

trap 'rm -rf "$WORK_DIR"' EXIT

command -v mkarchiso >/dev/null 2>&1 || {
  echo "Falta archiso. Instálalo con: sudo pacman -S --needed archiso" >&2
  exit 1
}
[[ -d "$RELENG_PROFILE" ]] || {
  echo "No se encuentra el perfil releng en $RELENG_PROFILE (¿está instalado archiso?)" >&2
  exit 1
}

echo "==> Generando assets de branding (logo, splash, login, GRUB)..."
"$REPO_ROOT/scripts/prepare-branding.sh"

echo "==> Generando icono de la ISO..."
"$REPO_ROOT/scripts/generate-iso-icon.sh"

echo "==> Generando tema de sonidos en ruso (insultos, vía espeak-ng)..."
"$REPO_ROOT/scripts/generate-russian-sounds.sh"

if [[ "${SKIP_WELCOME_VIDEO:-0}" != "1" ]]; then
  echo "==> Generando vídeo de bienvenida (esto puede tardar varios minutos)..."
  "$REPO_ROOT/scripts/generate-welcome-video.sh"
else
  echo "==> SKIP_WELCOME_VIDEO=1: se omite el vídeo de bienvenida."
fi

echo "==> Copiando perfil base releng..."
cp -r "$RELENG_PROFILE" "$WORK_DIR/profile"

echo "==> Aplicando overlay de RuloGamerOS..."
cp -r "$REPO_ROOT/profile/airootfs/." "$WORK_DIR/profile/airootfs/"
cat "$REPO_ROOT/profile/packages.x86_64" >> "$WORK_DIR/profile/packages.x86_64"
sort -u -o "$WORK_DIR/profile/packages.x86_64" "$WORK_DIR/profile/packages.x86_64"

echo "==> Empaquetando el repo dentro de la ISO (para el instalador en /opt/rulogameros)..."
mkdir -p "$WORK_DIR/profile/airootfs/opt/rulogameros"
tar --exclude='.git' --exclude='out' --exclude='profile/iso_root' -cf - -C "$REPO_ROOT" . \
  | tar -xf - -C "$WORK_DIR/profile/airootfs/opt/rulogameros"
chmod +x "$WORK_DIR/profile/airootfs/opt/rulogameros/installer/rulogameros-install.sh"
chmod +x "$WORK_DIR/profile/airootfs/opt/rulogameros/scripts/"*.sh
mkdir -p "$WORK_DIR/profile/airootfs/usr/local/bin"
ln -sf /opt/rulogameros/installer/rulogameros-install.sh "$WORK_DIR/profile/airootfs/usr/local/bin/rulogameros-install"

# Nombre de la ISO / etiqueta del volumen.
sed -i 's/^iso_name=.*/iso_name="rulogameros"/' "$WORK_DIR/profile/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="RULOGAMEROS_$(date +%Y%m)"/' "$WORK_DIR/profile/profiledef.sh"
sed -i 's/^iso_publisher=.*/iso_publisher="RuloGamerOS"/' "$WORK_DIR/profile/profiledef.sh"
sed -i 's/^iso_application=.*/iso_application="RuloGamerOS Live\/Rescue CD"/' "$WORK_DIR/profile/profiledef.sh"

chmod +x "$WORK_DIR/profile/airootfs/root/customize_airootfs.sh"

mkdir -p "$OUT_DIR"
echo "==> Ejecutando mkarchiso (esto puede tardar bastante)..."
mkarchiso -v -w "$WORK_DIR/build" -o "$OUT_DIR" "$WORK_DIR/profile"

ISO_PATH="$(find "$OUT_DIR" -maxdepth 1 -name '*.iso' -newer "$WORK_DIR/profile/profiledef.sh" | head -n1)"
if [[ -n "$ISO_PATH" && -d "$REPO_ROOT/profile/iso_root" ]]; then
  if command -v xorriso >/dev/null 2>&1; then
    echo "==> Inyectando icono personalizado en la ISO ($(basename "$ISO_PATH"))..."
    xorriso -indev "$ISO_PATH" -outdev "$ISO_PATH" -boot_image any replay -pathspecs on \
      -add "$REPO_ROOT/profile/iso_root/rulogameros.ico=rulogameros.ico" \
           "$REPO_ROOT/profile/iso_root/autorun.inf=autorun.inf" \
      -- commit
  else
    echo "AVISO: falta xorriso, no se pudo inyectar el icono en la ISO." >&2
  fi
fi

echo "==> Listo. ISO generada en: $OUT_DIR"
