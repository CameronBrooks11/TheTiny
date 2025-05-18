use <utilities.scad>;

/**
 * @module plank_2x4x8
 * @brief Models a nominal 2x4 lumber stick, 8 feet long.
 * 
 * @param cut Vector [x, y, z] specifying material trimmed from each dimension (in inches).
 * Useful for simulating cuts due to fit or length adjustments.
 */
module plank_2x4x8(cut = [0, 0, 0]) {
  echo("plank_2x4x8");
  cube([inches(1, 1 / 2) - cut[0], inches(3, 1 / 2) - cut[1], feet(8) - cut[2]]);
}
;

/**
 * @module plank_2x6x8
 * @brief Models a nominal 2x6 lumber stick, 8 feet long.
 * 
 * @param cut Vector [x, y, z] specifying material trimmed from each dimension (in inches).
 */
module plank_2x6x8(cut = [0, 0, 0]) {
  echo("plank_2x6x8");
  cube([inches(1, 1 / 2) - cut[0], inches(5, 1 / 2) - cut[1], feet(8) - cut[2]]);
}
;

/**
 * @module sheet_4x8x1_2
 * @brief Models a 4x8 foot plywood sheet with 1/2 inch thickness.
 * 
 * @param cut Vector [x, y, z] specifying material trimmed from each dimension (in inches).
 */
module sheet_4x8x1_2(cut = [0, 0, 0]) {
  echo("4x8x1/2");
  cube([feet(4) - cut[0], feet(8) - cut[1], inches(0, 1 / 2) - cut[2]]);
}
;

/**
 * @module sheet_4x8x3_4
 * @brief Models a 4x8 foot plywood sheet with 3/4 inch thickness.
 * 
 * @param cut Vector [x, y, z] specifying material trimmed from each dimension (in inches).
 */
module sheet_4x8x3_4(cut = [0, 0, 0]) {
  echo("4x8x3/4");
  cube([feet(4) - cut[0], feet(8) - cut[1], inches(0, 3 / 4) - cut[2]]);
}
;

plank_2x4x8();

translate([24, 0, 0])
  plank_2x6x8();

translate([48, 0, 0])
  sheet_4x8x1_2();

translate([120, 0, 0])
  sheet_4x8x3_4();
