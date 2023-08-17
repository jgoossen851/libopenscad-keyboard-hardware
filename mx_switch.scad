use <lib/geometry/prism.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

// Constants, from datasheet
mx_switch_plate_thickness_  = 1.5;    // mm, 0.06"
mx_switch_pcb_thickness_    = 1.5;    // mm, 0.06"
mx_switch_nominal_pitch_    = 19.05;  // mm, 0.75"

// Switch configurations to test
vec_x_w_color_geom = [
  // Default Switch
  [0, 1, [], []],
  // Custom Switches
  [-1, 1, ["Silver", "Beige", "Gainsboro", 0.5], [true, false, true]],
  [-2, 1, ["DodgerBlue", "LightSlateGray", "Azure"], [false, true, true]]
];

for (x_w_color_geom = vec_x_w_color_geom) {
  // Parse parameters
  dx = x_w_color_geom[0] * mx_switch_nominal_pitch_;
  w  = x_w_color_geom[1];
  switch_color = [
    len(x_w_color_geom[2]) > 0 ? x_w_color_geom[2][0] : "Red",
    len(x_w_color_geom[2]) > 1 ? x_w_color_geom[2][1] : "#222222",
    len(x_w_color_geom[2]) > 2 ? x_w_color_geom[2][2] : "#222222",
    len(x_w_color_geom[2]) > 3 ? x_w_color_geom[2][3] : 1,
  ];
  switch_geom = [
    len(x_w_color_geom[3]) > 0 ? x_w_color_geom[3][0] : false,
    len(x_w_color_geom[3]) > 1 ? x_w_color_geom[3][1] : false,
    len(x_w_color_geom[3]) > 2 ? x_w_color_geom[3][2] : false
  ];


  translate([dx, 0, 0]) {
    // Nominal Plate Cutout
    translate([0, 1.5*mx_switch_nominal_pitch_, 0])
    difference() {
      mx_switch_test_jig(w = w);
      mx_switch_cutout(led = switch_geom[0], diode = switch_geom[1], fixation = switch_geom[2]);
    }

    // Cutout in oversided plate
    translate([0, 3*mx_switch_nominal_pitch_, 0])
    difference() {
      mx_switch_test_jig(t = mx_switch_plate_thickness_*1.5, w = w, lip = 0.5);
      mx_switch_cutout(led = switch_geom[0], diode = switch_geom[1], fixation = switch_geom[2]);
    }

    // Component in Space
    mx_switch(stem = switch_color[0], bottom = switch_color[1], top = switch_color[2], alpha = switch_color[3],
          led = switch_geom[0], diode = switch_geom[1], fixation = switch_geom[2]);

    // Component in oversized cutout
    translate([0, 3*mx_switch_nominal_pitch_, 0])
    mx_switch(stem = switch_color[0], bottom = switch_color[1], top = switch_color[2], alpha = switch_color[3],
          led = switch_geom[0], diode = switch_geom[1], fixation = switch_geom[2]);
  }
}


module mx_switch_test_jig(t = mx_switch_plate_thickness_, w = 1, d = 1, lip = 0) {
  w = w * mx_switch_nominal_pitch_;
  d = d * mx_switch_nominal_pitch_;
  difference() {
    union() {
      color( "Gray" )
      translate([0, 0, lip])
      prism([w, d, t + lip], invert = true);

      color( "SeaGreen" )
      translate([0, 0, -mx_switch_pcbtop_to_platetop_])
      prism([w, d, mx_switch_pcb_thickness_], invert = true);
    }
    translate([w/2, -d/2, 0])
    cube([w, d, 20], center = true);
  }
}


// ### Module ########################################################

module mx_switch( stem = "Red", top = "#222222", bottom = "#222222", alpha = 1,
                  led = false, diode = false, fixation = false ) {
  color( bottom )             mx_switch_body_bottom();
  color( "Goldenrod" )        mx_switch_pins(led = led, diode = diode, fixation = fixation);
  color( top, alpha = alpha ) mx_switch_body_top();
  color( stem )               mx_switch_stem();
}


// Constants, from datasheet
mx_switch_pcbtop_to_platetop_       = 5.0;  // mm, 0.197"
mx_switch_frame_cutout_side_        = 14;   // mm, 0.551"
mx_switch_frame_cutout_max_radius_  = 0.3;  // mm, 0.012"
mx_switch_pin_length_               = 3.30; // mm, 0.13"

mx_switch_flange_side_            = 15.6;   // mm, 0.614"

