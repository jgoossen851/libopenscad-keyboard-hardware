use <lib/geometry/prism.scad>
use <stabilizer_spacing.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

color( "DimGray" )
keycap();

color( "Gray" )
translate([19.05*1.5, 0, 0])
keycap(w = 2);

wvec = [1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 5.5, 6.25, 7, 8];
translate([-19.05, 0, 0])
for (iw = [0 : len(wvec) - 1])
  translate([0, 19.05*iw, 0])
  keycap(w = wvec[iw]);

// ### Module ########################################################

// Key `d` x `w` keycap, with `d` and `w` in units of `u`.
// Key height, in mm, given as `h`.
// Other parameters:
// * `taper`
// * `z_offset`
// * `clearance`: amount by which `w*u` or `d*u` exceeds a key's physical dimension
module keycap(u = 19.05, d = 1, w = 1, h = 7.25,
              taper = 3.15, z_offset = 0, clearance = 0.75) {
  eps = 0.01;
  thickness = 1.2;

  translate([0, 0, z_offset]) {
    difference() {
      prism_tapered_cuboid([w*u - clearance, d*u - clearance, h], taper);
      translate([0, 0, -eps])
      prism_tapered_cuboid( [ w*u - clearance - thickness,
                              d*u - clearance - thickness,
                              h - thickness + eps],
                            taper);
    }
    keycap_pillars_(h - thickness + eps, w);
  }
}

module keycap_pillars_(h, w = 1) {
  keycap_pillar_(h);
  stab_dist = stabilizer_spacing(w);
  if (stab_dist != 0) {
    for (x = [-1, 1]*stab_dist/2)
    translate([x, 0, 0])
    keycap_pillar_(h);
  }
}

module keycap_pillar_(h) {
  center_diameter = 5.4;
  cylinder( h = h, d = center_diameter);
}
