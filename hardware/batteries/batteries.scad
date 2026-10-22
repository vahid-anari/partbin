// Batteries and battery holders:
//
//   cell_18650();                        an 18650 cell (65 x 18.5 mm)
//   holder_18650(slots = 1);             the black box holder, 1-4 slots; pins = "pcb" or "wire"
//   holder_18650_cutout(slots)           a pocket for the holder in the case floor, subtract it
//   holder_cr2032();                     the round black CR2032 holder (with the cell)
//   lipo_pouch(size = [8, 50, 60]);      a LiPo pouch cell, [thickness, width, length]
//                                        (2500 mAh is usually 8 x 50 x 60, "805060")
//
//   use <partbin/hardware/batteries/batteries.scad>
//
// Where they sit: lying flat, centred on x = y = 0, the bottom at z = 0,
// the long side along x, + at +x.

use <../../lib/parts.scad>

// ------------------------------------------------------------------- typical
c_d      = 18.5;    // 18650
c_l      = 65.0;
h_len    = 77.0;    // holder outside length
h_slot   = 20.7;    // per slot
h_h      = 18.6;    // holder height
h_floor  = 1.2;
h_holes  = 3.0;     // two holes in the floor of each slot
h_hole_x = 22.0;

function holder_18650_size(slots = 1) = [h_len, h_slot * slots, h_h];
function holder_18650_holes(slots = 1) = [for (s = [0:slots - 1], x = [-h_hole_x, h_hole_x]) [x, (s - (slots - 1) / 2) * h_slot]];

module cell_18650(wrap = [0.15, 0.35, 0.75]) {
    rotate([0, 90, 0]) translate([-c_d / 2, 0, -c_l / 2]) {
        color(wrap) cylinder(d = c_d, h = c_l - 1, $fn = 64);
        color(c_tin()) translate([0, 0, c_l - 1]) cylinder(d = 6, h = 1, $fn = 24);      // + button
        color(c_tin()) translate([0, 0, -0.01]) cylinder(d = c_d - 2, h = 0.3, $fn = 48);
    }
}

module holder_18650(slots = 1, pins = "pcb", cells = true) {
    w = h_slot * slots;
    color([0.08, 0.08, 0.08]) difference() {
        translate([-h_len / 2, -w / 2, 0]) cube([h_len, w, h_h]);
        for (s = [0:slots - 1]) translate([0, (s - (slots - 1) / 2) * h_slot, 0]) {
            translate([-c_l / 2 - 1, -c_d / 2 - 0.4, h_floor]) cube([c_l + 2, c_d + 0.8, h_h]);
            for (x = [-h_hole_x, h_hole_x]) translate([x, 0, -1]) cylinder(d = h_holes, h = 3, $fn = 20);
        }
    }
    for (s = [0:slots - 1]) translate([0, (s - (slots - 1) / 2) * h_slot, 0]) {
        color(c_tin()) {
            translate([c_l / 2 + 0.5, -4, h_floor]) cube([0.4, 8, 12]);     // + contact
            translate([-c_l / 2 - 1.5, -2, h_floor + 2]) cube([1.5, 4, 8]); // - spring
        }
        if (cells) translate([0, 0, h_floor]) cell_18650();
    }
    if (pins == "pcb") color(c_tin()) for (x = [-h_len / 2 + 2, h_len / 2 - 2]) translate([x - 0.4, -0.4, -4]) cube([0.8, 0.8, 4]);
    else color("red") translate([h_len / 2, 2, 3]) rotate([0, 90, 0]) cylinder(d = 1.6, h = 40, $fn = 12);
    if (pins != "pcb") color("black") translate([-h_len / 2, -2, 3]) rotate([0, -90, 0]) cylinder(d = 1.6, h = 40, $fn = 12);
}

// A pocket in the case floor for the holder to drop into (`depth` deep).
module holder_18650_cutout(slots = 1, depth = 3, clear = 0.4) {
    translate([-h_len / 2 - clear, -h_slot * slots / 2 - clear, -depth]) cube([h_len + 2 * clear, h_slot * slots + 2 * clear, depth + 0.01 + 50]);
}

module holder_cr2032(cell = true) {
    color([0.08, 0.08, 0.08]) difference() {
        union() { cylinder(d = 24.0, h = 5.6, $fn = 64); translate([-3.5, -14, 0]) cube([7, 6, 4]); }
        translate([0, 0, 1.2]) cylinder(d = 20.6, h = 6, $fn = 64);
        translate([-6, 6, 1.2]) cube([12, 10, 6]);
    }
    color(c_tin()) translate([-2, -16, 1]) cube([4, 10, 0.3]);
    color(c_tin()) for (y = [-12.5, 0]) translate([-0.4, y - 0.4, -3.5]) cube([0.8, 0.8, 3.5]);
    if (cell) translate([0, 0, 1.2]) color([0.8, 0.8, 0.82]) cylinder(d = 20, h = 3.2, $fn = 64);
}

module lipo_pouch(size = [8, 50, 60], tab = true) {
    color([0.75, 0.75, 0.8]) hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (size[2] / 2 - 1), sy * (size[1] / 2 - 1), 0]) cylinder(r = 1, h = size[0], $fn = 16);
    if (tab) {
        color([0.85, 0.85, 0.85]) translate([size[2] / 2, -size[1] / 2 + 3, size[0] / 2 - 0.3]) cube([5, size[1] - 6, 0.6]);
        color([0.1, 0.4, 0.2]) translate([size[2] / 2 + 1, -8, size[0] / 2 - 1.5]) cube([4, 16, 3]);   // protection board
    }
}

show = "demo";
translate([0, 40, 0]) holder_18650(1);
holder_18650(2, "wire");
translate([-55, -35, 0]) holder_cr2032();
translate([0, -45, 0]) lipo_pouch();
