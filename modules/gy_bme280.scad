// GY-BME280 / GY-BMP280 breakout (purple, 6 pins: VCC GND SCL SDA CSB SDO,
// two mounting holes). The same board is sold with a BME280 (temperature,
// humidity, pressure) or a BMP280 (no humidity).
//
//   use <partbin/modules/gy_bme280.scad>
//
//   gy_bme280();                      the board, with its parts
//   gy_bme280(detail = false);        only what matters for fit (fast)
//   gy_bme280(headers = "down");      with a pin header soldered on
//   gy_bme280_holder(h = 3);          posts under its holes, add to the case
//   gy_bme280_vents(gap, wall);       air slots over the sensor, subtract from the lid
//   gy_bme280_size()                  [width, length, pcb thickness]
//   gy_bme280_sensor()                [x, y] of the sensor chip
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pin row along the bottom edge (-y), the holes at the top (+y).
// For the vents, the lid's inside face is `gap` mm above the board's top.
//
// The sensor measures the air around it: keep it away from warm parts and
// give it vents. Opened on its own, this file shows it on its posts under a
// see-through lid with the vents (set show = "board" or "holder").

use <../lib/parts.scad>
use <../lib/breakout.scad>

// ------------------------- typical, from a seller photo scaled by the 2.54 mm pins
b_w      = 15.0;    // board width (x)
b_l      = 10.2;    // board length (y)
b_t      = 1.6;     // PCB
hole_d   = 3.0;     // mounting holes
ring_d   = 3.9;     // their gold ring
hole_x   = 5.1;     // each hole from the centre (x)
hole_top = 2.6;     // hole centre to the top edge
pin_bot  = 1.0;     // pin centre to the bottom edge
chip_top = 3.8;     // sensor chip centre to the top edge
chip_h   = 0.93;    // sensor chip height (the tallest part)

holes  = [[-hole_x, b_l / 2 - hole_top], [hole_x, b_l / 2 - hole_top]];
pins_y = -b_l / 2 + pin_bot;
chip   = [0, b_l / 2 - chip_top];
pins   = ["VCC", "GND", "SCL", "SDA", "CSB", "SDO"];   // left to right, parts up

function gy_bme280_size() = [b_w, b_l, b_t];
function gy_bme280_sensor() = chip;
function gy_bme280_holes() = holes;
function gy_bme280_height() = b_t + chip_h;
function gy_bme280_pin(i) = [(i - 2.5) * 2.54, pins_y];   // 0 = VCC ... 5 = SDO

// ======================================================================= board
module gy_bme280(detail = true, headers = "none") {
    bo_pcb([b_w, b_l], b_t, 0.4, holes, hole_d, ring_d, 6, 0, pins_y, c_pcb_purple());
    translate([chip[0], chip[1], b_t]) bosch_can([2.5, 2.5], chip_h);
    if (detail) {
        translate([0, 0, b_t]) {
            translate([0, b_l / 2 - 0.9, 0]) smd_passive("0603", "c");
            for (p = [[-3.3, "c"], [-1.6, "r"], [0.2, "r"], [2.0, "r"], [3.8, "r"]])
                translate([p[0], -2.3, 0]) smd_passive("0805", p[1], 90);
        }
        // underside: pin names and the board's name
        for (i = [0:5]) bo_under((i - 2.5) * 2.54, pins_y + 1.3) silk(pins[i], 0.75, "left", rot = 90);
        bo_under(0, 2.4) silk("GY-BME/P", 0.9, rot = 180);
        bo_under(0, 3.6) silk("280", 0.9, rot = 180);
    }
    bo_headers(6, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
// Posts under the two holes, `h` mm tall. style "peg": pins go up through
// the holes and the board presses on; "screw": pilot holes for small
// self-tapping screws (M2.5 or #2).
module gy_bme280_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ====================================================================== vents
// Air slots over the sensor in a lid `wall` mm thick whose inside face is
// `gap` mm above the board's top.
module gy_bme280_vents(gap = 2, wall = 2, area = [8, 6]) {
    bo_vents(chip[0], chip[1], b_t + gap, wall, area);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") gy_bme280();
else if (show == "holder") color("#d6a24a") gy_bme280_holder();
else bo_demo([b_w, b_l], 3, b_t + 2) {
    gy_bme280();
    gy_bme280_holder();
    gy_bme280_vents();
}
