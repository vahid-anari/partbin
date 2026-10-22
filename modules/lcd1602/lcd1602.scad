// LCD1602 character display (16 x 2, HD44780), optionally with the I2C
// "backpack" (PCF8574) soldered on the back.
//
//   use <partbin/modules/lcd1602/lcd1602.scad>
//
//   lcd1602();                        the display with the I2C backpack, green screen (default)
//   lcd1602(backpack = false);        without the backpack
//   lcd1602(screen = "blue");         the blue version
//   lcd1602(detail = false);          only what matters for fit (fast)
//   lcd1602_holder(h);                posts under its four holes, add to the case
//   lcd1602_window(gap, wall);        the opening in the front, subtract it
//   lcd1602_size()                    [width, height, pcb thickness]
//   lcd1602_height()                  PCB underside to the front of the frame
//   lcd1602_behind(backpack)          how far it reaches behind the PCB
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the 16 pins at the top (+y). For the window, the front's inside face
// is `gap` mm above the metal frame.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ---------------------------------- typical, from a manufacturer's drawing
b_w      = 80.0;    // board width (x)
b_l      = 36.0;    // board height (y)
b_t      = 1.6;     // PCB
hole_d   = 2.5;
holes_at = [75.0, 31.0];     // hole centres, x and y apart
frame    = [71.2, 24.2];     // metal frame outline
frame_h  = 7.4;     // frame height above the PCB
frame_y  = -1.0;    // frame centre (y)
view     = [66.0, 16.0];     // viewing area (the window in the frame)
active   = [56.2, 11.0];     // where the characters are
pin1_x   = 8.0;     // board's left edge to pin 1
pin_top  = 2.5;     // pin centre to the top edge
// I2C backpack
bp       = [41.6, 19.3];     // its PCB
bp_gap   = 2.5;     // between the two PCBs (the header's plastic)

holes  = [for (sx = [-1, 1], sy = [-1, 1]) [sx * holes_at[0] / 2, sy * holes_at[1] / 2]];
pins_y = b_l / 2 - pin_top;
pins_x0 = -b_w / 2 + pin1_x;          // pin 1
pins_xc = pins_x0 + 7.5 * 2.54;       // middle of the 16 pins

function lcd1602_size() = [b_w, b_l, b_t];
function lcd1602_height() = b_t + frame_h;
function lcd1602_behind(backpack = true) = backpack ? bp_gap + 1.6 + 6.5 : 1.5;
function lcd1602_holes() = holes;
function lcd1602_pin(i) = [pins_x0 + (i - 1) * 2.54, pins_y];   // i = 1 ... 16

// ======================================================================= board
module lcd1602(backpack = true, detail = true, screen = "green") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 5.0]],
            [for (i = [0:15]) [pins_x0 + i * 2.54, pins_y, 1.0, 1.7]]),
        [0.08, 0.40, 0.16], 0.5);
    translate([0, frame_y, b_t]) {
        // metal frame with the glass inside
        color(c_tin()) difference() {
            translate([-frame[0] / 2, -frame[1] / 2, 0]) cube([frame[0], frame[1], frame_h]);
            translate([-view[0] / 2, -view[1] / 2, frame_h - 1.4]) cube([view[0], view[1], 2]);
        }
        color(screen == "blue" ? [0.10, 0.22, 0.75] : [0.52, 0.70, 0.12]) translate([-view[0] / 2 + 0.01, -view[1] / 2 + 0.01, frame_h - 1.6]) cube([view[0] - 0.02, view[1] - 0.02, 0.3]);
        // two lines of 16 character cells
        if (detail) color(screen == "blue" ? [0.25, 0.40, 0.95] : [0.60, 0.80, 0.18]) for (r = [0, 1], c = [0:15])
            translate([-active[0] / 2 + c * 3.55, (r == 0 ? 0.5 : -active[1] / 2), frame_h - 1.28])
                cube([2.95, 5.2, 0.02]);
    }
    if (detail) {
        // back: the two controller blobs
        color([0.05, 0.05, 0.05]) for (x = [-18, 14]) translate([x, -2, -1.2]) cylinder(d = 9, h = 1.2, $fn = 32);
        translate([0, 0, b_t]) for (i = [1, 16]) translate([pins_x0 + (i - 1) * 2.54, pins_y - 1.6, 0]) silk(str(i), 0.8);
    }
    if (backpack) translate([pins_xc, pins_y, 0]) mirror([0, 0, 1]) {
        // header between the boards
        color(c_plastic()) translate([-20.32, -1.27, 0]) cube([40.64, 2.54, bp_gap]);
        color(c_gold()) for (i = [0:15]) translate([(i - 7.5) * 2.54 - 0.32, -0.32, -b_t - 0.5]) cube([0.64, 0.64, b_t + bp_gap + 1.6 + 1.0]);
        // its PCB, hanging down from the pin row
        translate([0, -bp[1] / 2 + 1.5, bp_gap]) {
            color([0.10, 0.10, 0.12]) translate([-bp[0] / 2, -bp[1] / 2, 0]) cube([bp[0], bp[1], 1.6]);
            translate([0, 0, 1.6]) {
                translate([-2, -2.5, 0]) soic(16, 7.5, 2.4);
                translate([12, -3, 0]) trimpot(6.6, 4.5);
                // 4-pin header at the left end, pointing out (GND VCC SDA SCL)
                translate([-bp[0] / 2 + 1.5, -4, 0]) mirror([1, 0, 0]) pin_header_angle(4, 6);
                // backlight jumper
                translate([bp[0] / 2 - 2, 4, 0]) rotate([0, 0, 90]) pin_header(2, pin = 8, spacer = 2.5, below = 0);
            }
        }
    }
}

// ===================================================================== holder
// Posts under the four holes. With the backpack, make them tall enough to
// clear it (lcd1602_behind(true) + 1, about 12 mm), or mount the holes on
// posts coming from the front instead.
module lcd1602_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
// The opening over the viewing area (or bigger by `margin`), in a front
// `wall` mm thick whose inside face is `gap` mm above the metal frame.
module lcd1602_window(gap = 0.3, wall = 2, margin = 0, flare = 0.8) {
    rect_window(0, frame_y, b_t + frame_h + gap, wall,
                [view[0] + 2 * margin, view[1] + 2 * margin], flare);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder | backpack
if (show == "board") lcd1602();
else if (show == "backpack") lcd1602(backpack = true);
else if (show == "bare") lcd1602(backpack = false);
else if (show == "holder") color("#d6a24a") lcd1602_holder();
else bo_demo([b_w, b_l], 12, b_t + frame_h + 0.3) {
    lcd1602();
    lcd1602_holder(12);
    lcd1602_window();
}
