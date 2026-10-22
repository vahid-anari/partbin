// Parts that go in a case wall, each with the hole to cut for it:
//
//   rocker_kcd11();          mini rocker switch 10 x 15 (KCD11)      rocker_kcd11_cutout(wall)
//   rocker_kcd1();           rocker switch 21 x 15 (KCD1)            rocker_kcd1_cutout(wall)
//   slide_ss12d00(handle);   SS12D00 slide switch (1P2T, 3 pins)     slide_ss12d00_cutout(wall)
//   slide_mss22d18();        MSS22D18 slide switch (2P2T, 6 pins)    slide_mss22d18_cutout(wall)
//   tact6(h);                6 x 6 tact switch, h = 4.3 ... 13      tact6_cutout(wall, d)
//   selflock_85();           8.5 x 8.5 self-locking push switch      selflock_85_cutout(wall)
//   dc_jack_panel();         5.5 x 2.1 DC jack with nut (DC-022)     dc_jack_panel_cutout(wall)
//   speaker_2831();          28 x 31 mm 3 W speaker                  speaker_2831_cutout(wall)
//
//   use <partbin/modules/panel_parts.scad>
//
// Where they sit: the wall's outside face is at z = 0 and the wall goes
// down to z = -wall; each part pokes up through it from inside, centred on
// x = y = 0 (except slide and tact switches, which stand on a PCB at z = 0:
// see their notes). Typical sizes; check the snap-in ones against yours.

use <../lib/parts.scad>

// ============================================================ rocker switches
// The bezel sits on the wall's outside face; the body snaps in through the
// rectangular hole (the clips grip walls ~1-3 mm thick).
module _rocker(bezel, cut, body_d, red = false) {
    color([0.08, 0.08, 0.08]) {
        translate([-bezel[0] / 2, -bezel[1] / 2, 0]) cube([bezel[0], bezel[1], 2]);
        translate([-cut[0] / 2 + 0.2, -cut[1] / 2 + 0.2, -body_d]) cube([cut[0] - 0.4, cut[1] - 0.4, body_d]);
    }
    color(red ? [0.75, 0.1, 0.1] : [0.12, 0.12, 0.12]) translate([0, 0, 2]) rotate([0, 8, 0]) translate([-cut[0] / 2 + 1, -cut[1] / 2 + 1, 0]) cube([cut[0] - 2, cut[1] - 2, 3.5]);
    color(c_tin()) for (x = [-cut[0] / 4, cut[0] / 4]) translate([x - 0.3, -1.5, -body_d - 5]) cube([0.6, 3, 5]);
}
module rocker_kcd11(red = false) { _rocker([15, 10], [13, 8.6], 10, red); }
module rocker_kcd11_cutout(wall = 2) { translate([-6.6, -4.4, -wall - 1]) cube([13.2, 8.8, wall + 2]); }
module rocker_kcd1(red = false) { _rocker([21, 15], [19, 12.8], 14, red); }
module rocker_kcd1_cutout(wall = 2) { translate([-9.6, -6.5, -wall - 1]) cube([19.2, 13.0, wall + 2]); }

// ============================================================ slide switches
// They solder to a PCB lying parallel to the wall; the PCB's top is at
// z = -wall - gap, the handle comes up through a slot.
module slide_ss12d00(handle = 3, gap = 0, wall = 2) {
    translate([0, 0, -wall - gap - 3.5]) {
        color(c_tin()) translate([-4.3, -1.8, 0]) cube([8.6, 3.6, 3.5]);
        color([0.1, 0.1, 0.1]) translate([-0.75, -0.75, 3.5]) cube([1.5, 1.5, handle]);
        color(c_tin()) for (x = [-2, 0, 2]) translate([x - 0.25, -0.25, -3.5]) cube([0.5, 0.5, 3.5]);
    }
}
module slide_ss12d00_cutout(wall = 2, travel = 3) { translate([-(travel + 2) / 2, -1.1, -wall - 1]) cube([travel + 2, 2.2, wall + 2]); }
module slide_mss22d18(handle = 2, gap = 0, wall = 2) {
    translate([0, 0, -wall - gap - 4.0]) {
        color(c_tin()) translate([-4.3, -2.2, 0]) cube([8.6, 4.4, 4.0]);
        color([0.1, 0.1, 0.1]) translate([-0.75, -0.75, 4.0]) cube([1.5, 1.5, handle]);
        color(c_tin()) for (x = [-2, 0, 2], y = [-1.25, 1.25]) translate([x - 0.25, y - 0.25, -3.5]) cube([0.5, 0.5, 3.5]);
    }
}
module slide_mss22d18_cutout(wall = 2, travel = 2) { translate([-(travel + 2) / 2, -1.1, -wall - 1]) cube([travel + 2, 2.2, wall + 2]); }

