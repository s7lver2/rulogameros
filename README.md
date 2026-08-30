# RuloGamerOS

Distro de Linux personalizada para simracing y gaming, basada en **Arch Linux**.
Incluye de fábrica:

- 🏎️ **Drivers de volante** (Logitech, Thrustmaster, Fanatec) con force feedback vía `new-lg4ff` / `oversteer`.
- 🎮 **Steam + Proton + Lutris** listos para instalar y jugar **Assetto Corsa** y **Counter-Strike 2**
  con un clic desde el escritorio (ver `docs/GAMES.md`).
- 🖼️ **Branding completo con tus fotos**: fondos de pantalla, logo, splash de arranque
  (Plymouth), **pantalla de login y de bloqueo** (SDDM/KDE), **tema de GRUB** y un
  **cursor propio** (`RuloGamerOS-Cursor`).
- 📸 **`fastfetch` con foto real** (no ASCII) al azar del pack, renderizada con el
  protocolo gráfico de **Kitty** (terminal por defecto).
- 🇷🇺 **Sonidos de sistema en ruso**: en vez de un "ding", el sistema te insulta
  (offline, generado con `espeak-ng`, sin audio con copyright).
- 🎬 **Vídeo de bienvenida** la primera vez que inicias sesión: tus fotos con
  efectos ridículos (swirl, implode, wave...) y un pitido de kazoo.
- 💿 **Icono propio para la ISO/USB** y un **instalador guiado por terminal**
  (`rulogameros-install`) que lo deja todo listo en el disco.
- 🧰 Escritorio ligero (KDE Plasma) pensado para rendimiento en juegos.

> Los juegos (Assetto Corsa, CS2) son de pago/con DRM y no se pueden redistribuir dentro
> de la ISO. RuloGamerOS deja Steam instalado y configurado para que, con tu cuenta,
> se instalen con un solo clic (ver `docs/GAMES.md`).

## Estructura del repo

```
rulogameros/
├── build.sh                 # Genera la ISO (ejecutar en Arch Linux)
├── profile/                  # Overlay que se aplica sobre el perfil "releng" de archiso
│   ├── packages.x86_64       # Paquetes extra (Steam, drivers, KDE, Kitty, etc.)
│   └── airootfs/             # Archivos que van directos al sistema (branding, scripts)
├── installer/
│   └── rulogameros-install.sh  # Instalador guiado (particiona, instala, aplica branding)
├── scripts/                  # Generación de branding + post-instalación en Arch ya instalado
│   ├── setup-wheel.sh          # Instala y configura drivers de volante
│   ├── setup-games.sh          # Instala Steam/Proton/Lutris y deja accesos a AC y CS2
│   ├── setup-branding.sh       # Aplica TODO el branding sobre un Arch ya instalado
│   ├── set-wallpaper.sh        # Aplica/rota el pack de fondos personalizados
│   ├── prepare-branding.sh     # Genera logo, splash, fondo de login/GRUB
│   ├── generate-russian-sounds.sh  # Tema de sonidos con insultos en ruso (espeak-ng)
│   ├── generate-welcome-video.sh   # Vídeo de bienvenida con efectos ridículos
│   └── generate-iso-icon.sh        # Icono .ico + autorun.inf para la ISO/USB
└── docs/                     # Guías detalladas
    ├── BUILD.md
    ├── WHEELS.md
    ├── GAMES.md
    ├── INSTALLER.md
    └── CUSTOMIZE.md
```

## Inicio rápido

### Opción A — Construir la ISO completa
Necesitas una máquina (o VM) con **Arch Linux** instalado:

```bash
sudo pacman -S --needed archiso imagemagick ffmpeg espeak-ng libisoburn git
git clone <este-repo>
cd rulogameros
sudo ./build.sh
```

La ISO sale en `out/rulogameros-<fecha>-x86_64.iso`. Grábala en un USB con `dd` o Ventoy
y arranca — desde el live puedes usar el icono de escritorio "Instalar RuloGamerOS"
para pasarlo al disco. Detalles en [`docs/BUILD.md`](docs/BUILD.md) e
[`docs/INSTALLER.md`](docs/INSTALLER.md).

### Opción B — Convertir un Arch Linux que ya tienes
Si no quieres generar la ISO, puedes aplicar RuloGamerOS sobre un Arch/Manjaro ya instalado:

```bash
git clone <este-repo>
cd rulogameros
sudo ./scripts/setup-wheel.sh
sudo ./scripts/setup-games.sh
sudo ./scripts/setup-branding.sh   # logo, cursor, login/bloqueo, GRUB, sonidos, bienvenida y fondo
```

Más detalles: [`docs/WHEELS.md`](docs/WHEELS.md), [`docs/GAMES.md`](docs/GAMES.md),
[`docs/INSTALLER.md`](docs/INSTALLER.md), [`docs/CUSTOMIZE.md`](docs/CUSTOMIZE.md).
