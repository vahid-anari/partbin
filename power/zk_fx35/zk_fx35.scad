// ZK-FX35 electronic load / battery capacity tester (1.5-25 V, 5 A, 35 W).
// The load goes in through the green screw terminal or the USB-A plug at one
// end; the MOSFET lies under the board, screwed through it to the heat sink
// with its 40 mm fan on top. The board itself runs from 5 V on the micro-USB
// (or the 5V+ / 5V- pads beside it). LCD, four buttons (- + SELECT ON/SET),
// the I-ADJ multi-turn trimmer, a buzzer and the RUN LED at the other end.
//
//   use <partbin/power/zk_fx35/zk_fx35.scad>
//
//   zk_fx35();                          the module, with its parts
//   zk_fx35(detail = false);            only what matters for fit (fast)
//   zk_fx35_holder(h = 5.8);            posts under its four holes, for M3 screws
//   zk_fx35_usb_a_cutout(gap, wall)     the slot for the USB-A plug in the end wall
//   zk_fx35_size()                      [length, width, pcb thickness]
//   zk_fx35_holes()                     the four hole centres
//   zk_fx35_at(u, v)                    [x, y] of a point u mm from the USB end,
//                                       v mm from the button side
//   zk_fx35_usb_a_front()               x of the plug's tip (negative)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB-A plug at the left end pointing -x,
// the buttons along the -y side. It came on 5.8 mm nylon standoffs, so the
// parts under it fit in 5.8 mm. Board, holes, fan, LCD, buttons, terminal,
// USB-A and trimmer measured; the small parts placed from photos.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------ measured
b_len    = 101.1;   // board length (x), without the USB-A plug
b_w      = 43.1;    // board width (y)
b_t      = 1.0;     // PCB (thin: it bends when the buttons are pressed)
hole_d   = 3.0;     // mounting holes, M3
hole_in  = 4.0;     // hole centres from both edges
stand_h  = 5.8;     // the nylon standoffs it came on
fan      = 40.0;    // fan, square
fan_u    = 11.0;    // fan's edge from the USB end
fan_top  = 20.0;    // top of the fan above the board
sink_h   = 10.0;    // heat sink under the fan (from photos)
lcd      = [32.0, 17.2];   // LCD glass, along x and y
lcd_u    = 58.2;    // its edge from the USB end
lcd_v    = 15.3;    // its edge from the button side
lcd_top  = 4.8;     // top of the glass above the board
btn_v    = 5.0;     // button centres from the button side
btn_u    = 63.0;    // first button (-) from the USB end
btn_p    = 9.0;     // button pitch
btn_h    = 3.7;     // top of the buttons above the board
term     = [10.7, 10.5, 14.4];   // screw terminal: along x, along y, height
term_v   = 7.0;     // its edge from the button side
term_out = 0.2;     // how far it sticks out past the USB end
usba_v   = 18.1;    // USB-A plug's edge from the button side (12 wide)
usba_out = 12.1;    // how far it sticks out past the board
usba_h   = 4.5;     // its thickness; the board runs through its middle
pot_u    = 83.6;    // I-ADJ 3296 trimmer: body from u = 83.6 to 93.1
pot_v    = 37.6;    // its centre from the button side (from photos)
pot_h    = 10.0;    // typical 3296 height

function zk_fx35_size() = [b_len, b_w, b_t];
function zk_fx35_at(u, v) = [-b_len / 2 + u, -b_w / 2 + v];
function zk_fx35_holes() = [for (u = [hole_in, b_len - hole_in], v = [hole_in, b_w - hole_in]) zk_fx35_at(u, v)];
function zk_fx35_usb_a_front() = -b_len / 2 - usba_out;
function zk_fx35_height() = b_t + fan_top;

