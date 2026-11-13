# Build the house at four sizes and check the framing
test:
    python3 tests/test_tiny.py

# Print the cut list, e.g. just cutlist -D length=192 -D width=90
cutlist *ARGS:
    openscad --export-format echo -o - {{ARGS}} src/house.scad

# Render the README pictures into images/
images:
    mkdir -p images
    openscad --imgsize 1200,800 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,62,0,325,0 -o images/house.png src/house.scad
    openscad --imgsize 1200,800 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,62,0,325,0 -D show_roof_sheathing=false -o images/frame.png src/house.scad
    openscad --imgsize 1200,800 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,90,0,90,0 --projection=ortho -o images/end.png src/house.scad
    openscad --imgsize 1200,800 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,40,0,325,0 -D show_walls=false -D show_roof=false -D show_roof_sheathing=false -D show_subfloor=false -o images/floor.png src/house.scad
