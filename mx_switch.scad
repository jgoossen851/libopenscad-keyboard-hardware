use <lib/geometry/prism.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

// Constants, from datasheet
mx_switch_plate_thickness_  = 1.5; // mm, 0.06"
mx_switch_pcb_thickness_    = 1.5; // mm, 0.06"


// Default Switch with mount hole in plate and PCB
difference() {
  mx_switch_sample_plate_pcb();
  mx_switch_cutout();
}
mx_switch();

// Custom Switchs
translate([-20, 0, 0])
mx_switch(  stem = "Silver", bottom = "Beige", top = "Gainsboro", alpha = .5,
            fixation = true, led = true );
translate([-20, 20, 0])
mx_switch( stem = "DodgerBlue", bottom = "LightSlateGray", top = "Azure",
         fixation = true, diode = true );

// Plate/PCB mount hole only
translate([-40, 0, 0])
difference() {
  mx_switch_sample_plate_pcb();
  mx_switch_cutout(fixation = true, led = true);
}
translate([-60, 0, 0])
difference() {
  mx_switch_sample_plate_pcb(2*mx_switch_plate_thickness_);
  mx_switch_cutout();
}

// Sample Plate/PCB model
module mx_switch_sample_plate_pcb(t = mx_switch_plate_thickness_) {
  sample_width = 20;
  difference() {
    union() {
      color( "Gray" )
      prism([sample_width, sample_width, t], invert = true);

      color( "SeaGreen" )
      translate([0, 0, -mx_switch_pcbtop_to_platetop_])
      prism([sample_width, sample_width, t], invert = true);
    }
    translate([sample_width/2, -sample_width/2, 0])
    cube([sample_width, sample_width, 20], center = true);
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
mx_switch_stem_base_thickness = 0.5;
mx_switch_flange_height = 1;


module mx_switch_cutout(led = false, diode = false, fixation = false) {
  eps = 0.01;
  tab_cutout_width = 6;
  tab_cutout_depth = 1;
  
  // Main cutout through plate
  translate([0, 0, eps])
  prism([ mx_switch_frame_cutout_side_,
          mx_switch_frame_cutout_side_,
          mx_switch_pcbtop_to_platetop_ + eps ],
        invert = true);
  // Flange seating surface, in case the key-hole is inset in plate
  prism([ mx_switch_flange_side_,
          mx_switch_flange_side_,
          1 ]);
  // Tabs cutout
  for (y = [-1, 1] / 2 * mx_switch_frame_cutout_side_)
  translate([0, y, -mx_switch_plate_thickness_])
  prism([ tab_cutout_width,
          2*tab_cutout_depth,
          mx_switch_pcbtop_to_platetop_ - mx_switch_plate_thickness_ ],
        invert = true);
  // PCB pins
  translate([0, 0, -mx_switch_pcbtop_to_platetop_ - mx_switch_pin_length_]){
    // Center Pin
    mx_switch_pin_( v = mx_switch_center_pin_location_,
                    d = mx_switch_center_pin_diameter_,
                    h = mx_switch_pin_length_ + eps);
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

module mx_switch_pin_(v, d, h) {
  for (xy = v) {
    translate(concat(xy, 0))
    cylinder(h = h, d = d);
  }
}

module mx_switch_body_top() {
  flange_width = 0.5;
  body_taper_top = 1.5;

  translate([0, 0, mx_switch_flange_height])
  prism_tapered_cuboid( [ mx_switch_frame_cutout_side_,
                          mx_switch_flange_side_ - 2*flange_width,
                          mx_switch_body_height_ - mx_switch_pcbtop_to_platetop_ - mx_switch_stem_base_thickness - mx_switch_flange_height],
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
            cylinder(h = mx_switch_flange_height, r = flange_corner_radius);
          }
        }
        // Cutouts in flange
        cube([2*mx_switch_flange_side_ , flange_side_cutout_length, 3*mx_switch_flange_height], center = true);
        for(y = [-1, 1] * mx_switch_flange_side_/2) {
          translate([0, y, 0])
          cube( [ flange_tab_cutout_length,
                  mx_switch_flange_side_ - mx_switch_frame_cutout_side_,
                  mx_switch_flange_height ],
                center = true);
        }
        
      }
      // Bottom body
      translate([0, 0, -mx_switch_pcbtop_to_platetop_ + eps])
      intersection() {
        prism_tapered_cuboid( [ body_base_width,
                                body_base_width,
                                mx_switch_pcbtop_to_platetop_ + mx_switch_flange_height],
                              taper = -body_taper_bottom);
        prism( [mx_switch_frame_cutout_side_,
                mx_switch_frame_cutout_side_,
                mx_switch_pcbtop_to_platetop_ + mx_switch_flange_height ] );
      }
    }
    // Tab cutouts
    for (x = [-1, 1] * (flange_tab_cutout_length + flange_tab_length)/4) {
      for (y = [-1, 1] * mx_switch_flange_side_/2) {
        translate([x, y, 0]) 
        cube( [ (flange_tab_cutout_length - flange_tab_length)/2,
                2*flange_tab_cutout_depth,
                2.5 * mx_switch_flange_height + eps ],
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
                            -2*mx_switch_stem_base_thickness ],
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
