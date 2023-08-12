use <lib/geometry/prism.scad>
use <lib/geometry/translate_and_mirror.scad>
use <hot_swap_socket.scad>

// ### Usage #########################################################
key();
hot_swap_socket();


// ### Module ########################################################
body_width = 13.9;
body_depth = 4.5;
body_engage_depth = 1.6;
body_addtl_clearance = 0.6;
body_slopeaway_depth = 2;
  
flange_width = 15.5;

eps = 0.01;

module key() {

  flange_depth = 1;

  tab_cutout_width = 5;

  keycap_width = 18.2;
  keycap_depth = 7.5;
  keycap_taper = 3.5;
  keycap_offset = 5.2;

  render(convexity = 4) {
    // Body
    key_body_square();
    intersection() {
      scale([1.4, 1, 1])  key_body_round();
      scale([1, 1.4, 1])  key_body_round();
    }

    // Flange & Tab cutout
    difference() {
      // Flange
      translate([0, 0, flange_depth])
      prism([flange_width, flange_width, flange_depth + body_depth], invert = true);
      // Tab
      translate([0, 0, eps])
      translate_and_mirror([(tab_cutout_width + flange_width)/2, 0, 0])
      prism([flange_width, 1.1*flange_width, 1.1*body_depth], invert = true);
    }
    
    // Keycap
    color("white", 0.5)
    translate([0, 0, flange_depth + keycap_offset])
    prism_tapered_cuboid([keycap_width, keycap_width, keycap_depth], keycap_taper);
  }
}

module key_profile() {
  polygon(
    points = [ 
      // 0----5
      // |    4
      // |     3
      // 1-----2
      [0, 2*eps],
      [0, -body_depth],
      [body_width/2 + body_addtl_clearance, -body_depth],
      [body_width/2 + body_addtl_clearance, -body_engage_depth - body_slopeaway_depth],
      [body_width/2, -body_engage_depth],
      [body_width/2, 2*eps],
    ],
    paths = [ 
      [0, 1, 2, 3, 4, 5]
    ], 
    convexity = 1
  );
}

module key_body_square() {
  scale([sqrt(2), sqrt(2), 1]) rotate([0, 0, 45])
  rotate_extrude(angle = 360, convexity = 1, $fn = 4) {
    key_profile();
  }
}

module key_body_round() {
  scale([flange_width/body_width, flange_width/body_width, 1]) rotate([0, 0, 0])
  rotate_extrude(angle = 360, convexity = 1) {
    key_profile();
  }
}
