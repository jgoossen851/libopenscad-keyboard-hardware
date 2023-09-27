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
mx_stabilizer_tab_barside_top_depth_ = 2.5;
mx_stabilizer_tab_barside_bottom_depth_ = 3.55;
mx_stabilizer_tab_clipside_top_depth_ = 3;
mx_stabilizer_tab_clipside_bottom_depth_ = 2.3;


module mx_stabilizer_cutout(w = 2, d = 1) {
  previewOffset = $preview ? 0.01 : 0; // Fix graphic rendering for adjacent surfaces
  eps = 0.01;

  cutout_z_max = 5; // Amount to extend cutout into space above plate's z=0 plane

  /// ToDo: Rotate module if d > w, and set d = w.

  if (w >= 2) {

    A = stabilizer_spacing(w);

    stabilizer_spacing_layout(w) {

      translate([0, 0, eps + previewOffset]) {
        // Main cutout through plate
        translate([0, 0, -mx_switch_pcbtop_to_platetop_ - eps])
        linear_extrude(height = mx_switch_pcbtop_to_platetop_ + eps, convexity = 2)
        mx_stabilizer_housing_face_cutout();

        // Flange seating surface (top side), in case the key-hole is inset in plate
        translate([0, 0, -eps])
        linear_extrude(height = cutout_z_max + eps, convexity = 2)
        mx_stabilizer_housing_inset_cutout();

        // Tab seating surface (bottom side), in case the key-hole is inset in plate
        translate([0, 0, - mx_switch_pcbtop_to_platetop_ + previewOffset])
        linear_extrude(height = mx_switch_pcbtop_to_platetop_ - mx_switch_plate_thickness_ - 2*previewOffset, convexity = 2)
        mx_stabilizer_housing_body_cutout();
      }
    }

    // Central bar cutout
    translate([0, 0, -mx_switch_pcbtop_to_platetop_ + previewOffset])
    linear_extrude(height = mx_switch_pcbtop_to_platetop_ + eps + cutout_z_max)
    central_bar_cutout_2d(w);

    // Cutout for stabilizer bar itself
    translate([0, 0, -mx_switch_pcbtop_to_platetop_ + previewOffset])
    linear_extrude(height = mx_switch_pcbtop_to_platetop_ - mx_switch_plate_thickness_ - 2*previewOffset)
    installed_stabilizer_bar_cutout_2d(w);
  }
}

// 2D cutout for the housing if inset into the plate
module mx_stabilizer_housing_inset_cutout () {
  // Flange seating surface (top side), in case the key-hole is inset in plate
  translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_ + (mx_stabilizer_tab_clipside_top_depth_ - mx_stabilizer_tab_barside_top_depth_)/2])
  square([mx_stabilizer_cutout_width_,
                  mx_stabilizer_cutout_depth_ + mx_stabilizer_tab_barside_top_depth_ + mx_stabilizer_tab_clipside_top_depth_], center = true);

  mx_stabilizer_housing_face_cutout();
}

// 2D cutout for the housing body, including cutouts beneath plates
module mx_stabilizer_housing_body_cutout () {

  // Tab seating surface (bottom side), in case the key-hole is inset in plate
  translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_ + (mx_stabilizer_tab_clipside_bottom_depth_ - mx_stabilizer_tab_barside_bottom_depth_)/2 ])
  square([mx_stabilizer_cutout_width_,
                  mx_stabilizer_cutout_depth_ + mx_stabilizer_tab_barside_bottom_depth_ + mx_stabilizer_tab_clipside_bottom_depth_],
                  center = true);

  mx_stabilizer_housing_face_cutout();
}

// 2D face cutout for the housing only
module mx_stabilizer_housing_face_cutout () {
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

module central_bar_cutout_2d (w = 2) {
  // Use thicker cutout for short stabilizers
  wy = w <= 3 ? mx_stabilizer_cutout_depth_ - 2*mx_stabilizer_channel_step_from_cutout_2u_
              : mx_stabilizer_channel_width_narrow_;
  // Offset bar cutout from center
  dy = w <= 3 ? mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_
              : 0;
  translate([0, dy])
  square([stabilizer_spacing(w), wy], center = true);
}

module installed_stabilizer_bar_cutout_2d (w = 2) {
  translate([0, (-mx_stabilizer_cutout_center_to_front_ - mx_stabilizer_tab_barside_bottom_depth_)/2])
  square( [ stabilizer_spacing(w) + 1,
            mx_stabilizer_cutout_center_to_front_ + mx_stabilizer_tab_barside_bottom_depth_],
          center = true);
}
