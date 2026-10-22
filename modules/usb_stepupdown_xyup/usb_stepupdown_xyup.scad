// "XY-UP" USB step-up/down stick: USB-A plug in, adjustable 1.2-24 V out on a
// 2-way screw terminal, 3-digit LED voltmeter, a blue trimmer with a long
// brass screw, an ON/OFF button, micro-USB input as an alternative.
//
//   use <partbin/modules/usb_stepupdown_xyup/usb_stepupdown_xyup.scad>
//
//   usb_stepupdown_xyup();                 the board, with its parts
//   usb_stepupdown_xyup_window(gap, wall)  an opening for the display in the lid
//   usb_stepupdown_xyup_size()             [length, width, pcb thickness] (without the plug)
//
// Where it sits: parts up, the board centred on x = y = 0, its underside at
// z = 0, the long side along x, the USB plug sticking out at the left (-x),
// the screw terminal at the right.

use <../../lib/parts.scad>
use <../../lib/display.scad>

// --------------------- typical; layout from the seller's photo
b_l      = 50.0;
b_w      = 17.0;
b_t      = 1.6;
plug_out = 12.0;    // the USB-A plug past the board's end
disp     = [9.0, 1.5];   // display centre

function usb_stepupdown_xyup_size() = [b_l, b_w, b_t];

module usb_stepupdown_xyup(detail = true) {
    color(c_pcb_blue()) translate([-b_l / 2, -b_w / 2, 0]) cube([b_l, b_w, b_t]);
    translate([-b_l / 2 + 4, 0, b_t]) rotate([0, 0, 90]) usb_a_male(plug_out + 4);
    translate([disp[0], disp[1], b_t]) seg7_display(3, [15.0, 9.0], 5.5, false, seg7_color("red"));
    translate([b_l / 2 - 4, 0, b_t]) rotate([0, 0, 90]) screw_terminal(2, 5.0, 10);
    translate([-6.5, -4.5, b_t]) { trimpot_3296(); color([0.75, 0.6, 0.25]) translate([-4.75, 0, 3]) rotate([0, -90, 0]) cylinder(d = 2, h = 6, $fn = 12); }
    if (detail) translate([0, 0, b_t]) {
        translate([-11, 5.0, 0]) usb_micro(7.5, 2.5, 5.0);
        translate([-3.0, 4.5, 0]) power_inductor(5.2, 3.0);
        translate([2.0, -6.0, 0]) smd_button([4.0, 3.0], 1.2, 0.5, 1.4);
        translate([-14, -4, 0]) soic(8, 3.9, 1.5);
    }
}

module usb_stepupdown_xyup_window(gap = 0.5, wall = 2) {
    rect_window(disp[0], disp[1], b_t + 5.5 + gap, wall, [15.4, 9.4], 0, 0.3);
}

show = "demo";
usb_stepupdown_xyup();
