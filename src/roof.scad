// roof.scad: a gable roof over the walls.
//
// Rafters in pairs sit over the studs, one flush with each end wall. Each
// rafter has a birdsmouth seat on the wall's top plate, a plumb cut against
// the ridge board and a plumb-cut tail at the eave. A ceiling joist beside
// each pair ties the walls together, its ends cut to the roof's slope.
// Sheathing covers both slopes up to a ridge vent gap.
//
// In each rafter's profile, y runs across the house and z is height; h_top
// is the top of the wall's top plates.

function slope(pitch) = atan(pitch / 12);
// The seat is as wide as the wall, but the notch above it no deeper than a
// third of the rafter.
function seat_len(pitch, rafter, wall) = min(wall, depth(rafter) / 3 / (pitch / 12));
// The ridge board: the first size deeper than the rafter's plumb cut.
function ridge_stock(pitch, rafter) =
  let (plumb = depth(rafter) / cos(slope(pitch)))
  [for (l = LUMBER) if (l[2] >= plumb && l[2] > depth(rafter)) l[0]][0];

// Height of the rafter's lower and upper edges at y, on the front slope.
function rafter_bottom(y, h_top, pitch, seat) = h_top + (y - seat) * pitch / 12;
function rafter_top(y, h_top, pitch, seat, rafter) =
  rafter_bottom(y, h_top, pitch, seat) + depth(rafter) / cos(slope(pitch));

// x of each rafter pair: flush at both ends, the rest on centres, leaving
// room for the ties at the ends.
function rafter_xs(length, t, spacing) =
  concat([0, length - t], [for (c = on_centre(0, length, spacing, 2.5 * t)) c - t / 2]);

function roof_frame(length, width, h_top, wall, rafter, pitch, overhang, spacing, max_len) =
  let (
    t = thickness(rafter),
    d = depth(rafter),
    k = pitch / 12,
    seat = seat_len(pitch, rafter, wall),
    ridge = ridge_stock(pitch, rafter),
    y_ridge = width / 2 - thickness(ridge) / 2,
    bot = function(y) rafter_bottom(y, h_top, pitch, seat),
    top = function(y) rafter_top(y, h_top, pitch, seat, rafter),
    front = concat(
      overhang > 0 ? [[-overhang, bot(-overhang)]] : [],
      [[0, bot(0)], [0, h_top], [seat, h_top], [y_ridge, bot(y_ridge)], [y_ridge, top(y_ridge)], [-overhang, top(-overhang)]]
    ),
    back = [for (p = front) [width - p[0], p[1]]],
    rafter_len = (y_ridge + overhang) / cos(slope(pitch)),
    // Ties: rafter stock on the top plates, ends cut under the roof line.
    z_tie = h_top + d,
    z_end = top(0),
    y_cut = z_end >= z_tie ? 0 : (z_tie - z_end) / k,
    tie = z_end >= z_tie
      ? [[0, h_top], [width, h_top], [width, z_tie], [0, z_tie]]
      : [[0, h_top], [width, h_top], [width, z_end], [width - y_cut, z_tie], [y_cut, z_tie], [0, z_end]],
    tie_x = function(x) x == 0 ? t : x == length - t ? length - 2 * t : x + t / 2 < length / 2 ? x + t : x - t
  )
  concat(
    [for (x = rafter_xs(length, t, spacing)) each [
      ["prism", rafter, "roof", [x, t, rafter_len], front],
      ["prism", rafter, "roof", [x, t, rafter_len], back],
      ["prism", rafter, "ties", [tie_x(x), t, width], tie],
    ]],
    [for (p = splice(0, length, max_len, spacing))
      box(ridge, "roof", [p[0], y_ridge, top(y_ridge) - depth(ridge)], [p[1] - p[0], thickness(ridge), depth(ridge)])]
  );

// Sheathing on both slopes, in 4' rows up from the eave, every other row
// shifted 4' so its joints land on rafters. It stops `vent` short of the
// ridge on each side.
function roof_sheathing(length, width, h_top, wall, rafter, pitch, overhang, sheet, vent) =
  let (
    seat = seat_len(pitch, rafter, wall),
    run = (width / 2 - vent + overhang) / cos(slope(pitch)),
    rows = ceil(run / SHEET_W - 1e-9),
    frame = function(flip) [-overhang, rafter_top(-overhang, h_top, pitch, seat, rafter), slope(pitch), flip, width]
  )
  [for (flip = [false, true], r = [0:1:rows - 1], p = staggered(0, length, r % 2 * SHEET_W))
    ["slab", sheet, "roof sheathing", [p[0], p[1] - p[0], r * SHEET_W, min(SHEET_W, run - r * SHEET_W)], frame(flip)]];
