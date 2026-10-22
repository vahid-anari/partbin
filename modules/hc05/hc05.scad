// HC-05 Bluetooth serial module on its blue backplane (6 pins at one end:
// STATE RXD TXD GND VCC EN, a small button, the green HC-05 board on top).
//
//   use <partbin/modules/hc05/hc05.scad>
//
//   hc05();                     the module, with its parts
//   hc05(headers = "none");     without the header ("angle" = default; pins point -y)
//   hc05_holder();              ledge and low walls, open at the pin end
//   hc05_size()                 [width, length, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the pins at the bottom end (-y), the antenna at the top. Keep the
// antenna end away from metal.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 15.5;    // backplane width (x)
b_l      = 37.3;    // backplane length (y)
b_t      = 1.6;
m_w      = 13.0;    // the green HC-05 board on it
m_l      = 27.0;
m_t      = 0.8;
pins_y   = -b_l / 2 + 1.5;
pins     = ["STATE", "RXD", "TXD", "GND", "VCC", "EN"];

function hc05_size() = [b_w, b_l, b_t];
function hc05_height() = b_t + 1.2 + m_t + 1.0;

module hc05(detail = true, headers = "angle") {
    pcb([b_w, b_l], b_t, [for (i = [0:5]) [(i - 2.5) * 2.54, pins_y, 1.0, 1.6]], c_pcb_blue(), 0.5);
    // the HC-05 board, soldered flat by its edge pads
    translate([0, b_l / 2 - m_l / 2 - 0.5, b_t + 0.2]) {
        color([0.10, 0.40, 0.25]) translate([-m_w / 2, -m_l / 2, 0]) cube([m_w, m_l, m_t]);
        if (detail) translate([0, 0, m_t]) {
            translate([0, -3, 0]) qfn(7, 1.0, 12, label = "CSR");
            translate([0, -10, 0]) qfn(5, 0.9, 8);
            color([0.8, 0.65, 0.25]) translate([-5, m_l / 2 - 5, 0]) cube([10, 4, 0.03]);   // PCB antenna
        }
        color(c_gold()) for (s = [-1, 1], i = [0:12]) translate([s * (m_w / 2) - 0.4, -m_l / 2 + 1.5 + i * 1.5, -0.01]) cube([0.8, 0.8, m_t + 0.02]);
    }
    if (detail) translate([0, 0, b_t]) {
        translate([-4.5, -b_l / 2 + 6.5, 0]) smd_button([3.6, 3.0], 1.2, 0.4, 1.2);
        translate([1, -b_l / 2 + 6.5, 0]) sot23(5);
        translate([5, -b_l / 2 + 6.5, 0]) smd_led("0603", "red", 90);
        for (i = [0:5]) translate([(i - 2.5) * 2.54, pins_y + 1.5, 0]) silk(pins[i], 0.45, "left", rot = 90);
    }
    if (headers == "angle") translate([0, pins_y, b_t]) rotate([0, 0, -90]) pin_header_angle(6, 6);
}

module hc05_holder(h = 2) {
    difference() {
        edge_holder([b_w, b_l], b_t, h, 1.5);
        translate([-b_w / 2 - 1, -b_l / 2 - 5, -0.01]) cube([b_w + 2, 6, 10]);
    }
}

show = "demo";  // demo | board | holder
if (show == "board") hc05();
else if (show == "holder") color("#d6a24a") hc05_holder();
else { hc05(); color("#d6a24a") hc05_holder(); }
