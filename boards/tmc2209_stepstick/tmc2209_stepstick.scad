// TMC2209 stepper driver, StepStick format (15.2 x 20.3 mm, two rows of 8
// pins 12.7 mm apart, the chip underneath, a heatsink stuck on top, a
// trimmer for the current).
//
//   use <partbin/boards/tmc2209_stepstick/tmc2209_stepstick.scad>
//
//   tmc2209_stepstick();                  with its pins and the heatsink
//   tmc2209_stepstick(heatsink = false);
//   tmc2209_stepstick_socket()            two 8-pin female headers it plugs into
//   tmc2209_stepstick_size()              [width, length, pcb thickness]
//
// Where it sits: the heatsink up, the board centred on x = y = 0, its
// underside at z = 0, the pin rows along y. Leave air above the heatsink.

use <../../lib/parts.scad>

// ---------------------------------------------- StepStick standard + typical
b_w      = 15.2;
b_l      = 20.3;
b_t      = 1.6;
rows     = 12.7;
sink     = [9.0, 9.0, 6.0];

function tmc2209_stepstick_size() = [b_w, b_l, b_t];
function tmc2209_stepstick_height(heatsink = true) = b_t + (heatsink ? sink[2] : 1.0);

module tmc2209_stepstick(heatsink = true) {
    pcb([b_w, b_l], b_t, [for (s = [-1, 1], i = [0:7]) [s * rows / 2, (i - 3.5) * 2.54, 1.0, 1.6]], [0.45, 0.10, 0.55], 0.3);
    mirror([0, 0, 1]) translate([0, 1, 0]) qfn(5, 0.9, 7, label = "2209");
    translate([0, 0, b_t]) translate([2.0, -7.0, 0]) color([0.85, 0.85, 0.85]) cylinder(d = 3.0, h = 1.5, $fn = 24);   // current trimmer
    if (heatsink) translate([0, 1, b_t]) color([0.85, 0.15, 0.15]) {
        translate([-sink[0] / 2, -sink[1] / 2, 0]) cube([sink[0], sink[1], 1.5]);
        for (i = [0:4]) translate([-sink[0] / 2 + i * 2.1, -sink[1] / 2, 1.5]) cube([0.8, sink[1], sink[2] - 1.5]);
    }
    // pins, down
    for (s = [-1, 1]) translate([s * rows / 2, 0, 0]) mirror([0, 0, 1]) pin_header(8, below = b_t + 1.5);
}

// Two 8-pin female sockets for it, standing on the base board at z = 0
// (the driver then sits `h` = 8.5 mm higher).
module tmc2209_stepstick_socket(h = 8.5) {
    color(c_plastic()) for (s = [-1, 1]) translate([s * rows / 2 - 1.27, -4 * 2.54, 0]) difference() {
        cube([2.54, 8 * 2.54, h]);
        for (i = [0:7]) translate([1.27 - 0.5, 1.27 + i * 2.54 - 0.5, 1]) cube([1, 1, h]);
    }
}

show = "demo";  // demo | board
if (show == "board") tmc2209_stepstick();
else { tmc2209_stepstick_socket(); translate([0, 0, 8.5 + 2.5]) tmc2209_stepstick(); }
