# partbin

3D models of the electronics modules in my drawer (dev boards, displays, sensors, chargers, switches), made in [OpenSCAD](https://openscad.org) for designing 3D-printed cases around them.

![Some of the modules](images/overview.png)

- 41 files covering the boards, displays, sensors, power modules, batteries and panel parts I own
- Each board looks like the real one: chips, resistors, capacitors, LEDs, connectors and pin labels
- Fast mode (`detail = false`) shows only what matters for fit, for quick previews of big cases
- A holder for every board: posts for its holes, or a ledge with low walls, or a press-fit tray
- Ready-made cutouts for the case: USB sockets, screen windows, LED slots, button holes, air vents, card slots
- Size and position functions (`_size()`, `_pin()`, `_height()`...) to place other things around a board
- The sizes that decide fit are at the top of each file, so they're easy to correct with calipers

## Use it in a project

Add it as a git submodule, so a fix here reaches every project:

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

Every module lies flat with its parts facing up, centred on x/y, with the underside of its PCB at z = 0. Put the board, its cutout and its holder through the same `translate`/`rotate` and they line up. Anyone cloning the project needs `git clone --recursive`, or `git submodule update --init` afterwards.

Opened on its own, each file shows the board in its holder, usually behind a piece of wall with the cutout. Set `show` near the end of the file to `"board"` or `"holder"` to see one part alone.

## Modules

**✓** measured with calipers, **◐** from a published drawing or the listing's sizes, **○** typical sizes from photos (to be measured).

| Group | Modules |
|---|---|
| Dev boards | [ESP32-C3 Super Mini](modules/esp32_c3_supermini.scad) ✓, [ESP32-DevKitC 38-pin](modules/esp32_devkitc_38.scad) ◐, [RP2040 Pico clone](modules/pico_rp2040_typec.scad) ◐, [Pro Micro (ATmega32U4 / RP2040)](modules/pro_micro.scad) ○ |
| Displays | [MAX7219 FC-16 4-in-1](modules/max7219_fc16.scad) ○, [MAX7219 8×8](modules/max7219_8x8.scad) ○, [0.96" TFT ST7735S](modules/st7735_096.scad) ○, [0.91" OLED](modules/ssd1306_091.scad) ○, [1.3" OLED SH1106](modules/sh1106_13.scad) ○, [LCD1602 + I2C](modules/lcd1602.scad) ◐, [4-digit 7-segment](modules/seg7_4digit_036.scad) ○ |
| Sensors | [BME280](modules/gy_bme280.scad) ○, [BH1750](modules/gy302_bh1750.scad) ○, [VEML7700](modules/veml7700.scad) ◐, [INA226](modules/ina226_cjmcu226.scad) ○, [ADS1115](modules/ads1115.scad) ○, [VL53L0X](modules/vl53l0x_gy530.scad) ○, [KY-024 hall](modules/ky024_hall.scad) ○ |
| Input and other boards | [KY-040 encoder](modules/ky040_encoder.scad) ○, [TTP223 touch](modules/ttp223_touch.scad) ○, [5-way button](modules/nav5_button.scad) ○, [HC-05](modules/hc05.scad) ○, [DFPlayer Mini](modules/dfplayer_mini.scad) ○, [WS2812 bar and 3×3](modules/ws2812_boards.scad) ○, [TMC2209](modules/tmc2209_stepstick.scad) ◐, [USB-C breakouts](modules/usbc_breakouts.scad) ◐ |
| Charging | [TP4056](modules/tp4056.scad) ○, [Type-C 5V 2A power bank board](modules/powerbank_5v2a_typec.scad) ◐, [2S 8.4 V charger](modules/charger_2s_typec.scad) ◐, [mini charger + boost](modules/charger_mini_typec_boost.scad) ◐, [mini 5V 3A boost](modules/boost_mini_5v3a.scad) ○ |
| Converters and meters | [LM2596S, MT3608, tiny step-up, mini step-down, S09](modules/converters.scad) ○, [XY-UP USB stick](modules/usb_stepupdown_xyup.scad) ○, [ZK-SJVA-4X with LCD](modules/buckboost_lcd_zksjva.scad) ○, [0.28" voltmeter](modules/voltmeter_028.scad) ○ |
| Batteries and panel parts | [18650 holders, CR2032, LiPo](modules/batteries.scad) ○, [rockers, slides, buttons, DC jack, speaker](modules/panel_parts.scad) ○ |

Also here, for boards I don't have: [1.8" TFT ST7735](modules/st7735_18.scad), [1.3" TFT ST7789](modules/st7789_13.scad), [TM1637 display](modules/tm1637_4digit.scad), [IP5306 MH-CD42](modules/ip5306_mhcd42.scad).

<details>
<summary>Pictures of all of them</summary>

| | | |
|---|---|---|
| ![ESP32-C3 Super Mini](images/esp32_c3_supermini.png) | ![ESP32 DevKitC](images/esp32_devkitc_38.png) | ![Pico clone](images/pico_rp2040_typec.png) |
| ![Pro Micro](images/pro_micro.png) | ![RP2040 Pro Micro](images/pro_micro_rp2040.png) | ![FC-16](images/max7219_fc16.png) |
| ![8x8](images/max7219_8x8.png) | ![0.96 TFT](images/st7735_096.png) | ![0.91 OLED](images/ssd1306_091.png) |
| ![1.3 OLED](images/sh1106_13.png) | ![LCD1602](images/lcd1602.png) | ![LCD1602 with I2C backpack](images/lcd1602_backpack.png) |
| ![7-segment](images/seg7_4digit_036_demo.png) | ![BME280](images/gy_bme280.png) | ![BH1750](images/gy302_bh1750.png) |
| ![VEML7700](images/veml7700.png) | ![INA226](images/ina226_cjmcu226.png) | ![ADS1115](images/ads1115.png) |
| ![VL53L0X](images/vl53l0x_gy530.png) | ![KY-024](images/ky024_hall.png) | ![KY-040](images/ky040_encoder_demo.png) |
| ![TTP223](images/ttp223_touch.png) | ![5-way button](images/nav5_button_demo.png) | ![HC-05](images/hc05.png) |
| ![DFPlayer](images/dfplayer_mini.png) | ![WS2812](images/ws2812_boards_demo.png) | ![TMC2209](images/tmc2209_stepstick_demo.png) |
| ![USB-C breakouts](images/usbc_breakouts.png) | ![TP4056](images/tp4056.png) | ![Power bank board](images/powerbank_5v2a_typec.png) |
| ![2S charger](images/charger_2s_typec.png) | ![Mini charger + boost](images/charger_mini_typec_boost.png) | ![Mini boost](images/boost_mini_5v3a.png) |
| ![Converters](images/converters.png) | ![XY-UP](images/usb_stepupdown_xyup.png) | ![ZK-SJVA-4X](images/buckboost_lcd_zksjva.png) |
| ![Voltmeter](images/voltmeter_028.png) | ![Batteries](images/batteries.png) | ![Panel parts](images/panel_parts.png) |

</details>

## In this repository

| Folder | Contents |
|---|---|
| [`modules/`](modules/) | One file per module (or a small family of parts), its sizes at the top |
| [`lib/`](lib/) | Shared shapes: [`parts.scad`](lib/parts.scad) (chips, passives, connectors, headers...), [`breakout.scad`](lib/breakout.scad) (breakout boards, posts, USB cutouts, vents), [`display.scad`](lib/display.scad) (glass, LED matrices, 7-segment digits, windows, edge holder) |
| [`images/`](images/) | Pictures of the modules |
| [`tools/`](tools/) | `render.sh`, which makes the pictures (needs OpenSCAD) |

## Planned

Measuring every board with calipers (only the ESP32-C3 so far), and new modules as I buy them.

## Support

This is a free project I work on in my spare time. If you like it, you can [buy me a coffee](https://buymeacoffee.com/vahidanarim) ☕

## License

MIT, see [LICENSE](LICENSE). The VEML7700 sizes come from [Adafruit's design files](https://github.com/adafruit/Adafruit-VEML7700-PCB); the Pico footprint from Raspberry Pi's drawing.
