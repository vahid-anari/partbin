// ADS1115 16-bit ADC breakout (blue, Adafruit-style: 10 pins along the
// bottom: VDD GND SCL SDA ADDR ALRT A0 A1 A2 A3, two holes at the top).
//
//   use <partbin/modules/ads1115/ads1115.scad>
//
//   ads1115();                     the board, with its parts
//   ads1115(headers = "down");     with the 10-pin header soldered on
//   ads1115_holder(h = 3);         posts under its two holes
//   ads1115_size()                 [width, length, pcb thickness]
//   ads1115_pin(i)                 [x, y] of pin i (0 = VDD ... 9 = A3)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pins along the bottom edge (-y), the holes at the top.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ------------------------------------------------------- typical (Adafruit 1085)
b_w      = 28.0;
b_l      = 17.8;
b_t      = 1.6;
hole_d   = 2.5;
hole_in  = 2.5;     // hole centre to the top and side edges
pin_bot  = 1.6;

holes  = [[-b_w / 2 + hole_in, b_l / 2 - hole_in], [b_w / 2 - hole_in, b_l / 2 - hole_in]];
pins_y = -b_l / 2 + pin_bot;
pins   = ["VDD", "GND", "SCL", "SDA", "ADDR", "ALRT", "A0", "A1", "A2", "A3"];

function ads1115_size() = [b_w, b_l, b_t];
function ads1115_holes() = holes;
function ads1115_pin(i) = [(i - 4.5) * 2.54, pins_y];

module ads1115(detail = true, headers = "none") {
    bo_pcb([b_w, b_l], b_t, 1.0, holes, hole_d, 4.2, 10, 0, pins_y, c_pcb_blue());
    if (detail) translate([0, 0, b_t]) {
        translate([5.5, 3.0, 0]) smd_ic([3.0, 3.0, 1.0], 5, 0.5);         // ADS1115 (MSOP-10)
        for (x = [-8.5, -6.0, -3.5, -1.0, 1.5]) translate([x, 1.5, 0]) smd_passive("0805", x == 1.5 ? "c" : "r", 90);
        for (i = [0:9]) translate([(i - 4.5) * 2.54, pins_y + 1.5, 0]) silk(pins[i], 0.55, "left", rot = 90);
        translate([-4, b_l / 2 - 1.8, 0]) silk("ADS1115", 1.0);
    }
    bo_headers(10, 0, pins_y, b_t, headers);
}

module ads1115_holder(h = 3, style = "peg") { bo_mounts(holes, hole_d, b_t, h, style); }

show = "demo";  // demo | board | holder
if (show == "board") ads1115();
else if (show == "holder") color("#d6a24a") ads1115_holder();
else { ads1115(); color("#d6a24a") ads1115_holder(); }
