use <utilities.scad>;
use <frame_floor.scad>;
use <sheet_floor.scad>;
use <frame_walls.scad>;
//use <sheet_walls.scad>;

// Show and hide layers, 1 to show, any other value to hide
show_frame_floor = 1;
show_sheet_floor = 1;
show_frame_walls = 1;
show_sheet_walls = 0;

wall_height = feet(8);
wall_width = feet(20);
wall_depth = feet(8);

wall_sheeting = inches(1 / 2);

// Advanced, see the README.md file
frame_floor_start_height = 0;
sheet_floor_start_height = inches(5, 1 / 2);
frame_walls_start_height = inches(5, 1 / 2) + inches(0, 3 / 4);
sheet_walls_start_height = -inches(0, 1 / 2); // Include a bit of overlap over the foundation, let's protect the sill plate (making foundation assumptions here)

// No configuration variables are below this line

if (show_frame_floor == 1) {
  translate([0, 0, frame_floor_start_height])
  frame_floor(width=wall_width - wall_sheeting * 2, depth=wall_depth - wall_sheeting * 2);
}

if (show_sheet_floor == 1) {
  translate([0, 0, sheet_floor_start_height])
    sheet_floor(width=wall_width - wall_sheeting * 2, depth=wall_depth - wall_sheeting * 2);
}

if (show_frame_walls == 1) {
  translate([0, 0, frame_walls_start_height])
    frame_walls(wall_height=wall_height, width=wall_width - wall_sheeting * 2, depth=wall_depth - wall_sheeting * 2);
}

if (show_sheet_walls == 1) {
  sheet_walls(wall_height=wall_height);
}
