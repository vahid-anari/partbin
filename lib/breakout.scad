// partbin - shared pieces for small breakout boards: a PCB with mounting
// holes and a row of pins, pin headers, mounts, and cutouts for sensors.
//
//   use <../lib/breakout.scad>
//
// Same convention as every module: parts up, the board centred on x/y, its
// underside at z = 0. The pin row runs along x.

use <parts.scad>

// ------------------------------------------------------------------- board
// size [x, y], t thickness, r corner radius.
// holes: [[x, y], ...] mounting holes, hole_d drill, ring_d copper ring (0 = none).
// pins: n pins, 2.54 mm apart, centred on x = pins_x, at y = pins_y.
module bo_pcb(size, t = 1.6, r = 0.5, holes = [], hole_d = 3.0, ring_d = 0,
              n = 4, pins_x = 0, pins_y = 0, color = [0.06, 0.30, 0.66]) {
    pcb(size, t, concat(
            [for (h = holes) [h[0], h[1], hole_d, ring_d]],
            [for (i = [0:n - 1]) [pins_x + (i - (n - 1) / 2) * 2.54, pins_y, 1.0, 1.7]]),
        color, r);
}

// Pin header soldered into the pin row: "down" (pins below the board, the
// usual way), "up", or "none".
module bo_headers(n, pins_x, pins_y, t, mode = "down") {
    if (mode == "down")
        translate([pins_x, pins_y, 0]) rotate([0, 0, 90]) mirror([0, 0, 1]) pin_header(n, below = t + 1.5);
    else if (mode == "up")
        translate([pins_x, pins_y, t]) rotate([0, 0, 90]) pin_header(n, below = t + 1.5);
}

// Text on the underside, readable from below.
module bo_under(x, y) translate([x, y, 0]) rotate([0, 180, 0]) children();

// -------------------------------------------------------------------- mounts
// Posts under the mounting holes, from z = -h up to the board's underside.
// style "peg": a pin goes up through the hole and the board presses on
//   (snug = how much smaller than the hole; 0.15 holds by friction).
// style "screw": a pilot hole for a self-tapping screw (screw_d).
// Add them to the case floor.
module bo_mounts(holes, hole_d, t, h = 3, style = "peg", wall = 1.4, snug = 0.15, screw_d = 0) {
    sd = screw_d > 0 ? screw_d : hole_d * 0.8;
    for (p = holes) translate([p[0], p[1], 0]) {
        difference() {
            translate([0, 0, -h]) cylinder(d = hole_d + 2 * wall, h = h, $fn = 40);
            if (style == "screw") translate([0, 0, -h + 0.8]) cylinder(d = sd, h = h, $fn = 24);
        }
        if (style == "peg") {
            pd = hole_d - snug;
            cylinder(d = pd, h = t + 0.3, $fn = 32);
            translate([0, 0, t + 0.3]) cylinder(d1 = pd, d2 = pd - 0.8, h = 0.4, $fn = 32);  // lead-in
        }
    }
}

// ------------------------------------------------------------------ cutouts
// For a sensor that looks up. The wall (or lid) above the board has its
// inside face at z0 and is `depth` thick.
//
// A round window over a light sensor, widening outwards by `flare` degrees
// so it sees a wide angle of the room.
module bo_window(x, y, z0, depth, d = 3, flare = 35) {
    translate([x, y, z0 - 0.5])
        cylinder(d1 = d, d2 = d + 2 * (depth + 1) * tan(flare), h = depth + 1.5, $fn = 40);
}

// Slots over a sensor that needs air (BME280): `area` [x, y] covered by
// slots along x, `slot` wide with `bar` between them.
module bo_vents(x, y, z0, depth, area = [8, 6], slot = 1.2, bar = 1.2) {
    n = max(1, floor((area[1] + bar) / (slot + bar)));
    span = n * slot + (n - 1) * bar;
    for (i = [0:n - 1])
        translate([x - area[0] / 2, y - span / 2 + i * (slot + bar), z0 - 0.5])
            hull() for (dx = [slot / 2, area[0] - slot / 2])
                translate([dx, slot / 2, 0]) cylinder(d = slot, h = depth + 1.5, $fn = 20);
}

// ---------------------------------------------------------------- demo scene
// The board on its mounts, standing on a piece of floor, with a piece of
// see-through lid above it holding the cutout. Used when a module file is
// opened on its own.
module bo_demo(size, mount_h, lid_z, lid_t = 2) {
    color("#d6a24a") translate([-size[0] / 2 - 3, -size[1] / 2 - 3, -mount_h - 1.6]) cube([size[0] + 6, size[1] + 6, 1.6]);
    children(0);                                        // board
    color("#d6a24a") children(1);                       // mounts
    color("#9aa3ab", 0.55) difference() {               // lid with the cutout
        translate([-size[0] / 2 - 3, -size[1] / 2 - 3, lid_z]) cube([size[0] + 6, size[1] + 6, lid_t]);
        children(2);
    }
}
