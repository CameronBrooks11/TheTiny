use <utilities.scad>;
use <frame_floor.scad>;
use <sheet_floor.scad>;
use <frame_walls.scad>;

// Show and hide layers, 1 to show, any other value to hide
show_frame_floor=1;
show_sheet_floor=1;
show_frame_walls=1;

// Advanced, see the README.md file
wall_height=feet(8);
frame_floor_start_height=0;
sheet_floor_start_height=inches(5, 1/2);
frame_walls_start_height=inches(5, 1/2) + inches(0, 3/4);

// No configuration variables are below this line

if (show_frame_floor == 1) {
    frame_floor(start_height=frame_floor_start_height);
}

if (show_sheet_floor == 1) {
    sheet_floor(start_height=inches(5, 1/2));
}

if (show_frame_walls == 1) {
    frame_walls(start_height=frame_walls_start_height, wall_height=wall_height);
}
