// 0.96" IPS TFT, 80 x 160, ST7735S (blue board, screen in landscape, 8 pins
// at the top: GND VCC SCL SDA RES DC CS BLK, four corner holes, the flex
// cable folded round the left edge).
//
//   use <partbin/modules/st7735_096.scad>
//
//   st7735_096();                       the board, with its parts
//   st7735_096(detail = false);         only what matters for fit (fast)
//   st7735_096(headers = "down");       with the 8-pin header soldered on
//   st7735_096_holder(h = 2);           posts under its holes, add to the case
//   st7735_096_window(gap, wall);       the screen opening in the front, subtract it
//   st7735_096_size()                   [width, height, pcb thickness]
//   st7735_096_height()                 PCB underside to the front of the glass
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the pins at the top (+y). For the window, the
// front's inside face is `gap` mm above the glass.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ------------------ typical, from the seller's photo scaled by the 2.54 mm pins
b_w      = 29.2;    // board width (x)
b_l      = 24.2;    // board height (y)
b_t      = 1.6;     // PCB
hole_d   = 2.0;
hole_x   = 1.8;     // hole centre to the side edges
hole_y   = 2.4;     // hole centre to the top and bottom edges
pin_top  = 1.8;     // pin centre to the top edge
glass    = [24.0, 13.5];     // glass outline (landscape)
glass_t  = 1.5;     // glass and its tape
glass_x  = 0.4;     // glass centre (x)
active   = [21.7, 10.8];     // the lit area
fold     = 2.0;     // the folded flex sticks out this far past the left edge

holes  = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_w / 2 - hole_x), sy * (b_l / 2 - hole_y)]];
pins_y = b_l / 2 - pin_top;
pins   = ["GND", "VCC", "SCL", "SDA", "RES", "DC", "CS", "BLK"];

function st7735_096_size() = [b_w, b_l, b_t];
function st7735_096_height() = b_t + glass_t;
function st7735_096_active() = [glass_x, 0];
function st7735_096_holes() = holes;
function st7735_096_pin(i) = [(i - 3.5) * 2.54, pins_y];

// ======================================================================= board
module st7735_096(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 3.4]],
            [for (i = [0:7]) [(i - 3.5) * 2.54, pins_y, 1.0, 1.6]]),
        c_pcb_blue(), 0.5);
    translate([glass_x, 0, b_t]) glass_panel(glass, glass_t, active);
    // the flex cable, folded round the left edge
    color([0.12, 0.12, 0.12]) translate([-b_w / 2 - fold, -6, -0.8]) cube([fold + 1.2, 12, b_t + glass_t + 0.8]);
    if (detail) {
        translate([0, 0, b_t]) {
            translate([0, -b_l / 2 + 2.2, 0]) silk("0.96\" 80x160(RGB)IPS", 1.0);
        }
        mirror([0, 0, 1]) {
            for (y = [3, 1, -1, -3]) translate([-5, y, 0]) smd_passive("0603", y == 3 ? "c" : "r");
            translate([-5, -5.5, 0]) sot23(3);
            color([0.85, 0.55, 0.15]) translate([3, -6, 0]) cube([7, 12, 0.15]);   // flex on the back
        }
        // pin names on the back (the front has no room between the pins and the glass)
        for (i = [0:7]) bo_under((i - 3.5) * 2.54, pins_y - 1.6) silk(pins[i], 0.55, "left", rot = 90);
    }
    bo_headers(8, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
module st7735_096_holder(h = 2, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
module st7735_096_window(gap = 0.3, wall = 2, margin = 0.4, flare = 0.8) {
    rect_window(glass_x, 0, b_t + glass_t + gap, wall, [active[0] + 2 * margin, active[1] + 2 * margin], flare);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") st7735_096();
else if (show == "holder") color("#d6a24a") st7735_096_holder();
else bo_demo([b_w, b_l], 2, b_t + glass_t + 0.3) {
    st7735_096();
    st7735_096_holder();
    st7735_096_window();
}
