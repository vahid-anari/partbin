// Small DC-DC converter boards, all in one file:
//
//   lm2596_hw411()       LM2596S step-down, "HW-411" (blue, 43 x 21, trimmer)
//   mt3608()             MT3608 step-up (blue, 36 x 17, trimmer)
//   stepup_tiny()        0.9-5 V -> 5 V (or 3.3 V) step-up, 3 pins: Vo GND Vi
//   stepdown_mini()      12-24 V -> 5 V 3 A mini step-down (green, "100" inductor)
//   s09_buckboost()      S09 automatic buck-boost to 3.3 / 5 V (red)
//
// and for each: <name>_size(), <name>_holder(h) (posts or a ledge), and
// <name>_pad(name) giving [x, y] of a pad ("IN+", "OUT-", ...).
//
//   use <partbin/power/converters/converters.scad>
//
// Where they sit: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the input at the left (-x). Typical sizes;
// layouts from the order listings' photos.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

function _pad(list, name) = [for (p = list) if (p[0] == name) [p[1], p[2]]][0];

// ===================================================================== LM2596
lm_size  = [43.2, 21.0, 1.6];
lm_holes = [[-15.5, 7.6], [15.5, -7.6]];
lm_pads  = [["IN+", -19.8, -8.0], ["IN-", -19.8, 8.0], ["OUT+", 19.8, 8.0], ["OUT-", 19.8, -8.0]];
function lm2596_hw411_size() = lm_size;
function lm2596_hw411_pad(n) = _pad(lm_pads, n);
function lm2596_hw411_height() = lm_size[2] + 11;   // the trimmer / capacitors

module lm2596_hw411(detail = true) {
    t = lm_size[2];
    pcb([lm_size[0], lm_size[1]], t, [for (h = lm_holes) [h[0], h[1], 3.0, 5.0]], c_pcb_blue(), 0.6);
    for (p = lm_pads) translate([p[1], p[2], 0]) pad([3.0, 3.0], 1.2, t);
    translate([0, 0, t]) {
        translate([-7.5, -1.5, 0]) power_inductor_big(12.0, 7.0);
        translate([7.0, 2.0, 0]) to263(rot = 180);
        translate([-17.0, 3.0, 0]) elco(6.3, 11);
        translate([16.0, -4.5, 0]) elco(6.3, 11);
        translate([6.0, -7.0, 0]) trimpot_3296();
        if (detail) {
            translate([12.0, 6.5, 0]) sma_diode();
            for (p = lm_pads) translate([p[1] + (p[1] < 0 ? 2.2 : -2.2), p[2], 0]) silk(p[0], 0.7, p[1] < 0 ? "left" : "right");
        }
    }
}
module lm2596_hw411_holder(h = 3, style = "screw") { bo_mounts(lm_holes, 3.0, lm_size[2], h, style); }

// ===================================================================== MT3608
mt_size = [36.0, 17.0, 1.6];
mt_pads = [["IN-", -16.0, 6.5], ["IN+", -16.0, -6.5], ["OUT+", 16.0, -6.5], ["OUT-", 16.0, 6.5]];
function mt3608_size() = mt_size;
function mt3608_pad(n) = _pad(mt_pads, n);
function mt3608_height() = mt_size[2] + 10.5;

module mt3608(detail = true) {
    t = mt_size[2];
    color(c_pcb_blue()) translate([-mt_size[0] / 2, -mt_size[1] / 2, 0]) cube(mt_size);
    for (p = mt_pads) translate([p[1], p[2], 0]) pad([2.6, 2.6], 1.2, t);
    translate([0, 0, t]) {
        translate([-6.5, 1.0, 0]) power_inductor(5.8, 4.5);
        translate([6.5, 0.5, 0]) rotate([0, 0, 90]) trimpot_3296();
        if (detail) {
            translate([-1.0, -4.5, 0]) sot23(5);
            translate([-1.0, 4.5, 0]) sma_diode([3.8, 2.0, 1.6]);
            for (x = [-11.5, 11.5]) translate([x, 0, 0]) smd_passive("1206", "c", 90);
            for (p = mt_pads) translate([p[1] + (p[1] < 0 ? 2.0 : -2.0), p[2], 0]) silk(str("V", p[0]), 0.6, p[1] < 0 ? "left" : "right");
        }
    }
}
module mt3608_holder(h = 2) { edge_holder([mt_size[0], mt_size[1]], mt_size[2], h, 1.2); }

// =========================================================== tiny step-up
su_size = [9.5, 10.0, 1.0];
su_pins = [["Vo", -2.54, -3.6], ["GND", 0, -3.6], ["Vi", 2.54, -3.6]];   // the output on the left
function stepup_tiny_size() = su_size;
function stepup_tiny_pad(n) = _pad(su_pins, n);
function stepup_tiny_height() = su_size[2] + 4.5;