// ======================================================================= board
module zk_fx35(detail = true) {
    pcb([b_len, b_w], b_t, [for (h = zk_fx35_holes()) [h[0], h[1], hole_d, 5.0]], c_pcb_blue(), 0.8);
    // heat sink and fan
    translate(concat(zk_fx35_at(fan_u + fan / 2, b_w / 2), [b_t])) {
        color([0.80, 0.81, 0.83]) difference() {
            translate([-fan / 2, -fan / 2, 0]) cube([fan, fan, sink_h]);
            if (detail) for (i = [0:8]) translate([-fan / 2 + 3 + i * 4.25, -fan / 2 - 1, 2]) cube([2.2, fan + 2, sink_h]);
        }
        translate([0, 0, sink_h]) fan40(fan_top - sink_h, detail);
    }
    // screw terminal (wires in from -x) and the USB-A plug
    translate(concat(zk_fx35_at(-term_out, term_v), [b_t])) color([0.25, 0.65, 0.35]) difference() {
        cube(term);
        for (j = [0.25, 0.75]) {
            translate([-1, term[1] * j - 1.6, 2]) cube([5, 3.2, 3.6]);
            translate([term[0] * 0.55, term[1] * j, term[2] - 3]) cylinder(d = 3.4, h = 4, $fn = 20);
        }
    }
    translate(concat(zk_fx35_at(3, usba_v + 6), [b_t / 2 - usba_h / 2])) rotate([0, 0, 90]) usb_a_male(usba_out + 3);
    // LCD
    translate(concat(zk_fx35_at(lcd_u + lcd[0] / 2, lcd_v + lcd[1] / 2), [b_t])) {
        color([0.9, 0.9, 0.9]) translate([-lcd[0] / 2, -lcd[1] / 2, 0]) cube([lcd[0], lcd[1], lcd_top - 1.6]);
        translate([0, 0, lcd_top - 1.6]) glass_panel(lcd, 1.6, lcd - [3, 3]);
    }
    // buttons, I-ADJ trimmer (screw towards the far end)
    for (i = [0:3]) translate(concat(zk_fx35_at(btn_u + i * btn_p, btn_v), [b_t])) tact6(btn_h);
    translate(concat(zk_fx35_at(pot_u + 4.75, pot_v), [b_t])) rotate([0, 0, 180]) trimpot_3296([9.5, 4.8], pot_h);
    // micro-USB (facing +y) with the 5V- / 5V+ pads either side
    translate(concat(zk_fx35_at(62, b_w - 0.6), [b_t])) usb_micro();
    for (u = [56.5, 67.5]) translate(concat(zk_fx35_at(u, 40.5), [0])) pad([2.0, 2.0], 1.0, b_t);
    if (detail) {
        translate(concat(zk_fx35_at(95.5, 27.5), [b_t])) color([0.1, 0.1, 0.1]) difference() {   // buzzer
            cylinder(d = 9, h = 5.5, $fn = 40);
            translate([0, 0, 4.5]) cylinder(d = 2, h = 2, $fn = 16);
        }
        translate(concat(zk_fx35_at(96.5, 34.5), [b_t])) elco(5, 7, [0.1, 0.45, 0.2]);
        translate(concat(zk_fx35_at(93.0, 19.0), [b_t])) smd_led("0603", "red");             // RUN
        translate(concat(zk_fx35_at(53.0, 3.0), [b_t])) color([0.93, 0.93, 0.9])            // fan socket
            translate([-3, -2.25, 0]) cube([6, 4.5, 6]);
        // under the board: MOSFET (TO-220) flat, screwed through to the sink,
        // a TO-252 next to it, the R025 shunt, and the heat sink's screws
        mirror([0, 0, 1]) {
            translate(concat(zk_fx35_at(24, 21.5), [0])) {
                color(c_tin()) translate([-14.5, -5.2, 0]) cube([12, 10.4, 1.3]);
                color(c_chip()) translate([-2.5, -5.0, 0]) cube([9, 10, 4.5]);
                color(c_tin()) for (i = [-1:1]) translate([6.5, i * 2.54 - 0.4, 2]) cube([7, 0.8, 0.6]);
            }
            translate(concat(zk_fx35_at(15, 10), [0])) to263(90);
            translate(concat(zk_fx35_at(7, 30), [0])) color(c_res()) translate([-3.2, -1.6, 0]) cube([6.4, 3.2, 0.8]);
            for (p = [[31.6, 4.9], [31.6, 38.2], [16, 20]]) translate(concat(zk_fx35_at(p[0], p[1]), [0]))
                color(c_tin()) cylinder(d = 5.5, h = 2.4, $fn = 24);
        }
    }
}

// 40 mm fan seen from above: frame, hub, blades.
module fan40(h, detail = true) {
    color([0.1, 0.1, 0.1]) difference() {
        translate([-fan / 2, -fan / 2, 0]) linear_extrude(h) offset(2) offset(-2) square(fan);
        translate([0, 0, -1]) cylinder(d = fan - 2.5, h = h + 2, $fn = 60);
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * 16, sy * 16, -1]) cylinder(d = 3.4, h = h + 2, $fn = 16);
    }
    color([0.1, 0.1, 0.1]) cylinder(d = 16, h = h, $fn = 40);
    if (detail) color([0.12, 0.12, 0.12]) for (a = [0:360 / 7:359]) rotate([0, 0, a])
        translate([7, -1.8, 1]) rotate([25, 0, 0]) cube([11.5, 7, 0.8]);
    color([0.9, 0.75, 0.2]) translate([0, 0, h]) cylinder(d = 13, h = 0.05, $fn = 40);   // label
}

// ===================================================================== holder
// Posts under the four holes, up to the board's underside, with pilot holes
// for M3 self-tapping screws from above (M3 x 8: 1 mm board + 7 in the post).
module zk_fx35_holder(h = stand_h) { bo_mounts(zk_fx35_holes(), hole_d, b_t, h, "screw", 1.9, screw_d = 2.5); }

// ================================================================= cutouts
// A slot for the USB-A plug in the end wall, open at the top; the wall's
// inside face is `gap` from the board's end and it is `wall` thick.
module zk_fx35_usb_a_cutout(gap = 0.3, wall = 2, clear = 0.4) {
    y = zk_fx35_at(0, usba_v + 6)[1];
    translate([-b_len / 2 - gap - wall - 1, y - 6 - clear, b_t / 2 - usba_h / 2 - clear]) cube([wall + 2, 12 + 2 * clear, 30]);
}

// ========================================================= shown when opened
show = "demo";  // demo | board | holder
if (show == "board") zk_fx35();
else if (show == "holder") color("#d6a24a") zk_fx35_holder();
else {
    zk_fx35();
    color("#d6a24a") zk_fx35_holder();
    color("#d6a24a") difference() {
        translate([-b_len / 2 - 2.3, -b_w / 2 - 2.3, -stand_h - 2]) cube([b_len + 4.6, b_w + 4.6, 2]);
    }
}
