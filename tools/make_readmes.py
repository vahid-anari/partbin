#!/usr/bin/env python3
"""Write <category>/<name>/README.md for every module, from its .scad file:
the header comment (description, how to use it, where it sits), the
settings at the top (the sizes to check with calipers), the pictures and
a link to the 3D view (GitHub shows .stl files in 3D). Also writes
<category>/README.md, listing that category's modules.

    tools/make_readmes.py
"""
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")

# category folder: (title, one line about it)
CATS = {
    "dev-boards": ("Dev boards", "Microcontroller boards: ESP32, RP2040, ATmega32U4."),
    "displays": ("Displays", "LED matrices, TFTs, OLEDs, a character LCD and 7-segment displays."),
    "sensors": ("Sensors", "Small I2C sensor boards: climate, light, current, ADC, distance, hall."),
    "inputs": ("Inputs", "Things you press, touch or turn."),
    "boards": ("Other boards", "Bluetooth, an MP3 player, LED boards, a stepper driver, USB-C breakouts."),
    "power": ("Power", "Chargers, power bank boards, DC-DC converters and a voltmeter."),
    "hardware": ("Hardware", "Batteries and holders, and parts that go in a panel."),
}
# here, but not boards I have
NOT_MINE = {"st7735_18", "st7789_13", "tm1637_4digit", "ip5306_mhcd42"}
MARK = {"measured": "✓", "drawing": "◐", "typical": "○"}

# name, and where the sizes come from: "measured", "drawing" (a published
# drawing or the listing's sizes) or "typical" (from photos)
INFO = {
    "esp32_c3_supermini": ("ESP32-C3 Super Mini", "measured"),
    "esp32_devkitc_38": ("ESP32-DevKitC V4, 38 pins", "drawing"),
    "pico_rp2040_typec": ("RP2040 Pico clone (USB-C, 16 MB)", "drawing"),
    "pro_micro": ("Pro Micro (ATmega32U4 / RP2040)", "typical"),
    "max7219_fc16": ("MAX7219 FC-16 4-in-1 LED matrix", "typical"),
    "max7219_8x8": ("MAX7219 8x8 LED matrix", "typical"),
    "st7735_096": ('0.96" IPS TFT (ST7735S)', "typical"),
    "st7735_18": ('1.8" TFT (ST7735)', "typical"),
    "st7789_13": ('1.3" IPS TFT (ST7789)', "typical"),
    "ssd1306_091": ('0.91" OLED (SSD1306)', "typical"),
    "sh1106_13": ('1.3" OLED (SH1106)', "typical"),
    "lcd1602": ("LCD1602 with I2C backpack", "drawing"),
    "seg7_4digit_036": ('4-digit 7-segment display, 0.36"', "typical"),
    "tm1637_4digit": ("TM1637 4-digit display module", "typical"),
    "gy_bme280": ("GY-BME280 / BMP280", "typical"),
    "gy302_bh1750": ("GY-302 BH1750 light sensor", "typical"),
    "veml7700": ("VEML7700 light sensor", "drawing"),
    "ina226_cjmcu226": ("INA226 current monitor (CJMCU-226)", "typical"),
    "ads1115": ("ADS1115 ADC", "typical"),
    "vl53l0x_gy530": ("VL53L0X distance sensor (GY-530)", "typical"),
    "ky024_hall": ("KY-024 hall sensor", "typical"),
    "ky040_encoder": ("KY-040 rotary encoder", "typical"),
    "ttp223_touch": ("TTP223 touch button", "typical"),
    "nav5_button": ("5-way navigation button", "typical"),
    "hc05": ("HC-05 Bluetooth module", "typical"),
    "dfplayer_mini": ("DFPlayer Mini", "typical"),
    "ws2812_boards": ("WS2812B LED boards", "typical"),
    "tmc2209_stepstick": ("TMC2209 stepper driver", "drawing"),
    "usbc_breakouts": ("USB-C breakout boards", "drawing"),
    "tp4056": ("TP4056 charger", "typical"),
    "powerbank_5v2a_typec": ("Type-C 5V 2A power bank board", "drawing"),
    "charger_2s_typec": ("2S Type-C boost charger", "drawing"),
    "charger_mini_typec_boost": ("Mini charger + 5V boost", "drawing"),
    "boost_mini_5v3a": ("Mini 5V 3A boost board", "typical"),
    "ip5306_mhcd42": ("IP5306 charge/discharge board (MH-CD42)", "typical"),
    "converters": ("DC-DC converter boards", "typical"),
    "usb_stepupdown_xyup": ("XY-UP USB step-up/down", "typical"),
    "buckboost_lcd_zksjva": ("ZK-SJVA-4X buck-boost with LCD", "typical"),
    "voltmeter_028": ('0.28" voltmeter', "typical"),
    "batteries": ("Batteries and holders", "typical"),
    "panel_parts": ("Panel parts", "typical"),
}

