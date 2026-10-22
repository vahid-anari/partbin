// KY-040 rotary encoder module (EC11 encoder with push switch, 5-pin
// right-angle header: CLK DT SW + GND, two mounting holes).
//
//   use <partbin/modules/ky040_encoder.scad>
//
//   ky040_encoder();                     the module, with its parts
//   ky040_encoder(knob = true);          with the knob from the kit
//   ky040_encoder(headers = "none");     without the header ("angle" = default)
//   ky040_encoder_panel_cutout(gap, wall) the hole for the shaft in the front panel
//   ky040_encoder_holder(h = 3);         posts under its holes
//   ky040_encoder_size()                 [length, width, pcb thickness]
//
// Where it sits: the shaft up, the board centred on x = y = 0, its underside
// at z = 0, the long side along x, the header at the right end (pins point +x).
// The encoder's threaded bushing (7 mm) can go through a panel up to ~5 mm
// thick and be held with its nut, or the board can sit on posts behind it.

use <../lib/parts.scad>
use <../lib/breakout.scad>

// ------------------------------------------------------------------- typical
b_l      = 31.5;    // length (x)
b_w      = 19.0;    // width (y)
b_t      = 1.6;
enc_x    = -3.5;    // encoder centre (x)
hole_d   = 3.0;
holes    = [[-b_l / 2 + 3.0, 7.0], [-b_l / 2 + 3.0, -7.0]];
pins_x   = b_l / 2 - 1.6;
pins     = ["CLK", "DT", "SW", "+", "GND"];   // top to bottom
shaft    = 20;      // shaft length above the encoder body
body_h   = 6.5;
bush_h   = 7;

function ky040_encoder_size() = [b_l, b_w, b_t];
function ky040_encoder_shaft() = [enc_x, 0];
function ky040_encoder_height() = b_t + body_h + shaft;

module ky040_encoder(detail = true, headers = "angle", knob = false) {
    pcb([b_l, b_w], b_t, concat([for (h = holes) [h[0], h[1], hole_d, 4.8]], [for (i = [0:4]) [pins_x, (2 - i) * 2.54, 1.0, 1.6]]),
        [0.10, 0.10, 0.12], 0.6);
    translate([enc_x, 0, b_t]) ec11(shaft, bush_h);
    if (knob) color([0.15, 0.15, 0.15]) translate([enc_x, 0, b_t + body_h + shaft - 12]) difference() {
        cylinder(d = 15, h = 13, $fn = 48);
        for (a = [0:15:359]) rotate([0, 0, a]) translate([7.5, 0, -1]) cylinder(d = 1, h = 15, $fn = 8);
    }
    if (detail) translate([0, 0, b_t]) {
        for (y = [-5, -2, 1]) translate([8.5, y, 0]) smd_passive("0805", "r", 90);
        for (i = [0:4]) translate([pins_x - 1.6, (2 - i) * 2.54, 0]) silk(pins[i], 0.6, "right");
    }
    if (headers == "angle") translate([pins_x, 0, b_t]) pin_header_angle(5, 6);
}

// The hole for the bushing in a front panel `wall` thick whose inside face
// is `gap` above the board's top (gap up to the encoder body: 6.5 mm).
module ky040_encoder_panel_cutout(gap = 6.5, wall = 2, d = 7.4) {
    translate([enc_x, 0, b_t + gap - 0.5]) cylinder(d = d, h = wall + 1, $fn = 40);
}

module ky040_encoder_holder(h = 3, style = "peg") { bo_mounts(holes, hole_d, b_t, h, style); }

show = "demo";  // demo | board | holder
if (show == "board") ky040_encoder();
else if (show == "holder") color("#d6a24a") ky040_encoder_holder();
else bo_demo([b_l, b_w], 3, b_t + body_h) { ky040_encoder(knob = true); ky040_encoder_holder(); ky040_encoder_panel_cutout(); }
