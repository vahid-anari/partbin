// USB-C female breakout boards:
//
//   usbc_breakout_red();      red, 14.2 x 21.8 mm, 6 pins (VBUS GND CC2 CC1 D- D+), 2 holes
//   usbc_breakout_green();    green 16-pin test board, 12 x 13.8 mm, 4 pins (V D- D+ G)
//
// and for each: <name>_usb_cutout(wall, gap), <name>_holder(h), <name>_size().
//
//   use <partbin/boards/usbc_breakouts/usbc_breakouts.scad>
//
// Where they sit: parts up, the board centred on x = y = 0, its underside at
// z = 0. Red: socket on the left long edge pointing -x, pins along the right.
// Green: socket at the bottom edge pointing -y, pins along the top.
// Sizes from the listings' photos.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

c_size = [8.94, 3.26, 7.35];

// ======================================================================== red
// The socket points out of one long edge (-x), the 6 pins run along the
// other (+x), holes in two opposite corners.
r_size  = [14.2, 21.8, 1.6];
r_holes = [[4.4, 8.9], [-4.4, -8.9]];
r_pins_x = r_size[0] / 2 - 1.6;
r_pins  = ["VBUS", "GND", "CC2", "CC1", "D-", "D+"];   // top to bottom
r_usb_y = -1.0;
r_out   = 0.6;

function usbc_breakout_red_size() = r_size;
function usbc_breakout_red_usb_front() = -r_size[0] / 2 - r_out;   // x

module usbc_breakout_red(headers = "none") {
    pcb([r_size[0], r_size[1]], r_size[2], concat([for (h = r_holes) [h[0], h[1], 2.2, 3.4]],
        [for (i = [0:5]) [r_pins_x, (2.5 - i) * 2.54, 1.0, 1.6]]), [0.80, 0.12, 0.15], 0.6);
    translate([-r_size[0] / 2 - r_out, r_usb_y, r_size[2]]) rotate([0, 0, 90]) usb_c(c_size[0], c_size[1], c_size[2]);
    translate([0, 0, r_size[2]]) for (i = [0:5]) translate([r_pins_x - 1.3, (2.5 - i) * 2.54, 0]) silk(r_pins[i], 0.5, "right");
    if (headers == "down") translate([r_pins_x, 0, 0]) mirror([0, 0, 1]) pin_header(6, below = r_size[2] + 1.5);
    else if (headers == "up") translate([r_pins_x, 0, r_size[2]]) pin_header(6, below = r_size[2] + 1.5);
}
module usbc_breakout_red_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([-r_size[0] / 2 - r_out, r_usb_y], r_size[2] + c_size[1] / 2, 90, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}
module usbc_breakout_red_holder(h = 3, style = "peg") { bo_mounts(r_holes, 2.2, r_size[2], h, style); }

// ====================================================================== green
g_size  = [12.0, 13.8, 1.6];
g_pins_y = g_size[1] / 2 - 1.6;
g_pins  = ["V", "D-", "D+", "G"];
g_out   = 1.0;

function usbc_breakout_green_size() = g_size;
function usbc_breakout_green_usb_front() = -g_size[1] / 2 - g_out;

module usbc_breakout_green(headers = "none") {
    pcb([g_size[0], g_size[1]], g_size[2], [for (i = [0:3]) [(i - 1.5) * 2.54, g_pins_y, 1.0, 1.7]], [0.20, 0.60, 0.30], 0.4);
    translate([0, -g_size[1] / 2 - g_out, g_size[2]]) rotate([0, 0, 180]) usb_c(c_size[0], c_size[1], c_size[2]);
    translate([0, 0, g_size[2]]) for (i = [0:3]) translate([(i - 1.5) * 2.54, g_pins_y - 1.8, 0]) silk(g_pins[i], 0.7);
    bo_headers(4, 0, g_pins_y, g_size[2], headers);
}
module usbc_breakout_green_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([0, -g_size[1] / 2 - g_out], g_size[2] + c_size[1] / 2, 180, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}
module usbc_breakout_green_holder(h = 1.5) {
    difference() {
        edge_holder([g_size[0], g_size[1]], g_size[2], h, 1.2);
        translate([-c_size[0] / 2 - 1, -g_size[1] / 2 - 5, -0.01]) cube([c_size[0] + 2, 6, 10]);
    }
}

show = "demo";
translate([-10, 0, 0]) usbc_breakout_red();
translate([10, 0, 0]) usbc_breakout_green();
