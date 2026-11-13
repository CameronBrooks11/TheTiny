"""Build the house at several sizes and check the framing.

usage: python3 tests/test_tiny.py [OPENSCAD]

For each configuration it reads every member from the console
(list_members = true) and checks:
  - each stick has its stock's cross-section and fits the longest stock;
    each sheet piece fits a 4' x 8' sheet;
  - no two axis-aligned members overlap;
  - the subfloor covers the floor exactly in staggered rows, and the walls and floor share
    the house's footprint;
  - every joint in a spliced run (rim joists, plates, ridge board) lands on
    a joist, stud or rafter, and upper top plate joints sit at least 24 in
    from the joints below (IRC R602.3.2);
  - the cut list buys one stick per piece, at the shortest stock it fits,
    and one sheet per sheet piece;
  - the birdsmouth notch is no deeper than a third of the rafter;
then through tests/probe.scad that the sloped members (rafters, ties and
roof sheathing) overlap nothing, and that every rafter sits on a plate.
Finally, sizes that cannot be built fail with a message.
"""

import json
import os
import re
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOUSE = os.path.join(ROOT, "src", "house.scad")
PROBE = os.path.join(ROOT, "tests", "probe.scad")

LUMBER = {"2x4": (1.5, 3.5), "2x6": (1.5, 5.5), "2x8": (1.5, 7.25), "2x10": (1.5, 9.25), "2x12": (1.5, 11.25)}
SHEETS = {"ply 3/4": 0.75, "ply 1/2": 0.5}
EPS = 1e-6

CONFIGS = {
    "default 20' x 8'": {},
    "16'8\" x 9'2\", 8/12, 24 in centres": {"length": 200, "width": 110, "wall_height": 90, "pitch": 8,
                                            "overhang": 6, "spacing": 24},
    "30' x 8'6\", 4/12, 12 in centres, 2x8 and 2x6": {"length": 360, "width": 102, "wall_height": 100, "pitch": 4,
                                                     "overhang": 0, "spacing": 12, "joist": '"2x8"',
                                                     "stud": '"2x6"', "rafter": '"2x8"'},
    "12' x 7', 12/12, 18 in overhang": {"length": 144, "width": 84, "pitch": 12, "overhang": 18},
}

REFUSED = {
    "joists longer than any stock": ({"width": 200}, "longer than the longest stock"),
    "20 in centres": ({"spacing": 20}, "spacing must be 12, 16 or 24"),
    "no stock of 8 ft": ({"stock_feet": "[6]"}, "at least 8 ft"),
    "roof too low for the ties": ({"pitch": 1}, "too low for the ceiling ties"),
}


def run(openscad, scad, out, defines, export="binstl"):
    cmd = [openscad, "--hardwarnings", "--export-format", export, "-o", out]
    for name, value in defines.items():
        cmd += ["-D", f"{name}={value}"]
    return subprocess.run(cmd + [scad], capture_output=True, text=True)


