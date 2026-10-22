// MAX7219 "FC-16" 4-in-1 LED matrix board: four 8 x 8 matrices (32 x 8
// LEDs) on a 128 x 32 mm board, a MAX7219 under each matrix on the back,
// a 5-pin header at each end (IN and OUT). Several boards can sit end to end.
//
//   use <partbin/modules/max7219_fc16.scad>
//
//   max7219_fc16();                      one board, with its parts
//   max7219_fc16(boards = 2);            two boards end to end (64 x 8 LEDs)
//   max7219_fc16(leds = "red");          LED colour: green (yours), red, blue, white, yellow
//   max7219_fc16(detail = false);        only what matters for fit (fast)
//   max7219_fc16(headers = "none");      without the end headers ("angle" = default)
//   max7219_fc16_holder(boards = 2);     ledge and low walls around the boards
//   max7219_fc16_window(gap, wall);      the window in the front, subtract it
//   max7219_fc16_size(boards)            [length, height, pcb thickness]
//   max7219_fc16_height()                PCB underside to the front of the LEDs
//
// Where it sits: LEDs up, the boards centred on x = y = 0, their underside at
// z = 0, the long side along x, the IN end at +x. The board has no mounting
// holes: the holder locates it and the case presses it against the front.
// For the window, the front's inside face is `gap` mm above the LEDs.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ---------------------------------- typical (same as the dotmatrix case)
b_w      = 128.0;   // one board (x)
b_l      = 32.0;    // its height (y)
b_t      = 1.6;     // PCB
led_h    = 9.0;     // front of the LEDs to the front of the PCB
matrix_h = 7.0;     // the matrix block itself (it stands on its legs)
behind   = 2.7;     // chips on the back
pin_in   = 1.5;     // header pads, from the board's end

function max7219_fc16_size(boards = 1) = [b_w * boards, b_l, b_t];
function max7219_fc16_height() = b_t + led_h;
function max7219_fc16_behind() = behind;

// ======================================================================= board
module max7219_fc16(boards = 1, detail = true, headers = "angle", leds = "green") {
    for (k = [0:boards - 1]) translate([(k - (boards - 1) / 2) * b_w, 0, 0]) {
        color([0.12, 0.12, 0.13]) translate([-b_w / 2, -b_l / 2, 0]) cube([b_w, b_l, b_t]);
        for (i = [0:3]) translate([(i - 1.5) * 32, 0, b_t + led_h - matrix_h]) {
            led_matrix(32, matrix_h, led_color(leds));
            if (detail) color(c_tin()) for (x = [-12, 12], j = [0:7])   // legs under the block
                translate([x - 0.25 + (x < 0 ? -2.5 : 2.5) * 0, (j - 3.5) * 2.54 * 1.2 - 0.25, -(led_h - matrix_h)]) cube([0.5, 0.5, led_h - matrix_h]);
        }
        // back: a MAX7219 (SOIC-24 wide) and two capacitors per matrix
        if (detail) for (i = [0:3]) translate([(i - 1.5) * 32, 0, 0]) mirror([0, 0, 1]) {
            soic(24, 7.5, 2.6, rot = 90);
            translate([7, 9, 0]) smd_passive("0805", "c", 90);
            translate([-7, 9, 0]) smd_passive("0805", "r", 90);
        }
        // pads at both ends
        color(c_gold()) for (s = [-1, 1], j = [0:4])
            translate([s * (b_w / 2 - pin_in), (j - 2) * 2.54, -0.02]) cylinder(d = 1.6, h = b_t + 0.04, $fn = 16);
    }
    // end headers on the back, pointing outwards (only at the two outer ends)
    if (headers == "angle") for (s = [-1, 1])
        translate([s * (boards * b_w / 2 - pin_in), 0, 0]) mirror([0, 0, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) pin_header_angle(5, 6);
}

// ===================================================================== holder
// A ledge under the boards' edges, `h` mm tall (room for the chips), with
// low walls around them. The ends get extra room for the headers.
module max7219_fc16_holder(boards = 1, h = 4) {
    edge_holder([b_w * boards, b_l], b_t, h, 1.5);
}

// ===================================================================== window
// The opening over the LEDs in a front `wall` mm thick whose inside face is
// `gap` mm above the LEDs; `lip` mm of the front overlaps the matrices' edges.
module max7219_fc16_window(boards = 1, gap = 0, wall = 2, lip = 1) {
    rect_window(0, 0, b_t + led_h + gap, wall, [b_w * boards - 2 * lip, b_l - 2 * lip], 0, 0.2);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") max7219_fc16();
else if (show == "holder") color("#d6a24a") max7219_fc16_holder();
else bo_demo([b_w, b_l], 4, b_t + led_h + 0.2) {
    max7219_fc16();
    max7219_fc16_holder();
    max7219_fc16_window(gap = 0.2);
}
