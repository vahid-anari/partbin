// partbin - shared shapes for the electronic parts on a module.
//
//   use <../lib/parts.scad>
//
// Every part sits on the board: its bottom is at z = 0, centred on x/y,
// unless said otherwise. All sizes in mm. These are "looks" shapes: right
// size and colour, not exact copies.

// ------------------------------------------------------------------ colours
// Functions, so files that `use` this one can have them too.
function c_pcb_black() = [0.07, 0.07, 0.08];
function c_silk() = [0.95, 0.95, 0.95];
function c_gold() = [0.85, 0.68, 0.30];
function c_tin() = [0.78, 0.78, 0.80];
function c_chip() = [0.13, 0.13, 0.14];
function c_res() = [0.10, 0.10, 0.10];
function c_cap() = [0.72, 0.58, 0.40];
function c_plastic() = [0.10, 0.10, 0.10];
function c_pcb_blue() = [0.06, 0.30, 0.66];
function c_pcb_purple() = [0.40, 0.12, 0.52];

// ---------------------------------------------------------------------- PCB
// Rectangle of `size` = [x, y], thickness t, from z = 0 up to z = t.
// holes: list of [x, y, drill, pad] (pad 0 = no copper ring).
module pcb(size, t = 1.6, holes = [], color = c_pcb_black(), r = 0.3) {
    difference() {
        color(color) linear_extrude(t) offset(r) offset(-r) square(size, center = true);
        for (h = holes) translate([h[0], h[1], -1]) cylinder(d = h[2], h = t + 2, $fn = 20);
    }
    // copper rings around the holes, both sides
    for (h = holes) if (h[3] > 0) color(c_gold()) translate([h[0], h[1], 0])
        for (z = [-0.02, t]) translate([0, 0, z]) difference() {
            cylinder(d = h[3], h = 0.02, $fn = 24);
            translate([0, 0, -1]) cylinder(d = h[2], h = 2, $fn = 20);
        }
}

// Silkscreen text lying on the board (z = 0 is the board surface).
module silk(txt, size = 0.8, halign = "center", valign = "center", rot = 0) {
    color(c_silk()) rotate([0, 0, rot]) linear_extrude(0.02)
        text(txt, size = size, font = "Liberation Sans:style=Bold",
             halign = halign, valign = valign, $fn = 8);
}

// ---------------------------------------------------------- small SMD parts
// Resistor or capacitor. code: "0402", "0603", "0805", "1206".
function smd_size(code) =
      code == "0402" ? [1.0, 0.5, 0.35]
    : code == "0603" ? [1.6, 0.8, 0.45]
    : code == "0805" ? [2.0, 1.25, 0.5]
    : code == "1206" ? [3.2, 1.6, 0.55]
    : [1.0, 0.5, 0.35];

module smd_passive(code = "0402", kind = "r", rot = 0) {
    s = smd_size(code);
    e = s[0] * 0.2;  // end caps
    rotate([0, 0, rot]) {
        color(kind == "c" ? c_cap() : c_res()) translate([-s[0] / 2 + e, -s[1] / 2, 0]) cube([s[0] - 2 * e, s[1], s[2]]);
        color(c_tin()) for (m = [-1, 1]) translate([m * (s[0] / 2 - e / 2) - e / 2, -s[1] / 2, 0]) cube([e, s[1], s[2]]);
    }
}

// SMD LED with a clear/white body and a coloured dot.
module smd_led(code = "0603", glow = "blue", rot = 0) {
    s = smd_size(code);
    rotate([0, 0, rot]) {
        color([0.95, 0.95, 0.9]) translate([-s[0] / 2, -s[1] / 2, 0]) cube([s[0], s[1], s[2] * 0.6]);
        color(glow, 0.8) translate([-s[0] / 4, -s[1] / 2, s[2] * 0.6]) cube([s[0] / 2, s[1], s[2] * 0.4]);
    }
}

// SOT-23 (3, 5 or 6 legs).
module sot23(legs = 3, rot = 0) {
    rotate([0, 0, rot]) {
        color(c_chip()) translate([-1.45, -0.8, 0.1]) cube([2.9, 1.6, 1.0]);
        n_top = legs == 3 ? 1 : legs == 5 ? 2 : 3;
        n_bot = legs == 3 ? 2 : 3;
        color(c_tin()) {
            for (i = [0:n_bot - 1]) translate([(n_bot == 2 ? (i - 0.5) * 1.9 : (i - 1) * 0.95) - 0.2, -1.3, 0]) cube([0.4, 0.6, 0.15]);
            for (i = [0:n_top - 1]) translate([(n_top == 1 ? 0 : n_top == 2 ? (i - 0.5) * 1.9 : (i - 1) * 0.95) - 0.2, 0.7, 0]) cube([0.4, 0.6, 0.15]);
        }
    }
}

