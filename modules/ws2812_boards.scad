// WS2812B (5050) LED boards: the 8-LED bar (black or white) and the 3 x 3
// square panel ("9 bits"). Pads on the back: 5V, GND and DIN at the input,
// 5V, GND and DOUT at the output.
//
//   use <partbin/modules/ws2812_boards.scad>
//
//   ws2812_bar8();                   the 8-LED bar (black)
//   ws2812_bar8(pcb = "white");
//   ws2812_square9();                the 3 x 3 panel
//   ws2812_bar8_window(gap, wall)    one opening per LED in a lid / diffuser
//   ws2812_square9_window(gap, wall)
//   ws2812_bar8_size(), ws2812_square9_size()
//
// Where they sit: LEDs up, the board centred on x = y = 0, its underside at
// z = 0; the bar's long side along x, DIN at the left end.

use <../lib/parts.scad>
use <../lib/display.scad>

// ------------------------------------------------------------------- typical
bar      = [53.0, 10.0];   // 8-LED bar
bar_p    = 6.6;            // LED spacing on the bar
sq       = [22.0, 22.0];   // 3 x 3 panel
sq_p     = 7.0;
t        = 1.2;
led_h    = 1.6;

function ws2812_bar8_size() = [bar[0], bar[1], t];
function ws2812_square9_size() = [sq[0], sq[1], t];
function ws2812_bar8_led(i) = [(i - 3.5) * bar_p, 0];
function ws2812_square9_led(i) = [(i % 3 - 1) * sq_p, (1 - floor(i / 3)) * sq_p];

module ws2812_bar8(pcb = "black") {
    color(pcb == "white" ? [0.93, 0.93, 0.92] : [0.08, 0.08, 0.09]) translate([-bar[0] / 2, -bar[1] / 2, 0]) cube([bar[0], bar[1], t]);
    for (i = [0:7]) translate([ws2812_bar8_led(i)[0], 0, t]) ws2812();
    color(c_gold()) for (s = [-1, 1], j = [-1, 0, 1]) translate([s * (bar[0] / 2 - 1.6) - 0.8, j * 2.8 - 0.8, -0.02]) cube([1.6, 1.6, 0.02]);
}

module ws2812_square9(pcb = "black") {
    color(pcb == "white" ? [0.93, 0.93, 0.92] : [0.08, 0.08, 0.09]) translate([-sq[0] / 2, -sq[1] / 2, 0]) cube([sq[0], sq[1], t]);
    for (i = [0:8]) translate([ws2812_square9_led(i)[0], ws2812_square9_led(i)[1], t]) ws2812();
    color(c_gold()) for (s = [-1, 1], j = [-1, 0, 1]) translate([s * (sq[0] / 2 - 1.4) - 0.7, j * 2.6 - 0.7, -0.02]) cube([1.4, 1.4, 0.02]);
}

// One square opening per LED, in a lid `wall` thick whose inside face is
// `gap` above the LEDs. Leave `wall` thin (or print it in white/clear) to
// use the lid as a diffuser instead.
module ws2812_bar8_window(gap = 0.5, wall = 2, size = 5.4) {
    for (i = [0:7]) rect_window(ws2812_bar8_led(i)[0], 0, t + led_h + gap, wall, [size, size], 0.6, 0.5);
}
module ws2812_square9_window(gap = 0.5, wall = 2, size = 5.4) {
    for (i = [0:8]) rect_window(ws2812_square9_led(i)[0], ws2812_square9_led(i)[1], t + led_h + gap, wall, [size, size], 0.6, 0.5);
}

show = "demo";  // demo | board | holder
if (show == "board") ws2812_bar8();
else if (show == "holder") ws2812_square9();
else { translate([0, 17, 0]) ws2812_bar8(); translate([0, 4, 0]) ws2812_bar8("white"); translate([0, -15, 0]) ws2812_square9(); }
