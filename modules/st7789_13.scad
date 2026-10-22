// 1.3" IPS TFT, 240 x 240, ST7789 (7 pins at the top: GND VCC SCL SDA RES
// DC BLK, no CS pin, four corner holes; the "GMT130" board).
//
//   use <partbin/modules/st7789_13.scad>
//
//   st7789_13();                      the board, with its parts
//   st7789_13(detail = false);        only what matters for fit (fast)
//   st7789_13(headers = "down");      with the 7-pin header soldered on
//   st7789_13_holder(h = 2);          posts under its holes, add to the case
//   st7789_13_window(gap, wall);      the screen opening in the front, subtract it
//   st7789_13_size()                  [width, length, pcb thickness]
//   st7789_13_height()                PCB underside to the front of the glass
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the pins at the top (+y). For the window, the front's inside face is
// `gap` mm above the glass.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ---------- typical; length and holes from a seller's photo (scaled by the pins)
b_w      = 27.8;    // board width (x)
b_l      = 40.3;    // board length (y)
hole_d   = 2.0;
hole_x   = 1.8;     // hole centre to the side edges
hole_top = 2.1;     // top holes, centre to the top edge
hole_bot = 2.4;     // bottom holes, centre to the bottom edge
b_t      = 1.6;     // PCB
pin_top  = 1.4;     // pin centre to the top edge
glass    = [26.2, 29.2];     // glass outline
glass_t  = 1.9;     // glass and its tape
glass_y  = 0.4;     // glass centre (y)
active   = [23.4, 23.4];     // the lit area (240 x 240)
active_y = 1.4;     // its centre, from the glass centre (the flex cable is at the bottom)

holes  = [for (sx = [-1, 1], y = [b_l / 2 - hole_top, -b_l / 2 + hole_bot]) [sx * (b_w / 2 - hole_x), y]];
pins_y = b_l / 2 - pin_top;
pins   = ["GND", "VCC", "SCL", "SDA", "RES", "DC", "BLK"];

function st7789_13_size() = [b_w, b_l, b_t];
function st7789_13_height() = b_t + glass_t;
function st7789_13_active() = [0, glass_y + active_y];
function st7789_13_holes() = holes;
function st7789_13_pin(i) = [(i - 3) * 2.54, pins_y];

// ======================================================================= board
module st7789_13(detail = true, headers = "none") {
    bo_pcb([b_w, b_l], b_t, 0.6, holes, hole_d, 3.4, 7, 0, pins_y, c_pcb_blue());
    translate([0, glass_y, b_t]) glass_panel(glass, glass_t, active, [0, active_y]);
    if (detail) {
        translate([0, 0, b_t]) for (i = [0:6])
            translate([(i - 3) * 2.54, pins_y - 1.5, 0]) silk(pins[i], 0.6, "right", rot = 90);
        // back: regulator and a few parts
        mirror([0, 0, 1]) {
            translate([-5, b_l / 2 - 7, 0]) sot23(5);
            for (x = [0, 3]) translate([x, b_l / 2 - 7, 0]) smd_passive("0603", "c", 90);
            translate([6, b_l / 2 - 7, 0]) sot23(3);
        }
    }
    bo_headers(7, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
module st7789_13_holder(h = 2, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
// The opening over the lit area, `margin` mm bigger all round, in a front
// `wall` mm thick whose inside face is `gap` mm above the glass.
module st7789_13_window(gap = 0.3, wall = 2, margin = 0.4, flare = 1) {
    rect_window(0, glass_y + active_y, b_t + glass_t + gap, wall,
                [active[0] + 2 * margin, active[1] + 2 * margin], flare);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") st7789_13();
else if (show == "holder") color("#d6a24a") st7789_13_holder();
else bo_demo([b_w, b_l], 2, b_t + glass_t + 0.3) {
    st7789_13();
    st7789_13_holder();
    st7789_13_window();
}
