// lumber.scad: stock sizes, layout rules, members and the cut list.
//
// Every part of the house is a member, a list that both draws it and counts
// it in the cut list:
//   ["box", stock, layer, min, size]
//       an axis-aligned stick or sheet, from corner `min`, `size` across
//   ["prism", stock, layer, [x0, w, length], profile]
//       a profile in the y-z plane, `w` thick along x from x0; `length` is
//       the stock it is cut from
//   ["slab", stock, layer, [x0, w, s0, sl], [y0, z0, angle, flip, width]]
//       a sheet on a roof slope: `w` along x from x0 and `sl` up the slope
//       from s0, in a frame at (y0, z0) tilted by `angle`; `flip` mirrors it
//       to the back slope of a house `width` deep
// All sizes are in inches.

function feet(f) = f * 12;

// Actual sizes of nominal lumber: [name, thickness, depth]
LUMBER = [
  ["2x4", 1.5, 3.5],
  ["2x6", 1.5, 5.5],
  ["2x8", 1.5, 7.25],
  ["2x10", 1.5, 9.25],
  ["2x12", 1.5, 11.25],
];
// 4' x 8' sheet goods: [name, thickness]
SHEETS = [["ply 3/4", 0.75], ["ply 1/2", 0.5]];
SHEET_W = 48;
SHEET_L = 96;

LAYER_COLOURS = [
  ["floor", "BurlyWood"],
  ["subfloor", "Tan"],
  ["walls", "Wheat"],
  ["roof", "Peru"],
  ["ties", "SandyBrown"],
  ["roof sheathing", "Sienna"],
];

function row(table, name) = table[search([name], table)[0]];
function is_sheet(name) = len([for (s = SHEETS) if (s[0] == name) 1]) > 0;
function is_lumber(name) = len([for (s = LUMBER) if (s[0] == name) 1]) > 0;
function thickness(name) = is_sheet(name) ? row(SHEETS, name)[1] : row(LUMBER, name)[1];
function depth(name) = row(LUMBER, name)[2];

// ---------------- Layout ----------------
// Centres of the members between two end members flush at a and b, on a grid
// of `spacing` measured from 0, at least `clear` in from either end.
function on_centre(a, b, spacing, clear = 2.25) =
  [for (k = [ceil((a + clear) / spacing):1:floor((b - clear) / spacing)]) k * spacing];

// A run from a to b in pieces no longer than max_len. Joints fall on the
// grid, every `piece`, so each lands on a member below or beside it. No end
// piece is shorter than two grid spaces: a joint closer to an end is
// dropped, and `piece` leaves room for that. `shifted` moves the joints half
// a piece along, for a second layer over the first. Returns [[start, end], ...].
function splice(a, b, max_len, spacing, shifted = false) =
  let (
    clear = 2 * spacing,
    piece = floor((max_len - clear) / spacing) * spacing,
    phase = shifted ? round(piece / 2 / spacing) * spacing : 0,
    joints = [for (k = [ceil((a + clear - phase) / piece):1:floor((b - clear - phase) / piece)]) phase + k * piece],
    ends = concat([a], joints, [b])
  )
  [for (i = [0:1:len(ends) - 2]) [ends[i], ends[i + 1]]];

// Sheets along a run, joined at `offset` and every 8' after it.
function staggered(a, b, offset) =
  let (
    joints = [for (x = [offset:SHEET_L:b]) if (x > a + 1e-6 && x < b - 1e-6) x],
    ends = concat([a], joints, [b])
  )
  [for (i = [0:1:len(ends) - 2]) [ends[i], ends[i + 1]]];

function box(stock, layer, min, size) = ["box", stock, layer, min, size];

// ---------------- Drawing ----------------
module draw(m) {
  color(row(LAYER_COLOURS, m[2])[1])
    if (m[0] == "box") translate(m[3]) cube(m[4]);
    else if (m[0] == "prism") translate([m[3][0], 0, 0]) rotate([90, 0, 90]) linear_extrude(m[3][1]) polygon(m[4]);
    else if (m[0] == "slab") {
      f = m[4];
      p = m[3];
      mirror_back(f[3], f[4]) translate([p[0], f[0], f[1]]) rotate([f[2], 0, 0]) translate([0, p[2], 0])
        cube([p[1], p[3], thickness(m[1])]);
    }
}

module mirror_back(flip, width) {
  if (flip) translate([0, width, 0]) mirror([0, 1, 0]) children();
  else children();
}

// ---------------- Cut list ----------------
function stick_length(m) = m[0] == "box" ? max(m[4]) : m[3][2];
function stock_length(l, lengths) = min([for (s = lengths) if (s >= l - 1e-6) s]);
function join(v, sep = ", ", i = 0) = i >= len(v) ? "" : str(v[i], i < len(v) - 1 ? sep : "", join(v, sep, i + 1));
function sorted(v) =
  len(v) <= 1 ? v
  : let (p = v[0], rest = [for (i = [1:1:len(v) - 1]) v[i]])
    concat(sorted([for (x = rest) if (x < p) x]), [p], sorted([for (x = rest) if (x >= p) x]));
function distinct(v) = [for (i = [0:1:len(v) - 1]) if (len([for (j = [0:1:i - 1]) if (v[j] == v[i]) 1]) == 0) v[i]];

// The stock to buy, one stick per piece with no reuse of offcuts, then each
// cut length; the sheet count, one sheet per piece.
module cut_list(members, lengths) {
  for (l = LUMBER) {
    cuts = [for (m = members) if (m[1] == l[0]) round(stick_length(m) * 8) / 8];
    if (len(cuts) > 0) {
      buy = [for (s = lengths) let (n = len([for (c = cuts) if (stock_length(c, lengths) == s) 1])) if (n > 0) str(n, " @ ", s / 12, "'")];
      echo(str("Buy ", l[0], ": ", join(buy)));
      kinds = sorted(distinct(cuts));
      echo(str("  cut ", l[0], ": ", join([for (k = kinds) str(len([for (c = cuts) if (c == k) 1]), " x ", k, " in")])));
    }
  }
  for (s = SHEETS) {
    n = len([for (m = members) if (m[1] == s[0]) 1]);
    if (n > 0) echo(str("Buy ", s[0], ": ", n, " sheets"));
  }
}
