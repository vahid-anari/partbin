// ESP32-C3 Super Mini (the black "Nologo" board, ceramic chip antenna,
// BOOT and RST buttons under the USB-C socket).
//
//   use <partbin/modules/esp32_c3_supermini.scad>
//
//   esp32c3_supermini();                   the board, with all its parts
//   esp32c3_supermini(detail = false);     only what matters for fit (fast)
//   esp32c3_supermini(headers = "down");   with pin headers soldered on
//   esp32c3_supermini_usb_cutout(wall=2);  subtract from the case wall
//   esp32c3_supermini_holder();            a tray the board presses into, add to the case
//   esp32c3_supermini_size()               [width, length, pcb thickness]
//
// Where it sits: the board lies flat, parts up. The centre of the board is at
// x = y = 0, its underside at z = 0, and the USB-C socket points to +y.
// Put the board, its cutout and its holder through the same translate/rotate
// and they line up.
//
// Opened on its own, this file shows the board, the holder and a wall piece
// (set show = "board" or "holder" for one of them alone).

use <../lib/parts.scad>

// ------------------------------------------------- measured (Vahid, calipers)
sm_w     = 18.0;    // board width (x)
sm_l     = 23.0;    // board length (y), without the USB socket
sm_t     = 0.8;     // PCB
usb_w    = 8.8;     // USB-C shell width
usb_h    = 3.1;     // USB-C height above the board (the tallest part)
usb_out  = 1.7;     // how far the socket sticks out past the board's edge
usb_left = 5.0;     // board's left edge to the socket's left side (parts up, USB away from you)
pin_span = 17.78;   // first to last hole in a row (8 pins, 2.54 mm)

// ------------------------------------------------ typical / from the photos
row_x    = 7.62;    // each pin row from the centre (rows 15.24 mm apart)
pin_y0   = 1.0;     // the pin rows' middle sits this far towards the USB
usb_len  = 7.6;     // socket depth
drill    = 1.0;
pad      = 1.6;

usb_x    = -sm_w / 2 + usb_left + usb_w / 2;   // socket centre (x)
usb_y    = sm_l / 2 + usb_out;                 // socket front (y)

// Pin names, top to bottom (USB end first). Right row as seen from the top.
right_pins = ["5V", "G", "3.3", "4", "3", "2", "1", "0"];
left_pins  = ["5", "6", "7", "8", "9", "10", "20", "21"];

function esp32c3_supermini_size() = [sm_w, sm_l, sm_t];
function esp32c3_supermini_usb_front() = usb_y;            // y of the socket's face
function esp32c3_supermini_height() = sm_t + usb_h;       // top of the tallest part
// [x, y] of pin i (0 = USB end) in row "left" or "right"
function esp32c3_supermini_pin(side, i) =
    [side == "left" ? -row_x : row_x, pin_y0 + pin_span / 2 - i * 2.54];

// ======================================================================= board
module esp32c3_supermini(detail = true, headers = "none") {
    holes = [for (s = [-1, 1], i = [0:7]) [s * row_x, pin_y0 + pin_span / 2 - i * 2.54, drill, pad]];
    pcb([sm_w, sm_l], sm_t, holes);
    // half-holes plated on the board's long edges
    color(c_gold()) for (s = [-1, 1], i = [0:7])
        translate([s * (sm_w / 2 + 0.01) + (s < 0 ? -0.03 : 0), pin_y0 + pin_span / 2 - i * 2.54 - 0.6, 0.01]) cube([0.03, 1.2, sm_t - 0.02]);
    // underside: pin names and the two white label boxes (read from below)
    if (detail) {
        for (i = [0:7]) {
            sm_under(row_x - 1.45, pin_y0 + pin_span / 2 - i * 2.54) silk(right_pins[i], 0.75, "left");
            sm_under(-row_x + 1.45, pin_y0 + pin_span / 2 - i * 2.54) silk(left_pins[i], 0.75, "right");
        }
        for (b = [[-2.4, 7.0, 1.6, "ESP32-C3", 1.0], [-4.6, 7.6, 2.0, "Super Mini", 1.1]]) sm_under(0, b[0]) {
            color(c_silk()) translate([-b[1] / 2, -b[2] / 2, 0.01]) cube([b[1], b[2], 0.03]);
            color(c_pcb_black()) translate([0, 0, 0.04]) linear_extrude(0.02)
                text(b[3], size = b[4], font = "Liberation Sans", halign = "center", valign = "center", $fn = 8);
        }
    }