mx_switch_pin_grid_               = 0.05 * 25.4; // mm
mx_switch_center_pin_location_    = mx_switch_pin_grid_ * [[0,0]]; // mm
mx_switch_fixation_pin_location_  = mx_switch_pin_grid_ * [[-4, 0], [4, 0]]; // mm
mx_switch_keyswitch_pin_location_ = mx_switch_pin_grid_ * [[-3, 2], [2, 4]]; // mm
mx_switch_diode_pin_location_     = mx_switch_pin_grid_ * [[-3, -4], [3, -4]]; // mm
mx_switch_led_pin_location_       = mx_switch_pin_grid_ * [[-1, -4], [1, -4]]; // mm

mx_switch_center_pin_diameter_    = 4;   // mm, 0.157"
mx_switch_fixation_pin_diameter_  = 1.7; // mm, 0.067"
mx_switch_keyswitch_pin_diameter_ = 1.5; // mm, 0.059"
mx_switch_diode_pin_diameter_     = 1.0; // mm, 0.039"

mx_switch_body_height_            = 11.6; // mm, 0.46"

// Estimated constants
mx_switch_stem_base_thickness_ = 0.5;
mx_switch_flange_height_ = 1;

// Publicly available constants
function mx_switch_plate_to_keycap_seat() = mx_switch_body_height_ - mx_switch_pcbtop_to_platetop_;


module mx_switch_cutout(offset = 0.01, led = false, diode = false, fixation = false) {
  previewOffset = $preview ? 0.01 : 0; // Fix graphic rendering for adjacent surfaces
  eps = 0.01;
  tab_cutout_width = 6;
  tab_cutout_depth = 1;
  
  // Main cutout through plate
  translate([0, 0, eps + previewOffset])
  prism([ mx_switch_frame_cutout_side_,
          mx_switch_frame_cutout_side_,
          mx_switch_pcbtop_to_platetop_ + eps ],
        invert = true);
  // Flange seating surface, in case the key-hole is inset in plate
  translate([0, 0, previewOffset])
  prism([ mx_switch_flange_side_,
          mx_switch_flange_side_,
          1 ]);
  // Tabs cutout
  for (y = [-1, 1] / 2 * mx_switch_frame_cutout_side_)
  translate([0, y, -mx_switch_plate_thickness_ - previewOffset])
  prism([ tab_cutout_width,
          2*tab_cutout_depth,
          mx_switch_pcbtop_to_platetop_ - mx_switch_plate_thickness_ - 2*previewOffset ],
        invert = true);
  // Center Pin
  mx_switch_center_pin(eps);
  // PCB pins
  translate([0, 0, -mx_switch_pcbtop_to_platetop_ - mx_switch_pin_length_]){
    // Fixation Pins
    if (fixation)
    mx_switch_pin_( v = mx_switch_fixation_pin_location_,
                    d = mx_switch_fixation_pin_diameter_,
                    h = mx_switch_pin_length_ + eps);
    // Keyswitch Pins
    mx_switch_pin_( v = mx_switch_keyswitch_pin_location_,
                    d = mx_switch_keyswitch_pin_diameter_,
                    h = mx_switch_pin_length_ + eps);
    // Diode Pins
    if (diode)
    mx_switch_pin_( v = mx_switch_diode_pin_location_,
                    d = mx_switch_diode_pin_diameter_,
                    h = mx_switch_pin_length_ + eps);
    // LED Pins
    if(led)
    mx_switch_pin_( v = mx_switch_led_pin_location_,
                    d = mx_switch_diode_pin_diameter_,
                    h = mx_switch_pin_length_ + eps);
  }
}

module mx_switch_center_pin(eps = 0) {
  translate([0, 0, -mx_switch_pcbtop_to_platetop_ - mx_switch_pin_length_])
  mx_switch_pin_( v = mx_switch_center_pin_location_,
                  d = mx_switch_center_pin_diameter_,
                  h = mx_switch_pin_length_ + eps);
}

module mx_switch_pin_(v, d, h) {
  for (xy = v) {
    translate(concat(xy, 0))
    cylinder(h = h, d = d);
  }
}

module mx_switch_body_top() {
  flange_width = 0.5;
  body_taper_top = 1.5;

  translate([0, 0, mx_switch_flange_height_])
  prism_tapered_cuboid( [ mx_switch_frame_cutout_side_,
                          mx_switch_flange_side_ - 2*flange_width,
                          mx_switch_body_height_ - mx_switch_pcbtop_to_platetop_ - mx_switch_stem_base_thickness_ - mx_switch_flange_height_],
                        taper = body_taper_top);
}

module mx_switch_body_bottom() {
  eps = 0.01;

