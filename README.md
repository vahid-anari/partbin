# partbin

Parametric [OpenSCAD](https://openscad.org) models of the small electronics modules I use (dev boards, chargers, sensors, displays), for designing 3D-printed cases around them.

Each module is drawn from my own boards: the sizes that decide whether a case fits (outline, thickness, holes, connectors, the tallest part) are measured with calipers, while the small parts (chips, resistors, capacitors, LEDs) are placed from photos and only roughly sized.

![ESP32-C3 Super Mini](images/esp32_c3_supermini.png)

## What each module gives you

| | What | Use it for |
|---|---|---|
| `<name>()` | the board with its parts; `detail = false` shows only what matters for fit and renders fast | seeing it inside the case, checking fit |
| `<name>_..._cutout()` | holes for its connectors | subtract from the case wall |
| `<name>_holder()` | a tray, standoffs or rails to mount it | add to the case |
| `<name>_size()` and friends | its sizes and positions | placing other things around it |

Every module lies flat with its parts facing up, centred on x/y, with the underside of the PCB at z = 0. Put the board, its cutout and its holder through the same `translate`/`rotate` and they line up.

## Use it in a project

As a git submodule, so a fix here reaches every project:

```sh
cd ~/Desktop/"Git projects"/<project>
git submodule add https://github.com/vahid-anari/partbin.git partbin
```

Then in the case file:

```openscad
use <partbin/modules/esp32_c3_supermini.scad>

difference() {
    my_case();
    translate([40, 20, 2]) esp32c3_supermini_usb_cutout(wall = 2);
}
translate([40, 20, 2]) esp32c3_supermini_holder();
%translate([40, 20, 2]) esp32c3_supermini(detail = false);  // only to look at
```

Anyone cloning the project then needs `git clone --recursive`, or `git submodule update --init` afterwards.

Opened on its own, each module file shows the board in its holder behind a piece of wall with the cutout. Set `show` near the end of the file to `"board"` or `"holder"` to see one part alone.

## Modules

| Module | File | Measured |
|---|---|---|
| ESP32-C3 Super Mini | [`modules/esp32_c3_supermini.scad`](modules/esp32_c3_supermini.scad) | yes, except the distance between the pin rows |

## Files

- `modules/`: one file per module, its measured numbers at the top.
- `lib/parts.scad`: the shared part shapes (PCB, SMD resistors and capacitors, chips, crystal, buttons, USB-C, pin headers).
- `images/`: pictures, made by `tools/render.sh` (needs OpenSCAD).

## Support

If this is useful to you: [buy me a coffee](https://buymeacoffee.com/vahidanarim).

## License

MIT
