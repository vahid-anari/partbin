// Type-C to 8.4 V boost charger for 2S Li-ion packs ("DDTCCRUB", green,
// 39 x 18 mm; also sold as 3S/4S and 1A/2A/4A by jumpers on the back).
// USB-C input with VIN/GND pads beside it; BAT and GND pads at the far end;
// red CR (charging) and green OK (full) LEDs.
//
//   use <partbin/modules/charger_2s_typec/charger_2s_typec.scad>
//
//   charger_2s_typec();                    the board, with its parts
//   charger_2s_typec(detail = false);      only what matters for fit (fast)
//   charger_2s_typec_usb_cutout(wall, gap) the USB-C opening, subtract it
//   charger_2s_typec_led_window(gap, wall) a slot over the two LEDs in the lid
//   charger_2s_typec_holder();             ledge and low walls, open at the USB end
//   charger_2s_typec_size()                [length, width, pcb thickness]
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB socket at the left end pointing -x.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// --------------------------------- from the listing (39 x 18 x 6 mm)
b_l      = 39.0;    // board length (x)
b_w      = 18.0;    // board width (y)
b_t      = 1.6;     // PCB
c_size   = [8.94, 3.26, 7.35];   // USB-C
usb_out  = 0.8;
tall_h   = 4.0;     // the inductor (6 mm overall with the PCB and the socket's legs)
leds_at  = [14.0, -6.5];         // OK and CR LEDs, between them

function charger_2s_typec_size() = [b_l, b_w, b_t];
function charger_2s_typec_usb_front() = -b_l / 2 - usb_out;
function charger_2s_typec_height() = b_t + tall_h;

// ======================================================================= board
module charger_2s_typec(detail = true) {
    color([0.10, 0.48, 0.22]) translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
    translate([-b_l / 2 - usb_out, 0, b_t]) rotate([0, 0, 90]) usb_c(c_size[0], c_size[1], c_size[2]);
    // VIN and GND beside the socket, BAT and GND at the far end
    for (p = [[-b_l / 2 + 2.0, 7.0], [-b_l / 2 + 2.0, -7.0], [b_l / 2 - 2.0, 6.0], [b_l / 2 - 2.0, -6.0]])
        translate([p[0], p[1], 0]) pad([2.2, 2.2], 1.2, b_t);
    translate([-2.0, 3.5, b_t]) power_inductor(5.2, tall_h);
    if (detail) translate([0, 0, b_t]) {
        translate([-2.0, -3.5, 0]) soic(8, 3.9, 1.5);
        translate([7.5, 0, 0]) soic(8, 3.9, 1.5, rot = 90);
        for (i = [0:3]) translate([b_l / 2 - 7 - i * 3.4, 5.8, 0]) smd_passive("1206", "r", 90);
        for (x = [-10, -7.5]) translate([x, -5, 0]) smd_passive("0805", "c", 90);
        translate([leds_at[0] - 1.2, leds_at[1], 0]) smd_led("0603", "lime");
        translate([leds_at[0] + 1.2, leds_at[1], 0]) smd_led("0603", "red");
        translate([leds_at[0], leds_at[1] - 1.5, 0]) silk("OK  CR", 0.6);
        translate([b_l / 2 - 4, 6, 0]) silk("BAT", 0.7, "right");
        translate([b_l / 2 - 4, -6, 0]) silk("GND", 0.7, "right");
        translate([-b_l / 2 + 4, 7, 0]) silk("VIN", 0.7, "left");
        translate([-b_l / 2 + 4, -7, 0]) silk("GND", 0.7, "left");
    }
}

// ==================================================================== cutouts
module charger_2s_typec_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([-b_l / 2 - usb_out, 0], b_t + c_size[1] / 2, 90, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

module charger_2s_typec_led_window(gap = 4.5, wall = 2) {
    rect_window(leds_at[0], leds_at[1], b_t + gap, wall, [4.4, 1.6], 0, 0.3);
}

// ===================================================================== holder
module charger_2s_typec_holder(h = 2) {
    difference() {
        edge_holder([b_l, b_w], b_t, h, 1.5);
        translate([-b_l / 2 - 5, -b_w / 2 + 2.5, -h - 1]) cube([6, b_w - 5, h + 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") charger_2s_typec();
else if (show == "holder") color("#d6a24a") charger_2s_typec_holder();
else {
    charger_2s_typec();
    color("#d6a24a") charger_2s_typec_holder();
    color("#9aa3ab", 0.9) difference() {
        translate([charger_2s_typec_usb_front() - 2, -12, -3]) cube([2, 24, 9]);
        charger_2s_typec_usb_cutout();
    }
}
