// 1.8" TFT, 128 x 160, ST7735 (the red board with a microSD slot on the
// back, 8 pins at the top: VCC GND CS RESET A0 SDA SCK LED, 4 SD pads at the
// bottom, four mounting holes).
//
//   use <partbin/modules/st7735_18/st7735_18.scad>
//
//   st7735_18();                      the board, with its parts
//   st7735_18(detail = false);        only what matters for fit (fast)
//   st7735_18(headers = "down");      with the 8-pin header soldered on
//   st7735_18_holder(h = 4);          posts under its holes, add to the case
//   st7735_18_window(gap, wall);      the screen opening in the front, subtract it
//   st7735_18_sd_cutout(wall);        a slot in the bottom wall for the microSD card
//   st7735_18_size()                  [width, length, pcb thickness]
//   st7735_18_height()                PCB underside to the front of the glass
//
// Where it sits: screen up, the board centred on x = y = 0, its underside at
// z = 0, the pins at the top (+y). For the window, the front's inside face is
// `gap` mm above the glass.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 34.5;    // board width (x)
b_l      = 58.0;    // board length (y)
b_t      = 1.6;     // PCB
hole_d   = 3.0;
hole_in  = 2.5;     // hole centre to the two nearest edges
pin_top  = 1.6;     // pin centre to the top edge
glass    = [34.0, 45.8];     // glass outline
glass_t  = 2.6;     // glass and its tape
glass_y  = -1.0;    // glass centre (y)
active   = [28.0, 35.0];     // the lit area
active_y = 2.3;     // its centre, from the glass centre (the flex cable is at the bottom)
sd_h     = 1.8;     // microSD socket on the back

holes  = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_w / 2 - hole_in), sy * (b_l / 2 - hole_in)]];
pins_y = b_l / 2 - pin_top;
pins   = ["VCC", "GND", "CS", "RESET", "A0", "SDA", "SCK", "LED"];

function st7735_18_size() = [b_w, b_l, b_t];
function st7735_18_height() = b_t + glass_t;
function st7735_18_active() = [0, glass_y + active_y];   // centre of the lit area
function st7735_18_holes() = holes;
function st7735_18_pin(i) = [(i - 3.5) * 2.54, pins_y];

// ======================================================================= board
module st7735_18(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, concat(
            [for (h = holes) [h[0], h[1], hole_d, 4.6]],
            [for (i = [0:7]) [(i - 3.5) * 2.54, pins_y, 1.0, 1.7]],
            [for (i = [0:3]) [(i - 1.5) * 2.54, -b_l / 2 + 1.6, 1.0, 1.7]]),
        [0.68, 0.10, 0.10], 0.5);
    translate([0, glass_y, b_t]) glass_panel(glass, glass_t, active, [0, active_y]);
    if (detail) {
        translate([0, 0, b_t]) {
            for (i = [0:7]) translate([(i - 3.5) * 2.54, pins_y - 1.8, 0]) silk(pins[i], 0.55, "right", rot = 90);
        }
        // back: microSD socket at the bottom, regulator and parts at the top
        mirror([0, 0, 1]) {
            translate([0, -b_l / 2 + 9.5, 0]) microsd_socket();
            translate([-6, b_l / 2 - 8, 0]) sot23(3);
            for (x = [0, 3, 6]) translate([x, b_l / 2 - 8, 0]) smd_passive("0805", x == 0 ? "c" : "r", 90);
        }
    }
    bo_headers(8, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
// Posts under the four holes, `h` mm tall (at least the SD socket: 1.8 mm).
module st7735_18_holder(h = 4, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
// The opening over the lit area, `margin` mm bigger all round, in a front
// `wall` mm thick whose inside face is `gap` mm above the glass. It widens
// outwards by `flare` so the screen is easy to see from the side.
module st7735_18_window(gap = 0.3, wall = 2, margin = 0.5, flare = 1) {
    rect_window(0, glass_y + active_y, b_t + glass_t + gap, wall,
                [active[0] + 2 * margin, active[1] + 2 * margin], flare);
}

// A slot in the case wall below the board's bottom edge, for pushing the
// microSD card in (the card sticks out of the socket ~2 mm).
module st7735_18_sd_cutout(wall = 2, gap = 0) {
    translate([-6.5, -b_l / 2 - gap - wall - 1, -sd_h - 0.6]) cube([13, wall + 2 + gap, sd_h + 1.0]);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") st7735_18();
else if (show == "holder") color("#d6a24a") st7735_18_holder();
else bo_demo([b_w, b_l], 4, b_t + glass_t + 0.3) {
    st7735_18();
    st7735_18_holder();
    st7735_18_window();
}
