# Panel parts

Parts that go in a case wall, each with the hole to cut for it:

![Panel parts](panel_parts.png)

**[View it in 3D](panel_parts.stl)** (turn it with the mouse; GitHub shows it in one colour)

## Use it

```openscad
use <partbin/modules/panel_parts/panel_parts.scad>
```

| Call | What it gives |
|---|---|
| `rocker_kcd11()` | mini rocker switch 10 x 15 (KCD11)      rocker_kcd11_cutout(wall) |
| `rocker_kcd1()` | rocker switch 21 x 15 (KCD1)            rocker_kcd1_cutout(wall) |
| `slide_ss12d00(handle)` | SS12D00 slide switch (1P2T, 3 pins)     slide_ss12d00_cutout(wall) |
| `slide_mss22d18()` | MSS22D18 slide switch (2P2T, 6 pins)    slide_mss22d18_cutout(wall) |
| `tact6(h)` | 6 x 6 tact switch, h = 4.3 ... 13      tact6_cutout(wall, d) |
| `selflock_85()` | 8.5 x 8.5 self-locking push switch      selflock_85_cutout(wall) |
| `dc_jack_panel()` | 5.5 x 2.1 DC jack with nut (DC-022)     dc_jack_panel_cutout(wall) |
| `speaker_2831()` | 28 x 31 mm 3 W speaker                  speaker_2831_cutout(wall) |

Where they sit: the wall's outside face is at z = 0 and the wall goes down to z = -wall; each part pokes up through it from inside, centred on x = y = 0 (except slide and tact switches, which stand on a PCB at z = 0: see their notes). Typical sizes; check the snap-in ones against yours.

---

Part of [partbin](../../README.md).
