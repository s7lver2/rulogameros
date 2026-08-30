# RuloGamerOS

Distro de Linux personalizada para simracing y gaming, basada en **Arch Linux**.
Incluye de fábrica:

- 🏎️ **Drivers de volante** (Logitech, Thrustmaster, Fanatec) con force feedback vía `new-lg4ff` / `oversteer`.
- 🎮 **Steam + Proton + Lutris** listos para instalar y jugar **Assetto Corsa** y **Counter-Strike 2**.
- 🖼️ **Branding completo con tus fotos**: fondos de pantalla, logo, splash de arranque
  (Plymouth), **pantalla de login y de bloqueo** (SDDM/KDE), **tema de GRUB** y un
  **cursor propio** (`RuloGamerOS-Cursor`).
- 🧰 Escritorio ligero (KDE Plasma) pensado para rendimiento en juegos.

> Los juegos (Assetto Corsa, CS2) son de pago/con DRM y no se pueden redistribuir dentro
> de la ISO. RuloGamerOS deja Steam instalado y configurado para que, con tu cuenta,
> se instalen con un solo clic (ver `docs/GAMES.md`).

## Estructura del repo

```
rulogameros/
├── build.sh              # Genera la ISO (ejecutar en Arch Linux)
├── profile/               # Overlay que se aplica sobre el perfil "releng" de archiso
│   ├── packages.x86_64    # Paquetes extra (Steam, drivers, KDE, etc.)
│   └── airootfs/          # Archivos que van directos al sistema (branding, scripts)
├── scripts/               # Scripts de post-instalación / uso en un Arch ya instalado
│   ├── setup-wheel.sh      # Instala y configura drivers de volante
│   ├── setup-games.sh      # Instala Steam/Proton/Lutris y deja accesos a AC y CS2
│   └── set-wallpaper.sh    # Aplica/rota el pack de fondos personalizados
└── docs/                  # Guías detalladas
    ├── BUILD.md
    ├── WHEELS.md
    ├── GAMES.md
    └── CUSTOMIZE.md
```

## Inicio rápido

### Opción A — Construir la ISO completa
Necesitas una máquina (o VM) con **Arch Linux** instalado:

```bash
sudo pacman -S --needed archiso git
git clone <este-repo>
cd rulogameros
sudo ./build.sh
```

La ISO sale en `out/rulogameros-<fecha>-x86_64.iso`. Grábala en un USB con `dd` o Ventoy
y arranca. Detalles en [`docs/BUILD.md`](docs/BUILD.md).

### Opción B — Convertir un Arch Linux que ya tienes
Si no quieres generar la ISO, puedes aplicar RuloGamerOS sobre un Arch/Manjaro ya instalado:

```bash
git clone <este-repo>
cd rulogameros
sudo ./scripts/setup-wheel.sh
sudo ./scripts/setup-games.sh
sudo ./scripts/setup-branding.sh   # logo, cursor, login/bloqueo, GRUB y fondo
```

Más detalles: [`docs/WHEELS.md`](docs/WHEELS.md), [`docs/GAMES.md`](docs/GAMES.md),
[`docs/CUSTOMIZE.md`](docs/CUSTOMIZE.md).
