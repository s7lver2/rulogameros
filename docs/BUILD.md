# Construir la ISO de RuloGamerOS

## Requisitos

- Una máquina o VM con **Arch Linux** ya instalado (puede ser una VM desechable).
- Paquetes: `archiso`, `imagemagick`, `git`.
- ~15 GB libres y conexión a internet (descarga todos los paquetes del sistema base).

```bash
sudo pacman -S --needed archiso imagemagick git
```

## Pasos

```bash
git clone <este-repo> rulogameros
cd rulogameros
sudo ./build.sh
```

`build.sh`:
1. Genera el logo y la barra del splash de arranque (`scripts/prepare-branding.sh`),
   usando la primera foto del pack en `profile/airootfs/usr/share/backgrounds/rulogameros/`.
2. Copia el perfil oficial `releng` de archiso (el mismo que usa el Arch Linux ISO
   oficial) a un directorio temporal.
3. Aplica el overlay de `profile/`: paquetes extra, branding y el script
   `customize_airootfs.sh` (que instala los drivers de volante vía AUR dentro del chroot).
4. Renombra la ISO/etiqueta a `RuloGamerOS`.
5. Ejecuta `mkarchiso` para generar la imagen final en `out/`.

La primera build tarda bastante (descarga y compila `new-lg4ff` desde AUR dentro del
chroot). Compilaciones siguientes son más rápidas si mantienes la caché de pacman.

## Grabar en un USB

```bash
sudo dd if=out/rulogameros-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Sustituye `/dev/sdX` por tu pendrive (revisa con `lsblk` antes, para no borrar el disco
equivocado). También puedes usar [Ventoy](https://www.ventoy.net/) o [balenaEtcher](https://etcher.balena.io/).

## Cambiar los paquetes incluidos

Edita `profile/packages.x86_64` y vuelve a ejecutar `sudo ./build.sh`.
