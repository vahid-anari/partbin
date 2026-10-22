// Raspberry Pi Pico-style RP2040 board, the black USB-C clone with 16 MB
// flash, BOOT and RST buttons and an RGB LED. Same footprint as the Pico:
// 21 x 51 mm, 20 half-holes down each side (rows 17.78 mm apart), 3 SWD pads
// at the far end, four mounting holes.
//
//   use <partbin/dev-boards/pico_rp2040_typec/pico_rp2040_typec.scad>
//
//   pico_rp2040_typec();                    the board, with its parts
//   pico_rp2040_typec(detail = false);      only what matters for fit (fast)
//   pico_rp2040_typec(headers = "down");    with pin headers soldered on
//   pico_rp2040_typec_usb_cutout(wall, gap) the USB-C opening, subtract it
//   pico_rp2040_typec_holder(h = 3);        posts under its four holes
//   pico_rp2040_typec_size()                [width, length, pcb thickness]
//   pico_rp2040_typec_pin(n)                [x, y] of Pico pin n (1 ... 40)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the USB socket at the top (+y). Pin 1 is top left, pins 1-20 run
// down the left side and 21-40 back up the right, like the Pico.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ---------------------- Pico footprint (Raspberry Pi drawing); USB-C typical
b_w      = 21.0;    // board width (x)
b_l      = 51.0;    // board length (y)
b_t      = 1.0;     // PCB
rows     = 17.78;   // between the two pin rows
pin1_y   = b_l / 2 - 1.37;   // first pin from the USB end
hole_d   = 2.1;
holes_at = [11.4, 47.0];     // hole centres, x and y apart
c_size   = [8.94, 3.26, 7.35];   // USB-C
usb_out  = 1.3;

holes = [for (sx = [-1, 1], sy = [-1, 1]) [sx * holes_at[0] / 2, sy * holes_at[1] / 2]];

function pico_rp2040_typec_size() = [b_w, b_l, b_t];
function pico_rp2040_typec_usb_front() = b_l / 2 + usb_out;
function pico_rp2040_typec_height() = b_t + c_size[1];
function pico_rp2040_typec_holes() = holes;
function pico_rp2040_typec_pin(n) =
    n <= 20 ? [-rows / 2, pin1_y - (n - 1) * 2.54] : [rows / 2, pin1_y - (40 - n) * 2.54];

// ======================================================================= board
module pico_rp2040_typec(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 3.4]],
            [for (s = [-1, 1], i = [0:19]) [s * rows / 2, pin1_y - i * 2.54, 1.0, 1.6]],
            [for (i = [-1, 0, 1]) [i * 2.54, -b_l / 2 + 1.6, 1.0, 1.6]]),
        c_pcb_black(), 0.6);
    // half-holes on the long edges
    color(c_gold()) for (s = [-1, 1], i = [0:19])
        translate([s * (b_w / 2 + 0.01) + (s < 0 ? -0.03 : 0), pin1_y - i * 2.54 - 0.6, 0.01]) cube([0.03, 1.2, b_t - 0.02]);
    translate([0, b_l / 2 + usb_out, b_t]) usb_c(c_size[0], c_size[1], c_size[2]);
    if (detail) translate([0, 0, b_t]) {
        translate([0, 4, 0]) qfn(7, 0.9, 14, rot = 45, label = "RP2040");
        translate([0, -9, 0]) soic(8, 5.3, 1.8, rot = 90);                     // 16 MB flash
        translate([-4.5, b_l / 2 - 12, 0]) smd_button([3.6, 3.0], 1.2, 0.4, 1.3);   // BOOT
        translate([4.5, b_l / 2 - 12, 0]) smd_button([3.6, 3.0], 1.2, 0.4, 1.3);    // RST
        translate([0, -16.5, 0]) { color([0.95, 0.95, 0.95]) translate([-1, -1, 0]) cube([2, 2, 0.6]); color([0.9, 0.9, 1], 0.6) translate([-0.5, -0.5, 0.6]) cube([1, 1, 0.05]); }  // RGB LED
        translate([0, -3, 0]) smd_crystal([3.2, 2.5], 0.8);
        translate([-4, b_l / 2 - 17, 0]) sot23(5);                             // 3.3 V regulator
        for (p = [[3.5, 10], [-3.5, 10], [3.5, -3], [-3.5, -3], [4, -14], [-4, -14]]) translate([p[0], p[1], 0]) smd_passive("0402", "c");
        translate([-4.5, b_l / 2 - 15, 0]) silk("BOOT", 0.6);
        translate([4.5, b_l / 2 - 15, 0]) silk("RST", 0.6);
    }
    if (headers == "down") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 9.5 * 2.54, 0]) mirror([0, 0, 1]) pin_header(20, below = b_t + 1.5);
    else if (headers == "up") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 9.5 * 2.54, b_t]) pin_header(20, below = b_t + 1.5);
}

// =============================================================== USB cutout
module pico_rp2040_typec_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([0, b_l / 2 + usb_out], b_t + c_size[1] / 2, 0, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

// ===================================================================== holder
// Posts under the four holes (M2 self-tapping screws with style = "screw").
module pico_rp2040_typec_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") pico_rp2040_typec();
else if (show == "holder") color("#d6a24a") pico_rp2040_typec_holder();
else {
    pico_rp2040_typec();
    color("#d6a24a") { pico_rp2040_typec_holder(); translate([-14, -29, -4.6]) cube([28, 58, 1.6]); }
    color("#9aa3ab", 0.9) difference() {
        translate([-14, pico_rp2040_typec_usb_front(), -4.6]) cube([28, 2, 10]);
        pico_rp2040_typec_usb_cutout();
    }
}
