use <utilities.scad>;
use <lumber.scad>;

/**
 * @module frame_walls
 * @brief Constructs stud-framed walls on all four sides.
 *
 * @param wall_height Vertical height of the walls.
 * @param width Width of the framed base (X direction).
 * @param depth Depth of the framed base (Y direction).
 *
 * Adds top/bottom plates and vertical studs spaced 16" apart.
 * Includes second top plates for overlapping strength.
 */
module frame_walls(wall_height = feet(8), width = feet(20), depth = feet(8) + inches(11)) {
  stud_cut_length = feet(8) - wall_height + inches(4, 1 / 2);
  assert(stud_cut_length > -0.00000000001, "Your wall height has exceeded your lumber length");

  for (a = [0:1]) {
    // Top and Bottom Plate
    // South Plates
    for (b = [0:feet(8):width]) {
      trim = b + feet(8) > width ? [0, 0, b + feet(8) - width + inches(3, 1 / 2)] : [0, 0, 0];

      translate([b, 0, inches(1, 1 / 2) + a * (wall_height - inches(3))])
        rotate(a=[0, 90, 0])
          plank_2x4x8(cut=trim);
    }

    // Add a second top plate
    if (a == 1) {
      for (b = [width:-feet(8):0]) {
        echo("b:", b); trim = b < feet(8) ? [0, 0, feet(8) - b + inches(3, 1 / 2)] : [0, 0, 0];

        translate([b - feet(8) + trim[2], 0, a * wall_height])
          rotate(a=[0, 90, 0])
            plank_2x4x8(cut=trim);
      }
    }

    // East Plates
    for (b = [0:feet(8):depth]) {
      // near to far
      translate([width, 0, inches(1, 1 / 2) + a * (wall_height - inches(3))])
        rotate(a=[270, 90, 0])
          plank_2x4x8(cut=[0, 0, feet(8) - depth + inches(3, 1 / 2)]);
    }

    // Add a second top plate
    if (a == 1) {
      for (b = [0:feet(8):depth]) {
        // near to far
        translate([width, inches(3, 1 / 2), a * wall_height ])
          rotate(a=[270, 90, 0])
            plank_2x4x8(cut=[0, 0, feet(8) - depth + inches(3, 1 / 2)]);
      }
    }

    // North Plates
    for (b = [width:-feet(8):0]) {
      // Right to left
      trim = b < feet(8) ? [0, 0, feet(8) - b + 3.5] : [0, 0, 0];

      translate([b, depth - inches(3, 1 / 2), a * (wall_height - inches(3))])
        rotate(a=[0, 270, 0])
          plank_2x4x8(cut=trim);
    }

    // Add a second top plate
    if (a == 1) {
      for (b = [0:feet(8):width]) {
        // Right to left
        trim = width - b < feet(8) ? [0, 0, feet(8) - (width - b) + inches(3, 1 / 2)] : [0, 0, 0];

        translate([b, depth - inches(3, 1 / 2), a * wall_height])
          rotate(a=[0, 90, 0])
            plank_2x4x8(cut=trim);
      }
    }

    // West Plates
    for (b = [0:feet(8):depth]) {
      // near to far
      translate([0, depth, inches(1, 1 / 2) + a * (wall_height - inches(3))])
        rotate(a=[90, 90, 0])
          plank_2x4x8(cut=[0, 0, feet(8) - depth + inches(3, 1 / 2)]);
    }

    // Add a second top plate
    if (a == 1) {
      for (b = [0:feet(8):depth]) {
        // near to far
        translate([0, depth - inches(3, 1 / 2), a * wall_height])
          rotate(a=[90, 90, 0])
            plank_2x4x8(cut=[0, 0, feet(8) - depth + inches(3, 1 / 2)]);
      }
    }
  }

  // South Wall
  translate([0, 0, inches(1, 1 / 2)])
    plank_2x4x8(cut=[0, 0, stud_cut_length]);

  let (stud_placement = [for (i = [inches(15, 1 / 4):inches(16):width - inches(1, 1 / 2)]) i]) {
    // Switch to specific studs when we add window and door framing
    for (stud = stud_placement) {
      translate([stud, 0, inches(1, 1 / 2)])
        plank_2x4x8(cut=[0, 0, stud_cut_length]);
    }
  }

  translate([width - inches(5), 0, inches(1, 1 / 2)])
    plank_2x4x8(cut=[0, 0, stud_cut_length]);

  // East Wall
  translate([width - inches(3, 1 / 2), inches(1, 1 / 2), inches(1, 1 / 2)])
    rotate(a=[0, 0, 270])
      plank_2x4x8(cut=[0, 0, stud_cut_length]);

  let (stud_placement = [for (i = [inches(15, 1 / 4):inches(16):depth - inches(1, 1 / 2)]) i]) {
    // Switch to specific studs when we add window and door framing
    for (stud = stud_placement) {
      translate([width - inches(3, 1 / 2), inches(1, 1 / 2) + stud, inches(1, 1 / 2)])
        rotate(a=[0, 0, 270])
          plank_2x4x8(cut=[0, 0, stud_cut_length]);
    }
  }

  translate([width - inches(3, 1 / 2), depth - inches(3, 1 / 2), inches(1, 1 / 2)])
    rotate(a=[0, 0, 270])
      plank_2x4x8(cut=[0, 0, stud_cut_length]);

  // North Wall
  translate([width - inches(1, 1 / 2), depth - inches(3, 1 / 2), inches(1, 1 / 2)])
    plank_2x4x8(cut=[0, 0, stud_cut_length]);

  let (stud_placement = [for (i = [inches(15, 1 / 4):inches(16):width - inches(1, 1 / 2)]) i]) {
    // Switch to specific studs when we add window and door framing
    for (stud = stud_placement) {
      translate([width - inches(3, 1 / 2) - stud, depth - inches(3, 1 / 2), inches(1, 1 / 2)])
        plank_2x4x8(cut=[0, 0, stud_cut_length]);
    }
  }

  translate([inches(3, 1 / 2), depth - inches(3, 1 / 2), inches(1, 1 / 2)])
    plank_2x4x8(cut=[0, 0, stud_cut_length]);

  // West Wall
  translate([0, depth, inches(1, 1 / 2)])
    rotate(a=[0, 0, 270])
      plank_2x4x8(cut=[0, 0, stud_cut_length]);

  let (stud_placement = [for (i = [inches(15, 1 / 4):inches(16):depth - inches(1, 1 / 2)]) i]) {
    // Switch to specific studs when we add window and door framing
    for (stud = stud_placement) {
      translate([0, depth - stud, inches(1, 1 / 2)])
        rotate(a=[0, 0, 270])
          plank_2x4x8(cut=[0, 0, stud_cut_length]);
    }
  }

  translate([0, inches(5), inches(1, 1 / 2)])
    rotate(a=[0, 0, 270])
      plank_2x4x8(cut=[0, 0, stud_cut_length]);
}

frame_walls();
