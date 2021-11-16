use <utilities.scad>;
use <lumber.scad>;

module sheet_floor(start_height=0, width=feet(20), depth=feet(8)) {
    trim_depth = depth < feet(8) ? feet(8) - depth : 0;

    for (x = [0:feet(4):width]) {
        trim = x + feet(4) > width ? [x + feet(4) - width, trim_depth, 0] : [0, trim_depth, 0];
        
        translate([x, 0, start_height])
            4x8x3_4(cut=trim);
    }
}
    
sheet_floor();