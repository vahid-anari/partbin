# XY-UP USB step-up/down

"XY-UP" USB step-up/down stick: USB-A plug in, adjustable 1.2-24 V out on a 2-way screw terminal, 3-digit LED voltmeter, a blue trimmer with a long brass screw, an ON/OFF button, micro-USB input as an alternative.

![XY-UP USB step-up/down](usb_stepupdown_xyup.png)

**[View it in 3D](usb_stepupdown_xyup.stl)** (turn it with the mouse; GitHub shows it in one colour)

## Use it

```openscad
use <partbin/power/usb_stepupdown_xyup/usb_stepupdown_xyup.scad>
```

| Call | What it gives |
|---|---|
| `usb_stepupdown_xyup()` | the board, with its parts |
| `usb_stepupdown_xyup_window(gap, wall)` | an opening for the display in the lid |
| `usb_stepupdown_xyup_size()` | [length, width, pcb thickness] (without the plug) |

Where it sits: parts up, the board centred on x = y = 0, its underside at z = 0, the long side along x, the USB plug sticking out at the left (-x), the screw terminal at the right.

## Sizes

At the top of [`usb_stepupdown_xyup.scad`](usb_stepupdown_xyup.scad), in mm: typical, from photos; measure yours and change them.

| Setting | Value | What |
|---|---|---|
| `plug_out` | 12.0 | the USB-A plug past the board's end |
| `disp` | [9.0, 1.5] | display centre |

---

Part of [partbin](../../README.md), in [Power](../README.md).
