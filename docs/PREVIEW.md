# Sobre las imágenes de "Así se ve" del README

Las capturas en `docs/preview/` **no son de una instalación real** de
RuloGamerOS — son mockups en HTML/CSS renderizados con Chromium headless,
usando los colores, tipografías y fotos exactos de los temas del repo
(`profile/airootfs/boot/grub/themes/rulogameros/theme.txt`, `.../sddm/themes/rulogameros/`,
`profile/airootfs/etc/skel/.config/kitty/kitty.conf`, etc.), no capturas
inventadas al azar.

## Por qué son mockups y no capturas reales

Generar estas imágenes requiere `mkarchiso` corriendo en una máquina Arch
Linux de verdad (ver `docs/BUILD.md`), arrancar la ISO resultante y hacer
capturas de pantalla reales. El entorno donde se desarrolló este repo no
tiene acceso a los mirrors de Arch Linux ni a Docker Hub (política de red
restringida), así que no se pudo hacer una build real para las capturas —
en su lugar se replicó fielmente cada pantalla a partir de los propios
archivos de tema del repo.

## Cómo sacar capturas reales

En cuanto construyas la ISO y la arranques (`docs/BUILD.md`), sustituye
`docs/preview/*.png` por capturas de verdad:

- **GRUB**: una foto de la pantalla, o `grub-mkscreenshot` si tu firmware lo soporta.
- **Login (SDDM)**: `Ctrl+Alt+F2` a una TTY y `scrot`/`grim`, o el propio
  atajo de captura del compositor gráfico antes de iniciar sesión.
- **Escritorio + `fastfetch`**: `spectacle` (KDE) o `grim` con la terminal
  Kitty abierta y `fastfetch` ejecutado.
- **Cursor**: cualquier captura de pantalla con el puntero visible
  (`spectacle` incluye el cursor si activas esa opción).

## Cómo se generaron los mockups actuales

Si cambias el branding (otras fotos, otros colores) y quieres regenerar los
mockups sin tener aún una build real, el script vive fuera del repo (usa
Playwright + Chromium headless para renderizar HTML y capturarlo). El propio
HTML de cada mockup replica:

- `grub.png`: `profile/airootfs/boot/grub/themes/rulogameros/theme.txt` (colores,
  logo, barra de progreso).
- `login.png`: `profile/airootfs/usr/share/sddm/themes/rulogameros/{theme.conf,Main.qml}`.
- `desktop.png`: la paleta de `profile/airootfs/etc/skel/.config/kitty/kitty.conf`
  y el listado de `profile/airootfs/etc/skel/.config/fastfetch/config.jsonc`.
- `cursor.png`: el resultado de `scripts/generate-photo-cursor.sh`.

Si quieres el script generador para volver a usarlo, pídelo — no se incluyó
en el repo porque depende de Playwright/Chromium, que no forman parte de
RuloGamerOS.
