// IP5306 charge/discharge board, "MH-CD42" (5 V 2.1 A boost + 2.1 A
// Li-ion charger, button, 4 battery LEDs). Pads only, no USB socket:
// VIN and GND at one end, BAT, GND and VOUT at the other, KEY by the button.
//
//   use <partbin/modules/ip5306_mhcd42/ip5306_mhcd42.scad>
//
//   ip5306_mhcd42();                    the board, with its parts
//   ip5306_mhcd42(detail = false);      only what matters for fit (fast)
//   ip5306_mhcd42_holder();             ledge and low walls, add to the case
//   ip5306_mhcd42_button_cutout(gap, wall)   a hole over the button in the lid
//   ip5306_mhcd42_led_window(gap, wall)      a slot over the 4 LEDs in the lid
//   ip5306_mhcd42_size()                [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the button at the left end.
// The inductor is the tallest part (~3 mm). Remember the IP5306 turns its
// output off below ~50 mA of load.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_l      = 25.0;    // board length (x)
b_w      = 16.0;    // board width (y)
b_t      = 1.2;     // PCB
button   = [-9.0, 3.5];     // button centre
button_h = 1.5;     // button height above the board (with its cap)
leds_x   = -2.0;    // the 4 LEDs, in a row along y, at this x
tall_h   = 3.0;     // the inductor

function ip5306_mhcd42_size() = [b_l, b_w, b_t];
function ip5306_mhcd42_button() = button;
function ip5306_mhcd42_height() = b_t + tall_h;

pads_l = [["VIN", 3.5], ["GND", -1.0]];                 // left end, y
pads_r = [["VOUT", 4.5], ["GND", 0], ["BAT", -4.5]];    // right end, y

// ======================================================================= board
module ip5306_mhcd42(detail = true) {
    color([0.10, 0.10, 0.12]) translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
    translate([button[0], button[1], b_t]) smd_button([3.6, 3.0], 1.1, 0.4, 1.4);
    translate([4.5, -1.5, b_t]) power_inductor(5.2, tall_h);
    for (p = pads_l) translate([-b_l / 2 + 1.4, p[1] - 4.5, 0]) pad([2.0, 2.4], 0, b_t);
    for (p = pads_r) translate([b_l / 2 - 1.4, p[1], 0]) pad([2.0, 2.6], 0, b_t);
    translate([-b_l / 2 + 4.5, -b_w / 2 + 1.5, 0]) pad([1.6, 1.6], 0, b_t);   // KEY
    if (detail) translate([0, 0, b_t]) {
        translate([1.5, 3.5, 0]) soic(8, 3.9, 1.5);                     // IP5306
        for (i = [0:3]) translate([leds_x, (i - 1.5) * 2.0 - 1.5, 0]) smd_led("0603", "red", 90);
        for (p = [[-5, 6, "c"], [-1, -6, "c"], [8.0, 6.6, "c"], [1.5, -5.5, "c"], [-5.5, 1.0, "r"]])
            translate([p[0], p[1], 0]) smd_passive("0805", p[2], 90);
        for (p = pads_l) translate([-b_l / 2 + 3.0, p[1] - 4.5, 0]) silk(p[0], 0.6, "left");
        for (p = pads_r) translate([b_l / 2 - 2.6, p[1], 0]) silk(p[0], 0.55, "right");
        translate([-b_l / 2 + 6.0, -b_w / 2 + 1.5, 0]) silk("KEY", 0.6, "left");
    }
}

// ===================================================================== holder
module ip5306_mhcd42_holder(h = 1.5) {
    edge_holder([b_l, b_w], b_t, h, 1.2);
}

// ==================================================================== cutouts
// A hole over the button for a printed plunger or a finger, in a lid `wall`
// thick whose inside face is `gap` above the board's top.
module ip5306_mhcd42_button_cutout(gap = 3, wall = 2, d = 4) {
    translate([button[0], button[1], b_t + gap - 0.5]) cylinder(d = d, h = wall + 1, $fn = 32);
}

// A slot over the four LEDs.
module ip5306_mhcd42_led_window(gap = 3, wall = 2) {
    rect_window(leds_x, -1.5, b_t + gap, wall, [1.6, 7.6], 0, 0.3);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") ip5306_mhcd42();
else if (show == "holder") color("#d6a24a") ip5306_mhcd42_holder();
else bo_demo([b_l, b_w], 1.5, b_t + 3.2) {
    ip5306_mhcd42();
    ip5306_mhcd42_holder();
    union() { ip5306_mhcd42_button_cutout(3.2); ip5306_mhcd42_led_window(3.2); }
}
