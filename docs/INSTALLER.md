# Instalador de RuloGamerOS

`installer/rulogameros-install.sh` es un instalador guiado por terminal que
lleva RuloGamerOS del live USB a un disco real. No es un instalador gráfico
tipo Calamares (eso es un proyecto mucho más grande), pero automatiza todos
los pasos de una instalación manual de Arch Linux + toda la personalización
del repo en un solo comando.

> ⚠️ **Borra todo el contenido del disco que elijas.** El script pide que
> escribas el nombre exacto del disco (`sda`, `nvme0n1`...) para confirmar,
> y no continúa si te equivocas al escribirlo. Aun así, revisa dos veces qué
> disco eliges — sobre todo en un portátil con un solo disco donde también
> vive tu sistema actual.

## Cómo se lanza

- **Desde el live USB de RuloGamerOS**: doble clic en el icono de escritorio
  "Instalar RuloGamerOS", o en una terminal:
  ```bash
  sudo rulogameros-install
  ```
- **Desde cualquier Arch Linux live** (por ejemplo si aún no has generado tu
  propia ISO): clona el repo y ejecútalo directamente:
  ```bash
  git clone <este-repo> rulogameros
  cd rulogameros
  sudo ./installer/rulogameros-install.sh
  ```

## Qué hace, paso a paso

1. Te pregunta el disco de destino, el hostname, el usuario y contraseña a
   crear, y la zona horaria.
2. Particiona el disco en GPT: partición EFI (512 MiB, si arrancas en modo
   UEFI) + partición raíz ext4 con el resto del espacio.
3. Instala el sistema base con `pacstrap` (kernel, Steam, KDE Plasma, drivers
   de volante, Kitty/fastfetch... todo lo que hay en `profile/packages.x86_64`).
4. Genera `/etc/fstab`, copia el repo entero a `/opt/rulogameros` dentro del
   sistema instalado, y entra en `arch-chroot` para:
   - Configurar idioma, zona horaria, hostname, usuario y contraseñas.
   - Instalar GRUB (UEFI o BIOS, detectado automáticamente).
   - Ejecutar `customize_airootfs.sh` (el mismo script que usa la ISO en vivo):
     branding, servicios, cursor y drivers vía AUR.
   - Ejecutar `setup-wheel.sh`, `setup-games.sh` y `setup-branding.sh` para
     dejar el volante calibrable, Steam listo y todo el branding aplicado
     igual que en la ISO.
5. Desmonta todo y te dice que ya puedes reiniciar.

## Cosas a tener en cuenta

- No redimensiona particiones existentes ni hace dual-boot automático: usa
  **todo** el disco que elijas. Si quieres dual-boot, particiona tú mismo
  antes con `cfdisk`/`gparted` y adapta el script (o pide instalación manual
  siguiendo la [wiki de Arch](https://wiki.archlinux.org/title/Installation_guide)
  y luego aplica solo el branding con `scripts/setup-branding.sh`).
- Necesita conexión a internet durante la instalación (descarga paquetes).
- La primera vez que arranques el sistema instalado, verás el vídeo de
  bienvenida y podrás iniciar sesión en Steam para instalar Assetto Corsa/CS2
  (ver `docs/GAMES.md`).