// ============================================================== push buttons
// tact6(h) itself comes from lib/parts.scad (standing on a PCB at z = 0).
module tact6_cutout(wall = 2, d = 4.0) { translate([0, 0, -wall - 1]) cylinder(d = d, h = wall + 2, $fn = 32); }

module selflock_85(pressed = false) {
    color([0.2, 0.2, 0.2]) translate([-4.25, -4.25, -11]) cube([8.5, 8.5, 9]);
    color([0.85, 0.85, 0.85]) translate([0, 0, -2]) cylinder(d = 3.4, h = pressed ? 2 : 3.5, $fn = 24);
    color(c_tin()) for (x = [-2.5, 0, 2.5], y = [-2.5, 2.5]) translate([x - 0.3, y - 0.15, -15]) cube([0.6, 0.3, 4]);
}
module selflock_85_cutout(wall = 2, d = 4.5) { translate([0, 0, -wall - 1]) cylinder(d = d, h = wall + 2, $fn = 32); }

// ==================================================================== DC jack
// Panel-mount 5.5 x 2.1 female jack: M8 thread through the wall, a nut
// inside, the flange outside.
module dc_jack_panel() {
    color([0.12, 0.12, 0.12]) translate([0, 0, 0]) cylinder(d = 10.8, h = 2.0, $fn = 6);   // flange
    color(c_tin()) translate([0, 0, -9]) difference() { cylinder(d = 8, h = 9, $fn = 40); translate([0, 0, 4]) cylinder(d = 5.6, h = 6, $fn = 32); }
    color(c_tin()) translate([0, 0, -6]) cylinder(d = 12.5, h = 2, $fn = 6);               // nut
    color([0.12, 0.12, 0.12]) translate([0, 0, -18]) cylinder(d = 8, h = 9, $fn = 32);
    color(c_tin()) translate([0, 0, 0.5]) cylinder(d = 2.0, h = 1.2, $fn = 16);
}
module dc_jack_panel_cutout(wall = 2, d = 8.2) { translate([0, 0, -wall - 1]) cylinder(d = d, h = wall + 2, $fn = 40); }

// ==================================================================== speaker
// The 2831 speaker (31 x 28 mm, ~9 mm deep), its front against the wall's
// inside face (z = -wall). The cutout is a grid of holes over the cone.
module speaker_2831(wall = 2) {
    translate([0, 0, -wall]) {
        color([0.1, 0.1, 0.1]) translate([0, 0, -9]) linear_extrude(9) offset(3) offset(-3) square([31, 28], center = true);
        color([0.25, 0.25, 0.25]) translate([0, 0, -0.5]) linear_extrude(0.5) offset(2) offset(-2) square([26, 23], center = true);
        color(c_tin()) translate([0, 0, -9]) mirror([0, 0, 1]) cylinder(d = 14, h = 3, $fn = 32);   // magnet
    }
}
module speaker_2831_cutout(wall = 2, area = [24, 21], d = 1.8, pitch = 3.0) {
    for (x = [-area[0] / 2:pitch:area[0] / 2], y = [-area[1] / 2:pitch:area[1] / 2])
        translate([x, y, -wall - 1]) cylinder(d = d, h = wall + 2, $fn = 12);
}

// ========================================================= shown when opened
show = "demo";
color("#9aa3ab", 0.5) difference() {
    translate([-60, -25, -2]) cube([130, 45, 2]);
    translate([-45, 0, 0]) rocker_kcd11_cutout(); translate([-22, 0, 0]) rocker_kcd1_cutout();
    translate([0, 8, 0]) slide_ss12d00_cutout(); translate([0, -8, 0]) selflock_85_cutout();
    translate([18, 0, 0]) dc_jack_panel_cutout(); translate([48, 0, 0]) speaker_2831_cutout();
}
translate([-45, 0, 0]) rocker_kcd11(true); translate([-22, 0, 0]) rocker_kcd1();
translate([0, 8, 0]) slide_ss12d00(); translate([0, -8, 0]) selflock_85();
translate([18, 0, 0]) dc_jack_panel(); translate([48, 0, 0]) speaker_2831();