SOURCE = {
    "measured": "measured with calipers",
    "drawing": "from a published drawing or the seller's sizes",
    "typical": "typical, from photos; measure yours and change them",
}


def header(lines):
    """The leading // comment block, as paragraphs of text lines."""
    paras, cur = [], []
    for ln in lines:
        if not ln.startswith("//"):
            break
        text = ln[2:]
        if text.startswith(" "):
            text = text[1:]
        if text.strip() == "":
            if cur:
                paras.append(cur)
            cur = []
        else:
            cur.append(text)
    if cur:
        paras.append(cur)
    return paras


def settings(lines):
    """Top-level `name = value;  // comment` lines before the first
    function or module: the sizes to check."""
    out = []
    for ln in lines:
        if re.match(r"\s*(module|function)\b", ln):
            break
        m = re.match(r"^([a-z_][a-z0-9_]*)\s*=\s*([^;]+);\s*//\s*(.*)$", ln)
        plain = re.fullmatch(r'-?[0-9.]+|\[[-0-9., ]+\]|"[^"]*"', m.group(2).strip()) if m else None
        if m and m.group(1) != "show" and plain:
            out.append((m.group(1), m.group(2).strip(), m.group(3).strip()))
    return out


def prose(par):
    text = " ".join(s.strip() for s in par)
    return text.replace("<", "&lt;").replace(">", "&gt;")


