// walls.scad: four stud walls on the floor.
//
// The front and back walls run the full length; the end walls fit between
// them. Each has a bottom plate, studs flush at both ends and on centres
// between, and a double top plate. The upper top plates of the end walls run
// the full width and lap over the long walls, and every upper plate joint
// sits half a piece along from the joints below it.

function walls(length, width, z0, height, stud, spacing, max_len) =
  let (
    t = thickness(stud),
    w = depth(stud),
    h = height - 3 * t,
    z_top = z0 + t + h
  )
  concat(
    // Front and back
    [for (y = [0, width - w]) each concat(
      [for (p = splice(0, length, max_len, spacing), z = [z0, z_top])
        box(stud, "walls", [p[0], y, z], [p[1] - p[0], w, t])],
      [for (p = splice(w, length - w, max_len, spacing, true))
        box(stud, "walls", [p[0], y, z_top + t], [p[1] - p[0], w, t])],
      [for (x = concat([0, length - t], [for (c = on_centre(0, length, spacing)) c - t / 2]))
        box(stud, "walls", [x, y, z0 + t], [t, w, h])]
    )],
    // Ends
    [for (x = [0, length - w]) each concat(
      [for (p = splice(w, width - w, max_len, spacing), z = [z0, z_top])
        box(stud, "walls", [x, p[0], z], [w, p[1] - p[0], t])],
      [for (p = splice(0, width, max_len, spacing, true))
        box(stud, "walls", [x, p[0], z_top + t], [w, p[1] - p[0], t])],
      [for (y = concat([w, width - w - t], [for (c = on_centre(w, width - w, spacing)) c - t / 2]))
        box(stud, "walls", [x, y, z0 + t], [w, t, h])]
    )]
  );
