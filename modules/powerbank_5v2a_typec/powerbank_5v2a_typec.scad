// Type-C 5 V 2 A charge/boost ("power bank") board: black, 25 x 20 mm,
// USB-C input, a USB-A output that solders on the back, 4 battery LEDs,
// battery pads and a KEY pad at the far end, 5 V output pads on one side,
// a half-round notch in each long side. (Sold as "5V2A charge-discharge
// integrated module" and "Type-C USB 5V 2A boost converter".)
//
//   use <partbin/modules/powerbank_5v2a_typec/powerbank_5v2a_typec.scad>
//
//   powerbank_5v2a_typec();                     the board (USB-A not soldered)
//   powerbank_5v2a_typec(usb_a = true);         with the USB-A socket on the back
//   powerbank_5v2a_typec(detail = false);       only what matters for fit (fast)
//   powerbank_5v2a_typec_usb_cutout(wall, gap)  the USB-C opening, subtract it
//   powerbank_5v2a_typec_usb_a_cutout(wall, gap) the USB-A opening, subtract it
//   powerbank_5v2a_typec_led_window(gap, wall)  a slot over the 4 LEDs in the lid
//   powerbank_5v2a_typec_holder();              ledge and low walls, open at the USB end
//   powerbank_5v2a_typec_size()                 [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB end at -x (both sockets point -x).

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ---------------------- from the listing (25 x 20, notches 13 mm from the USB end)
b_l      = 25.0;    // board length (x)
b_w      = 20.0;    // board width (y)
b_t      = 1.2;     // PCB (typical)
notch_x  = -b_l / 2 + 13.0;   // the side notches
notch_r  = 1.5;
c_size   = [8.94, 3.26, 7.35];  // USB-C
usb_out  = 0.5;     // the sockets stick out past the end
a_size   = [13.1, 5.7, 10.0];   // USB-A on the back
leds     = [for (i = [0:3]) [3.0 + i * 2.0, 8.4]];   // 25 50 75 100 %

function powerbank_5v2a_typec_size() = [b_l, b_w, b_t];
function powerbank_5v2a_typec_usb_front() = -b_l / 2 - usb_out;
function powerbank_5v2a_typec_height() = b_t + 4.0;   // the inductor
function powerbank_5v2a_typec_behind(usb_a = false) = usb_a ? a_size[1] : 0.5;

// ======================================================================= board
module powerbank_5v2a_typec(usb_a = false, detail = true) {
    color([0.08, 0.08, 0.09]) difference() {
        translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
        for (s = [-1, 1]) translate([notch_x, s * b_w / 2, -1]) cylinder(r = notch_r, h = b_t + 2, $fn = 32);
    }
    translate([-b_l / 2 - usb_out, 0, b_t]) rotate([0, 0, 90]) usb_c(c_size[0], c_size[1], c_size[2]);
    if (usb_a) translate([-b_l / 2 - usb_out, 0, 0]) mirror([0, 0, 1]) rotate([0, 0, 90]) usb_a_female(a_size[0], a_size[1], a_size[2]);
    // pads: 5V out (- +) on one side, battery (- +) and KEY at the far end
    for (p = [[-7.6, -7.7], [-1.7, -7.7], [11.2, 3.4], [11.2, -2.6], [11.2, -7.6]])
        translate([p[0], p[1], 0]) pad([1.8, 1.8], 1.0, b_t);
    translate([5.9, -4.5, b_t]) power_inductor(5.2, 4.0);
    if (detail) translate([0, 0, b_t]) {
        translate([5.9, 3.4, 0]) soic(8, 3.9, 1.5);
        for (l = leds) translate([l[0], l[1], 0]) smd_led("0603", "white");
        for (p = [[-1.4, 5.3], [-1.4, -1.1], [2.2, 4.9], [10.3, 1.6], [-4.5, 5.0]]) translate([p[0], p[1], 0]) smd_passive("0805", "c");
        translate([-7.6, -5.8, 0]) silk("-", 1.0);
        translate([-1.7, -5.8, 0]) silk("+", 1.0);
        translate([-4.6, -8.3, 0]) silk("5V", 0.8);
        translate([9.4, 3.4, 0]) silk("-", 1.0);
        translate([9.4, -2.6, 0]) silk("+", 1.0);
        translate([9.4, -7.6, 0]) silk("K", 0.9);
    }
}

// ==================================================================== cutouts
module powerbank_5v2a_typec_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([-b_l / 2 - usb_out, 0], b_t + c_size[1] / 2, 90, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

// A rectangular opening for the USB-A socket on the back (with usb_a = true).
module powerbank_5v2a_typec_usb_a_cutout(wall = 2, gap = 0, clear = 0.4) {
    translate([-b_l / 2 - usb_out - gap - wall - 1, -a_size[0] / 2 - clear, -a_size[1] - clear])
        cube([wall + gap + 1.5, a_size[0] + 2 * clear, a_size[1] + 2 * clear]);
}

// A slot over the 4 battery LEDs in a lid `gap` above the board's top.
module powerbank_5v2a_typec_led_window(gap = 4.5, wall = 2) {
    rect_window(6.0, 8.4, b_t + gap, wall, [8.5, 1.6], 0, 0.3);
}

// ===================================================================== holder
// Ledge and low walls, open at the USB end; `h` tall (12 leaves room for
// the USB-A socket underneath).
module powerbank_5v2a_typec_holder(h = 2, usb_a = false) {
    hh = usb_a ? a_size[1] + 0.8 : h;
    difference() {
        edge_holder([b_l, b_w], b_t, hh, 1.5);
        translate([-b_l / 2 - 5, -b_w / 2 + 2.5, -hh - 1]) cube([6, b_w - 5, hh + 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder | usb_a
if (show == "board") powerbank_5v2a_typec();
else if (show == "usb_a") powerbank_5v2a_typec(usb_a = true);
else if (show == "holder") color("#d6a24a") powerbank_5v2a_typec_holder();
else {
    powerbank_5v2a_typec(usb_a = true);
    color("#d6a24a") powerbank_5v2a_typec_holder(usb_a = true);
    color("#9aa3ab", 0.9) difference() {
        translate([powerbank_5v2a_typec_usb_front() - 2, -12, -8]) cube([2, 24, 14]);
        powerbank_5v2a_typec_usb_cutout();
        powerbank_5v2a_typec_usb_a_cutout();
    }
}
