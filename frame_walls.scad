use <utilities.scad>;
use <lumber.scad>;

module frame_walls(start_height=0, wall_height=0) {
    stud_cut_length = feet(8) - wall_height + inches(4, 1/2);
    echo(stud_cut_length);
    assert(stud_cut_length > -0.00000000001, "Your wall height has exceeded your lumber length");
    
    for (a=[0:1]) { // Top and Bottom Plate
        // South Plates    
        for (b=[0:2]) { // Left to right        
            trim = b == 2 ? [0, 0, feet(4) + inches(3, 1/2)] : [0, 0, 0];

            translate([feet(8) * b, 0, inches(1, 1/2) + start_height + a * (wall_height - inches(3))])
                rotate(a=[0,90,0])
                    2x4x8(cut=trim);
        }
        
        // Add a second top plate
        if (a == 1) {
            for (b=[2:0]) { // Left to right
                trim = b == 0 ? [0, 0, feet(4) + inches(3, 1/2)]: [0, 0, 0];
            
                translate([feet(8) * b - feet(4) + trim[2], 0, a * wall_height + start_height])
                    rotate(a=[0,90,0])
                        2x4x8(cut=trim);
            }
        }
        
        // East Plates
        for (b=[0:2]) { // near to far
            translate([feet(20) - inches(3, 1/2), feet(8) - inches(3, 1/2), inches(1, 1/2) + start_height + a * (wall_height - inches(3))])
                rotate(a=[90,90,0])
                    2x4x8(cut=[0, 0, inches(3, 1/2)]);
        }
        
        // Add a second top plate
        if (a == 1) {
            for (b=[0:2]) { // near to far
                translate([feet(20) - inches(3, 1/2), feet(8), a * wall_height + start_height])
                    rotate(a=[90,90,0])
                        2x4x8(cut=[0, 0, inches(3, 1/2)]);
            }
        }
        
        // North Plates
        for (b=[2:0]) { // Right to left
            trim = b == 0 ? [0, 0, feet(4) + inches(3, 1/2)] : [0, 0, 0];

            translate([feet(8) * b - feet(4) + trim[2], feet(8) - inches(3, 1/2), inches(1, 1/2) + start_height + a * (wall_height - inches(3))])
                rotate(a=[0,90,0])
                    2x4x8(cut=trim);
        }
        
        // Add a second top plate
        if (a == 1) {
            for (b=[2:0]) { // Right to left
                trim = b == 2 ? [0, 0, feet(4) + inches(3, 1/2)] : [0, 0, 0];

                translate([feet(8) * b, feet(8) - inches(3, 1/2), a * wall_height + start_height])
                    rotate(a=[0,90,0])
                        2x4x8(cut=trim);
            }
        }
        
        // West Plates
        for (b=[0:2]) { // near to far
            translate([0, feet(8), inches(1, 1/2) + start_height + a * (wall_height - inches(3))])
                rotate(a=[90,90,0])
                    2x4x8(cut=[0, 0, inches(3, 1/2)]);
        }
        
        // Add a second top plate
        if (a == 1) {
            for (b=[0:2]) { // near to far
                translate([0, feet(8) - inches(3, 1/2), a * wall_height + start_height])
                    rotate(a=[90,90,0])
                        2x4x8(cut=[0, 0, inches(3, 1/2)]);
            }
        }
    }
    
    // South Wall
    translate([0, 0, inches(1, 1/2) + start_height])
        2x4x8(cut=[0, 0, stud_cut_length]);
    
    let(stud_placement = [ for ( i = [inches(15, 1/4):inches(16):feet(20) - inches(1, 1/2)] ) i]) {  // Switch to specific studs when we add window and door framing
        for (stud = stud_placement) {
            translate([stud, 0, inches(1, 1/2) + start_height])
                2x4x8(cut=[0, 0, stud_cut_length]);
        }
    }
    
    translate([feet(20) - inches(5), 0, inches(1, 1/2) + start_height])
        2x4x8(cut=[0, 0, stud_cut_length]);

    // East Wall
    translate([feet(20) - inches(3, 1/2), inches(1, 1/2), inches(1, 1/2) + start_height])
        rotate(a=[0,0,270])
            2x4x8(cut=[0, 0, stud_cut_length]);
    
    let(stud_placement = [ for ( i = [inches(15, 1/4):inches(16):feet(8) - inches(1, 1/2)] ) i]) {  // Switch to specific studs when we add window and door framing
        for (stud = stud_placement) {
        translate([feet(20) - inches(3, 1/2), inches(1, 1/2) + stud, inches(1, 1/2) + start_height])
            rotate(a=[0,0,270])
                2x4x8(cut=[0, 0, stud_cut_length]);
        }
    }
    
    translate([feet(20) - inches(3, 1/2), feet(8), inches(1, 1/2) + start_height])
        rotate(a=[0,0,270])
            2x4x8(cut=[0, 0, stud_cut_length]);

    // North Wall
    translate([feet(20) - inches(3, 1/2) - inches(1, 1/2), feet(8) - inches(3, 1/2), inches(1, 1/2) + start_height])
        2x4x8(cut=[0, 0, stud_cut_length]);
    
    let(stud_placement = [ for ( i = [inches(15, 1/4):inches(16):feet(20) - inches(1, 1/2)] ) i]) {  // Switch to specific studs when we add window and door framing
        for (stud = stud_placement) {
            translate([feet(20) - inches(3, 1/2) - stud, feet(8) - inches(3, 1/2), inches(1, 1/2) + start_height])
                2x4x8(cut=[0, 0, stud_cut_length]);
        }
    }
    
    translate([inches(3, 1/2), feet(8) - inches(3, 1/2), inches(1, 1/2) + start_height])
        2x4x8(cut=[0, 0, stud_cut_length]);

    // West Wall
    translate([0, feet(8), inches(1, 1/2) + start_height])
        rotate(a=[0,0,270])
            2x4x8(cut=[0, 0, stud_cut_length]);
    
    let(stud_placement = [ for ( i = [inches(15, 1/4):inches(16):feet(8) - inches(1, 1/2)] ) i]) {  // Switch to specific studs when we add window and door framing
        for (stud = stud_placement) {
        translate([0, feet(8) - stud, inches(1, 1/2) + start_height])
            rotate(a=[0,0,270])
                2x4x8(cut=[0, 0, stud_cut_length]);
        }
    }
    
    translate([0, inches(5), inches(1, 1/2) + start_height])
        rotate(a=[0,0,270])
            2x4x8(cut=[0, 0, stud_cut_length]);
}

frame_walls(start_height=feet(1), wall_height=feet(8));