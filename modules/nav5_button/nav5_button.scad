// Five-direction navigation button module (blue: a 5-way switch, SET and
// RST tact buttons, 8-pin right-angle header COM UP DWN LFT RHT MID SET RST,
// four corner holes).
//
//   use <partbin/modules/nav5_button/nav5_button.scad>
//
//   nav5_button();                      the module, with its parts
//   nav5_button(headers = "none");      without the header ("angle" = default)
//   nav5_button_panel_cutout(gap, wall) holes for the stick and the two buttons
//   nav5_button_holder(h = 3);          posts under its holes
//   nav5_button_size()                  [length, width, pcb thickness]
//
// Where it sits: the switch up, the board centred on x = y = 0, its underside
// at z = 0, the header along the bottom edge (pins point -y).

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ------------------------------------------------------------------- typical
b_l      = 30.0;    // length (x)
b_w      = 24.0;    // width (y)
b_t      = 1.6;
hole_d   = 3.0;
hole_in  = 2.5;
nav      = [-3.0, 2.0];      // the 5-way switch
buttons  = [[7.0, 6.0], [7.0, -1.5]];   // RST, SET
pins_y   = -b_w / 2 + 1.6;
pins     = ["COM", "UP", "DWN", "LFT", "RHT", "MID", "SET", "RST"];

holes = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_l / 2 - hole_in), sy * (b_w / 2 - hole_in)]];

function nav5_button_size() = [b_l, b_w, b_t];
function nav5_button_stick() = nav;

module nav5_button(detail = true, headers = "angle") {
    pcb([b_l, b_w], b_t, concat([for (h = holes) [h[0], h[1], hole_d, 4.8]], [for (i = [0:7]) [(i - 3.5) * 2.54, pins_y, 1.0, 1.6]]),
        c_pcb_blue(), 0.6);
    translate([nav[0], nav[1], b_t]) nav5_switch();
    for (b = buttons) translate([b[0], b[1], b_t]) smd_button([4.2, 3.2], 1.5, 0.5, 1.5);
    if (detail) translate([0, 0, b_t]) for (i = [0:7]) translate([(i - 3.5) * 2.54, pins_y + 1.5, 0]) silk(pins[i], 0.5, "left", rot = 90);
    if (headers == "angle") translate([0, pins_y, b_t]) rotate([0, 0, -90]) pin_header_angle(8, 6);
}

// Holes in a front panel `wall` thick whose inside face is `gap` above the
// board's top: one for the stick, two small ones for SET and RST.
module nav5_button_panel_cutout(gap = 5.6, wall = 2, d = 5, d_btn = 2.5) {
    translate([nav[0], nav[1], b_t + gap - 0.5]) cylinder(d = d, h = wall + 1, $fn = 32);
    for (b = buttons) translate([b[0], b[1], b_t + gap - 0.5]) cylinder(d = d_btn, h = wall + 1, $fn = 24);
}

module nav5_button_holder(h = 3, style = "peg") { bo_mounts(holes, hole_d, b_t, h, style); }

show = "demo";  // demo | board | holder
if (show == "board") nav5_button();
else if (show == "holder") color("#d6a24a") nav5_button_holder();
else bo_demo([b_l, b_w], 3, b_t + 5.6) { nav5_button(); nav5_button_holder(); nav5_button_panel_cutout(); }
