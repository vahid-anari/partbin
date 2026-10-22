// TP4056 1 A Li-ion charger board, with USB-C or micro-USB, with or without
// the protection chips (DW01 + FS8205). Pads: IN+ IN- beside the USB socket,
// B+ B- (battery) and OUT+ OUT- (protected output) at the far end.
//
//   use <partbin/power/tp4056/tp4056.scad>
//
//   tp4056();                               USB-C, with protection
//   tp4056(usb = "micro");                  the micro-USB board
//   tp4056(protection = false);             only B+ B- at the far end
//   tp4056(detail = false);                 only what matters for fit (fast)
//   tp4056_usb_cutout(usb, wall, gap);      the USB opening, subtract from the wall
//   tp4056_holder(usb);                     ledge and low walls, add to the case
//   tp4056_size(usb)                        [length, width, pcb thickness]
//   tp4056_usb_front(usb)                   x of the USB socket's face (negative)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB socket at the left end pointing -x.
// The red LED is on while charging, the other (green or blue) when full.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
c_len    = 28.0;    // board length with USB-C (x)
m_len    = 26.0;    // with micro-USB
b_w      = 17.0;    // board width (y)
b_t      = 1.6;     // PCB
c_size   = [8.94, 3.26, 7.35];   // USB-C socket: width, height, depth
m_size   = [7.5, 2.5, 5.0];      // micro-USB
usb_out  = 0.6;     // how far the socket sticks out past the board's end
pad_in   = 1.8;     // pad centres from the board's end and side edges

function tp4056_size(usb = "c") = [usb == "c" ? c_len : m_len, b_w, b_t];
function tp4056_usb_front(usb = "c") = -tp4056_size(usb)[0] / 2 - usb_out;
function tp4056_height(usb = "c") = b_t + (usb == "c" ? c_size[1] : m_size[1]);

// ======================================================================= board
module tp4056(usb = "c", protection = true, detail = true) {
    l = tp4056_size(usb)[0];
    s = usb == "c" ? c_size : m_size;
    color(c_pcb_blue()) translate([-l / 2, -b_w / 2, 0]) cube([l, b_w, b_t]);
    // USB socket pointing -x
    translate([-l / 2 - usb_out, 0, b_t]) rotate([0, 0, 90]) {
        if (usb == "c") usb_c(s[0], s[1], s[2]); else usb_micro(s[0], s[1], s[2]);
    }
    // pads: IN- IN+ beside the socket; B+ B- (and OUT+ OUT-) at the far end
    for (p = [[-l / 2 + pad_in, b_w / 2 - pad_in], [-l / 2 + pad_in, -b_w / 2 + pad_in]])
        translate([p[0], p[1], 0]) pad([2.2, 2.2], 1.0, b_t);
    for (y = protection ? [1, 0.4, -0.4, -1] : [0.4, -0.4])
        translate([l / 2 - pad_in, y * (b_w / 2 - pad_in), 0]) pad([2.4, 2.6], 1.0, b_t);
    if (detail) translate([0, 0, b_t]) {
        translate([-1, 0, 0]) soic(8, 3.9, 1.5);                              // TP4056
        translate([-l / 2 + 9.5, 5.2, 0]) smd_led("0603", "red");
        translate([-l / 2 + 9.5, -5.2, 0]) smd_led("0603", "lime");
        for (p = [[-l / 2 + 9.5, 2.2, "r"], [-l / 2 + 9.5, -2.2, "r"], [-l / 2 + 12, 5.2, "r"], [-l / 2 + 12, -5.2, "c"], [4, 4.8, "c"], [4, -4.8, "r"]])
            translate([p[0], p[1], 0]) smd_passive("0603", p[2], 90);
        if (protection) {
            translate([l / 2 - 6.5, 3.2, 0]) smd_ic([2.9, 1.6, 1.0], 3, 0.95, rot = 90);   // DW01
            translate([l / 2 - 6.5, -3.0, 0]) smd_ic([3.0, 3.0, 1.0], 4, 0.65, rot = 90);  // FS8205A
        }
        for (i = [0:(protection ? 3 : 1)])
            translate([l / 2 - pad_in - 2.0, (protection ? [1, 0.4, -0.4, -1] : [0.4, -0.4])[i] * (b_w / 2 - pad_in), 0])
                silk((protection ? ["OUT+", "B+", "B-", "OUT-"] : ["B+", "B-"])[i], 0.7, "right");
        for (p = [[1, "IN-"], [-1, "IN+"]]) translate([-l / 2 + pad_in + 1.6, p[0] * (b_w / 2 - pad_in), 0]) silk(p[1], 0.6, "left");
    }
}

// =============================================================== USB cutout
module tp4056_usb_cutout(usb = "c", wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    s = usb == "c" ? c_size : m_size;
    bo_usb_cutout([tp4056_usb_front(usb), 0], b_t + s[1] / 2, 90, [s[0], s[1]], wall, gap, clear,
                  usb == "c" ? [12.4, 6.6] : [11, 8], lip);
}

// ===================================================================== holder
// The board has no mounting holes: a ledge under its edges and low walls,
// open at the USB end. The case wall with the USB cutout closes that end.
module tp4056_holder(usb = "c", h = 1.5) {
    l = tp4056_size(usb)[0];
    difference() {
        edge_holder([l, b_w], b_t, h, 1.5);
        translate([-l / 2 - 5, -b_w / 2 + 3, -0.01]) cube([6, b_w - 6, 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder | micro
if (show == "board") tp4056();
else if (show == "micro") tp4056(usb = "micro");
else if (show == "holder") color("#d6a24a") tp4056_holder();
else {
    tp4056();
    color("#d6a24a") tp4056_holder();
    color("#9aa3ab", 0.9) difference() {
        translate([tp4056_usb_front() - 2, -12, -3]) cube([2, 24, 9]);
        tp4056_usb_cutout(wall = 2);
    }
}
