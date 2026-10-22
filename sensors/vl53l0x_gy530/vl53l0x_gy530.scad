// VL53L0X time-of-flight distance sensor, GY-530 / "VL53L0/1XV2" (purple,
// 6 pins: VIN GND SCL SDA GPIO1 XSHUT, a hole in each rounded end).
//
//   use <partbin/sensors/vl53l0x_gy530/vl53l0x_gy530.scad>
//
//   vl53l0x_gy530();                   the board, with its parts
//   vl53l0x_gy530(headers = "down");   with the 6-pin header soldered on
//   vl53l0x_gy530_holder(h = 3);       posts under its two holes
//   vl53l0x_gy530_window(gap, wall);   an opening over the sensor in the lid
//   vl53l0x_gy530_size()               [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the pins along the bottom edge (-y). The
// sensor looks up; a cover in front of it should be IR-clear or have a hole.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 25.0;    // length (x), with the rounded ends
b_l      = 10.7;    // width (y)
b_t      = 1.6;
hole_d   = 3.0;
hole_x   = 10.2;    // each hole from the centre
pin_bot  = 1.5;
chip     = [0, 2.2];          // sensor centre
chip_s   = [4.4, 2.4, 1.0];   // VL53L0X package

holes  = [[-hole_x, 0], [hole_x, 0]];
pins_y = -b_l / 2 + pin_bot;
pins   = ["VIN", "GND", "SCL", "SDA", "GPIO1", "XSHUT"];

function vl53l0x_gy530_size() = [b_w, b_l, b_t];
function vl53l0x_gy530_sensor() = chip;
function vl53l0x_gy530_holes() = holes;

module vl53l0x_gy530(detail = true, headers = "none") {
    difference() {
        color(c_pcb_purple()) hull() for (s = [-1, 1]) translate([s * (b_w / 2 - b_l / 2), 0, 0]) cylinder(d = b_l, h = b_t, $fn = 48);
        for (h = holes) translate([h[0], h[1], -1]) cylinder(d = hole_d, h = b_t + 2, $fn = 24);
        for (i = [0:5]) translate([(i - 2.5) * 2.54, pins_y, -1]) cylinder(d = 1.0, h = b_t + 2, $fn = 16);
    }
    color(c_gold()) for (h = holes) translate([h[0], h[1], b_t]) difference() { cylinder(d = 4.8, h = 0.02, $fn = 32); translate([0, 0, -1]) cylinder(d = hole_d, h = 2, $fn = 24); }
    color(c_gold()) for (i = [0:5]) translate([(i - 2.5) * 2.54, pins_y, b_t]) difference() { cylinder(d = 1.7, h = 0.02, $fn = 16); translate([0, 0, -1]) cylinder(d = 1.0, h = 2, $fn = 16); }
    translate([chip[0], chip[1], b_t]) {
        color(c_chip()) translate([-chip_s[0] / 2, -chip_s[1] / 2, 0]) cube(chip_s);
        color([0.3, 0.3, 0.35]) for (x = [-1.0, 1.0]) translate([x, 0, chip_s[2]]) cylinder(d = 0.6, h = 0.02, $fn = 12);
    }
    if (detail) translate([0, 0, b_t]) {
        for (x = [-6, -4.2, 4.2, 6]) translate([x, 2.2, 0]) smd_passive("0603", abs(x) > 5 ? "c" : "r", 90);
        for (i = [0:5]) translate([(i - 2.5) * 2.54, pins_y + 1.2, 0]) silk(pins[i], 0.5, "left", rot = 90);
    }
    bo_headers(6, 0, pins_y, b_t, headers);
}

module vl53l0x_gy530_holder(h = 3, style = "peg") { bo_mounts(holes, hole_d, b_t, h, style); }

// An opening over the sensor (both its emitter and receiver), in a lid
// `wall` thick whose inside face is `gap` above the board's top.
module vl53l0x_gy530_window(gap = 1.5, wall = 2) {
    rect_window(chip[0], chip[1], b_t + gap, wall, [5.0, 3.0], 0.6, 0.6);
}

show = "demo";  // demo | board | holder
if (show == "board") vl53l0x_gy530();
else if (show == "holder") color("#d6a24a") vl53l0x_gy530_holder();
else bo_demo([b_w, b_l], 3, b_t + 1.5) { vl53l0x_gy530(); vl53l0x_gy530_holder(); vl53l0x_gy530_window(); }
