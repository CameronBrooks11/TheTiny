// floor.scad: the floor platform and its sheathing.
//
// Rim joists run the length of the house, spliced over a joist where the
// stock runs out. Joists span its width between them: one flush at each end,
// the rest on centres from the house's end. Sheathing runs across the joists
// in 4' rows, every other row shifted 4', so each end joint lands on a joist.

function floor_frame(length, width, joist, spacing, max_len) =
  let (t = thickness(joist), d = depth(joist))
  concat(
    [for (y = [0, width - t], p = splice(0, length, max_len, spacing))
      box(joist, "floor", [p[0], y, 0], [p[1] - p[0], t, d])],
    [for (x = concat([0, length - t], [for (c = on_centre(0, length, spacing)) c - t / 2]))
      box(joist, "floor", [x, t, 0], [t, width - 2 * t, d])]
  );

function floor_sheathing(length, width, z, sheet) =
  let (rows = ceil(width / SHEET_W - 1e-9))
  [for (r = [0:1:rows - 1], p = staggered(0, length, r % 2 * SHEET_W))
    box(sheet, "subfloor", [p[0], r * SHEET_W, z], [p[1] - p[0], min(SHEET_W, width - r * SHEET_W), thickness(sheet)])];
