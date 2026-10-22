// Mini Li-ion charger + 5 V boost with protection (white, 15.8 x 12 mm).
// One USB-C socket does both: it charges the cell and gives 5 V out.
// B- and B+ pads at the far end; two small LEDs.
//
//   use <partbin/modules/charger_mini_typec_boost/charger_mini_typec_boost.scad>
//
//   charger_mini_typec_boost();                    the board, with its parts
//   charger_mini_typec_boost(detail = false);      only what matters for fit (fast)
//   charger_mini_typec_boost_usb_cutout(wall, gap) the USB-C opening, subtract it
//   charger_mini_typec_boost_holder();             ledge and low walls, open at the USB end
//   charger_mini_typec_boost_size()                [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB socket at the left end pointing -x.
// The socket is mid-mount: it sits in a notch, half below the board.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// --------------------------------- from the listing (15.8 x 12 mm)
b_l      = 15.8;    // board length (x), with the socket's notch
b_w      = 12.0;    // board width (y)
b_t      = 1.0;     // PCB
hole_d   = 1.2;     // four small corner holes
hole_in  = 1.1;
c_size   = [8.94, 3.26, 7.35];   // USB-C
usb_out  = 1.6;     // the socket sticks out past the board's end
usb_z    = -0.8;    // socket bottom, below the board's underside (mid-mount)

holes = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_l / 2 - hole_in), sy * (b_w / 2 - hole_in)]];

function charger_mini_typec_boost_size() = [b_l, b_w, b_t];
function charger_mini_typec_boost_usb_front() = -b_l / 2 - usb_out;
function charger_mini_typec_boost_holes() = holes;
function charger_mini_typec_boost_height() = b_t + 2.6;   // the drum inductor

// ======================================================================= board
module charger_mini_typec_boost(detail = true) {
    color([0.93, 0.93, 0.92]) difference() {
        translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
        // notch for the socket
        translate([-b_l / 2 - 1, -c_size[0] / 2 - 0.2, -1]) cube([c_size[2] - usb_out + 1, c_size[0] + 0.4, b_t + 2]);
        for (h = holes) translate([h[0], h[1], -1]) cylinder(d = hole_d, h = b_t + 2, $fn = 16);
    }
    translate([-b_l / 2 - usb_out, 0, usb_z]) rotate([0, 0, 90]) usb_c(c_size[0], c_size[1], c_size[2]);
    for (y = [-2.6, 2.6]) translate([b_l / 2 - 1.6, y, 0]) pad([2.0, 2.4], 0, b_t);
    translate([2.6, 3.0, b_t]) drum_inductor(3.8, 2.6);
    if (detail) translate([0, 0, b_t]) {
        translate([2.2, -1.6, 0]) smd_ic([2.9, 1.6, 1.0], 3, 0.95, rot = 90);
        for (p = [[-0.6, -4.3], [0.8, -4.3]]) translate([p[0], p[1], 0]) smd_led("0603", p[0] < 0 ? "red" : "deepskyblue");
        for (p = [[5.0, -3.8], [-0.5, 2.5]]) translate([p[0], p[1], 0]) smd_passive("0603", "c", 90);
        translate([b_l / 2 - 3.6, 2.6, 0]) silk("B+", 0.8, "right");
        translate([b_l / 2 - 3.6, -2.6, 0]) silk("B-", 0.8, "right");
    }
}

// ==================================================================== cutouts
module charger_mini_typec_boost_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([-b_l / 2 - usb_out, 0], usb_z + c_size[1] / 2, 90, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

// ===================================================================== holder
// Ledge and low walls, open at the USB end (the socket hangs below the board).
module charger_mini_typec_boost_holder(h = 1.5) {
    difference() {
        edge_holder([b_l, b_w], b_t, h, 1.0);
        translate([-b_l / 2 - 5, -c_size[0] / 2 - 0.5, -h - 1]) cube([c_size[2] + 4, c_size[0] + 1, h + 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") charger_mini_typec_boost();
else if (show == "holder") color("#d6a24a") charger_mini_typec_boost_holder();
else {
    charger_mini_typec_boost();
    color("#d6a24a") charger_mini_typec_boost_holder();
    color("#9aa3ab", 0.9) difference() {
        translate([charger_mini_typec_boost_usb_front() - 2, -10, -3]) cube([2, 20, 8]);
        charger_mini_typec_boost_usb_cutout();
    }
}
