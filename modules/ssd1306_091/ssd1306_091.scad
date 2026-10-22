// 0.91" OLED, 128 x 32, SSD1306 over I2C (4 pins at the left end: GND VCC
// SCL SDA).
//
//   use <partbin/modules/ssd1306_091/ssd1306_091.scad>
//
//   ssd1306_091();                      the board, with its parts
//   ssd1306_091(detail = false);        only what matters for fit (fast)
//   ssd1306_091(headers = "down");      with the 4-pin header soldered on
//   ssd1306_091_holder();               ledge and low walls around the board
//   ssd1306_091_window(gap, wall);      the screen opening in the front, subtract it
//   ssd1306_091_size()                  [length, height, pcb thickness]
//   ssd1306_091_height()                PCB underside to the front of the glass
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the pins at the left end (-x). For the window,
// the front's inside face is `gap` mm above the glass.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 38.0;    // board length (x)
b_l      = 12.0;    // board height (y)
b_t      = 1.0;     // PCB
pin_end  = 1.6;     // pin centre to the left end
glass    = [30.0, 11.5];     // glass outline
glass_t  = 1.4;     // glass and its tape (total 2.7 with the PCB)
glass_x  = 3.0;     // glass centre (x)
active   = [22.4, 5.6];      // the lit area
active_x = -1.8;    // its centre, from the glass centre (the flex is at the right)

pins_x = -b_w / 2 + pin_end;
pins   = ["GND", "VCC", "SCL", "SDA"];   // top to bottom

function ssd1306_091_size() = [b_w, b_l, b_t];
function ssd1306_091_height() = b_t + glass_t;
function ssd1306_091_active() = [glass_x + active_x, 0];
function ssd1306_091_pin(i) = [pins_x, (1.5 - i) * 2.54];

// ======================================================================= board
module ssd1306_091(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, [for (i = [0:3]) [pins_x, (1.5 - i) * 2.54, 1.0, 1.7]], c_pcb_blue(), 0.5);
    translate([glass_x, 0, b_t]) glass_panel(glass, glass_t, active, [active_x, 0]);
    if (detail) {
        translate([0, 0, b_t]) for (i = [0:3])
            translate([pins_x + 1.6, (1.5 - i) * 2.54, 0]) silk(pins[i], 0.6, "left");
        mirror([0, 0, 1]) for (x = [-8, -4, 0, 4]) translate([x, 2.5, 0]) smd_passive("0603", x < 0 ? "c" : "r");
    }
    if (headers == "down")
        translate([pins_x, 0, 0]) mirror([0, 0, 1]) pin_header(4, below = b_t + 1.5);
    else if (headers == "up")
        translate([pins_x, 0, b_t]) pin_header(4, below = b_t + 1.5);
}

// ===================================================================== holder
module ssd1306_091_holder(h = 1.5) {
    edge_holder([b_w, b_l], b_t, h, 1.2);
}

// ===================================================================== window
module ssd1306_091_window(gap = 0.2, wall = 2, margin = 0.5, flare = 0.6) {
    rect_window(glass_x + active_x, 0, b_t + glass_t + gap, wall,
                [active[0] + 2 * margin, active[1] + 2 * margin], flare);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") ssd1306_091();
else if (show == "holder") color("#d6a24a") ssd1306_091_holder();
else bo_demo([b_w, b_l], 1.5, b_t + glass_t + 0.2) {
    ssd1306_091();
    ssd1306_091_holder();
    ssd1306_091_window();
}
