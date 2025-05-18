use <utilities.scad>;

// Stick
module stick_2x4x8(cut = [0, 0, 0]) {
  echo("stick_2x4x8");
  cube([inches(1, 1 / 2) - cut[0], inches(3, 1 / 2) - cut[1], feet(8) - cut[2]]);
}
;

module stick_2x6x8(cut = [0, 0, 0]) {
  echo("stick_2x6x8");
  cube([inches(1, 1 / 2) - cut[0], inches(5, 1 / 2) - cut[1], feet(8) - cut[2]]);
}
;

// Sheet
module stick_4x8x1_2(cut = [0, 0, 0]) {
  echo("4x8x1/2");
  cube([feet(4) - cut[0], feet(8) - cut[1], inches(0, 1 / 2) - cut[2]]);
}
;

module stick_4x8x3_4(cut = [0, 0, 0]) {
  echo("4x8x3/4");
  cube([feet(4) - cut[0], feet(8) - cut[1], inches(0, 3 / 4) - cut[2]]);
}
;

stick_2x4x8();

translate([24, 0, 0])
  stick_2x6x8();

translate([48, 0, 0])
  stick_4x8x1_2();

translate([120, 0, 0])
  stick_4x8x3_4();
