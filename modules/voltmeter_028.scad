// 0.28" 3-digit LED voltmeter, DC 0-100 V, 3 wires (red: power, yellow:
// measure, black: GND). A small green board with the display and a mounting
// ear with a hole at each end. Yours are red and green.
//
//   use <partbin/modules/voltmeter_028.scad>
//
//   voltmeter_028();                     the meter (red digits)
//   voltmeter_028(seg = "green");
//   voltmeter_028_panel_cutout(wall)     the window for a front panel it sits behind
//   voltmeter_028_holder(h = 3);         two posts for its ears
//   voltmeter_028_size()                 [length with the ears, width, thickness]
//
// Where it sits: digits up, the meter centred on x = y = 0, the PCB's
// underside at z = 0, the long side along x. Typical sizes.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ------------------------------------------------------------------- typical
b_l      = 30.0;    // with the ears
b_w      = 10.6;
b_t      = 1.0;
body     = [22.8, 10.2];
body_h   = 6.0;
ear_hole = [13.0, 0];
hole_d   = 2.2;

function voltmeter_028_size() = [b_l, b_w, b_t + body_h];

module voltmeter_028(seg = "red") {
    pcb([b_l, b_w], b_t, [for (s = [-1, 1]) [s * ear_hole[0], 0, hole_d, 3.2]], [0.20, 0.60, 0.30], 0.4);
    translate([0, 0, b_t]) seg7_display(3, body, body_h, false, seg7_color(seg));
    // the three wires leaving the back
    for (i = [0:2]) color(["red", "yellow", "black"][i]) translate([-2 + i * 2, 0, 0]) mirror([0, 0, 1]) cylinder(d = 1.2, h = 15, $fn = 12);
}

// The window for the digits in a front panel `wall` thick that touches the
// meter's face (or set `gap`).
module voltmeter_028_panel_cutout(wall = 2, gap = 0, margin = 0.3) {
    rect_window(0, 0, b_t + body_h + gap, wall, [body[0] + 2 * margin, body[1] + 2 * margin], 0, 0.3);
}

module voltmeter_028_holder(h = 3, style = "screw") { bo_mounts([for (s = [-1, 1]) [s * ear_hole[0], 0]], hole_d, b_t, h, style); }

show = "demo";
voltmeter_028();