    // the USB-C socket (always shown: it decides the cutout)
    translate([usb_x, usb_y, sm_t]) usb_c(usb_w, usb_h, usb_len);

    if (detail) translate([0, 0, sm_t]) {
        // buttons, BOOT left and RST right
        for (x = [-2.4, 3.5]) translate([x, 4.3, 0]) smd_button([3.8, 3.2], h = 1.3, press = 0.4);
        // the ESP32-C3, turned 45 degrees
        translate([0.6, -2.4, 0]) qfn(5, 0.85, 8, rot = 45, label = "ESP32-C3");
        translate([-4.4, -6.5, 0]) smd_crystal([3.2, 2.5], 0.8);            // 40 MHz crystal
        translate([-4.9, -1.2, 0]) sot23(5, rot = 90);                      // 3.3 V regulator
        translate([-5.3, 9.6, 0]) scale(0.75) sot23(3, rot = 90);
        translate([0.6, -9.85, 0]) chip_antenna([6.8, 1.6], 0.9);
        translate([-5.9, 6.6, 0]) smd_led("0603", "red", rot = 90);        // power LED
        translate([4.9, 0.6, 0]) smd_led("0603", "deepskyblue");          // GPIO 8 LED
        // resistors and capacitors
        for (p = [[-4.9, 3.1, "c", 90], [0.9, 3.1, "r", 90], [-4.6, 0.4, "c", 0], [-3.4, 0.4, "r", 0],
                  [-4.6, -3.3, "c", 0], [-3.4, -3.3, "c", 0], [5.7, -6.4, "c", 90], [5.7, -7.6, "c", 90],
                  [4.3, -7.2, "r", 90], [3.1, -0.4, "c", 90], [6.3, -2.0, "r", 0], [6.3, -3.0, "c", 0],
                  [-0.4, -7.2, "c", 90], [1.8, -7.2, "r", 90], [-1.6, 1.4, "c", 0], [2.6, 1.6, "r", 0]])
            translate([p[0], p[1], 0]) smd_passive("0402", p[2], p[3]);
        // labels
        for (i = [0:2])  // only 5V, G and 3.3 are printed on the top
            translate([5.3, pin_y0 + pin_span / 2 - i * 2.54, 0]) silk(right_pins[i], 0.65, "left");
        translate([-row_x + 0.1, -10.6, 0]) silk("21", 0.75);
        translate([row_x - 0.1, -10.6, 0]) silk("0", 0.75);
        translate([-5.0, 4.3, 0]) silk("BOOT", 0.6, rot = 90);
        translate([5.9, 2.7, 0]) silk("RST", 0.6, rot = 90);
    }

    if (headers == "down")
        for (s = [-1, 1]) translate([s * row_x, pin_y0, 0]) mirror([0, 0, 1]) pin_header(8, below = sm_t + 1.5);
    else if (headers == "up")
        for (s = [-1, 1]) translate([s * row_x, pin_y0, sm_t]) pin_header(8, below = sm_t + 1.5);
}