  flange_corner_radius = 1;
  flange_side_cutout_length = 10.5;
  flange_tab_cutout_length = 5;
  flange_tab_length = 2;
  flange_tab_cutout_depth = 1.5;

  body_taper_bottom = 1;

  body_base_width = 12.7;
  body_stab_pin_depth = 3;

  difference() {
    union() {
      // Flange
      translate([0, 0, eps])
      difference() {
        // Continuous flange
        hull() {
          for (xy = [[1, 1], [1, -1], [-1, -1], [-1, 1]]) {
            translate((mx_switch_flange_side_/2 - flange_corner_radius) * concat(xy, 0))
            cylinder(h = mx_switch_flange_height_, r = flange_corner_radius);
          }
        }
        // Cutouts in flange
        cube([2*mx_switch_flange_side_ , flange_side_cutout_length, 3*mx_switch_flange_height_], center = true);
        for(y = [-1, 1] * mx_switch_flange_side_/2) {
          translate([0, y, 0])
          cube( [ flange_tab_cutout_length,
                  mx_switch_flange_side_ - mx_switch_frame_cutout_side_,
                  mx_switch_flange_height_ ],
                center = true);
        }
        
      }
      // Bottom body
      translate([0, 0, -mx_switch_pcbtop_to_platetop_ + eps])
      intersection() {
        prism_tapered_cuboid( [ body_base_width,
                                body_base_width,
                                mx_switch_pcbtop_to_platetop_ + mx_switch_flange_height_],
                              taper = -body_taper_bottom);
        prism( [mx_switch_frame_cutout_side_,
                mx_switch_frame_cutout_side_,
                mx_switch_pcbtop_to_platetop_ + mx_switch_flange_height_ ] );
      }
    }
    // Tab cutouts
    for (x = [-1, 1] * (flange_tab_cutout_length + flange_tab_length)/4) {
      for (y = [-1, 1] * mx_switch_flange_side_/2) {
        translate([x, y, 0]) 
        cube( [ (flange_tab_cutout_length - flange_tab_length)/2,
                2*flange_tab_cutout_depth,
                2.5 * mx_switch_flange_height_ + eps ],
              center = true);
      }
    }
  }
      // Bottom Stabilizer Pin
      translate([0, 0, -mx_switch_pcbtop_to_platetop_ - body_stab_pin_depth])
      mx_switch_pin_( v = mx_switch_center_pin_location_,
                d = mx_switch_center_pin_diameter_,
                h = body_stab_pin_depth);
}

module mx_switch_stem() {
  stem_thickness = 1.17;
  stem_width = 4;
  stem_height = 3.6;
  stem_chamfer = 0.5;

  stem_base_x = 6;
  stem_base_y = stem_width * 1.1;
  stem_base_taper = 0.5;

  translate([0, 0, mx_switch_body_height_ - mx_switch_pcbtop_to_platetop_]) {
    // Stem Base
    prism_tapered_cuboid( [ stem_base_x,
                            stem_base_y,
                            -2*mx_switch_stem_base_thickness_ ],
                          taper = -2*stem_base_taper);
    // Stem
    intersection() {
      union() {
        cube([stem_thickness, stem_width, 2*stem_height], center = true);
        cube([stem_width, stem_thickness, 2*stem_height], center = true);
      }
      cylinder( h=2*stem_height,
                d2 = stem_width - 2*stem_chamfer,
                d1 = stem_width - 2*stem_chamfer + 4*stem_height,
                center = true );
    }
  }
}

module mx_switch_pins(led = false, diode = false, fixation = false) {
  eps = 0.1;
  pin_diameter = 1;

  translate([0, 0, -mx_switch_pcbtop_to_platetop_ - mx_switch_pin_length_]){
    // Fixation Pins
    if (fixation)
    mx_switch_pin_( v = mx_switch_fixation_pin_location_,
                    d = mx_switch_fixation_pin_diameter_ - 0.5,
                    h = mx_switch_pin_length_ + eps);
    // Keyswitch Pins
    mx_switch_pin_( v = mx_switch_keyswitch_pin_location_,
                    d = mx_switch_keyswitch_pin_diameter_ - 0.5,
                    h = mx_switch_pin_length_ + eps);
    // Diode Pins
    if (diode)
    mx_switch_pin_( v = mx_switch_diode_pin_location_,
                    d = mx_switch_diode_pin_diameter_ - 0.5,
                    h = mx_switch_pin_length_ + eps);
    // LED Pins
    if (led)
    mx_switch_pin_( v = mx_switch_led_pin_location_,
                    d = mx_switch_diode_pin_diameter_ - 0.5,
                    h = mx_switch_pin_length_ + eps);
  }
}
