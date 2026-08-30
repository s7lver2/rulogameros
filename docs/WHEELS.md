# Volantes de simracing en RuloGamerOS

RuloGamerOS trae de serie:

- **`new-lg4ff`** (vía AUR: `new-lg4ff-dkms-git`): módulo de kernel con soporte de
  force feedback mejorado para volantes Logitech (G25, G27, G29, G920, G923...),
  con rango de giro completo (900°) en vez de los 200° por defecto del driver `hid-logitech`.
- **`oversteer`**: interfaz gráfica para calibrar sensibilidad, fuerza del FFB,
  rango de giro y combinar pedales/palanca de cambios.
- Utilidades de bajo nivel: `joyutils`, `sdl2-jstest`, `python-evdev`.

## Comprobar que el volante se detecta

```bash
lsusb                 # debería aparecer tu volante (Logitech, Thrustmaster, etc.)
ls /dev/input/js*     # dispositivo de joystick
sdl2-jstest --list
```

## Calibrar con Oversteer

```bash
oversteer
```

Desde ahí puedes:
- Elegir el rango de giro (ej. 900° para simracing "serio").
- Ajustar la fuerza global del force feedback.
- Combinar los ejes de acelerador/freno/embrague si tu volante los reporta por separado.

## Volantes Thrustmaster / Fanatec

- Thrustmaster: la mayoría funcionan out-of-the-box con el driver genérico de HID;
  para force feedback completo instala el paquete AUR `thrustmaster-ff` (no viene
  preinstalado por licencias del propio driver, instálalo con `yay -S thrustmaster-ff`).
- Fanatec: soporte vía el driver comunitario `fanatec-hid` (AUR) — algunos modelos
  requieren firmware adicional del propio fabricante.

## Si el volante no aparece tras conectar

```bash
sudo modprobe -r hid-logitech-hidpp hid-logitech
sudo modprobe lg4ff
dmesg | tail -30   # revisa si el kernel detectó el dispositivo
```

Si sigue sin aparecer, reinstala el driver con:

```bash
sudo ./scripts/setup-wheel.sh
```
