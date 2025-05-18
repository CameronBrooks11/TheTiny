use <utilities.scad>;
use <lumber.scad>;

module frame_floor(start_height = 0, width = feet(20), depth = feet(8)) {
  // South Rim Joists
  for (x = [0:feet(8):width]) {
    trim = x + feet(8) > width ? [0, 0, x + feet(8) - width] : [0, 0, 0];

    translate([x, 0, 0])
      rotate(a=[0, 90, 0])
        rotate(a=90, v=[0, 0, 1])
          stick_2x6x8(cut=trim);
  }

  // North Rim Joists
  for (x = [width:feet(8) * -1:1]) {
    echo(x - feet(8)); trim = x - feet(8) < 0 ? [0, 0, feet(8) - x] : [0, 0, 0];

    translate([x - feet(8) + trim[2], depth - inches(1, 1 / 2), 0])
      rotate(a=[0, 90, 0])
        rotate(a=90, v=[0, 0, 1])
          stick_2x6x8(cut=trim);
  }

  // floor joists
  translate([0, inches(1, 1 / 2), inches(5, 1 / 2)])
    rotate(a=[270, 0, 00])
      stick_2x6x8(cut=[0, 0, feet(8) - depth + inches(3)]);

  for (x = [inches(15, 1 / 4):inches(16):width - inches(1, 1 / 2)]) {
    translate([x, inches(1, 1 / 2), inches(5, 1 / 2)])
      rotate(a=[270, 0, 00])
        stick_2x6x8(cut=[0, 0, feet(8) - depth + inches(3)]);
  }

  translate([width - inches(1, 1 / 2), inches(1, 1 / 2), inches(5, 1 / 2)])
    rotate(a=[270, 0, 00])
      stick_2x6x8(cut=[0, 0, feet(8) - depth + inches(3)]);
}

frame_floor();