def write(cat, name):
    folder = os.path.join(ROOT, cat, name)
    scad = os.path.join(folder, name + ".scad")
    lines = open(scad).read().splitlines()
    paras = header(lines)
    title, source = INFO.get(name, (name, "typical"))

    desc, usage, notes = [], [], []
    for p in paras:
        if any(s.strip().startswith("use <") for s in p):
            continue
        if all(s.startswith("  ") for s in p):       # the list of modules / functions
            usage.append(p)
        elif not desc:
            desc.append(p)
        else:
            notes.append(p)

    out = [f"# {title}", ""]
    for p in desc:
        out += [prose(p), ""]

    pics = [f for f in [name + ".png", name + "_bottom.png", name + "_holder.png", name + "_demo.png"]
            + sorted(x for x in os.listdir(folder) if x.startswith(name + "_") and x.endswith(".png")
                     and x not in (name + "_bottom.png", name + "_holder.png", name + "_demo.png"))
            if os.path.exists(os.path.join(folder, f))]
    if pics:
        out.append(f"![{title}]({pics[0]})")
        out.append("")
    if os.path.exists(os.path.join(folder, name + ".stl")):
        out += [f"**[View it in 3D]({name}.stl)** (turn it with the mouse; GitHub shows it in one colour)", ""]
    if len(pics) > 1:
        labels = {"_bottom": "Underneath", "_holder": "Holder", "_demo": "In its holder / case"}
        cells = []
        for f in pics[1:]:
            suffix = f[len(name):-4]
            cells.append((labels.get(suffix, suffix.strip("_").replace("_", " ").capitalize()), f))
        out.append("| " + " | ".join(c[0] for c in cells) + " |")
        out.append("|" + "---|" * len(cells))
        out.append("| " + " | ".join(f"![{c[0]}]({c[1]})" for c in cells) + " |")
        out.append("")

    out += ["## Use it", "", "```openscad", f"use <partbin/{cat}/{name}/{name}.scad>", "```", ""]
    rows = []
    for p in usage:
        for s in p:
            s = s.strip()
            parts = re.split(r"\s{2,}", s, maxsplit=1)
            if len(parts) == 2:
                rows.append((parts[0], parts[1]))
            elif rows and not s.endswith((")", ";")):
                rows[-1] = (rows[-1][0], rows[-1][1] + " " + s)     # a description that wrapped
            else:
                rows.append((parts[0], ""))
    if rows:
        out += ["| Call | What it gives |", "|---|---|"]
        out += [f"| `{c.rstrip(';')}` | {w} |" for c, w in rows] + [""]
    for p in notes:
        out += [prose(p), ""]

    sets = settings(lines)
    if sets:
        out += ["## Sizes", "", f"At the top of [`{name}.scad`]({name}.scad), in mm: {SOURCE[source]}.", "",
                "| Setting | Value | What |", "|---|---|---|"]
        for n, v, c in sets:
            out.append(f"| `{n}` | {v} | {c} |")
        out.append("")

    out += ["---", "", f"Part of [partbin](../../README.md), in [{CATS[cat][0]}](../README.md)."]
    open(os.path.join(folder, "README.md"), "w").write("\n".join(out) + "\n")


def modules(cat):
    d = os.path.join(ROOT, cat)
    return sorted(n for n in os.listdir(d) if os.path.isfile(os.path.join(d, n, n + ".scad")))


def rows(cat, prefix=""):
    """The two-column table of a category: mark and name, picture.
    Boards I don't have go last."""
    names = modules(cat)
    order = [n for n in INFO if n in names] + [n for n in names if n not in INFO]
    order = [n for n in order if n not in NOT_MINE] + [n for n in order if n in NOT_MINE]
    out = ["| Module | Picture |", "|---|---|"]
    for n in order:
        t, src = INFO.get(n, (n, "typical"))
        extra = " (not one I have)" if n in NOT_MINE else ""
        out.append(f"| {MARK[src]} [{t}]({prefix}{n}/){extra} | <img src=\"{prefix}{n}/{n}.png\" width=\"200\"> |")
    return out


LEGEND = "✓ measured with calipers · ◐ from a published drawing or the listing's sizes · ○ typical, from photos (to be measured)"


def write_cat(cat):
    title, line = CATS[cat]
    out = [f"# {title}", "", line, "", LEGEND, ""] + rows(cat)
    out += ["", "---", "", "Part of [partbin](../README.md)."]
    open(os.path.join(ROOT, cat, "README.md"), "w").write("\n".join(out) + "\n")


def write_main():
    """The module list in the main README, between the two markers:
    a fold-out per category."""
    path = os.path.join(ROOT, "README.md")
    text = open(path).read()
    a, b = "<!-- modules: written by tools/make_readmes.py -->", "<!-- /modules -->"
    out = [a, "", LEGEND, ""]
    for cat, (title, line) in CATS.items():
        out += ["<details>", f"<summary><b><a href=\"{cat}/\">{title}</a></b>: {line}</summary>", ""]
        out += rows(cat, cat + "/") + ["", "</details>", ""]
    out.append(b)
    i, j = text.index(a), text.index(b) + len(b)
    open(path, "w").write(text[:i] + "\n".join(out) + text[j:])


for cat in CATS:
    for name in modules(cat):
        write(cat, name)
    write_cat(cat)
write_main()
print("done")
