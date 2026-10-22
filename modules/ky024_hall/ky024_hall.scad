// KY-024 linear hall sensor module (red, 4-pin right-angle header: A0 G +
// D0, a 49E hall sensor on bent legs at the far end, a blue 3296 trimmer,
// an LM393, two LEDs, one mounting hole).
//
//   use <partbin/modules/ky024_hall/ky024_hall.scad>
//
//   ky024_hall();                       the module, with its parts
//   ky024_hall(sensor = "up");          the hall sensor standing up instead of bent over
//   ky024_hall(headers = "none");       without the header ("angle" = default)
//   ky024_hall_holder(h = 3);           a post under its hole + a ledge
//   ky024_hall_size()                   [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the header at the left end (pins point -x),
// the hall sensor at the right end.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ------------------------------------------------------------------- typical
b_l      = 32.0;    // board length (x)
b_w      = 14.5;    // board width (y)
b_t      = 1.6;
hole     = [-6.5, 0];
hole_d   = 3.0;
pins_x   = -b_l / 2 + 1.6;
pins     = ["D0", "+", "G", "A0"];   // top to bottom

function ky024_hall_size() = [b_l, b_w, b_t];

module ky024_hall(detail = true, headers = "angle", sensor = "bent") {
    pcb([b_l, b_w], b_t, concat([[hole[0], hole[1], hole_d, 4.8]], [for (i = [0:3]) [pins_x, (1.5 - i) * 2.54, 1.0, 1.6]],
                               [for (i = [-1, 0, 1]) [b_l / 2 - 2.0, i * 1.27, 0.8, 1.3]]),
        [0.72, 0.10, 0.12], 0.6);
    translate([b_l / 2 - 2.0, 0, b_t]) rotate([0, 0, -90]) to92s(sensor == "bent" ? 2.0 : 6.0, sensor == "bent");
    translate([-0.5, 3.0, b_t]) trimpot_3296();
    if (detail) translate([0, 0, b_t]) {
        translate([3.0, -3.0, 0]) soic(8, 3.9, 1.5);
        for (p = [[8.5, -4.5, "r"], [8.5, 1.0, "r"], [-9.5, 4.8, "r"], [-3, -5.5, "c"]]) translate([p[0], p[1], 0]) smd_passive("0805", p[2], 90);
        for (p = [[-9.5, -4.8], [10.5, 4.8]]) translate([p[0], p[1], 0]) smd_led("0805", "red", 90);
        for (i = [0:3]) translate([pins_x + 1.6, (1.5 - i) * 2.54, 0]) silk(pins[i], 0.6, "left");
    }
    if (headers == "angle") translate([pins_x, 0, b_t]) mirror([1, 0, 0]) pin_header_angle(4, 6);
}

module ky024_hall_holder(h = 3, style = "peg") {
    bo_mounts([hole], hole_d, b_t, h, style);
    translate([b_l / 2 - 6, -b_w / 2 + 2, -h]) cube([3, b_w - 4, h]);   // ledge under the sensor end
}

show = "demo";  // demo | board | holder
if (show == "board") ky024_hall();
else if (show == "holder") color("#d6a24a") ky024_hall_holder();
else { ky024_hall(); color("#d6a24a") ky024_hall_holder(); }
