use <utilities.scad>;
use <lumber.scad>;

module sheet_floor(start_height=0) {
    // Takes four sheets of plywood
    for (x = [0:1:4]) {
        translate([x * feet(4), 0, start_height])
            4x8x34ths();
    }
}
    
sheet_floor();