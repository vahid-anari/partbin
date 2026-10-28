# USB-C breakout boards

USB-C female breakout boards:

![USB-C breakout boards](usbc_breakouts.png)

**[View it in 3D](usbc_breakouts.stl)** (turn it with the mouse; GitHub shows it in one colour)

## Use it

```openscad
use <partbin/boards/usbc_breakouts/usbc_breakouts.scad>
```

| Call | What it gives |
|---|---|
| `usbc_breakout_red()` | red, 12.6 x 21.8 mm (14.2 with the socket), 6 pins (VBUS GND CC2 CC1 D- D+), 2 holes beside the socket |
| `usbc_breakout_green()` | green 16-pin test board, 12 x 13.8 mm, 4 pins (V D- D+ G) |

and for each: &lt;name&gt;_usb_cutout(wall, gap), &lt;name&gt;_holder(h), &lt;name&gt;_size().

Where they sit: parts up, the board centred on x = y = 0, its underside at z = 0. Red: socket on the left long edge pointing -x, pins along the right. Green: socket at the bottom edge pointing -y, pins along the top. Red: outline, M3 holes and socket checked with a test print. Green: from the listing's photos.

## Sizes

At the top of [`usbc_breakouts.scad`](usbc_breakouts.scad), in mm: from a published drawing or the seller's sizes.

| Setting | Value | What |
|---|---|---|
| `r_size` | [12.6, 21.8, 1.6] | 14.2 across with the socket (measured) |
| `r_usb_y` | 0 | the socket is about in the middle (test print) |
| `r_out` | 1.6 | the socket sticks out past the board (measured) |

---

Part of [partbin](../../README.md), in [Other boards](../README.md).