// QFN / QFP-style square chip with a row of pads on each side.
module qfn(size = 5, h = 0.85, pads = 8, rot = 0, label = "") {
    rotate([0, 0, rot]) {
        color(c_chip()) translate([-size / 2, -size / 2, 0]) cube([size, size, h]);
        p = size / (pads + 1);
        color(c_tin()) for (a = [0:3]) rotate([0, 0, a * 90])
            for (i = [1:pads]) translate([-size / 2 + i * p - p * 0.2, -size / 2 - 0.05, 0]) cube([p * 0.4, 0.3, 0.2]);
        if (label != "") translate([0, 0, h]) color([0.5, 0.5, 0.5]) linear_extrude(0.01)
            text(label, size = size / 7, font = "Liberation Sans", halign = "center", valign = "center", $fn = 8);
        color([0.3, 0.3, 0.3]) translate([-size / 2 + 0.6, size / 2 - 0.6, h]) cylinder(d = 0.4, h = 0.01, $fn = 12);
    }
}

// Metal-can SMD crystal (3225 by default).
module smd_crystal(size = [3.2, 2.5], h = 0.8, rot = 0) {
    rotate([0, 0, rot]) {
        color(c_tin()) translate([-size[0] / 2, -size[1] / 2, 0]) cube([size[0], size[1], h]);
        color([0.6, 0.6, 0.62]) translate([-size[0] / 2 + 0.25, -size[1] / 2 + 0.25, h]) cube([size[0] - 0.5, size[1] - 0.5, 0.01]);
    }
}

// Ceramic chip antenna: coloured body with metal ends.
module chip_antenna(size = [6.8, 1.6], h = 0.9, body = [0.75, 0.12, 0.12], rot = 0) {
    e = 0.9;
    rotate([0, 0, rot]) {
        color(body) translate([-size[0] / 2 + e, -size[1] / 2, 0]) cube([size[0] - 2 * e, size[1], h]);
        color(c_silk()) for (m = [-1, 1]) translate([m * (size[0] / 2 - e / 2) - e / 2, -size[1] / 2, 0]) cube([e, size[1], h]);
    }
}

// Small SMD tact switch: metal frame, body and a round button.
// size [x, y], body height h, button sticks up `press` more.
module smd_button(size = [3.8, 3.2], h = 1.4, press = 0.4, d = 1.2, rot = 0) {
    rotate([0, 0, rot]) {
        color([0.85, 0.85, 0.85]) translate([-size[0] / 2, -size[1] / 2, 0]) cube([size[0], size[1], h * 0.75]);
        color(c_tin()) translate([-size[0] / 2 + 0.3, -size[1] / 2 + 0.3, h * 0.75]) cube([size[0] - 0.6, size[1] - 0.6, h * 0.25]);
        color(c_plastic()) translate([0, 0, h]) cylinder(d = d, h = press, $fn = 24);
        color(c_tin()) for (mx = [-1, 1], my = [-1, 1])
            translate([mx * (size[0] / 2 + 0.2) - 0.25, my * (size[1] / 2 - 0.6) - 0.25, 0]) cube([0.5, 0.5, 0.15]);
    }
}

// ------------------------------------------------------------------ USB-C
// USB-C receptacle lying on the board. Its front face is at y = 0 and it
// points towards +y; the body goes back to y = -len. w x h is the metal shell.
module usb_c(w = 8.94, h = 3.26, len = 7.35) {
    r = h / 2;
    module stadium(ww, hh) hull() for (m = [-1, 1]) translate([m * (ww - hh) / 2, hh / 2]) circle(d = hh, $fn = 32);
    color(c_tin()) difference() {
        translate([0, 0, 0]) rotate([90, 0, 0]) linear_extrude(len) stadium(w, h);
        translate([0, 0.01, 0]) rotate([90, 0, 0]) linear_extrude(len - 1) translate([0, 0.25]) stadium(w - 0.5, h - 0.5);
    }
    // the tongue inside
    color(c_plastic()) translate([-(w - 2.6) / 2, -len + 0.5, h / 2 - 0.35]) cube([w - 2.6, len - 1.0, 0.7]);
    // contacts at the back, soldered to the board
    color(c_tin()) for (i = [0:11]) translate([(i - 5.5) * 0.5 - 0.12, -len - 0.6, 0]) cube([0.25, 0.8, 0.12]);
}

// ------------------------------------------------------------- pin headers
// A straight 2.54 mm header with n pins along y, centred at x/y = 0.
// It stands on the board's surface at z = 0 and points up (+z).
// pin: total pin length; spacer: the black plastic.
module pin_header(n, pitch = 2.54, pin = 11.5, spacer = 2.5, below = 3.0) {
    color(c_plastic()) translate([-1.27, -n * pitch / 2, 0]) cube([2.54, n * pitch, spacer]);
    color(c_gold()) for (i = [0:n - 1]) translate([-0.32, (i - (n - 1) / 2) * pitch - 0.32, -below]) cube([0.64, 0.64, pin]);
}

