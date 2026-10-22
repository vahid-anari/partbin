// TTP223 capacitive touch button module (small red board, 3 pins: GND I/O
// VCC; the touch pad is the whole underside; A/B jumpers set the mode).
//
//   use <partbin/modules/ttp223_touch/ttp223_touch.scad>
//
//   ttp223_touch();                    the module, with its parts
//   ttp223_touch(headers = "down");    with the 3-pin header soldered on
//   ttp223_touch_holder();             a pocket that holds it pad-down against a wall
//   ttp223_touch_size()                [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pins at the right end (+x). It senses through plastic: glue or
// press its underside against the inside of a wall up to ~3 mm thick.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ------------------------------------------------------------------- typical
b_l      = 15.0;    // length (x)
b_w      = 11.0;    // width (y)
b_t      = 1.0;
pins_x   = b_l / 2 - 1.4;
pins     = ["GND", "I/O", "VCC"];   // top to bottom

function ttp223_touch_size() = [b_l, b_w, b_t];

module ttp223_touch(detail = true, headers = "none") {
    pcb([b_l, b_w], b_t, [for (i = [0:2]) [pins_x, (1 - i) * 2.54, 0.9, 1.5]], [0.72, 0.10, 0.12], 0.4);
    if (detail) {
        translate([0, 0, b_t]) {
            translate([-1.5, -1.5, 0]) smd_ic([2.9, 1.6, 1.0], 3, 0.95, rot = 90);   // TTP223
            translate([-5.0, 2.8, 0]) smd_led("0603", "red");
            translate([1.0, 3.5, 0]) smd_passive("0603", "r");
            translate([-5.0, -3.0, 0]) smd_passive("0603", "c", 90);
            color(c_gold()) for (p = [[2.5, 0.5], [2.5, -1.8]]) translate([p[0], p[1], 0]) cube([1.0, 0.8, 0.02]);
            for (i = [0:2]) translate([pins_x - 1.2, (1 - i) * 2.54, 0]) silk(pins[i], 0.5, "right");
        }
        color(c_gold()) translate([-b_l / 2 + 1, -b_w / 2 + 1, -0.02]) cube([b_l - 4, b_w - 2, 0.02]);   // touch pad
    }
    if (headers == "down") translate([pins_x, 0, 0]) mirror([0, 0, 1]) pin_header(3, below = b_t + 1.5);
    else if (headers == "up") translate([pins_x, 0, b_t]) pin_header(3, below = b_t + 1.5);
}

// A pocket for the board lying pad-down against the wall it senses through:
// the wall's inside face is at z = 0 (under the board); add the pocket to it.
module ttp223_touch_holder(wall = 1.2, clear = 0.2, h = 2.0) {
    difference() {
        translate([-b_l / 2 - clear - wall, -b_w / 2 - clear - wall, 0]) cube([b_l + 2 * (clear + wall), b_w + 2 * (clear + wall), h]);
        translate([-b_l / 2 - clear, -b_w / 2 - clear, -1]) cube([b_l + 2 * clear, b_w + 2 * clear, h + 2]);
        translate([pins_x - 2, -5, -1]) cube([10, 10, h + 2]);   // room for the wires
    }
}

show = "demo";  // demo | board | holder
if (show == "board") ttp223_touch();
else if (show == "holder") color("#d6a24a") ttp223_touch_holder();
else { ttp223_touch(); color("#d6a24a") ttp223_touch_holder(); }
