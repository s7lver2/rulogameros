# Personalizar RuloGamerOS con tus propias fotos

Todo el branding (fondos, logo, splash de arranque, login/bloqueo, GRUB y cursor)
se genera a partir de las fotos que hay en:

```
profile/airootfs/usr/share/backgrounds/rulogameros/
```

## 1. Añadir/cambiar fotos del pack de fondos

Copia tus imágenes (`.jpg`/`.png`) a esa carpeta. `scripts/set-wallpaper.sh` las
detecta automáticamente (usa la primera en orden alfabético por defecto, o
`--random` para rotar entre todas):

```bash
cp mi_foto.jpg profile/airootfs/usr/share/backgrounds/rulogameros/rulogameros-14.jpg
./scripts/set-wallpaper.sh --random
```

## 2. Regenerar el logo, splash, GRUB y pantalla de login/bloqueo

`scripts/prepare-branding.sh` recorta un logo circular y genera los fondos de
pantalla completa a partir de dos fotos del pack (por defecto la 01 para el logo
y la 02 para los fondos de login/GRUB). Puedes elegir otras dos fotos:

```bash
sudo pacman -S --needed imagemagick   # si no lo tienes
./scripts/prepare-branding.sh profile/airootfs/usr/share/backgrounds/rulogameros/rulogameros-05.jpg \
                               profile/airootfs/usr/share/backgrounds/rulogameros/rulogameros-08.jpg
```

Esto regenera:
- `profile/airootfs/usr/share/plymouth/themes/rulogameros/logo.png` (splash de arranque)
- `profile/airootfs/usr/share/sddm/themes/rulogameros/{logo.png,background.jpg}` (login/bloqueo)
- `profile/airootfs/boot/grub/themes/rulogameros/{logo.png,background.png}` (menú de GRUB)

## 3. Aplicar los cambios

- **Si aún no has construido la ISO**: vuelve a ejecutar `sudo ./build.sh`, el
  overlay recoge los assets actualizados automáticamente.
- **Si ya tienes RuloGamerOS instalado**: ejecuta `sudo ./scripts/setup-branding.sh`
  de nuevo, copia los ficheros regenerados al sistema y reconstruye `grub.cfg`.

## 4. Cambiar el cursor

El cursor (`RuloGamerOS-Cursor`) es un rebranding de
[Bibata-Modern-Amber](https://github.com/ful1e5/Bibata_Cursor) mediante herencia
de tema de iconos (`profile/airootfs/usr/share/icons/RuloGamerOS-Cursor/index.theme`).
Para usar otra paleta de Bibata (o cualquier otro cursor instalado), edita la
línea `Inherits=` de ese archivo, por ejemplo:

```ini
Inherits=Bibata-Modern-Ice
```

Paletas disponibles en el paquete AUR `bibata-cursor-theme-bin`: `Bibata-Modern-Classic`,
`Bibata-Modern-Ice`, `Bibata-Modern-Amber`, `Bibata-Original-Classic`, etc.

## 5. Cambiar el texto/colores del tema de GRUB

Edita `profile/airootfs/boot/grub/themes/rulogameros/theme.txt` (colores,
tamaños y posiciones de la fuente, el logo y la barra de progreso). La sintaxis
completa está documentada en el
[manual de GRUB](https://www.gnu.org/software/grub/manual/grub/grub.html#Theme-file-format).

## 6. Cambiar el nombre/branding del sistema

- Nombre del sistema (`/etc/os-release`, hostname): edita
  `profile/airootfs/root/customize_airootfs.sh`.
- Mensaje de bienvenida en terminal: `profile/airootfs/etc/motd`.
- Nombre/etiqueta de la ISO: variables `iso_name`, `iso_label`, `iso_publisher`
  en `build.sh`.
