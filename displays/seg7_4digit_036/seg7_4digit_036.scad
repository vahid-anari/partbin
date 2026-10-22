// Bare 4-digit 7-segment LED display, 0.36" (3641-style, common cathode,
// 12 pins in two rows of 6 underneath). Sold in red, green, blue,
// white and other colours.
//
//   use <partbin/displays/seg7_4digit_036/seg7_4digit_036.scad>
//
//   seg7_4digit_036();                    the display (red)
//   seg7_4digit_036(seg = "blue");        segment colour: red, green, blue, white, yellow
//   seg7_4digit_036_holder();             a frame around it, add to the case
//   seg7_4digit_036_window(gap, wall);    the opening in the front, subtract it
//   seg7_4digit_036_size()                [length, height, body height]
//   seg7_4digit_036_pin(i)                [x, y] of pin i (1 ... 12)
//
// Where it sits: digits up, the body centred on x = y = 0, its underside at
// z = 0 (the pins go down), the long side along x. Pin 1 is bottom left
// (-x, -y), counting along the bottom row and back along the top row.

use <../../lib/parts.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
size     = [30.1, 14.0];   // body
h        = 7.2;     // body height
rows     = 10.16;   // between the two pin rows
pin_len  = 6.0;     // how far the pins stick out below

function seg7_4digit_036_size() = [size[0], size[1], h];
function seg7_4digit_036_pin(i) =
    i <= 6 ? [(i - 3.5) * 2.54, -rows / 2] : [(9.5 - i) * 2.54, rows / 2];

// ===================================================================== display
module seg7_4digit_036(seg = "red") {
    // the bare display has a dark face and no clock colon (dots only)
    difference() {
        seg7_display(4, size, h, false, seg7_color(seg));
    }
    color([0.15, 0.15, 0.15]) translate([-size[0] / 2, -size[1] / 2, h - 0.06]) cube([size[0], size[1], 0.02]);
    color(c_tin()) for (i = [1:12]) let(p = seg7_4digit_036_pin(i))
        translate([p[0] - 0.25, p[1] - 0.25, -pin_len]) cube([0.5, 0.5, pin_len]);
}

// ===================================================================== holder
// A frame `h_frame` tall that the display sits in, with a little play.
module seg7_4digit_036_holder(h_frame = 4, wall = 1.2, clear = 0.2) {
    difference() {
        translate([-size[0] / 2 - clear - wall, -size[1] / 2 - clear - wall, 0]) cube([size[0] + 2 * (clear + wall), size[1] + 2 * (clear + wall), h_frame]);
        translate([-size[0] / 2 - clear, -size[1] / 2 - clear, -1]) cube([size[0] + 2 * clear, size[1] + 2 * clear, h_frame + 2]);
    }
}

// ===================================================================== window
// The opening over the digits in a front `wall` thick whose inside face is
// `gap` above the display (0 = touching; or let the display poke through).
module seg7_4digit_036_window(gap = 0, wall = 2, margin = 0.2) {
    rect_window(0, 0, h + gap, wall, [size[0] + 2 * margin, size[1] + 2 * margin], 0, 0.3);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") seg7_4digit_036();
else if (show == "holder") color("#d6a24a") seg7_4digit_036_holder();
else {
    for (i = [0:3]) translate([(i - 1.5) * 33, 0, 0]) seg7_4digit_036(["red", "green", "blue", "white"][i]);
}
