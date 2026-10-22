// partbin - shared pieces for display modules: glass panels, LED matrix
// blocks, 7-segment displays, the LCD1602 frame, a window cutout for the
// case and a holder that grips a board by its edges.
//
//   use <../lib/display.scad>
//
// Same convention as every module: parts up (the display faces +z), the
// board centred on x/y, its underside at z = 0.

use <parts.scad>

function c_glass() = [0.04, 0.04, 0.06];
function c_screen() = [0.08, 0.10, 0.16];

// ------------------------------------------------------------ glass panel
// A TFT/OLED glass panel lying on the board: outline [x, y], thickness t,
// with the active (lit) area [x, y] centred at `off` from the panel centre.
module glass_panel(outline, t = 2.4, active, off = [0, 0]) {
    color(c_glass()) translate([-outline[0] / 2, -outline[1] / 2, 0]) cube([outline[0], outline[1], t]);
    color(c_screen()) translate([off[0] - active[0] / 2, off[1] - active[1] / 2, t]) cube([active[0], active[1], 0.02]);
}

// ------------------------------------------------------------- LED matrix
// An 8 x 8 LED matrix block (1088AS-style): `size` square, h tall, with
// the 64 round LEDs on top.
module led_matrix(size = 32, h = 7, led = [0.55, 0.06, 0.06], body = [0.12, 0.12, 0.12]) {
    p = size / 8;
    color(body) translate([-size / 2, -size / 2, 0]) cube([size, size, h]);
    color(led) for (i = [0:7], j = [0:7])
        translate([-size / 2 + p / 2 + i * p, -size / 2 + p / 2 + j * p, h]) cylinder(d = p * 0.75, h = 0.05, $fn = 16);
}

// ------------------------------------------------------- 7-segment digits
// A block of `digits` 7-segment digits, `size` [x, y], h tall. `seg` is the
// (unlit) segment colour.
function seg7_color(name) =
      name == "green" ? [0.10, 0.40, 0.10] : name == "blue" ? [0.10, 0.20, 0.55]
    : name == "white" ? [0.75, 0.75, 0.72] : name == "yellow" ? [0.55, 0.50, 0.10] : [0.45, 0.06, 0.06];
// LED colours for the matrices
function led_color(name) =
      name == "green" ? [0.08, 0.45, 0.10] : name == "blue" ? [0.10, 0.20, 0.60]
    : name == "white" ? [0.80, 0.80, 0.78] : name == "yellow" ? [0.60, 0.55, 0.10] : [0.55, 0.06, 0.06];
module seg7_display(digits = 4, size = [30, 14], h = 7.2, colon = true, seg = [0.35, 0.05, 0.05]) {
    color([0.92, 0.92, 0.92]) translate([-size[0] / 2, -size[1] / 2, 0]) cube([size[0], size[1], h - 0.05]);
    color([0.12, 0.12, 0.12]) translate([-size[0] / 2, -size[1] / 2, h - 0.05]) cube([size[0], size[1], 0.05]);
    dw = size[0] / digits;
    sh = size[1] * 0.68;  sw = dw * 0.5;  st = 0.7;
    color(seg) for (d = [0:digits - 1]) translate([-size[0] / 2 + dw * (d + 0.5), 0, h]) {
        for (y = [-1, 0, 1]) translate([-sw / 2, y * sh / 2 - st / 2, 0]) cube([sw, st, 0.03]);       // a g d
        for (x = [-1, 1], y = [-1, 1]) translate([x * sw / 2 - st / 2, y < 0 ? -sh / 2 : 0, 0]) cube([st, sh / 2, 0.03]);
        translate([sw / 2 + 0.7, -sh / 2 - 0.4, 0]) cylinder(d = 0.8, h = 0.03, $fn = 10);         // dot
    }
    if (colon) color(seg) for (y = [-1.6, 1.6]) translate([0, y, h]) cylinder(d = 0.8, h = 0.03, $fn = 10);
}

// ----------------------------------------------------------------- windows
// A rectangular window in the lid above a display. The lid's inside face is
// at z0 and it is `depth` thick; `size` [x, y] is the opening at the inside,
// and it widens outwards by `flare` mm on each side (0 = straight walls).
module rect_window(x, y, z0, depth, size, flare = 0, r = 0.5) {
    translate([x, y, z0 - 0.5]) hull() {
        linear_extrude(0.01) offset(r) offset(-r) square(size, center = true);
        translate([0, 0, depth + 1.0]) linear_extrude(0.01)
            offset(r + flare * (depth + 1) / depth) offset(-r) square(size, center = true);
    }
}

// ----------------------------------------------------------------- holder
// For boards without mounting holes: a ledge under the board's edges (`h`
// tall, so parts underneath have room), low walls around it with gaps to
// get a fingernail in, and `top` mm of wall above the board's top.
// The display is meant to be pressed against the lid from behind, so the
// walls only locate it. Add it to the case floor.
module edge_holder(size, t, h = 6, ledge = 1.5, wall = 1.2, clear = 0.3, top = 0.8) {
    x0 = size[0] / 2 + clear;  y0 = size[1] / 2 + clear;
    difference() {
        translate([-x0 - wall, -y0 - wall, -h]) cube([2 * (x0 + wall), 2 * (y0 + wall), h + t + top]);
        // room for the board
        translate([-x0, -y0, 0]) cube([2 * x0, 2 * y0, t + top + 1]);
        // room under it, inside the ledge
        translate([-x0 + ledge, -y0 + ledge, -h - 1]) cube([2 * (x0 - ledge), 2 * (y0 - ledge), h + 2]);
        // fingernail gaps in the middle of each side, down to the board's underside
        for (a = [0, 90]) rotate([0, 0, a]) {
            g = min(8, (a == 0 ? size[0] : size[1]) / 4);
            translate([-g / 2, -50, 0]) cube([g, 100, t + top + 1]);
        }
    }
}

// --------------------------------------------------------------- SD socket
// A push-push microSD socket (metal), its opening towards -y.
module microsd_socket() {
    color(c_tin()) translate([-7, -7.5, 0]) cube([14, 15, 1.8]);
    color(c_plastic()) translate([-5.5, -7.6, 0.3]) cube([11, 0.2, 1.2]);
}
