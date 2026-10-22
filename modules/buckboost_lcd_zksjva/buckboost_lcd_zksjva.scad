// "ZK-SJVA-4X" buck-boost converter with LCD (5.5-30 V in, 0.5-30 V 4 A out,
// a blue LCD showing volts and amps, four buttons, screw terminals for IN
// and OUT, a big toroid inductor and capacitors behind the display).
//
//   use <partbin/modules/buckboost_lcd_zksjva/buckboost_lcd_zksjva.scad>
//
//   buckboost_lcd_zksjva();                    the module, with its parts
//   buckboost_lcd_zksjva_panel_cutout(gap, wall)   the LCD window and button holes
//   buckboost_lcd_zksjva_holder(h = 3);         posts under its four holes
//   buckboost_lcd_zksjva_size()                 [width, height, pcb thickness]
//
// Where it sits: the LCD up, the board centred on x = y = 0, its underside
// at z = 0. The LCD and buttons face a front panel; the tall parts (toroid,
// capacitors) are behind the LCD at the top edge. Typical sizes.

use <../../lib/parts.scad>
use <../../lib/breakout.scad>
use <../../lib/display.scad>

// ------------------------------------------------------------------- typical
b_w      = 62.0;
b_l      = 44.0;
b_t      = 1.6;
hole_d   = 3.0;
hole_in  = 3.0;
lcd      = [38.0, 22.0];   // the LCD glass
lcd_c    = [-3.0, -6.0];   // its centre
lcd_h    = 7.0;            // front of the LCD above the PCB
buttons  = [[22.0, -11.0], [22.0, -2.0], [-26.0, -11.0], [-26.0, -2.0]];

holes = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (b_w / 2 - hole_in), sy * (b_l / 2 - hole_in)]];

function buckboost_lcd_zksjva_size() = [b_w, b_l, b_t];
function buckboost_lcd_zksjva_height() = b_t + 18.0;   // the capacitors

module buckboost_lcd_zksjva(detail = true) {
    pcb([b_w, b_l], b_t, [for (h = holes) [h[0], h[1], hole_d, 5.0]], c_pcb_blue(), 0.8);
    translate([lcd_c[0], lcd_c[1], b_t]) {
        color([0.85, 0.85, 0.85]) translate([-lcd[0] / 2 - 1, -lcd[1] / 2 - 1, 0]) cube([lcd[0] + 2, lcd[1] + 2, lcd_h - 1.5]);
        translate([0, 0, lcd_h - 1.5]) glass_panel(lcd, 1.5, [lcd[0] - 4, lcd[1] - 5]);
        color([0.15, 0.35, 0.95]) translate([-lcd[0] / 2 + 2, -lcd[1] / 2 + 2.5, lcd_h + 0.01]) cube([lcd[0] - 4, lcd[1] - 5, 0.02]);
    }
    for (b = buttons) translate([b[0], b[1], b_t]) tact6(5.0);
    translate([-6, 13, b_t]) { color([0.75, 0.45, 0.2]) rotate_extrude($fn = 40) translate([7, 0, 0]) scale([1, 1.4]) circle(r = 3.3, $fn = 20); }
    for (p = [[-22, 14], [10, 14], [17, 14]]) translate([p[0], p[1], b_t]) elco(10, 18, [0.15, 0.4, 0.2]);
    translate([-b_w / 2 + 6, 13, b_t]) rotate([0, 0, 90]) screw_terminal(2, 5.0, 10);
    translate([b_w / 2 - 6, 13, b_t]) rotate([0, 0, -90]) screw_terminal(2, 5.0, 10);
}

// The LCD window and four button holes in a front panel `wall` thick whose
// inside face is `gap` above the LCD.
module buckboost_lcd_zksjva_panel_cutout(gap = 0.3, wall = 2, margin = 0.5, d_btn = 4.0) {
    rect_window(lcd_c[0], lcd_c[1], b_t + lcd_h + gap, wall, [lcd[0] - 4 + 2 * margin, lcd[1] - 5 + 2 * margin], 0.6);
    for (b = buttons) translate([b[0], b[1], b_t + lcd_h + gap - 0.5]) cylinder(d = d_btn, h = wall + 1, $fn = 24);
}

module buckboost_lcd_zksjva_holder(h = 3, style = "screw") { bo_mounts(holes, hole_d, b_t, h, style); }

show = "demo";  // demo | board
buckboost_lcd_zksjva();
