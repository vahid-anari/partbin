// Pro Micro boards with USB-C: the ATmega32U4 (Arduino Leonardo compatible)
// and the TENSTAR RP2040 Pro Micro (16 MB, BOOT and RST buttons, RGB LED).
// Same footprint: 33 x 18 mm, 12 pins down each side, rows 15.24 mm apart.
//
//   use <partbin/modules/pro_micro/pro_micro.scad>
//
//   pro_micro();                         the ATmega32U4 board
//   pro_micro(chip = "rp2040");          the RP2040 one
//   pro_micro(detail = false);           only what matters for fit (fast)
//   pro_micro(headers = "down");         with pin headers soldered on
//   pro_micro_usb_cutout(wall, gap)      the USB-C opening, subtract it
//   pro_micro_holder();                  ledge and low walls, open at the USB end
//   pro_micro_size()                     [width, length, pcb thickness]
//   pro_micro_pin(side, i)               [x, y] of pin i (0 = USB end) on "left"/"right"
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the USB socket at the top (+y).

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 18.0;    // board width (x)
b_l      = 33.0;    // board length (y)
b_t      = 1.2;     // PCB
rows     = 15.24;
pin1_y   = b_l / 2 - 3.0;    // first pin from the USB end (the socket takes the space above)
c_size   = [8.94, 3.26, 7.35];
usb_out  = 1.0;

function pro_micro_size() = [b_w, b_l, b_t];
function pro_micro_usb_front() = b_l / 2 + usb_out;
function pro_micro_height() = b_t + c_size[1];
function pro_micro_pin(side, i) = [side == "left" ? -rows / 2 : rows / 2, pin1_y - i * 2.54];

// ======================================================================= board
module pro_micro(chip = "atmega32u4", detail = true, headers = "none") {
    col = chip == "rp2040" ? c_pcb_black() : [0.10, 0.18, 0.55];
    pcb([b_w, b_l], b_t, [for (s = [-1, 1], i = [0:11]) [s * rows / 2, pin1_y - i * 2.54, 1.0, 1.6]], col, 0.6);
    translate([0, b_l / 2 + usb_out, b_t]) usb_c(c_size[0], c_size[1], c_size[2]);
    if (detail) translate([0, 0, b_t]) {
        if (chip == "rp2040") {
            translate([0, -3, 0]) qfn(7, 0.9, 14, rot = 45, label = "RP2040");
            translate([0, -11.5, 0]) soic(8, 5.3, 1.8, rot = 90);
            for (x = [-4, 4]) translate([x, b_l / 2 - 10.5, 0]) smd_button([3.6, 3.0], 1.2, 0.4, 1.3);
            translate([0, b_l / 2 - 10.5, 0]) { color([0.95, 0.95, 0.95]) translate([-1, -1, 0]) cube([2, 2, 0.6]); }
        } else {
            translate([0, -4, 0]) qfn(7, 1.0, 11, rot = 45, label = "32U4");     // TQFP-44, roughly
            translate([4.5, 5, 0]) smd_crystal([3.2, 2.5], 0.8);
            translate([-4.5, 5, 0]) sot23(5);
            for (x = [-3, 3]) translate([x, b_l / 2 - 10, 0]) smd_led("0603", x < 0 ? "red" : "lime");
        }
        for (p = [[-5.5, -12], [5.5, -12], [-5.5, 1], [5.5, 1]]) translate([p[0], p[1], 0]) smd_passive("0603", "c", 90);
    }
    if (headers == "down") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 5.5 * 2.54, 0]) mirror([0, 0, 1]) pin_header(12, below = b_t + 1.5);
    else if (headers == "up") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 5.5 * 2.54, b_t]) pin_header(12, below = b_t + 1.5);
}

// =============================================================== USB cutout
module pro_micro_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([0, b_l / 2 + usb_out], b_t + c_size[1] / 2, 0, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

// ===================================================================== holder
module pro_micro_holder(h = 2) {
    difference() {
        edge_holder([b_w, b_l], b_t, h, 1.5);
        translate([-c_size[0] / 2 - 2, b_l / 2 - 1, -h - 1]) cube([c_size[0] + 4, 6, h + 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder | rp2040
if (show == "board") pro_micro();
else if (show == "rp2040") pro_micro(chip = "rp2040");
else if (show == "holder") color("#d6a24a") pro_micro_holder();
else {
    pro_micro();
    color("#d6a24a") pro_micro_holder();
    color("#9aa3ab", 0.9) difference() {
        translate([-12, pro_micro_usb_front(), -3]) cube([24, 2, 9]);
        pro_micro_usb_cutout();
    }
}
