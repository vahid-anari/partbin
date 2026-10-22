// GY-302 light sensor breakout with a BH1750 (blue, 5 pins: VCC GND SCL SDA
// ADDR, two mounting holes).
//
//   use <partbin/sensors/gy302_bh1750/gy302_bh1750.scad>
//
//   gy302_bh1750();                     the board, with its parts
//   gy302_bh1750(detail = false);       only what matters for fit (fast)
//   gy302_bh1750(headers = "down");     with a pin header soldered on
//   gy302_bh1750_holder(h = 3);         posts under its holes, add to the case
//   gy302_bh1750_window(gap, wall);     a window over the sensor, subtract from the lid
//   gy302_bh1750_size()                 [width, length, pcb thickness]
//   gy302_bh1750_sensor()               [x, y] of the sensor chip
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pin row along the bottom edge (-y), the holes at the top (+y).
// The BH1750 looks straight up. For the window, the lid's inside face is
// `gap` mm above the board's top. Opened on its own, this file shows it on its
// posts under a see-through lid with the window (set show = "board" or "holder").

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ------------------------- typical, from a seller photo scaled by the 2.54 mm pins
b_w      = 13.9;    // board width (x)
b_l      = 18.5;    // board length (y)
b_t      = 1.6;     // PCB
hole_d   = 3.0;     // mounting holes (no ring)
hole_x   = 4.5;     // each hole from the centre (x)
hole_top = 2.4;     // hole centre to the top edge
pin_bot  = 1.27;    // pin centre to the bottom edge
chip_top = 6.5;     // BH1750 centre to the top edge
tall_h   = 1.1;     // the tallest part (the regulator)

holes  = [[-hole_x, b_l / 2 - hole_top], [hole_x, b_l / 2 - hole_top]];
pins_y = -b_l / 2 + pin_bot;
chip   = [0, b_l / 2 - chip_top];
pins   = ["ADDR", "SDA", "SCL", "GND", "VCC"];   // left to right, parts up

function gy302_bh1750_size() = [b_w, b_l, b_t];
function gy302_bh1750_sensor() = chip;
function gy302_bh1750_holes() = holes;
function gy302_bh1750_height() = b_t + tall_h;
function gy302_bh1750_pin(i) = [(i - 2) * 2.54, pins_y];   // 0 = ADDR ... 4 = VCC

// ======================================================================= board
module gy302_bh1750(detail = true, headers = "none") {
    bo_pcb([b_w, b_l], b_t, 0.4, holes, hole_d, 0, 5, 0, pins_y, c_pcb_blue());
    translate([chip[0], chip[1], b_t]) smd_ic([3.0, 1.6, 0.7], 3, 0.5);   // BH1750 (WSOF6)
    if (detail) {
        translate([0, 0, b_t]) {
            translate([-0.15, chip[1] + 3.85, 0]) smd_passive("0805", "c");
            translate([-0.15, chip[1] + 2.6, 0]) smd_passive("0805", "r");
            translate([-4.8, chip[1] - 4.2, 0]) smd_passive("0603", "r", 90);
            for (p = [[-5.8, "r"], [-4.2, "r"], [-2.6, "r"], [-0.9, "c"], [0.45, "c"], [5.9, "c"]])
                translate([p[0], chip[1] - 6.6, 0]) smd_passive("0805", p[1], 90);
            translate([2.9, chip[1] - 6.6, 0]) sot23(3, rot = 90);             // 3.3 V regulator
            translate([0, chip[1] - 3.0, 0]) silk("BH1750", 1.5);
        }
        // underside: pin names and the board's name
        for (i = [0:4]) bo_under((i - 2) * 2.54, pins_y + 1.4) silk(pins[i], 0.8, "left", rot = 90);
        bo_under(1.0, 3.0) silk("GY-302", 1.0, rot = 90);
    }
    bo_headers(5, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
// Posts under the two holes, `h` mm tall. style "peg": pins go up through
// the holes and the board presses on; "screw": pilot holes for M3 or M2.5
// self-tapping screws.
module gy302_bh1750_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
// A round window over the sensor in a lid `wall` mm thick whose inside face
// is `gap` mm above the board's top; it widens outwards so the sensor sees
// the room. Keep the lid close (small gap) or light leaks in from the side.
module gy302_bh1750_window(gap = 1, wall = 2, d = 3) {
    bo_window(chip[0], chip[1], b_t + gap, wall, d);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") gy302_bh1750();
else if (show == "holder") color("#d6a24a") gy302_bh1750_holder();
else bo_demo([b_w, b_l], 3, b_t + 1.5) {
    gy302_bh1750();
    gy302_bh1750_holder();
    gy302_bh1750_window(gap = 1.5);
}