// ---------------------------------------------------------- more SMD chips
// Small IC with legs on its two short sides (x), n legs per side.
// Used for SOT-363 (SC-70-6), WSOF6 (BH1750) and similar.
module smd_ic(body = [2.0, 1.25, 0.9], n = 3, pitch = 0.65, leg = 0.35, rot = 0) {
    rotate([0, 0, rot]) {
        color(c_chip()) translate([-body[0] / 2, -body[1] / 2, 0.05]) cube([body[0], body[1], body[2] - 0.05]);
        color(c_tin()) for (s = [-1, 1], i = [0:n - 1])
            translate([s * (body[0] / 2 + leg / 2) - leg / 2 - (s < 0 ? 0 : 0), (i - (n - 1) / 2) * pitch - 0.12, 0]) cube([leg, 0.24, 0.15]);
    }
}

// Resistor array (4 x 0603 in one 1206-size body), pads on the long sides.
module resistor_array(rot = 0) {
    rotate([0, 0, rot]) {
        color(c_res()) translate([-1.6, -0.8, 0]) cube([3.2, 1.6, 0.45]);
        color(c_tin()) for (s = [-1, 1], i = [0:3]) translate([(i - 1.5) * 0.8 - 0.2, s * 0.8 - (s < 0 ? 0.3 : 0), 0]) cube([0.4, 0.3, 0.45]);
    }
}

// Bosch BME280 / BMP280: a metal lid with a vent hole. size [x, y].
module bosch_can(size = [2.5, 2.5], h = 0.93, rot = 0) {
    rotate([0, 0, rot]) {
        color(c_tin()) translate([-size[0] / 2, -size[1] / 2, 0]) cube([size[0], size[1], h]);
        color([0.2, 0.2, 0.2]) translate([-size[0] / 2 + 0.45, size[1] / 2 - 0.45, h]) cylinder(d = 0.35, h = 0.01, $fn = 12);
    }
}

// Vishay VEML7700: a clear block (6.8 x 2.35 x 3.0) with the chip inside,
// long side along x.
module veml7700_pkg(rot = 0) {
    rotate([0, 0, rot]) {
        color([0.92, 0.92, 0.96, 0.55]) translate([-3.4, -1.175, 0.1]) cube([6.8, 2.35, 2.9]);
        color([0.45, 0.35, 0.55]) translate([-0.4, -0.4, 1.6]) cube([0.8, 0.8, 0.3]);
        color(c_tin()) for (x = [-2.5, 0, 2.5], s = [-1, 1]) translate([x - 0.4, s * 0.75 - 0.3, 0]) cube([0.8, 0.6, 0.12]);
    }
}

// A right-angle 2.54 mm header with n pins along y, soldered on the surface
// at z = 0 (pads at x = y = 0 ... centred), pins pointing towards +x and
// sticking out `reach` mm past the pad row. Mirror it for -x.
module pin_header_angle(n, reach = 7, below = 2.6) {
    color(c_plastic()) translate([0.3, -n * 1.27, 0]) cube([2.54, n * 2.54, 2.54]);
    color(c_gold()) for (i = [0:n - 1]) translate([0, (i - (n - 1) / 2) * 2.54, 0]) {
        translate([-0.32, -0.32, -below]) cube([0.64, 0.64, below + 1.59]);
        translate([-0.32, -0.32, 0.63]) cube([reach + 0.32, 0.64, 0.64]);
    }
}

// SOIC chip (8, 16, 20, 24 legs...), long side along x. w = body width.
module soic(legs = 16, w = 3.9, h = 1.6, pitch = 1.27, rot = 0) {
    n = legs / 2;  l = n * pitch + 0.4;
    rotate([0, 0, rot]) {
        color(c_chip()) translate([-l / 2, -w / 2, 0.1]) cube([l, w, h - 0.1]);
        color(c_tin()) for (s = [-1, 1], i = [0:n - 1])
            translate([(i - (n - 1) / 2) * pitch - 0.2, s < 0 ? -w / 2 - 1.0 : w / 2, 0]) cube([0.4, 1.0, 0.25]);
    }
}

// Electrolytic capacitor (can standing up).
module elco(d = 5, h = 7, col = [0.1, 0.1, 0.45]) {
    color(col) cylinder(d = d, h = h - 0.3, $fn = 32);
    color(c_tin()) translate([0, 0, h - 0.3]) cylinder(d = d - 0.6, h = 0.3, $fn = 32);
}

// Small blue trimmer potentiometer (3362-style) with its slot on top.
module trimpot(size = 6.6, h = 4.5) {
    color([0.15, 0.35, 0.85]) translate([-size / 2, -size / 2, 0]) cube([size, size, h - 0.6]);
    color([0.9, 0.9, 0.9]) translate([0, 0, h - 0.6]) difference() {
        cylinder(d = size * 0.6, h = 0.6, $fn = 24);
        translate([-size * 0.35, -0.3, 0.2]) cube([size * 0.7, 0.6, 1]);
    }
}
