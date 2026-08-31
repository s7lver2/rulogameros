# Personalizar RuloGamerOS con tus propias fotos

Todo el branding (fondos, logo, splash de arranque, login/bloqueo, GRUB y cursor)
se genera a partir de las fotos que hay en:

```
profile/airootfs/usr/share/backgrounds/rulogameros/
```

## 1. Añadir/cambiar fotos del pack de fondos

Copia tus imágenes (`.jpg`/`.png`) a esa carpeta. `scripts/set-wallpaper.sh` las
detecta automáticamente (usa la primera en orden alfabético por defecto,
`--random` para rotar entre todas, o `--pick` para elegirla a mano):

```bash
cp mi_foto.jpg profile/airootfs/usr/share/backgrounds/rulogameros/rulogameros-14.jpg
./scripts/set-wallpaper.sh --random
```

### Selector de fondos con vista previa

Para elegir la foto a mano en vez de que rote sola, RuloGamerOS trae un
selector gráfico: **"Selector de fondos de RuloGamerOS"** en el menú de
aplicaciones (búscalo por "fondo" en el lanzador de KDE), o desde terminal:

```bash
rulogameros-set-wallpaper.sh --pick
```

Abre el diálogo de archivos de KDE (`kdialog`) ya colocado en la carpeta del
pack, con miniaturas de cada foto, y aplica la que elijas al momento. El
lanzador vive en `profile/airootfs/usr/share/applications/rulogameros-wallpaper-picker.desktop`
y necesita el paquete `kde-cli-tools` (ya incluido en `profile/packages.x86_64`).

## 2. Regenerar el logo, splash, GRUB y pantalla de login/bloqueo

`scripts/prepare-branding.sh` recorta un logo circular y genera los fondos de
pantalla completa a partir de dos fotos del pack (por defecto la 03 —la del
selfie con la pantalla rota— para el logo, y la 02 para los fondos de
login/GRUB). Puedes elegir otras dos fotos:

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

## 4. Cambiar el cursor (literalmente una foto)

El cursor `RuloGamerOS-Cursor` **no es un cursor de verdad**: es una foto del
pack recortada en cuadrado (sin máscara circular, sin suavizar, sin nada) y
convertida a formato de cursor X11 con `xcursorgen`. Es feo a propósito — esa
es la idea. Por defecto usa `rulogameros-03.jpg` (la del selfie con la
pantalla rota), que ya tiene la pinta perfecta para esto.

Para cambiar la foto:

```bash
sudo pacman -S --needed imagemagick xorg-xcursorgen   # si no los tienes
./scripts/generate-photo-cursor.sh profile/airootfs/usr/share/backgrounds/rulogameros/rulogameros-09.jpg
```

El script (`scripts/generate-photo-cursor.sh`) genera varios tamaños (24 a 96px)
y enlaza todos los nombres de cursor habituales (flecha, texto, espera,
redimensionar, mano...) al mismo archivo, así que **cualquier** puntero del
sistema se ve como esa foto, sea cual sea la acción. El hotspot (el punto
exacto donde "clicas") está fijado en la esquina superior izquierda de la
foto, como un cursor normal — si no, sería inutilizable.

Aplica los cambios con `sudo ./build.sh` (ISO) o `sudo ./scripts/setup-branding.sh`
(sistema ya instalado).

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

## 7. `fastfetch` con fotos reales (Kitty)

`neofetch`/`fastfetch` normalmente muestran el logo ASCII de la distro.
RuloGamerOS lo sustituye por una **foto real** del pack, escogida al azar cada
vez, renderizada con el protocolo gráfico de Kitty (`/usr/local/bin/fastfetch`,
que hace de wrapper del `fastfetch` real). Para que se vea la imagen de
verdad necesitas un terminal compatible con el protocolo Kitty — por eso
Kitty viene como terminal por defecto (`profile/airootfs/etc/skel/.config/kitty/`).
Si usas Konsole u otro terminal sin ese soporte, `fastfetch` caerá de vuelta
a un logo genérico.

Para cambiar qué información se muestra junto a la foto, edita
`profile/airootfs/etc/skel/.config/fastfetch/config.jsonc`. El tema de color
de Kitty se cambia en `profile/airootfs/etc/skel/.config/kitty/kitty.conf`.

## 8. Sonidos de sistema en ruso (insultos)

El tema de sonidos `RuloGamerOS` sustituye los "dings" educados por insultos
en ruso generados offline con `espeak-ng` (sin usar ningún audio con
copyright). Las frases están en `scripts/generate-russian-sounds.sh`, en el
array `PHRASES` (una por evento: login, logout, error, aviso...). Edítalas y
vuelve a generar el tema:

```bash
sudo pacman -S --needed espeak-ng ffmpeg   # si no los tienes
./scripts/generate-russian-sounds.sh
```

Esto regenera `profile/airootfs/usr/share/sounds/RuloGamerOS/`. Se aplica
solo en la construcción de la ISO (`customize_airootfs.sh`) o con
`sudo ./scripts/setup-branding.sh` en un sistema ya instalado.

## 9. Vídeo de bienvenida con efectos ridículos

`scripts/generate-welcome-video.sh` coge cada foto del pack, le aplica un
efecto distinto de ImageMagick en bucle (`-swirl`, `-implode`, `-wave`,
`-spread`, `-charcoal`, `-solarize`, `-sepia-tone`, `-negate`...), las une en
un slideshow con zoom (Ken Burns) y les pone un pitido de kazoo sintetizado
de fondo. Se reproduce a pantalla completa una única vez, la primera vez que
inicias sesión (`/usr/local/bin/rulogameros-welcome.sh`, vía autostart).

Para cambiar los efectos, edita el array `EFFECTS` del script. Para volver a
ver el vídeo tras haberlo visto ya, borra el marcador:

```bash
rm ~/.config/.rulogameros-welcome-shown
```

Para regenerarlo con fotos nuevas:

```bash
sudo pacman -S --needed imagemagick ffmpeg   # si no los tienes
./scripts/generate-welcome-video.sh
```

## 10. Icono de la ISO/USB

`scripts/generate-iso-icon.sh` genera un `.ico` multi-resolución a partir del
logo (el mismo que usan el login y GRUB) y un `autorun.inf` para que
Explorador de Windows lo muestre al insertar el USB. `build.sh` lo inyecta
automáticamente en la raíz de la ISO con `xorriso` al terminar la build (no
hace falta reconstruir toda la ISO para actualizarlo, con volver a ejecutar
`sudo ./build.sh` es suficiente).