def solids(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for i in range(n):
        a = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        corners = [a[0:3], a[3:6], a[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    return len({find(v) for v in parent})


def volume(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    v = 0.0
    for i in range(n):
        a = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        p, q, r = a[0:3], a[3:6], a[6:9]
        v += (p[0] * (q[1] * r[2] - q[2] * r[1]) - p[1] * (q[0] * r[2] - q[2] * r[0])
              + p[2] * (q[0] * r[1] - q[1] * r[0])) / 6
    return abs(v)


def bounds(m):
    """Axis-aligned bounds of a box or prism member: (lo, hi)."""
    if m[0] == "box":
        lo = m[3]
        return lo, [lo[i] + m[4][i] for i in range(3)]
    if m[0] == "prism":
        x0, w, _ = m[3]
        ys = [p[0] for p in m[4]]
        zs = [p[1] for p in m[4]]
        return [x0, min(ys), min(zs)], [x0 + w, max(ys), max(zs)]
    return None


def stick_len(m):
    return max(m[4]) if m[0] == "box" else m[3][2]


def overlap(a, b):
    return all(a[0][i] < b[1][i] - EPS and b[0][i] < a[1][i] - EPS for i in range(3))


def touch(a, b):
    return all(a[0][i] <= b[1][i] + EPS and b[0][i] <= a[1][i] + EPS for i in range(3))


def check_config(openscad, tmp, name, defines, report):
    echo = os.path.join(tmp, "house.echo")
    result = run(openscad, HOUSE, echo, {**defines, "list_members": "true"}, export="echo")
    lines = open(echo).read().splitlines() if os.path.exists(echo) else []
    errors = [l for l in lines if l.startswith("ERROR")]
    if result.returncode != 0 or errors:
        report(f"{name}: renders", False, errors[:1] or result.stderr.strip().splitlines()[-1:])
        return
    members = [json.loads(l[len('ECHO: "MEMBER '):-1].replace('\\"', '"')) for l in lines if l.startswith('ECHO: "MEMBER ')]
    length = defines.get("length", 240)
    width = defines.get("width", 96)
    spacing = defines.get("spacing", 16)
    max_len = 192
    report(f"{name}: renders with no warnings", "WARNING" not in result.stderr, f"{len(members)} members")

    # Sizes: each stick has its stock's section and fits the longest stock.
    bad = []
    for m in members:
        if m[1] in SHEETS:
            th = SHEETS[m[1]]
            if m[0] == "box":
                dims = sorted(m[4])
                ok = abs(dims[0] - th) < EPS and dims[1] <= 48 + EPS and dims[2] <= 96 + EPS
            else:
                ok = m[3][1] <= 96 + EPS and m[3][3] <= 48 + EPS
        elif m[0] == "box":
            dims = sorted(m[4])
            ok = (abs(dims[0] - LUMBER[m[1]][0]) < EPS and abs(dims[1] - LUMBER[m[1]][1]) < EPS
                  and dims[2] <= max_len + EPS)
        else:
            ok = abs(m[3][1] - LUMBER[m[1]][0]) < EPS and m[3][2] <= max_len + EPS
        if not ok:
            bad.append(m[:4])
    report(f"{name}: every piece has its stock's section and fits the stock", not bad, bad[:2] or "all fit")

    boxes = [(m, bounds(m)) for m in members if m[0] == "box"]
    clashes = [(a[0][2], b[0][2]) for i, a in enumerate(boxes) for b in boxes[i + 1:] if overlap(a[1], b[1])]
    report(f"{name}: no two axis-aligned members overlap", not clashes, clashes[:3] or f"{len(boxes)} members apart")

    sub = [b for m, b in boxes if m[2] == "subfloor"]
    area = sum((b[1][0] - b[0][0]) * (b[1][1] - b[0][1]) for b in sub)
    inside = all(b[0][0] >= -EPS and b[0][1] >= -EPS and b[1][0] <= length + EPS and b[1][1] <= width + EPS for b in sub)
    report(f"{name}: the subfloor covers the floor exactly", inside and abs(area - length * width) < 1e-3,
           f"{area:.1f} of {length * width} sq in in {len(sub)} pieces")

    # Neighbouring subfloor rows share no end joint.
    rows = {}
    for b in sub:
        rows.setdefault(round(b[0][1], 6), set()).update({round(b[0][0], 6), round(b[1][0], 6)} - {0, length})
    ys = sorted(rows)
    shared = [(ys[i], sorted(rows[ys[i]] & rows[ys[i + 1]])) for i in range(len(ys) - 1) if rows[ys[i]] & rows[ys[i + 1]]]
    report(f"{name}: subfloor rows are staggered", not shared, shared[:2] or f"{len(ys)} rows")

    for layer in ("floor", "walls"):
        bs = [b for m, b in boxes if m[2] == layer]
        foot = [min(b[0][0] for b in bs), min(b[0][1] for b in bs), max(b[1][0] for b in bs), max(b[1][1] for b in bs)]
        report(f"{name}: the {layer} footprint is {length} x {width}",
               all(abs(a - b) < EPS for a, b in zip(foot, [0, 0, length, width])), foot)

    # Spliced runs: two collinear pieces of the same stock end to end. The
    # joint must sit inside some other member that touches both.
    supports = [(m, bounds(m)) for m in members if m[0] in ("box", "prism") and m[2] not in ("subfloor",)]
    joints, unsupported = [], []
    for i, (a, ab) in enumerate(boxes):
        for b, bb in boxes[i + 1:]:
            if a[1] != b[1] or a[2] != b[2] or a[1] in SHEETS:
                continue
            for k in range(3):
                others = [j for j in range(3) if j != k]
                if any(abs(ab[0][j] - bb[0][j]) > EPS or abs(ab[1][j] - bb[1][j]) > EPS for j in others):
                    continue
                if abs(ab[1][k] - bb[0][k]) < EPS or abs(bb[1][k] - ab[0][k]) < EPS:
                    at = ab[1][k] if abs(ab[1][k] - bb[0][k]) < EPS else bb[1][k]
                    joints.append((a, k, at, ab))
                    held = any(s is not a and s is not b and sb[0][k] < at - EPS and at + EPS < sb[1][k]
                               and touch(sb, ab) and touch(sb, bb) for s, sb in supports)
                    if not held:
                        unsupported.append((a[1], a[2], k, at))
    report(f"{name}: every splice joint lands on a member", joints and not unsupported,
           f"{len(joints)} joints" if not unsupported else unsupported[:3])

    # Upper top plate joints against the lower ones, per wall.
    plates = [(m, b) for m, b in boxes if m[2] == "walls" and abs(b[1][2] - b[0][2] - 1.5) < EPS]
    tops = sorted({round(b[0][2], 6) for m, b in plates})
    lower_z, upper_z = tops[-2], tops[-1]
    near = []
    for m, k, at, b in joints:
        if m[2] == "walls" and abs(b[0][2] - upper_z) < EPS:
            for m2, k2, at2, b2 in joints:
                if m2[2] == "walls" and k2 == k and abs(b2[0][2] - lower_z) < EPS and touch(b, [b2[0], [b2[1][0], b2[1][1], b2[1][2] + 1.5]]):
                    if abs(at - at2) < 24 - EPS:
                        near.append((k, at, at2))
    report(f"{name}: upper plate joints sit 24 in or more from those below", not near, near[:3] or "apart")

    # Cut list: one stick per piece, one sheet per sheet piece.
    buys = {}
    for l in lines:
        mo = re.match(r'ECHO: "Buy (.+?): (.*)"', l)
        if mo:
            buys[mo.group(1)] = sum(int(n) for n in re.findall(r"(\d+) (?:@|sheets)", mo.group(2)))
    counts = {}
    for m in members:
        counts[m[1]] = counts.get(m[1], 0) + 1
    report(f"{name}: the cut list buys one stick or sheet per piece", buys == counts, buys)

    # Each stick is bought at the shortest stock length it fits.
    stock = [96, 120, 144, 168, 192]
    wrong = []
    for size in LUMBER:
        want = sorted(min(s for s in stock if s >= round(stick_len(m) * 8) / 8 - EPS) for m in members if m[1] == size)
        line = next((l for l in lines if l.startswith(f'ECHO: "Buy {size}: ')), "")
        got = sorted(int(ft) * 12 for n, ft in re.findall(r"(\d+) @ (\d+)'", line) for _ in range(int(n)))
        if got != want:
            wrong.append(size)
    report(f"{name}: each stick is bought at the shortest stock it fits", not wrong, wrong or "all")

    notch = float(re.search(r"notch ([\d.]+) in", "\n".join(lines)).group(1))
    rafter = defines.get("rafter", '"2x6"').strip('"')
    report(f"{name}: the birdsmouth notch is at most a third of the rafter", notch <= LUMBER[rafter][1] / 3 + 0.01,
           f"{notch} in")

    stl = os.path.join(tmp, "probe.stl")
    for check in ("rafters_vs_boxes", "rafters_vs_ties", "sheathing_vs_frame", "sheathing_sides"):
        result = run(openscad, PROBE, stl, {**defines, "CHECK": f'"{check}"'})
        # An empty result exits 1 under --hardwarnings; anything else must render.
        empty = "top level object is empty" in result.stderr.lower()
        failed = "ERROR" in result.stderr or (result.returncode != 0 and not empty)
        v = 0.0 if empty or failed else volume(stl)
        report(f"{name}: {check.replace('_', ' ')}: no overlap", not failed and v < 0.01,
               "failed" if failed else "empty" if empty else f"{v:.3f} cu in")

    # Each rafter's seat, the full seat length on a plate, meets the plates
    # raised 0.02 in over seat x 1.5 x 0.02 cu in (plus a sliver where the
    # rafter rises past the seat). The total must match one seat per rafter.
    rafters = [m for m in members if m[0] == "prism" and m[2] == "roof"]
    seat = float(re.search(r"seat ([\d.]+) in", "\n".join(lines)).group(1))
    pitch = defines.get("pitch", 6) / 12
    one = rafters[0][3][1] * (seat * 0.02 + 0.02 * 0.02 / pitch / 2)
    result = run(openscad, PROBE, stl, {**defines, "CHECK": '"seats"'})
    ok = result.returncode == 0 and "ERROR" not in result.stderr
    v = volume(stl) if ok else 0.0
    report(f"{name}: every rafter sits its full seat on a plate", ok and abs(v / one - len(rafters)) < 0.5,
           f"{v / one:.2f} seats for {len(rafters)} rafters")


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    failures = []

    def report(label, ok, got):
        print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")
        if not ok:
            failures.append(label)

    with tempfile.TemporaryDirectory() as tmp:
        for name, defines in CONFIGS.items():
            check_config(openscad, tmp, name, defines, report)
        out = os.path.join(tmp, "refused.echo")
        for name, (defines, message) in REFUSED.items():
            # An assertion leaves its ERROR in the echo file, and the exit is 0.
            result = run(openscad, HOUSE, out, defines, export="echo")
            text = result.stderr + (open(out).read() if os.path.exists(out) else "")
            os.path.exists(out) and os.remove(out)
            refused = any(l.startswith("ERROR") and message in l for l in text.splitlines())
            report(f"refuses {name}", refused, "refused" if refused else text.strip().splitlines()[-1:])

    print("all checks passed" if not failures else f"{len(failures)} failed")
    sys.exit(1 if failures else 0)


main()
