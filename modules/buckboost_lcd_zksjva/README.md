# ZK-SJVA-4X buck-boost with LCD

"ZK-SJVA-4X" buck-boost converter with LCD (5.5-30 V in, 0.5-30 V 4 A out, a blue LCD showing volts and amps, four buttons, screw terminals for IN and OUT, a big toroid inductor and capacitors behind the display).

![ZK-SJVA-4X buck-boost with LCD](buckboost_lcd_zksjva.png)

**[View it in 3D](buckboost_lcd_zksjva.stl)** (turn it with the mouse; GitHub shows it in one colour)

## Use it

```openscad
use <partbin/modules/buckboost_lcd_zksjva/buckboost_lcd_zksjva.scad>
```

| Call | What it gives |
|---|---|
| `buckboost_lcd_zksjva()` | the module, with its parts |
| `buckboost_lcd_zksjva_panel_cutout(gap, wall)` | the LCD window and button holes |
| `buckboost_lcd_zksjva_holder(h = 3)` | posts under its four holes |
| `buckboost_lcd_zksjva_size()` | [width, height, pcb thickness] |

Where it sits: the LCD up, the board centred on x = y = 0, its underside at z = 0. The LCD and buttons face a front panel; the tall parts (toroid, capacitors) are behind the LCD at the top edge. Typical sizes.

## Sizes

At the top of [`buckboost_lcd_zksjva.scad`](buckboost_lcd_zksjva.scad), in mm: typical, from photos; measure yours and change them.

| Setting | Value | What |
|---|---|---|
| `lcd` | [38.0, 22.0] | the LCD glass |
| `lcd_c` | [-3.0, -6.0] | its centre |
| `lcd_h` | 7.0 | front of the LCD above the PCB |

---

Part of [partbin](../../README.md).
