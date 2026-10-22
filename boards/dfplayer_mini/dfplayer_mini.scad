// DFPlayer Mini MP3 player (black, 20.5 x 20.5 mm, 8 pins down each side,
// microSD socket on top, the decoder chip and amplifier underneath).
//
//   use <partbin/boards/dfplayer_mini/dfplayer_mini.scad>
//
//   dfplayer_mini();                    the module, with its parts
//   dfplayer_mini(headers = "down");    with pin headers (the usual way: into sockets)
//   dfplayer_mini_sd_cutout(wall, gap)  a slot in the wall for the microSD card
//   dfplayer_mini_holder();             ledge and low walls
//   dfplayer_mini_size()                [width, length, pcb thickness]
//   dfplayer_mini_pin(n)                [x, y] of pin n (1 ... 16)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the card slot opening at the bottom end (-y). Pin 1 (VCC) is top
// left; 1-8 run down the left side, 9-16 up the right (pin 16 BUSY top right).

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 20.5;
b_l      = 20.5;
b_t      = 1.6;
rows     = 17.78;   // between the two pin rows
pin1_y   = 8.89;    // first pin

function dfplayer_mini_size() = [b_w, b_l, b_t];
function dfplayer_mini_pin(n) = n <= 8 ? [-rows / 2, pin1_y - (n - 1) * 2.54] : [rows / 2, pin1_y - (16 - n) * 2.54];

module dfplayer_mini(detail = true, headers = "none") {
    pcb([b_w, b_l], b_t, [for (s = [-1, 1], i = [0:7]) [s * rows / 2, pin1_y - i * 2.54, 1.0, 1.6]], c_pcb_black(), 0.4);
    translate([0, -1.5, b_t]) microsd_socket();
    if (detail) {
        translate([0, 0, b_t]) for (x = [-4, -2, 2, 4]) translate([x, 8.2, 0]) smd_passive("0603", "c", 90);
        mirror([0, 0, 1]) {
            translate([0, 2, 0]) soic(24, 7.5, 2.4);
            translate([0, -6, 0]) soic(8, 3.9, 1.5);
        }
    }
    if (headers == "down") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 3.5 * 2.54, 0]) mirror([0, 0, 1]) pin_header(8, below = b_t + 1.5);
    else if (headers == "up") for (s = [-1, 1]) translate([s * rows / 2, pin1_y - 3.5 * 2.54, b_t]) pin_header(8, below = b_t + 1.5);
}

// A slot in the wall at the card end, to push the microSD card in.
module dfplayer_mini_sd_cutout(wall = 2, gap = 0) {
    translate([-6.5, -b_l / 2 - gap - wall - 1, b_t - 0.3]) cube([13, wall + gap + 2, 2.4]);
}

module dfplayer_mini_holder(h = 3.5) {
    difference() {
        edge_holder([b_w, b_l], b_t, h, 1.5);
        translate([-7.5, -b_l / 2 - 5, -0.01]) cube([15, 6, 10]);   // the card end stays open
    }
}

show = "demo";  // demo | board | holder
if (show == "board") dfplayer_mini();
else if (show == "holder") color("#d6a24a") dfplayer_mini_holder();
else { dfplayer_mini(); color("#d6a24a") dfplayer_mini_holder(); }
