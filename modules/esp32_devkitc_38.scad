// ESP32-DevKitC V4, 38 pins (ESP32-WROOM-32D or -32U module, CP2102, USB-C),
// 19 pins down each side, rows 25.4 mm apart (too wide for one breadboard).
//
//   use <partbin/modules/esp32_devkitc_38.scad>
//
//   esp32_devkitc_38();                    the board, with its parts
//   esp32_devkitc_38(wroom = "32U");       the -32U module (antenna socket, no PCB antenna)
//   esp32_devkitc_38(detail = false);      only what matters for fit (fast)
//   esp32_devkitc_38(headers = "down");    with pin headers soldered on
//   esp32_devkitc_38_usb_cutout(wall, gap) the USB-C opening, subtract it
//   esp32_devkitc_38_holder();             rails along the long edges, add to the case
//   esp32_devkitc_38_size()                [width, length, pcb thickness]
//   esp32_devkitc_38_pin(side, i)          [x, y] of pin i (0 = top) on "left"/"right"
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the module (antenna) at the top (+y), the USB socket at the bottom
// pointing -y. Keep the antenna end clear of metal and away from the case wall.

use <../lib/parts.scad>
use <../lib/breakout.scad>
use <../lib/display.scad>

// ---------------------------------- from the seller's drawing
b_w      = 27.94;   // board width (x)
b_l      = 48.26;   // board length (y)
b_t      = 1.6;     // PCB
rows     = 25.40;   // between the two pin rows
mod_w    = 18.0;    // WROOM module
mod_l    = 25.5;
mod_h    = 3.1;
mod_out  = 1.30;    // the module sticks out past the top edge
c_size   = [8.94, 3.26, 7.35];   // USB-C
usb_out  = 1.29;    // the socket sticks out past the bottom edge

function esp32_devkitc_38_size() = [b_w, b_l, b_t];
function esp32_devkitc_38_usb_front() = -b_l / 2 - usb_out;
function esp32_devkitc_38_height() = b_t + mod_h;
function esp32_devkitc_38_pin(side, i) = [side == "left" ? -rows / 2 : rows / 2, b_l / 2 - 1.27 - i * 2.54];

// ======================================================================= board
module esp32_devkitc_38(wroom = "32D", detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, [for (s = [-1, 1], i = [0:18]) [s * rows / 2, b_l / 2 - 1.27 - i * 2.54, 1.0, 1.7]], c_pcb_black(), 0.8);
    // the module, sticking out past the top
    translate([0, b_l / 2 + mod_out - mod_l / 2, b_t]) {
        color([0.12, 0.12, 0.12]) translate([-mod_w / 2, -mod_l / 2, 0]) cube([mod_w, mod_l, 0.8]);
        color(c_tin()) translate([-mod_w / 2 + 0.6, -mod_l / 2 + 0.6, 0.8]) cube([mod_w - 1.2, 17.6, mod_h - 0.8]);   // the can
        if (wroom == "32D" && detail) color([0.75, 0.6, 0.2]) translate([-6, mod_l / 2 - 4.5, 0.8]) linear_extrude(0.03)
            polygon([[0, 0], [12, 0], [12, 3], [10, 3], [10, 1], [8, 1], [8, 3], [6, 3], [6, 1], [4, 1], [4, 3], [2, 3], [2, 1], [0, 1]]);
        if (wroom == "32U") color(c_tin()) translate([5, mod_l / 2 - 3, 0.8]) cylinder(d = 2.6, h = 1.2, $fn = 24);
    }
    translate([0, -b_l / 2 - usb_out, b_t]) rotate([0, 0, 180]) usb_c(c_size[0], c_size[1], c_size[2]);
    if (detail) translate([0, 0, b_t]) {
        for (x = [-8.5, 8.5]) translate([x, -b_l / 2 + 4.5, 0]) smd_button([4.0, 3.0], 1.4, 0.4, 1.4);   // EN, BOOT
        translate([0, -b_l / 2 + 13, 0]) qfn(5, 0.9, 7, label = "CP2102");
        translate([0, -b_l / 2 + 22, 0]) {                                                               // AMS1117
            color(c_chip()) translate([-3.25, -1.75, 0]) cube([6.5, 3.5, 1.6]);
            color(c_tin()) translate([-1.5, 1.75, 0]) cube([3, 1.6, 0.2]);
        }
        translate([7, -b_l / 2 + 21, 0]) smd_led("0603", "red");
        for (p = [[-6, -8, "c"], [-6, -10, "r"], [6, -8, "r"], [6, -10, "c"], [-4, -2, "c"], [4, -2, "c"]])
            translate([p[0], p[1], 0]) smd_passive("0603", p[2]);
        translate([-8.5, -b_l / 2 + 7.5, 0]) silk("EN", 0.7);
        translate([8.5, -b_l / 2 + 7.5, 0]) silk("Boot", 0.7);
    }
    if (headers == "down") for (s = [-1, 1]) translate([s * rows / 2, 0, 0]) mirror([0, 0, 1]) pin_header(19, below = b_t + 1.5);
    else if (headers == "up") for (s = [-1, 1]) translate([s * rows / 2, 0, b_t]) pin_header(19, below = b_t + 1.5);
}

// =============================================================== USB cutout
module esp32_devkitc_38_usb_cutout(wall = 2, gap = 0, clear = 0.3, lip = 0.8) {
    bo_usb_cutout([0, -b_l / 2 - usb_out], b_t + c_size[1] / 2, 180, [c_size[0], c_size[1]], wall, gap, clear, [12.4, 6.6], lip);
}

// ===================================================================== holder
// The board has no mounting holes: a ledge under it and low walls, open at
// the USB end and at the antenna end (the module sticks out there, and the
// antenna works better with nothing around it). With headers soldered on,
// plug it into two 19-pin sockets instead.
module esp32_devkitc_38_holder(h = 2.5) {
    difference() {
        edge_holder([b_w, b_l], b_t, h, 1.5);
        translate([-c_size[0] / 2 - 2, -b_l / 2 - 5, -h - 1]) cube([c_size[0] + 4, 6, h + 10]);
        translate([-mod_w / 2 - 0.5, b_l / 2 - 1, 0]) cube([mod_w + 1, 6, 10]);
    }
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") esp32_devkitc_38();
else if (show == "holder") color("#d6a24a") esp32_devkitc_38_holder();
else {
    esp32_devkitc_38();
    color("#d6a24a") esp32_devkitc_38_holder();
    color("#9aa3ab", 0.9) difference() {
        translate([-15, esp32_devkitc_38_usb_front() - 2, -3]) cube([30, 2, 9]);
        esp32_devkitc_38_usb_cutout();
    }
}
