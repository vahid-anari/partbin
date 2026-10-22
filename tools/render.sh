#!/bin/sh
# Pictures and the 3D file (binary STL) of every module, into its own folder
# (<category>/<name>/):
#
#   tools/render.sh                  all modules, pictures and STL
#   tools/render.sh tp4056 lcd1602   only these
#   PICS=0 tools/render.sh ...       only the STL
#   STL=0 tools/render.sh ...        only the pictures
#
# Each picture is framed to fit (--viewall). Needs OpenSCAD (and xvfb-run on
# Linux without a screen). After it, run tools/make_readmes.py.
cd "$(dirname "$0")/.."
run() { if command -v xvfb-run >/dev/null && [ -z "$DISPLAY" ]; then xvfb-run -a "$@"; else "$@"; fi; }
# files holding a family of parts: their STL shows the whole family (show = "demo")
families="converters batteries panel_parts ws2812_boards usbc_breakouts"
mods=${*:-$(ls -d */*/*.scad | grep -v "^lib/" | xargs -n1 dirname | xargs -n1 basename)}
for m in $mods; do
  f=$(ls */"$m"/"$m".scad 2>/dev/null | head -1)
  [ -n "$f" ] || { echo "no module $m"; continue; }
  d=$(dirname "$f")
  shot() {  # name, camera (translate x,y,z, rotate x,y,z, distance), show
    run openscad -q --imgsize=1600,1200 --colorscheme=Tomorrow --projection=p \
        --autocenter --viewall --camera="$2" -D "show=\"$3\"" -o "$d/$1.png" "$f"
  }
  if [ "${PICS:-1}" = 1 ]; then
    case " $families " in
      *" $m "*) shot "$m" 0,0,0,50,0,30,95 demo ;;
      *) shot "$m"          0,0,0,50,0,30,95     board
         shot "${m}_bottom" 0,0,0,230,0,200,90   board
         shot "${m}_holder" 0,-1,0,50,0,20,80    holder
         shot "${m}_demo"   0,2,0,55,0,210,110   demo ;;
    esac
  fi
  if [ "${STL:-1}" = 1 ]; then
    case " $families " in *" $m "*) s=demo ;; *) s=board ;; esac
    openscad -q --export-format binstl -D "show=\"$s\"" -o "$d/$m.stl" "$f"
  fi
done
