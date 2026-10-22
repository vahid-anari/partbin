// VEML7700 light sensor breakout, Adafruit #4162 layout (blue, 5 pins:
// VIN 3Vo GND SCL SDA, two mounting holes). Most clones copy it exactly.
//
//   use <partbin/modules/veml7700/veml7700.scad>
//
//   veml7700();                       the board, with its parts
//   veml7700(detail = false);         only what matters for fit (fast)
//   veml7700(headers = "down");       with a pin header soldered on
//   veml7700_holder(h = 3);           posts under its holes, add to the case
//   veml7700_window(gap, wall);       a window over the sensor, subtract from the lid
//   veml7700_size()                   [width, length, pcb thickness]
//   veml7700_sensor()                 [x, y] of the sensor
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pin row along the bottom edge (-y), the holes at the top (+y).
// The VEML7700 looks straight up and is the tallest part (3 mm). For the
// window, the lid's inside face is `gap` mm above the board's top.
// Opened on its own, this file shows it on its posts under a see-through lid
// with the window (set show = "board" or "holder").

use <../../lib/parts.scad>
use <../../lib/breakout.scad>

// ---------------------- from Adafruit's design files (github.com/adafruit/Adafruit-VEML7700-PCB)
b_w      = 16.51;   // board width (x), 0.65"
b_l      = 16.51;   // board length (y)
b_t      = 1.6;     // PCB (typical; measure yours)
corner   = 2.54;    // corner radius
hole_d   = 2.5;     // mounting holes, plated
ring_d   = 4.0;
hole_in  = 2.54;    // hole centre to the top and the side edges
pin_bot  = 2.54;    // pin centre to the bottom edge
chip     = [0.381, 0];   // VEML7700 centre
chip_h   = 3.0;     // VEML7700 height (the tallest part)

holes  = [[-b_w / 2 + hole_in, b_l / 2 - hole_in], [b_w / 2 - hole_in, b_l / 2 - hole_in]];
pins_y = -b_l / 2 + pin_bot;
pins   = ["VIN", "3Vo", "GND", "SCL", "SDA"];   // left to right, parts up

function veml7700_size() = [b_w, b_l, b_t];
function veml7700_sensor() = chip;
function veml7700_holes() = holes;
function veml7700_height() = b_t + chip_h;
function veml7700_pin(i) = [(i - 2) * 2.54, pins_y];   // 0 = VIN ... 4 = SDA

// ======================================================================= board
module veml7700(detail = true, headers = "none") {
    bo_pcb([b_w, b_l], b_t, corner, holes, hole_d, ring_d, 5, 0, pins_y, c_pcb_blue());
    translate([chip[0], chip[1], b_t]) veml7700_pkg(rot = 90);
    if (detail) {
        translate([0, 0, b_t]) {
            translate([-5.207, -2.54, 0]) smd_passive("0805", "c");
            translate([-5.207, 2.54, 0]) smd_passive("0805", "c");
            translate([-5.08, 0, 0]) sot23(5, rot = 270);               // 3.3 V regulator
            translate([-2.413, 0, 0]) smd_passive("0603", "c", 90);
            translate([4.699, 1.524, 0]) resistor_array();
            translate([4.445, -1.778, 0]) smd_ic([2.0, 1.25, 0.9], 3, 0.65, rot = 90);  // level shifter
            translate([1.0, 6.3, 0]) silk("VEML", 1.3);
            translate([1.0, 4.6, 0]) silk("7700", 1.3);
            for (i = [0:4]) translate([(i - 2) * 2.54, pins_y + (i % 2 == 0 ? 1.7 : -1.5), 0])
                silk(pins[i], 0.75);
        }
        bo_under(0, 5.2) silk("I2C  Lux", 1.1);
        bo_under(0, 3.4) silk("Sensor", 1.1);
        bo_under(0, 1.6) silk("Vin/logic: 3-5V", 0.9);
    }
    bo_headers(5, 0, pins_y, b_t, headers);
}

// ===================================================================== holder
// Posts under the two holes, `h` mm tall. style "peg": pins go up through
// the holes and the board presses on; "screw": pilot holes for M2
// self-tapping screws.
module veml7700_holder(h = 3, style = "peg") {
    bo_mounts(holes, hole_d, b_t, h, style);
}

// ===================================================================== window
// A round window over the sensor in a lid `wall` mm thick whose inside face
// is `gap` mm above the board's top (at least 3 mm: the sensor is 3 mm
// tall). It widens outwards so the sensor sees the room.
module veml7700_window(gap = 3.2, wall = 2, d = 3) {
    bo_window(chip[0], chip[1], b_t + gap, wall, d);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") veml7700();
else if (show == "holder") color("#d6a24a") veml7700_holder();
else bo_demo([b_w, b_l], 3, b_t + 3.2) {
    veml7700();
    veml7700_holder();
    veml7700_window();
}
