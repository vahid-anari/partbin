# 0.28" voltmeter

0.28" 3-digit LED voltmeter, DC 0-100 V, 3 wires (red: power, yellow: measure, black: GND). A small green board with the display and a mounting ear with a hole at each end. Sold in red, green, blue and other colours.

![0.28" voltmeter](voltmeter_028.png)

**[View it in 3D](voltmeter_028.stl)** (turn it with the mouse; GitHub shows it in one colour)

## Use it

```openscad
use <partbin/modules/voltmeter_028/voltmeter_028.scad>
```

| Call | What it gives |
|---|---|
| `voltmeter_028()` | the meter (red digits) |
| `voltmeter_028(seg = "green")` |  |
| `voltmeter_028_panel_cutout(wall)` | the window for a front panel it sits behind |
| `voltmeter_028_holder(h = 3)` | two posts for its ears |
| `voltmeter_028_size()` | [length with the ears, width, thickness] |

Where it sits: digits up, the meter centred on x = y = 0, the PCB's underside at z = 0, the long side along x. Typical sizes.

## Sizes

At the top of [`voltmeter_028.scad`](voltmeter_028.scad), in mm: typical, from photos; measure yours and change them.

| Setting | Value | What |
|---|---|---|
| `b_l` | 30.0 | with the ears |

---

Part of [partbin](../../README.md).
