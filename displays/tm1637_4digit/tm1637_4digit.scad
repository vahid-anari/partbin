// TM1637 4-digit 7-segment display module (0.36" digits with a clock colon,
// 4-pin right-angle header at the left end: CLK DIO VCC GND, four holes).
//
//   use <partbin/displays/tm1637_4digit/tm1637_4digit.scad>
//
//   tm1637_4digit();                    the module, with its parts
//   tm1637_4digit(detail = false);      only what matters for fit (fast)
//   tm1637_4digit(headers = "none");    without the header ("angle" = default)
//   tm1637_4digit_holder(h = 3);        posts under its holes, add to the case
//   tm1637_4digit_window(gap, wall);    the opening in the front, subtract it
//   tm1637_4digit_size()                [length, height, pcb thickness]
//   tm1637_4digit_height()              PCB underside to the front of the digits
//
// Where it sits: digits up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the header at the left end (-x). For the
// window, the front's inside face is `gap` mm above the digits.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 42.0;    // board length (x)
b_l      = 24.0;    // board height (y)
b_t      = 1.6;     // PCB
hole_d   = 2.2;
hole_in  = 2.0;     // hole centre to the two nearest edges
digits   = [30.1, 14.0];     // the display block
digits_h = 7.2;     // its height above the PCB
digits_x = 1.5;     // its centre (x)
pin_end  = 1.6;     // pin centre to the left end

holes  = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_w / 2 - hole_in), sy * (b_l / 2 - hole_in)]];
pins_x = -b_w / 2 + pin_end;
pins   = ["CLK", "DIO", "VCC", "GND"];   // top to bottom

function tm1637_4digit_size() = [b_w, b_l, b_t];
function tm1637_4digit_height() = b_t + digits_h;
function tm1637_4digit_holes() = holes;

// ======================================================================= board
module tm1637_4digit(detail = true, headers = "angle") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 3.6]],
            [for (i = [0:3]) [pins_x, (1.5 - i) * 2.54, 1.0, 1.7]]),
        c_pcb_blue(), 0.5);
    translate([digits_x, 0, b_t]) seg7_display(4, digits, digits_h);
    if (detail) {
        mirror([0, 0, 1]) {
            translate([digits_x, 0, 0]) soic(20, 7.5, 2.4);
            for (x = [-6, 9]) translate([digits_x + x, 7, 0]) smd_passive("0805", "c");
        }
        translate([0, 0, b_t]) for (i = [0:3])
            translate([pins_x + 2.0, (1.5 - i) * 2.54, 0]) silk(pins[i], 0.55, "left");
    }
    if (headers == "angle")
        translate([pins_x, 0, b_t]) mirror([1, 0, 0]) pin_header_angle(4, 6);
}

// ===================================================================== holder
// Posts under the four holes, `h` mm tall (the chip on the back is ~2.5 mm).
module tm1637_4digit_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
module tm1637_4digit_window(gap = 0.2, wall = 2, margin = 0.2) {
    rect_window(digits_x, 0, b_t + digits_h + gap, wall,
                [digits[0] + 2 * margin, digits[1] + 2 * margin], 0, 0.3);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") tm1637_4digit();
else if (show == "holder") color("#d6a24a") tm1637_4digit_holder();
else bo_demo([b_w, b_l], 3, b_t + digits_h + 0.2) {
    tm1637_4digit();
    tm1637_4digit_holder();
    tm1637_4digit_window();
}
