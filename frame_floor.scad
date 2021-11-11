use <utilities.scad>;
use <lumber.scad>;

module frame_floor() {
    // South Rim Joists
    rotate(a=[0,90,0])
        rotate(a=90, v=[0,0,1])
            2x6x8();
                    
    rotate(a=[0,90,0])
        rotate(a=90, v=[0,0,1])
            translate([0, 0, feet(8)])
                2x6x8();
                
    rotate(a=[0,90,0])
        rotate(a=90, v=[0,0,1])
            translate([0, 0, feet(16)])
                2x6x8(cut=[0, 0, feet(4)]);
                
    // floor joists
    translate([0,1.5,5.5])
            rotate(a=[270,0,00])
               2x6x8(cut=[0, 0, inches(3)]);

    for (x = [15.25:16:239]) {
        translate([x, inches(1, 1/2), inches(5, 1/2)])
            rotate(a=[270,0,00])
                2x6x8(cut=[0, 0, inches(3)]);
    }

    translate([238.5,1.5,5.5])
            rotate(a=[270,0,00])
                2x6x8(cut=[0, 0, inches(3)]);

    // North Rim Joists
    translate([0, feet(7) + inches(10, 1/2), 0])
        rotate(a=[0,90,0])
            rotate(a=90, v=[0,0,1])
                2x6x8();

    translate([feet(8), feet(7) + inches(10, 1/2), 0])
        rotate(a=[0,90,0])
            rotate(a=90, v=[0,0,1])
                2x6x8();

    translate([feet(16), feet(7) + inches(10, 1/2), 0])
        rotate(a=[0,90,0])
            rotate(a=90, v=[0,0,1])
                2x6x8(cut=[0, 0, feet(4)]);
}

frame_floor();