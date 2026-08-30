# Construir la ISO de RuloGamerOS

## Requisitos

- Una máquina o VM con **Arch Linux** ya instalado (puede ser una VM desechable).
- Paquetes: `archiso`, `imagemagick`, `ffmpeg`, `espeak-ng`, `git`, `libisoburn` (trae `xorriso`, opcional pero recomendado para el icono de la ISO).
- ~15 GB libres y conexión a internet (descarga todos los paquetes del sistema base).

```bash
sudo pacman -S --needed archiso imagemagick ffmpeg espeak-ng libisoburn git
```

## Pasos

```bash
git clone <este-repo> rulogameros
cd rulogameros
sudo ./build.sh
```

`build.sh`:
1. Genera el branding a partir de las fotos del pack
   (`profile/airootfs/usr/share/backgrounds/rulogameros/`):
   - Logo, splash de arranque y fondo de login/GRUB (`scripts/prepare-branding.sh`).
   - Icono de la ISO/USB (`scripts/generate-iso-icon.sh`).
   - Tema de sonidos en ruso (`scripts/generate-russian-sounds.sh`, vía `espeak-ng`, offline).
   - Vídeo de bienvenida del primer login con efectos ridículos
     (`scripts/generate-welcome-video.sh`) — pon `SKIP_WELCOME_VIDEO=1 sudo ./build.sh`
     para saltártelo si vas con prisa, tarda varios minutos.
2. Copia el perfil oficial `releng` de archiso (el mismo que usa el Arch Linux ISO
   oficial) a un directorio temporal.
3. Aplica el overlay de `profile/`: paquetes extra, branding, `customize_airootfs.sh`
   (instala drivers de volante y cursor vía AUR dentro del chroot), y empaqueta el
   repo entero en `/opt/rulogameros` dentro de la ISO para que el instalador
   guiado (`installer/rulogameros-install.sh`, accesible como `rulogameros-install`
   desde el live) esté disponible.
4. Renombra la ISO/etiqueta a `RuloGamerOS`.
5. Ejecuta `mkarchiso` para generar la imagen final en `out/`.
6. Inyecta el icono personalizado (`rulogameros.ico` + `autorun.inf`) en la raíz
   de la ISO con `xorriso`, sin tener que reconstruirla.

La primera build tarda bastante (descarga y compila `new-lg4ff` y el cursor desde
AUR dentro del chroot, más el vídeo de bienvenida). Compilaciones siguientes son
más rápidas si mantienes la caché de pacman.

## Grabar en un USB

```bash
sudo dd if=out/rulogameros-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Sustituye `/dev/sdX` por tu pendrive (revisa con `lsblk` antes, para no borrar el disco
equivocado). También puedes usar [Ventoy](https://www.ventoy.net/) o [balenaEtcher](https://etcher.balena.io/).

## Cambiar los paquetes incluidos

Edita `profile/packages.x86_64` y vuelve a ejecutar `sudo ./build.sh`.
