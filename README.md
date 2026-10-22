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
| ESP32-C3 Super Mini | [`modules/esp32_c3_supermini.scad`](modules/esp32_c3_supermini.scad) | yes |
| GY-BME280 / GY-BMP280 (purple, 6 pins) | [`modules/gy_bme280.scad`](modules/gy_bme280.scad) | not yet: typical, from a photo |
| GY-302 BH1750 light sensor | [`modules/gy302_bh1750.scad`](modules/gy302_bh1750.scad) | not yet: typical, from a photo |
| VEML7700 light sensor (Adafruit layout) | [`modules/veml7700.scad`](modules/veml7700.scad) | from Adafruit's design files; thickness typical |
| MAX7219 FC-16 4-in-1 LED matrix (one or more end to end) | [`modules/max7219_fc16.scad`](modules/max7219_fc16.scad) | not yet: typical |
| MAX7219 single 8x8 LED matrix (DIP kit) | [`modules/max7219_8x8.scad`](modules/max7219_8x8.scad) | not yet: typical |
| 1.8" TFT 128x160 ST7735 (red, microSD) | [`modules/st7735_18.scad`](modules/st7735_18.scad) | not yet: typical |
| 1.3" IPS TFT 240x240 ST7789 (7 pins) | [`modules/st7789_13.scad`](modules/st7789_13.scad) | not yet: typical |
| 0.91" OLED 128x32 SSD1306 | [`modules/ssd1306_091.scad`](modules/ssd1306_091.scad) | not yet: typical |
| LCD1602, with or without the I2C backpack | [`modules/lcd1602.scad`](modules/lcd1602.scad) | not yet: from a manufacturer's drawing |
| TM1637 4-digit 7-segment | [`modules/tm1637_4digit.scad`](modules/tm1637_4digit.scad) | not yet: typical |

Displays face up like everything else, so a case with a front panel turns them to face it. Each comes with a `_window` for the front (the lit area, widening outwards) and a holder: posts for boards with holes, or `edge_holder` (a ledge under the edges and low walls) for boards without.

Sensor boards come with posts for their holes (`_holder`, pegs or screws) and a cutout for the lid above them: a window over a light sensor (`_window`), air slots over the BME280 (`_vents`).

| | | |
|---|---|---|
| ![BME280](images/gy_bme280.png) | ![BH1750](images/gy302_bh1750.png) | ![VEML7700](images/veml7700.png) |
| ![FC-16](images/max7219_fc16.png) | ![8x8](images/max7219_8x8.png) | ![LCD1602](images/lcd1602.png) |
| ![ST7735](images/st7735_18.png) | ![ST7789](images/st7789_13.png) | ![OLED](images/ssd1306_091.png) |
| ![TM1637](images/tm1637_4digit.png) | ![LCD1602 with I2C backpack](images/lcd1602_backpack.png) | |

## Files

- `modules/`: one file per module, its measured numbers at the top.
- `lib/parts.scad`: the shared part shapes (PCB, SMD resistors and capacitors, chips, crystal, buttons, USB-C, pin headers).
- `lib/display.scad`: shared pieces for displays (glass panels, LED matrices, 7-segment digits, window cutout, edge holder).
- `lib/breakout.scad`: shared pieces for small breakout boards (board with holes and a pin row, mounts, light window, air vents).
- `images/`: pictures, made by `tools/render.sh` (needs OpenSCAD).

## Support

If this is useful to you: [buy me a coffee](https://buymeacoffee.com/vahidanarim).

## License

MIT
