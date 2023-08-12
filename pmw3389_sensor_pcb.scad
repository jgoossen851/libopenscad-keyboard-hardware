use <lib/geometry/prism.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

pmw3389_sensor_pcb();

// ### Module ########################################################

tb_z_lf2ns   = 2.4; // Vertical distance from lens flange to navigation surface (from datasheet)
tb_z_pcbt2ns = 7.4; // Vertical distance from pcb top to navigation surface (from datasheet)

module pmw3389_sensor_pcb() {
  color( "SeaGreen" )
  translate([0, 0, tb_z_pcbt2ns])
  prism([28.2, 21.1, 1.6], invert = true);
}
