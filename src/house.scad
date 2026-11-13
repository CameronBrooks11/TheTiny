// house.scad: The Tiny, a parametric tiny house frame.
//
// A floor platform, four stud walls and a gable roof, sized from the
// parameters below, with a cut list of the lumber and sheets to buy in the
// console. All sizes are in inches.

include <lumber.scad>
include <floor.scad>
include <walls.scad>
include <roof.scad>

/* [House] */
// Outside length, along the ridge (in)
length = 240;
// Outside width (in)
width = 96;
// Wall framing height, bottom plate to the top of the top plates (in)
wall_height = 96;

/* [Framing] */
// Distance between joist, stud and rafter centres (in)
spacing = 16; // [12, 16, 24]
joist = "2x6"; // [2x6, 2x8, 2x10, 2x12]
stud = "2x4"; // [2x4, 2x6]
rafter = "2x6"; // [2x4, 2x6, 2x8, 2x10]
// Lumber lengths you can buy (ft)
stock_feet = [8, 10, 12, 14, 16];

/* [Roof] */
// Rise per 12 in of run
pitch = 6;
// Eave overhang, measured level from the wall (in)
overhang = 12;
// Gap left open in the sheathing each side of the ridge (in)
ridge_vent = 1;

/* [Sheathing] */
subfloor = "ply 3/4"; // [ply 3/4, ply 1/2]
roof_sheet = "ply 1/2"; // [ply 1/2, ply 3/4]

/* [Show] */
show_floor = true;
show_subfloor = true;
show_walls = true;
show_roof = true;
show_roof_sheathing = true;
// "house" draws the house; "none" draws nothing, for including this file
part = "house"; // [house, none]
// Echo every member, for the checks
list_members = false;

LENGTHS = stock_feet * 12;
MAX_LEN = max(LENGTHS);

assert(MAX_LEN >= 96, "stock_feet must include a length of at least 8 ft");
assert(spacing == 12 || spacing == 16 || spacing == 24, "spacing must be 12, 16 or 24 in, so sheet joints land on framing");
assert(pitch > 0 && overhang >= 0 && ridge_vent >= 0, "pitch must be positive, overhang and ridge_vent not negative");
assert(is_lumber(joist) && is_lumber(stud) && is_lumber(rafter), "joist, stud and rafter must be sizes in LUMBER");
assert(is_sheet(subfloor) && is_sheet(roof_sheet), "subfloor and roof_sheet must be sizes in SHEETS");
assert(!is_undef(ridge_stock(pitch, rafter)), str("no ridge board in LUMBER is deep enough for ", rafter, " rafters at ", pitch, "/12"));

Z_SUBFLOOR = depth(joist);
Z_WALLS = Z_SUBFLOOR + thickness(subfloor);
H_TOP = Z_WALLS + wall_height;
WALL = depth(stud);
SEAT = seat_len(pitch, rafter, WALL);
RIDGE = ridge_stock(pitch, rafter);
RIDGE_TOP = rafter_top(width / 2 - thickness(RIDGE) / 2, H_TOP, pitch, SEAT, rafter);

assert(RIDGE_TOP - depth(RIDGE) >= H_TOP + depth(rafter), "the roof is too low for the ceiling ties to pass under the ridge board: raise the pitch or widen the house");

MEMBERS = concat(
  floor_frame(length, width, joist, spacing, MAX_LEN),
  floor_sheathing(length, width, Z_SUBFLOOR, subfloor),
  walls(length, width, Z_WALLS, wall_height, stud, spacing, MAX_LEN),
  roof_frame(length, width, H_TOP, WALL, rafter, pitch, overhang, spacing, MAX_LEN),
  roof_sheathing(length, width, H_TOP, WALL, rafter, pitch, overhang, roof_sheet, ridge_vent)
);

TOO_LONG = [for (m = MEMBERS) if (!is_sheet(m[1]) && stick_length(m) > MAX_LEN + 1e-6) [m[1], m[2], stick_length(m)]];
assert(len(TOO_LONG) == 0, str("pieces longer than the longest stock (", MAX_LEN / 12, "'): ", TOO_LONG,
                               ". Add a longer length to stock_feet or make the house smaller."));

function shown(layer) =
  layer == "floor" ? show_floor
  : layer == "subfloor" ? show_subfloor
  : layer == "walls" ? show_walls
  : layer == "roof" || layer == "ties" ? show_roof
  : show_roof_sheathing;

if (part == "house") {
  echo(str("The Tiny: ", length, " x ", width, " in, walls ", wall_height, " in, ", pitch, "/12 roof"));
  echo(str("Top plates at ", H_TOP, " in; ridge board (", RIDGE, ") top at ", round(RIDGE_TOP * 100) / 100, " in"));
  echo(str("Birdsmouth: seat ", round(SEAT * 100) / 100, " in, notch ", round(SEAT * pitch / 12 * 100) / 100, " in deep"));
  cut_list(MEMBERS, LENGTHS);
  if (list_members) for (m = MEMBERS) echo(str("MEMBER ", m));
  for (m = MEMBERS) if (shown(m[2])) draw(m);
} else assert(part == "none", str("part must be house or none, not ", part));
