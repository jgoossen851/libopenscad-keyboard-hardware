use <lib/geometry/prism.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

color( "DimGray" )
keycap();

color( "Gray" )
translate([19.05*1.5, 0, 0])
keycap(w = 2);


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
  center_diameter = 5.4;

  translate([0, 0, z_offset]) {
    difference() {
      prism_tapered_cuboid([w*u - clearance, d*u - clearance, h], taper);
      translate([0, 0, -eps])
      prism_tapered_cuboid( [ w*u - clearance - thickness,
                              d*u - clearance - thickness,
                              h - thickness + eps],
                            taper);
    }
    cylinder( h = h - thickness + eps, d = center_diameter);
  }
}
