// CJMCU-226 INA226 current/power monitor (blue, 8 pins down one side: VCC
// GND SDA SCL ALE VBS IN- IN+; two big holes for the IN- / IN+ wires next to
// the 0.1 ohm shunt; one mounting hole).
//
//   use <partbin/sensors/ina226_cjmcu226/ina226_cjmcu226.scad>
//
//   ina226_cjmcu226();                   the board, with its parts
//   ina226_cjmcu226(headers = "down");   with the 8-pin header soldered on
//   ina226_cjmcu226_holder(h = 3);       a post under its mounting hole + a ledge
//   ina226_cjmcu226_size()               [width, length, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pin row along the left edge (-x), VCC at the bottom.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// --------------------- typical; layout from the seller's photo
b_w      = 20.5;    // board (x)
b_l      = 20.5;    // board (y)
b_t      = 1.6;
pin_x    = -b_w / 2 + 1.3;
big_d    = 2.2;     // IN- / IN+ wire holes
bigs     = [[6.6, -1.6], [6.6, -6.6]];
mount    = [6.6, 6.6];
mount_d  = 3.0;
pins     = ["VCC", "GND", "SDA", "SCL", "ALE", "VBS", "IN-", "IN+"];   // bottom to top

function ina226_cjmcu226_size() = [b_w, b_l, b_t];
function ina226_cjmcu226_pin(i) = [pin_x, (i - 3.5) * 2.54];

module ina226_cjmcu226(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, concat(
            [for (i = [0:7]) [pin_x, (i - 3.5) * 2.54, 1.0, 1.7]],
            [for (b = bigs) [b[0], b[1], big_d, 3.8]],
            [[mount[0], mount[1], mount_d, 4.6]]),
        c_pcb_blue(), 0.5);
    translate([0.5, -4.0, b_t]) {                                   // R100 shunt (2512)
        color([0.1, 0.1, 0.1]) translate([-3.2, -1.6, 0]) cube([6.4, 3.2, 0.6]);
        color(c_tin()) for (s = [-1, 1]) translate([s * 3.2 - (s > 0 ? 0.8 : 0), -1.6, 0]) cube([0.8, 3.2, 0.6]);
    }
    if (detail) translate([0, 0, b_t]) {
        translate([0.5, 4.0, 0]) smd_ic([3.0, 3.0, 1.0], 5, 0.5);     // INA226 (MSOP-10)
        for (y = [7.5, 1.0]) translate([4.0, y, 0]) smd_passive("0603", "c", 90);
        for (i = [0:7]) translate([pin_x + 1.5, (i - 3.5) * 2.54, 0]) silk(pins[i], 0.6, "left");
    }
    if (headers == "down") translate([pin_x, 0, 0]) mirror([0, 0, 1]) pin_header(8, below = b_t + 1.5);
    else if (headers == "up") translate([pin_x, 0, b_t]) pin_header(8, below = b_t + 1.5);
}

// A post under the mounting hole and a ledge under the pin edge.
module ina226_cjmcu226_holder(h = 3, style = "peg") {
    bo_mounts([mount], mount_d, b_t, h, style);
    translate([-b_w / 2 - 0.5, -b_l / 2 + 2, -h]) difference() {
        cube([3.5, b_l - 4, h]);
        translate([1.0, -1, h - 1.5]) cube([1.6, b_l, 2]);   // room for the solder under the pins
    }
}

show = "demo";  // demo | board | holder
if (show == "board") ina226_cjmcu226();
else if (show == "holder") color("#d6a24a") ina226_cjmcu226_holder();
else { ina226_cjmcu226(); color("#d6a24a") ina226_cjmcu226_holder(); }
