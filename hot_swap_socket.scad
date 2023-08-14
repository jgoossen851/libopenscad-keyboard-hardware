use <lib/geometry/prism.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

hot_swap_socket(z_offset = 0);


// ### Module ########################################################

module hot_swap_socket(z_offset = -5) {
  pinD = 3;
  pin_x = 1.27 * [-3, 2];
  pin_y = 1.27 * [2, 4];
  pin_h = 3.2;
  pin_x_avg = (pin_x[0] + pin_x[1]) / 2;
  pin_y_avg = (pin_y[0] + pin_y[1]) / 2;

  cutD = 4 + 0.5;
  body_h = 1.8;
  body_x = 10.9;
  body_y = 6;
  body_fillet = 2;

  tab_sep = 14.5;
  tab_x = pin_x_avg * [1, 1] + tab_sep / 2 * [-1, 1];
  tab_y = 1.75;
  tab_len = 4;
  center_cutout_d = 6;

  eps = 0.01;

  translate([0, 0, z_offset - pin_h]) {
    color( "DarkSlateGray" ) {
      translate([pin_x[0], pin_y[0], 0])
      cylinder(d = pinD, h = pin_h);

      translate([pin_x[1], pin_y[1], 0])
      cylinder(d = pinD, h = pin_h);

      difference() {
        translate([pin_x_avg, pin_y_avg, 0])
        prism([body_x, body_y, body_h]);
        hull() {
          cylinder(h = 3*body_h, d = center_cutout_d, center = true);
          translate([body_x, 0, 0])
          cylinder(h = 3*body_h, d = center_cutout_d, center = true);
        }
      }
    }

    color( "Silver" ) {
      translate([tab_x[0], pin_y[0], body_h / 2 - eps])
      rotate([0, 90, 0])
      prism([body_h, tab_y, tab_len]);

      translate([tab_x[1], pin_y[1], body_h / 2 - eps])
      rotate([0, -90, 0])
      prism([body_h, tab_y, tab_len]);
    }
  }
}
