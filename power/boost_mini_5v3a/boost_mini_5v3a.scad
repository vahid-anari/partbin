// Mini DC-DC boost board, 3.7 V to 5 V 3 A (green, a pad with a hole in each
// corner: IN+ IN- at one end, OUT+ OUT- at the other; SOP-8 chip, two
// diodes, a 2.2 uH inductor). Sold as "3.7V lithium battery boost charging
// board 5V3A / 9V1.3A / 12V1A".
//
//   use <partbin/power/boost_mini_5v3a/boost_mini_5v3a.scad>
//
//   boost_mini_5v3a();                    the board, with its parts
//   boost_mini_5v3a(detail = false);      only what matters for fit (fast)
//   boost_mini_5v3a_holder();             ledge and low walls, add to the case
//   boost_mini_5v3a_size()                [length, width, pcb thickness]
//   boost_mini_5v3a_pad(name)             [x, y] of "IN+", "IN-", "OUT+", "OUT-"
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, IN at the right end (+x), OUT at the left.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// --------------------- typical; proportions from the seller's photo
b_l      = 22.0;    // board length (x)
b_w      = 13.5;    // board width (y)
b_t      = 1.6;     // PCB
pad_in   = 1.6;     // corner pads, centre to the edges
tall_h   = 3.0;     // the inductor

pads = [["IN+", b_l / 2 - pad_in, -b_w / 2 + pad_in], ["IN-", b_l / 2 - pad_in, b_w / 2 - pad_in],
        ["OUT+", -b_l / 2 + pad_in, b_w / 2 - pad_in], ["OUT-", -b_l / 2 + pad_in, -b_w / 2 + pad_in]];

function boost_mini_5v3a_size() = [b_l, b_w, b_t];
function boost_mini_5v3a_height() = b_t + tall_h;
function boost_mini_5v3a_pad(name) = [for (p = pads) if (p[0] == name) [p[1], p[2]]][0];

// ======================================================================= board
module boost_mini_5v3a(detail = true) {
    color([0.20, 0.62, 0.30]) translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
    for (p = pads) translate([p[1], p[2], 0]) pad([2.4, 2.4], 1.2, b_t);
    translate([4.0, 0.3, b_t]) power_inductor(5.2, tall_h);
    if (detail) {
        translate([0, 0, b_t]) {
            translate([-3.0, 3.6, 0]) soic(8, 3.9, 1.5);
            translate([-3.0, -0.6, 0]) sma_diode();
            translate([-3.0, -4.2, 0]) sma_diode();
            for (y = [2.5, -2.5]) translate([-8.3, y, 0]) smd_passive("1206", "c", 90);
            for (p = pads) translate([p[1] + (p[1] < 0 ? 1.6 : -1.6), p[2], 0]) silk(p[0], 0.55, p[1] < 0 ? "left" : "right");
        }
        // the underside is mostly a tinned copper area
        color(c_tin()) translate([-b_l / 2 + 4, -b_w / 2 + 1.5, -0.02]) cube([b_l - 8, b_w - 3, 0.02]);
    }
}

// ===================================================================== holder
module boost_mini_5v3a_holder(h = 1.5) {
    edge_holder([b_l, b_w], b_t, h, 1.2);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") boost_mini_5v3a();
else if (show == "holder") color("#d6a24a") boost_mini_5v3a_holder();
else {
    boost_mini_5v3a();
    color("#d6a24a") boost_mini_5v3a_holder();
}