module stepup_tiny(detail = true, headers = "none") {
    t = su_size[2];
    pcb([su_size[0], su_size[1]], t, [for (p = su_pins) [p[1], p[2], 1.0, 1.6]], [0.20, 0.60, 0.30], 0.3);
    translate([-1.3, 1.6, t]) power_inductor(5.8, 4.5);
    if (detail) translate([3.0, 1.8, t]) {
        color(c_chip()) translate([-1.25, -2.25, 0]) cube([2.5, 4.5, 1.5]);   // SOT-89
        color(c_tin()) translate([-0.8, 2.25, 0]) cube([1.6, 0.8, 0.3]);
    }
    if (detail) translate([0, 0, t]) for (p = su_pins) translate([p[1], p[2] + 1.4, 0]) silk(p[0], 0.45);
    if (headers == "down") translate([0, su_pins[0][2], 0]) rotate([0, 0, 90]) mirror([0, 0, 1]) pin_header(3, below = t + 1.5);
}
module stepup_tiny_holder(h = 1.5) { edge_holder([su_size[0], su_size[1]], su_size[2], h, 1.0); }

// ========================================================== mini step-down
sd_size = [22.0, 17.0, 1.6];
sd_pads = [["IN+", -9.6, 6.6], ["IN-", -9.6, -6.6], ["OUT+", 9.6, 6.6], ["OUT-", 9.6, -6.6]];
function stepdown_mini_size() = sd_size;
function stepdown_mini_pad(n) = _pad(sd_pads, n);
function stepdown_mini_height() = sd_size[2] + 3.5;

module stepdown_mini(detail = true) {
    t = sd_size[2];
    color([0.20, 0.60, 0.30]) translate([-sd_size[0] / 2, -sd_size[1] / 2, 0]) cube(sd_size);
    for (p = sd_pads) translate([p[1], p[2], 0]) pad([2.2, 2.2], 1.0, t);
    translate([1.0, 2.0, t]) power_inductor(7.0, 3.5);
    if (detail) translate([0, 0, t]) {
        for (y = [-4.5, 4.5]) translate([-5.5, y, 0]) { color([0.75, 0.55, 0.15]) translate([-1.75, -1.4, 0]) cube([3.5, 2.8, 1.9]); }  // tantalum caps
        translate([1.0, -5.0, 0]) sot23(5);
        translate([6.5, -4.0, 0]) color([0.9, 0.9, 0.9]) cube([3, 3, 1.5], center = false);    // small trimmer
        for (p = sd_pads) translate([p[1] + (p[1] < 0 ? 1.8 : -1.8), p[2], 0]) silk(p[0], 0.5, p[1] < 0 ? "left" : "right");
    }
}
module stepdown_mini_holder(h = 1.5) { edge_holder([sd_size[0], sd_size[1]], sd_size[2], h, 1.2); }

// ======================================================== S09 buck-boost
s9_size = [22.0, 13.5, 1.2];
s9_pads = [["VIN", -10.0, 3.0], ["GND", -10.0, -3.0], ["VOUT", 10.0, 3.0], ["GND2", 10.0, -3.0]];
function s09_buckboost_size() = s9_size;
function s09_buckboost_pad(n) = _pad(s9_pads, n);
function s09_buckboost_height() = s9_size[2] + 2.6;

module s09_buckboost(detail = true) {
    t = s9_size[2];
    color([0.75, 0.12, 0.12]) translate([-s9_size[0] / 2, -s9_size[1] / 2, 0]) cube(s9_size);
    for (p = s9_pads) translate([p[1], p[2], 0]) pad([2.0, 2.4], 1.0, t);
    for (x = [-2.5, 3.5]) translate([x, 2.0, t]) drum_inductor(3.8, 2.6);
    if (detail) translate([0, 0, t]) {
        translate([0.5, -3.5, 0]) smd_ic([3.0, 3.0, 1.0], 5, 0.5);
        for (x = [-6.5, 6.5]) translate([x, -3.5, 0]) smd_passive("1206", "c", 90);
    }
}
module s09_buckboost_holder(h = 1.5) { edge_holder([s9_size[0], s9_size[1]], s9_size[2], h, 1.2); }

// ========================================================= shown when opened
show = "demo";  // demo | board
if (show == "board") lm2596_hw411();
else {
    translate([0, 30, 0]) lm2596_hw411();
    translate([-20, 0, 0]) mt3608();
    translate([12, 0, 0]) stepup_tiny();
    translate([-20, -25, 0]) stepdown_mini();
    translate([12, -25, 0]) s09_buckboost();
}
