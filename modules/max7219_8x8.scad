// MAX7219 single 8 x 8 LED matrix module (the DIP kit: a MAX7219 DIP-24
// under the matrix, the matrix plugged into two socket strips, a 5-pin
// header at each end: IN and OUT).
//
//   use <partbin/modules/max7219_8x8.scad>
//
//   max7219_8x8();                      the module, with its parts
//   max7219_8x8(detail = false);        only what matters for fit (fast)
//   max7219_8x8(headers = "none");      without the end headers ("angle" = default)
//   max7219_8x8_holder();               ledge and low walls around the board
//   max7219_8x8_window(gap, wall);      the window in the front, subtract it
//   max7219_8x8_size()                  [length, height, pcb thickness]
//   max7219_8x8_height()                PCB underside to the front of the LEDs
//
// Where it sits: LEDs up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the IN end at +x. For the window, the front's
// inside face is `gap` mm above the LEDs.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 50.0;    // board length (x)
b_l      = 32.0;    // board height (y)
b_t      = 1.6;     // PCB
socket_h = 8.5;     // the socket strips the matrix plugs into
matrix_h = 7.0;     // the matrix block
pin_in   = 1.6;     // header pads, from the board's end

led_h = socket_h + matrix_h;   // front of the LEDs to the front of the PCB

function max7219_8x8_size() = [b_w, b_l, b_t];
function max7219_8x8_height() = b_t + led_h;

// ======================================================================= board
module max7219_8x8(detail = true, headers = "angle") {
    color([0.70, 0.12, 0.12]) translate([-b_w / 2, -b_l / 2, 0]) cube([b_w, b_l, b_t]);
    translate([0, 0, b_t + socket_h]) led_matrix(32, matrix_h);
    translate([0, 0, b_t]) {
        // socket strips under the matrix's two rows of legs
        color(c_plastic()) for (s = [-1, 1]) translate([s * 13.3 - 1.27, -10.16, 0]) cube([2.54, 20.32, socket_h]);
        if (detail) {
            // the MAX7219 (DIP-24) between the strips
            color(c_chip()) translate([-15.2, -3.3, 0.5]) cube([30.4, 6.6, 3.3]);
            translate([-b_w / 2 + 5.5, 7, 0]) elco(5, 7);
            translate([-b_w / 2 + 5.5, -6, 0]) smd_passive("1206", "c", 90);
            translate([b_w / 2 - 5.5, -7, 0]) smd_passive("1206", "r", 90);
        }
    }
    color(c_gold()) for (s = [-1, 1], j = [0:4])
        translate([s * (b_w / 2 - pin_in), (j - 2) * 2.54, -0.02]) cylinder(d = 1.6, h = b_t + 0.04, $fn = 16);
    if (headers == "angle") for (s = [-1, 1])
        translate([s * (b_w / 2 - pin_in), 0, b_t]) mirror([s < 0 ? 1 : 0, 0, 0]) pin_header_angle(5, 6);
}

// ===================================================================== holder
module max7219_8x8_holder(h = 3) {
    edge_holder([b_w, b_l], b_t, h, 1.5);
}

// ===================================================================== window
// The opening over the LEDs in a front `wall` mm thick whose inside face is
// `gap` mm above the LEDs; `lip` mm overlaps the matrix's edge.
module max7219_8x8_window(gap = 0, wall = 2, lip = 1) {
    rect_window(0, 0, b_t + led_h + gap, wall, [32 - 2 * lip, 32 - 2 * lip], 0, 0.2);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") max7219_8x8();
else if (show == "holder") color("#d6a24a") max7219_8x8_holder();
else bo_demo([b_w, b_l], 3, b_t + led_h + 0.2) {
    max7219_8x8();
    max7219_8x8_holder();
    max7219_8x8_window(gap = 0.2);
}
