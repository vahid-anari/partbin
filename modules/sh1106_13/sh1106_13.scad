// 1.3" OLED, 128 x 64, SH1106 over I2C (4 pins at the top: GND VCC SCL SDA,
// four corner holes). Drawn after the TENSTAR one (white screen).
//
//   use <partbin/modules/sh1106_13/sh1106_13.scad>
//
//   sh1106_13();                       the board, with its parts
//   sh1106_13(detail = false);         only what matters for fit (fast)
//   sh1106_13(headers = "down");       with the 4-pin header soldered on
//   sh1106_13_holder(h = 2);           posts under its holes, add to the case
//   sh1106_13_window(gap, wall);       the screen opening in the front, subtract it
//   sh1106_13_size()                   [width, height, pcb thickness]
//   sh1106_13_height()                 PCB underside to the front of the glass
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the pins at the top (+y). For the window, the front's inside face is
// `gap` mm above the glass.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 35.4;    // board width (x)
b_l      = 33.5;    // board height (y)
b_t      = 1.2;     // PCB
hole_d   = 2.5;
hole_in  = 2.5;     // hole centre to the two nearest edges
pin_top  = 1.6;     // pin centre to the top edge
glass    = [34.5, 23.0];     // glass outline
glass_t  = 1.5;     // glass and its tape
glass_y  = -2.0;    // glass centre (y)
active   = [29.4, 14.7];     // the lit area
active_y = 1.3;     // its centre, from the glass centre (the flex is at the bottom)

holes  = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_w / 2 - hole_in), sy * (b_l / 2 - hole_in)]];
pins_y = b_l / 2 - pin_top;
pins   = ["GND", "VCC", "SCL", "SDA"];

function sh1106_13_size() = [b_w, b_l, b_t];
function sh1106_13_height() = b_t + glass_t;
function sh1106_13_active() = [0, glass_y + active_y];
function sh1106_13_holes() = holes;
function sh1106_13_pin(i) = [(i - 1.5) * 2.54, pins_y];

// ======================================================================= board
module sh1106_13(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 4.0]],
            [for (i = [0:3]) [(i - 1.5) * 2.54, pins_y, 1.0, 1.6]]),
        c_pcb_blue(), 0.5);
    translate([0, glass_y, b_t]) glass_panel(glass, glass_t, active, [0, active_y]);
    if (detail) {
        translate([0, 0, b_t]) for (i = [0:3]) translate([(i - 1.5) * 2.54, pins_y - 1.6, 0]) silk(pins[i], 0.6, "right", rot = 90);
        mirror([0, 0, 1]) {
            translate([-6, 9, 0]) sot23(3);
            for (x = [-2, 0, 2, 4, 6]) translate([x, 9, 0]) smd_passive("0603", x < 2 ? "c" : "r", 90);
            color([0.85, 0.55, 0.15]) translate([-7, -b_l / 2 + 0.5, 0]) cube([14, 5, 0.15]);
        }
    }
    bo_headers(4, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
module sh1106_13_holder(h = 2, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
module sh1106_13_window(gap = 0.3, wall = 2, margin = 0.5, flare = 0.8) {
    rect_window(0, glass_y + active_y, b_t + glass_t + gap, wall, [active[0] + 2 * margin, active[1] + 2 * margin], flare);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") sh1106_13();
else if (show == "holder") color("#d6a24a") sh1106_13_holder();
else bo_demo([b_w, b_l], 2, b_t + glass_t + 0.3) {
    sh1106_13();
    sh1106_13_holder();
    sh1106_13_window();
}
