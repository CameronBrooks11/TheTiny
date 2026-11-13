// Checks on the sloped members, chosen by CHECK. Each renders an
// intersection that should be empty (or, for "seats", one piece per rafter).
//   "rafters_vs_boxes":   rafters and ties against every axis-aligned member
//   "rafters_vs_ties":    rafters against ties
//   "sheathing_vs_frame": roof sheathing against everything else
//   "sheathing_sides":    front roof sheathing against back
//   "seats":              rafters against the wall plates raised 0.02 in;
//                         one piece per rafter if each sits on a plate
include <../src/house.scad>

part = "none";
CHECK = "rafters_vs_boxes";

module members(pick) for (m = MEMBERS) if (pick(m)) draw(m);

is_rafter = function(m) m[0] == "prism" && m[2] == "roof";
is_tie = function(m) m[2] == "ties";
is_slab = function(m) m[0] == "slab";

if (CHECK == "rafters_vs_boxes")
  intersection() { members(function(m) m[0] == "prism"); members(function(m) m[0] == "box"); }
else if (CHECK == "rafters_vs_ties")
  intersection() { members(is_rafter); members(is_tie); }
else if (CHECK == "sheathing_vs_frame")
  intersection() { members(is_slab); members(function(m) !is_slab(m)); }
else if (CHECK == "sheathing_sides")
  intersection() { members(function(m) is_slab(m) && !m[4][3]); members(function(m) is_slab(m) && m[4][3]); }
else if (CHECK == "seats")
  intersection() { members(is_rafter); translate([0, 0, 0.02]) members(function(m) m[2] == "walls"); }
