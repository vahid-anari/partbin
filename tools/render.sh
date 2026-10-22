#!/bin/sh
# Pictures of every module into images/:  tools/render.sh [module ...]
# Needs OpenSCAD (and xvfb-run on Linux without a screen).
cd "$(dirname "$0")/.."
mkdir -p images
run() { if command -v xvfb-run >/dev/null && [ -z "$DISPLAY" ]; then xvfb-run -a "$@"; else "$@"; fi; }
shot() {  # name, camera (translate x,y,z, rotate x,y,z, distance), show
  run openscad -q --imgsize=1600,1200 --colorscheme=Tomorrow --projection=p \
      --camera="$2" -D "show=\"$3\"" -o "images/$1.png" "modules/$m.scad"
}
mods=${*:-$(cd modules && ls *.scad | sed 's/\.scad$//')}
for m in $mods; do
  shot "$m"          0,0,0,50,0,30,95     board
  shot "${m}_bottom" 0,0,0,230,0,200,90   board
  shot "${m}_holder" 0,-1,0,50,0,20,80    holder
  shot "${m}_demo"   0,2,0,55,0,210,110   demo
done
