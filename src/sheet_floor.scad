use <utilities.scad>;
use <lumber.scad>;

/**
 * @module sheet_floor
 * @brief Lays 4x8 sheathing sheets across the floor frame.
 *
 * @param width Width to cover (X direction).
 * @param depth Depth to cover (Y direction).
 *
 * Places plywood sheets and trims overhangs where needed.
 */
module sheet_floor(width = feet(20), depth = feet(8)) {
  trim_depth = depth < feet(8) ? feet(8) - depth : 0;

  for (x = [0:feet(4):width]) {
    trim = x + feet(4) > width ? [x + feet(4) - width, trim_depth, 0] : [0, trim_depth, 0];

    translate([x, 0, 0])
      sheet_4x8x3_4(cut=trim);
  }
}

sheet_floor();