// =================================================================== USB cutout
// Subtract this from the case wall the socket faces. The wall's inside face
// is `gap` mm in front of the socket (0 = touching it), and the wall is
// `wall` mm thick. The hole fits the socket with `clear` play; from the
// outside a wider recess (`plug` = width, height of the cable's plastic plug)
// leaves only `lip` mm of wall, so the cable goes all the way in.
module esp32c3_supermini_usb_cutout(wall = 2, gap = 0, clear = 0.3, plug = [12.4, 6.6], lip = 0.8) {
    module stadium(ww, hh) hull() for (m = [-1, 1]) translate([m * (ww - hh) / 2, 0]) circle(d = hh, $fn = 32);
    zc = sm_t + usb_h / 2;
    translate([usb_x, usb_y - 0.5, zc]) rotate([-90, 0, 0])
        linear_extrude(gap + wall + 1.5) stadium(usb_w + 2 * clear, usb_h + 2 * clear);
    if (lip < wall)
        translate([usb_x, usb_y + gap + lip, zc]) rotate([-90, 0, 0])
            linear_extrude(wall - lip + 1) stadium(plug[0], plug[1]);
}

// ======================================================================= holder
// A tray the board presses into: floor, a back wall, low side walls with
// small crush ribs that grip the board's edges, and two stops at the front
// corners beside the USB socket. Nothing has to bend, so nothing breaks.
// To take the board out, lift it at the gaps in the side walls with a
// fingernail. In a case, the lid or back cover keeps it down.
// The floor is below z = 0 (the board's underside); add it to the case floor.
// Channels under the pin rows leave room for solder, so solder wires from the
// top. `grip`: how much the ribs press into the board's edge (0 = loose).
module esp32c3_supermini_holder(floor = 1.6, wall = 1.2, clear = 0.2, grip = 0.1) {
    x0 = sm_w / 2 + clear;            // inner faces
    y0 = sm_l / 2 + clear;
    top = sm_t + 0.6;                 // walls reach this far above the board's underside
    gap = [-2.5, 2.5];                // fingernail gap in each side wall (y)
    difference() {
        union() {
            // floor
            translate([-x0 - wall, -y0 - wall, -floor]) cube([2 * (x0 + wall), y0 + wall + sm_l / 2, floor]);
            // back wall
            translate([-x0 - wall, -y0 - wall, -floor]) cube([2 * (x0 + wall), wall, floor + top]);
            // side walls, with the fingernail gap
            for (s = [-1, 1], seg = [[-y0, gap[0]], [gap[1], sm_l / 2]])
                translate([s < 0 ? -x0 - wall : x0, seg[0], -floor]) cube([wall, seg[1] - seg[0], floor + top]);
            // front corner stops, beside the USB socket
            for (s = [-1, 1]) translate([s < 0 ? -x0 : x0 - 2.5, y0, -floor])
                cube([2.5, wall, floor + top]);
            // crush ribs on the side walls, with a sloped top to lead the board in
            for (s = [-1, 1], y = [-8.5, 6.5])
                translate([s * x0, y, 0]) mirror([s < 0 ? 1 : 0, 0, 0]) sm_rib(clear + grip, top);
        }
        // room for solder under the pin rows
        for (s = [-1, 1]) translate([s * row_x - 1.4, -y0 + 0.2, -1.0]) cube([2.8, 2 * y0 - 0.4, 2]);
    }
}

// A small vertical rib on a right-hand wall (x = 0 is the wall's inner face),
// sticking out `d` towards -x, from the floor up to `top`.
module sm_rib(d, top, w = 1.6) {
    translate([0, w / 2, 0]) rotate([90, 0, 0]) linear_extrude(w)
        polygon([[0.01, -0.01], [-d, -0.01], [-d, top - 0.5], [0.01, top]]);
}

// place something on the underside, readable from below
module sm_under(x, y) translate([x, y, 0]) rotate([0, 180, 0]) children();

// ========================================================= shown when opened
module esp32c3_supermini_demo() {
    esp32c3_supermini();
    color("#d6a24a") esp32c3_supermini_holder();
    // a piece of case wall with the cutout
    color("#9aa3ab", 0.9) difference() {
        translate([-12, usb_y, -1.6]) cube([24, 2, 9]);
        esp32c3_supermini_usb_cutout(wall = 2);
    }
}

show = "demo";  // demo | board | holder
if (show == "board") esp32c3_supermini();
else if (show == "holder") color("#d6a24a") esp32c3_supermini_holder();
else esp32c3_supermini_demo();
