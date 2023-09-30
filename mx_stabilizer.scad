use <lib/geometry/prism.scad>
use <mx_switch.scad>
use <stabilizer_spacing.scad>

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
  [0, 2, [], []],
  // Custom Switches
  [-2.75, 2.75, ["Silver", "Beige", "Gainsboro", 0.5]],
  [-7.5, 6.25, ["DodgerBlue", "LightSlateGray", "Azure"]]
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


  translate([dx, 0, 0]) {
    // Nominal Plate Cutout
    translate([0, 1.5*mx_switch_nominal_pitch_, 0])
    difference() {
      mx_switch_test_jig(w = w, d = 1.25);
      mx_stabilizer_cutout(w = w);
    }

    // Cutout in oversided plate
    translate([0, 3*mx_switch_nominal_pitch_, 0])
    difference() {
      mx_switch_test_jig(t = mx_switch_plate_thickness_*1.5, w = w, d = 1.25, lip = 0.5);
      mx_stabilizer_cutout(w = w);
    }

    // Component in Space
    *mx_stabilizer(stem = switch_color[0], bottom = switch_color[1], top = switch_color[2], alpha = switch_color[3]);

    // Component in oversized cutout
    *translate([0, 3*mx_switch_nominal_pitch_, 0])
    mx_stabilizer(stem = switch_color[0], bottom = switch_color[1], top = switch_color[2], alpha = switch_color[3]);
  }
}



// ### Module ########################################################

// Constants, from datasheet
mx_switch_pcbtop_to_platetop_       = 5.0;  // mm, 0.197"

mx_stabilizer_cutout_width_                 =  6.65; // mm, 0.262"
mx_stabilizer_cutout_depth_                 = 12.3;  // mm, 0.484"
mx_stabilizer_cutout_center_to_front_       =  6.6;  // mm, 0.26"
mx_stabilizer_front_tab_depth_from_back_    = 13.5;  // mm, 0.53"
mx_stabilizer_front_tab_width_              =  3.0;  // mm, 0.12"
mx_stabilizer_side_tab_width_               =  3.0;  // mm, 0.12"
mx_stabilizer_side_tab_offset_from_center_  = -0.50; // mm, -0.02"
mx_stabilizer_side_tab_depth_from_middle_   =  4.2;  // mm, 0.165"
mx_stabilizer_channel_step_from_cutout_2u_  =  0.80; // mm, 0.0315"
mx_stabilizer_channel_width_narrow_         =  4.6;  // mm, 0.181"

// Assumed constants
mx_stabilizer_tab_barside_top_depth_      = 2.5;
mx_stabilizer_tab_barside_bottom_depth_   = 3.55;
mx_stabilizer_tab_clipside_top_depth_     = 3;
mx_stabilizer_tab_clipside_bottom_depth_  = 0.5;


module mx_stabilizer_cutout(w = 2, d = 1) {
  eps = 0.01;
  cutout_z_max = 5; // Amount to extend cutout into space above plate's z=0 plane

  /// ToDo: Rotate module if d > w, and set d = w.

  if (w >= 2) {
    // Main cutout through plate
    translate([0, 0, -mx_switch_pcbtop_to_platetop_])
    linear_extrude(height = mx_switch_pcbtop_to_platetop_ + eps, convexity = 2)
    mx_stabilizer_face_cutout_2d(w);

    // Flange seating surface (top side), in case the key-hole is inset in plate
    linear_extrude(height = cutout_z_max, convexity = 2)
    mx_stabilizer_inset_cutout_2d(w);

    // Tab seating surface (bottom side), in case the key-hole is inset in plate
    translate([0, 0, -mx_switch_pcbtop_to_platetop_])
    linear_extrude(height = mx_switch_pcbtop_to_platetop_ - mx_switch_plate_thickness_, convexity = 2)
    mx_stabilizer_body_cutout_2d(w);
  }
}

// 2D cutout above plate for stabilizer seating surface (includes nominal cutout)
module mx_stabilizer_inset_cutout_2d (w = 2) {
  // Flange seating surface (top side), in case the key-hole is inset in plate
  stabilizer_spacing_layout(w)
  mx_stabilizer_housing_inset_cutout_2d();

