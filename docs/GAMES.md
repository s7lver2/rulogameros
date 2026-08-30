# Assetto Corsa y Counter-Strike 2 en RuloGamerOS

Assetto Corsa y CS2 son juegos con DRM/licencia de Steam: **no se pueden incluir
dentro de la ISO**. Lo que hace RuloGamerOS es dejar todo listo (Steam, Proton,
multilib, GameMode, MangoHud) para que la instalación real sea de un clic con tu
propia cuenta.

## Qué instala `setup-games.sh` / la ISO

- Repositorio `[multilib]` habilitado (necesario para las librerías de 32 bits de Steam/Wine).
- `steam`, `lutris`, `wine`, `winetricks`.
- `gamemode` + `lib32-gamemode`: mejora el rendimiento en juegos automáticamente.
- `mangohud` + `lib32-mangohud`: overlay de FPS/temperaturas/uso de CPU-GPU.
- Accesos directos en el escritorio "Assetto Corsa" y "Counter-Strike 2" que
  lanzan `steam steam://install/<appid>`.

## Primer arranque

1. Abre **Steam** e inicia sesión con tu cuenta.
2. Ve a **Steam > Configuración > Compatibilidad** y activa
   "Forzar el uso de una herramienta de compatibilidad específica" con
   **Proton Experimental** (Assetto Corsa no es nativo de Linux, corre vía Proton).
3. Counter-Strike 2 sí es nativo de Linux, no necesita Proton.
4. Haz doble clic en los accesos del escritorio, o busca el juego en tu
   biblioteca de Steam y pulsa "Instalar".

## Rendimiento

- Lanza cualquier juego con GameMode activado añadiendo `gamemoderun %command%` en
  las opciones de lanzamiento del juego (Steam > botón derecho > Propiedades).
- Activa el overlay de MangoHud desde Steam: opciones de lanzamiento
  `mangohud %command%`, o edita `~/.config/MangoHud/MangoHud.conf` para personalizarlo.

## Volante en el juego

- **Assetto Corsa**: Opciones > Controles > selecciona tu volante y ajusta la
  sensibilidad del force feedback (se recomienda dejarlo en 100% y ajustar el
  global desde `oversteer`, ver `docs/WHEELS.md`).
- **CS2**: no usa volante, pero MangoHud/GameMode ayudan igual al rendimiento.
