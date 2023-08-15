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


// Default Switch with mount hole in plate and PCB
difference() {
  mx_switch_sample_plate_pcb();
  mx_stabilizer_cutout();
}

translate([0, 19.05, 0])
difference() {
  mx_switch_sample_plate_pcb(w = 60);
  mx_stabilizer_cutout(w = 6.25);
}

// Plate/PCB mount hole only
translate([-4 * mx_switch_nominal_pitch_, 0, 0])
difference() {
  mx_switch_sample_plate_pcb();
  mx_stabilizer_cutout();
}
translate([-6 * mx_switch_nominal_pitch_, 0, 0])
difference() {
  mx_switch_sample_plate_pcb(2*mx_switch_plate_thickness_);
  mx_stabilizer_cutout();
}

// Sample Plate/PCB model
module mx_switch_sample_plate_pcb(t = mx_switch_plate_thickness_, w = mx_switch_nominal_pitch_, d = mx_switch_nominal_pitch_) {
  difference() {
    union() {
      color( "Gray" )
      prism([2*w, d, t], invert = true);

      color( "SeaGreen" )
      translate([0, 0, -mx_switch_pcbtop_to_platetop_])
      prism([2*w, d, mx_switch_pcb_thickness_], invert = true);
    }
    translate([w, -d/2, 0])
    cube([2*w, d, 20], center = true);
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


module mx_stabilizer_cutout(w = 2) {
  previewOffset = $preview ? 0.01 : 0; // Fix graphic rendering for adjacent surfaces
  eps = 0.01;

  /// ToDo: Rotate module if d > w, and set d = w.

  if (w >= 2) {

    A = stabilizer_spacing(w);

    stabilizer_spacing_layout(w) {
      // Center hole
      mx_switch_center_pin(eps);

      translate([0, 0, eps + previewOffset]) {
        // Main cutout through plate
        translate([0, mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_, 0])
        prism([ mx_stabilizer_cutout_width_,
                mx_stabilizer_cutout_depth_,
                mx_switch_pcbtop_to_platetop_ + eps ],
              invert = true);
        // Front tabs
        translate([0, -mx_stabilizer_cutout_center_to_front_, 0])
        prism([ mx_stabilizer_front_tab_width_,
                2*(mx_stabilizer_front_tab_depth_from_back_ - mx_stabilizer_cutout_depth_),
                mx_switch_pcbtop_to_platetop_ + eps ],
              invert = true);
        // Side tabs
        translate([0, mx_stabilizer_side_tab_width_/2 + mx_stabilizer_side_tab_offset_from_center_, 0])
        prism([ 2*mx_stabilizer_side_tab_depth_from_middle_,
                mx_stabilizer_side_tab_width_,
                mx_switch_pcbtop_to_platetop_ + eps ],
              invert = true);
      }
    }

    // Central bar cutout
    translate([0, 0, eps + previewOffset]) {
      hull()
      translate([0, w <= 3 ? mx_stabilizer_cutout_depth_/2 - mx_stabilizer_cutout_center_to_front_ : 0, 0])
      stabilizer_spacing_layout(w) {
        prism([ eps,
                w <= 3 ? mx_stabilizer_cutout_depth_ - 2*mx_stabilizer_channel_step_from_cutout_2u_ : mx_stabilizer_channel_width_narrow_,
                mx_switch_pcbtop_to_platetop_ + eps ],
              invert = true);
      }
    }
  }
}
