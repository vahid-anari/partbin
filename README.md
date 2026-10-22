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
cd your-project
git submodule add https://github.com/vahid-anari/partbin.git partbin
```

Then in the case file:

```openscad
use <partbin/dev-boards/esp32_c3_supermini/esp32_c3_supermini.scad>

difference() {
    my_case();
    translate([40, 20, 2]) esp32c3_supermini_usb_cutout(wall = 2);
}
translate([40, 20, 2]) esp32c3_supermini_holder();
%translate([40, 20, 2]) esp32c3_supermini(detail = false);  // only to look at
```

Every module lies flat with its parts facing up, centred on x/y, with the underside of its PCB at z = 0. Put the board, its cutout and its holder through the same `translate`/`rotate` and they line up. Anyone cloning the project needs `git clone --recursive`, or `git submodule update --init` afterwards.

Modules are sorted into category folders (`dev-boards/`, `displays/`, `sensors/`...). Each module has its own folder there with its pictures, a README listing what it gives you and the sizes to check, and an `.stl` that GitHub shows in 3D: open the folder and click **View it in 3D**. Opened in OpenSCAD on its own, each file shows the board in its holder, usually behind a piece of wall with the cutout; set `show` near the end of the file to `"board"` or `"holder"` to see one part alone.

## Modules

Open a category to see its modules; a module's folder has its pictures, sizes and 3D view.

<!-- modules: written by tools/make_readmes.py -->

✓ measured with calipers · ◐ from a published drawing or the listing's sizes · ○ typical, from photos (to be measured)

<details>
<summary><b><a href="dev-boards/">Dev boards</a></b>: Microcontroller boards: ESP32, RP2040, ATmega32U4.</summary>

| Module | Picture |
|---|---|
| ✓ [ESP32-C3 Super Mini](dev-boards/esp32_c3_supermini/) | <img src="dev-boards/esp32_c3_supermini/esp32_c3_supermini.png" width="200"> |
| ◐ [ESP32-DevKitC V4, 38 pins](dev-boards/esp32_devkitc_38/) | <img src="dev-boards/esp32_devkitc_38/esp32_devkitc_38.png" width="200"> |
| ◐ [RP2040 Pico clone (USB-C, 16 MB)](dev-boards/pico_rp2040_typec/) | <img src="dev-boards/pico_rp2040_typec/pico_rp2040_typec.png" width="200"> |
| ○ [Pro Micro (ATmega32U4 / RP2040)](dev-boards/pro_micro/) | <img src="dev-boards/pro_micro/pro_micro.png" width="200"> |

</details>

<details>
<summary><b><a href="displays/">Displays</a></b>: LED matrices, TFTs, OLEDs, a character LCD and 7-segment displays.</summary>

| Module | Picture |
|---|---|
| ○ [MAX7219 FC-16 4-in-1 LED matrix](displays/max7219_fc16/) | <img src="displays/max7219_fc16/max7219_fc16.png" width="200"> |
| ○ [MAX7219 8x8 LED matrix](displays/max7219_8x8/) | <img src="displays/max7219_8x8/max7219_8x8.png" width="200"> |
| ○ [0.96" IPS TFT (ST7735S)](displays/st7735_096/) | <img src="displays/st7735_096/st7735_096.png" width="200"> |
| ○ [0.91" OLED (SSD1306)](displays/ssd1306_091/) | <img src="displays/ssd1306_091/ssd1306_091.png" width="200"> |
| ○ [1.3" OLED (SH1106)](displays/sh1106_13/) | <img src="displays/sh1106_13/sh1106_13.png" width="200"> |
| ◐ [LCD1602 with I2C backpack](displays/lcd1602/) | <img src="displays/lcd1602/lcd1602.png" width="200"> |
| ○ [4-digit 7-segment display, 0.36"](displays/seg7_4digit_036/) | <img src="displays/seg7_4digit_036/seg7_4digit_036.png" width="200"> |
| ○ [1.8" TFT (ST7735)](displays/st7735_18/) (not one I have) | <img src="displays/st7735_18/st7735_18.png" width="200"> |
| ○ [1.3" IPS TFT (ST7789)](displays/st7789_13/) (not one I have) | <img src="displays/st7789_13/st7789_13.png" width="200"> |
| ○ [TM1637 4-digit display module](displays/tm1637_4digit/) (not one I have) | <img src="displays/tm1637_4digit/tm1637_4digit.png" width="200"> |

</details>

<details>
<summary><b><a href="sensors/">Sensors</a></b>: Small I2C sensor boards: climate, light, current, ADC, distance, hall.</summary>

| Module | Picture |
|---|---|
| ○ [GY-BME280 / BMP280](sensors/gy_bme280/) | <img src="sensors/gy_bme280/gy_bme280.png" width="200"> |
| ○ [GY-302 BH1750 light sensor](sensors/gy302_bh1750/) | <img src="sensors/gy302_bh1750/gy302_bh1750.png" width="200"> |
| ◐ [VEML7700 light sensor](sensors/veml7700/) | <img src="sensors/veml7700/veml7700.png" width="200"> |
| ○ [INA226 current monitor (CJMCU-226)](sensors/ina226_cjmcu226/) | <img src="sensors/ina226_cjmcu226/ina226_cjmcu226.png" width="200"> |
| ○ [ADS1115 ADC](sensors/ads1115/) | <img src="sensors/ads1115/ads1115.png" width="200"> |
| ○ [VL53L0X distance sensor (GY-530)](sensors/vl53l0x_gy530/) | <img src="sensors/vl53l0x_gy530/vl53l0x_gy530.png" width="200"> |
| ○ [KY-024 hall sensor](sensors/ky024_hall/) | <img src="sensors/ky024_hall/ky024_hall.png" width="200"> |

</details>

<details>
<summary><b><a href="inputs/">Inputs</a></b>: Things you press, touch or turn.</summary>

| Module | Picture |
|---|---|
| ○ [KY-040 rotary encoder](inputs/ky040_encoder/) | <img src="inputs/ky040_encoder/ky040_encoder.png" width="200"> |
| ○ [TTP223 touch button](inputs/ttp223_touch/) | <img src="inputs/ttp223_touch/ttp223_touch.png" width="200"> |
| ○ [5-way navigation button](inputs/nav5_button/) | <img src="inputs/nav5_button/nav5_button.png" width="200"> |

</details>

<details>
<summary><b><a href="boards/">Other boards</a></b>: Bluetooth, an MP3 player, LED boards, a stepper driver, USB-C breakouts.</summary>

| Module | Picture |
|---|---|
| ○ [HC-05 Bluetooth module](boards/hc05/) | <img src="boards/hc05/hc05.png" width="200"> |
| ○ [DFPlayer Mini](boards/dfplayer_mini/) | <img src="boards/dfplayer_mini/dfplayer_mini.png" width="200"> |
| ○ [WS2812B LED boards](boards/ws2812_boards/) | <img src="boards/ws2812_boards/ws2812_boards.png" width="200"> |
| ◐ [TMC2209 stepper driver](boards/tmc2209_stepstick/) | <img src="boards/tmc2209_stepstick/tmc2209_stepstick.png" width="200"> |
| ◐ [USB-C breakout boards](boards/usbc_breakouts/) | <img src="boards/usbc_breakouts/usbc_breakouts.png" width="200"> |

</details>

<details>
<summary><b><a href="power/">Power</a></b>: Chargers, power bank boards, DC-DC converters and a voltmeter.</summary>

| Module | Picture |
|---|---|
| ○ [TP4056 charger](power/tp4056/) | <img src="power/tp4056/tp4056.png" width="200"> |
| ◐ [Type-C 5V 2A power bank board](power/powerbank_5v2a_typec/) | <img src="power/powerbank_5v2a_typec/powerbank_5v2a_typec.png" width="200"> |
| ◐ [2S Type-C boost charger](power/charger_2s_typec/) | <img src="power/charger_2s_typec/charger_2s_typec.png" width="200"> |
| ◐ [Mini charger + 5V boost](power/charger_mini_typec_boost/) | <img src="power/charger_mini_typec_boost/charger_mini_typec_boost.png" width="200"> |
| ○ [Mini 5V 3A boost board](power/boost_mini_5v3a/) | <img src="power/boost_mini_5v3a/boost_mini_5v3a.png" width="200"> |
| ○ [DC-DC converter boards](power/converters/) | <img src="power/converters/converters.png" width="200"> |
| ○ [XY-UP USB step-up/down](power/usb_stepupdown_xyup/) | <img src="power/usb_stepupdown_xyup/usb_stepupdown_xyup.png" width="200"> |
| ○ [ZK-SJVA-4X buck-boost with LCD](power/buckboost_lcd_zksjva/) | <img src="power/buckboost_lcd_zksjva/buckboost_lcd_zksjva.png" width="200"> |
| ○ [0.28" voltmeter](power/voltmeter_028/) | <img src="power/voltmeter_028/voltmeter_028.png" width="200"> |
| ○ [IP5306 charge/discharge board (MH-CD42)](power/ip5306_mhcd42/) (not one I have) | <img src="power/ip5306_mhcd42/ip5306_mhcd42.png" width="200"> |

</details>

<details>
<summary><b><a href="hardware/">Hardware</a></b>: Batteries and holders, and parts that go in a panel.</summary>

| Module | Picture |
|---|---|
| ○ [Batteries and holders](hardware/batteries/) | <img src="hardware/batteries/batteries.png" width="200"> |
| ○ [Panel parts](hardware/panel_parts/) | <img src="hardware/panel_parts/panel_parts.png" width="200"> |

</details>

<!-- /modules -->

## In this repository

| Folder | Contents |
|---|---|
| [`dev-boards/`](dev-boards/), [`displays/`](displays/), [`sensors/`](sensors/), [`inputs/`](inputs/), [`boards/`](boards/), [`power/`](power/), [`hardware/`](hardware/) | A folder per category with a README listing its modules, and in it a folder per module (or a small family of parts): the `.scad` file with its sizes at the top, its pictures, a 3D `.stl` and a README |
| [`lib/`](lib/) | Shared shapes: [`parts.scad`](lib/parts.scad) (chips, passives, connectors, headers...), [`breakout.scad`](lib/breakout.scad) (breakout boards, posts, USB cutouts, vents), [`display.scad`](lib/display.scad) (glass, LED matrices, 7-segment digits, windows, edge holder) |
| [`tools/`](tools/) | `render.sh` makes the pictures and the 3D files (needs OpenSCAD), `make_readmes.py` writes the module and category READMEs and the module list above |

## Planned

Measuring every board with calipers (only the ESP32-C3 so far), and new modules as I buy them.

## Support

This is a free project I work on in my spare time. If you like it, you can [buy me a coffee](https://buymeacoffee.com/vahidanarim) ☕

## License

MIT, see [LICENSE](LICENSE). The VEML7700 sizes come from [Adafruit's design files](https://github.com/adafruit/Adafruit-VEML7700-PCB); the Pico footprint from Raspberry Pi's drawing.