  // Nominal cutout
  mx_stabilizer_face_cutout_2d(w);
}

// 2D cutout beneath plate for clearance to stabilizer tabs and mechanisms (includes nominal cutout)
module mx_stabilizer_body_cutout_2d (w = 2) {
  // Tab seating surface (bottom side), in case the key-hole is inset in plate
  stabilizer_spacing_layout(w)
  mx_stabilizer_housing_body_cutout_2d();

  // Cutout for stabilizer bar itself
  mx_stabilizer_installed_bar_cutout_2d(w);

  // Nominal cutout
  mx_stabilizer_face_cutout_2d(w);
}

// 2D nominal cutout for stabilizer through plate
module mx_stabilizer_face_cutout_2d (w = 2) {
  // Main cutout through plate (housing)
  stabilizer_spacing_layout(w)
  mx_stabilizer_housing_face_cutout_2d();

  // Central bar cutout
  mx_stabilizer_central_bar_cutout_2d(w);
}

// Additional 2D cutout for the housing if inset into the plate (does not include main housing cutout)
module mx_stabilizer_housing_inset_cutout_2d () {
  // Flange seating surface (top side), in case the key-hole is inset in plate
  translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_ + (mx_stabilizer_tab_clipside_top_depth_ - mx_stabilizer_tab_barside_top_depth_)/2])
  square([mx_stabilizer_cutout_width_,
                  mx_stabilizer_cutout_depth_ + mx_stabilizer_tab_barside_top_depth_ + mx_stabilizer_tab_clipside_top_depth_], center = true);
}

// Additional 2D cutout beneath plate for housing tabs, etc. (does not include main housing cutout)
module mx_stabilizer_housing_body_cutout_2d () {

  // Tab seating surface (bottom side), in case the key-hole is inset in plate
  translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_ + (mx_stabilizer_tab_clipside_bottom_depth_ - mx_stabilizer_tab_barside_bottom_depth_)/2 ])
  square([mx_stabilizer_cutout_width_,
                  mx_stabilizer_cutout_depth_ + mx_stabilizer_tab_barside_bottom_depth_ + mx_stabilizer_tab_clipside_bottom_depth_],
                  center = true);
}

// 2D face cutout for the housing only
module mx_stabilizer_housing_face_cutout_2d () {
  // Main Cutout
  translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_])
  square([mx_stabilizer_cutout_width_, mx_stabilizer_cutout_depth_], center = true);

  // Front tabs
  translate([0, -mx_stabilizer_cutout_center_to_front_])
  square([ mx_stabilizer_front_tab_width_,
          2*(mx_stabilizer_front_tab_depth_from_back_ - mx_stabilizer_cutout_depth_) ],
        center = true);

  // Side tabs
  translate([0, mx_stabilizer_side_tab_width_/2 + mx_stabilizer_side_tab_offset_from_center_])
  square([ 2*mx_stabilizer_side_tab_depth_from_middle_,
          mx_stabilizer_side_tab_width_ ],
        center = true);
}

module mx_stabilizer_central_bar_cutout_2d (w = 2) {
  // Use thicker cutout for short stabilizers
  wy = w <= 3 ? mx_stabilizer_cutout_depth_ - 2*mx_stabilizer_channel_step_from_cutout_2u_
              : mx_stabilizer_channel_width_narrow_;
  // Offset bar cutout from center
  dy = w <= 3 ? mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_
              : 0;
  translate([0, dy])
  square([stabilizer_spacing(w), wy], center = true);
}

module mx_stabilizer_installed_bar_cutout_2d (w = 2) {
  translate([0, (-mx_stabilizer_cutout_center_to_front_ - mx_stabilizer_tab_barside_bottom_depth_)/2])
  square( [ stabilizer_spacing(w) + 1,
            mx_stabilizer_cutout_center_to_front_ + mx_stabilizer_tab_barside_bottom_depth_],
          center = true);
}
