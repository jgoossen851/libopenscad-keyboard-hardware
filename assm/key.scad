use <../keycap.scad>
use <../mx_switch.scad>
use <../hot_swap_socket.scad>

// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment


wvec = [1, 1.25, 1.5, 1.75, 2, 2.25, 3, 6.25, 7];

for (ivec = [ 0 : len(wvec)-1 ]) {
  translate_key_pitch(wvec, ivec)
  key(w = wvec[ivec]);
}


module translate_key_pitch(v, i, s = 0) {
  echo(i, s);
  u = 19.05; // mm, 1u key pitch
  translate([0.5*v[i]*u, 0, 0])
  if (i > s) {
    translate([0.5*v[i-1]*u, 0, 0])
    translate_key_pitch(v, i-1, s)
    children();
  } else {
    children();
  }
}


// ### Module ########################################################

module key( u = 19.05, d = 1, w = 1 ) {

  // Switch
  mx_switch(stem = "Silver", bottom = "Beige", top = "Gainsboro", alpha = .5);

  // Keycap
  color( "DimGray" )
  keycap(u = u, d = d, w = w, z_offset = mx_switch_plate_to_keycap_seat());

  // Hot-sway socket
  hot_swap_socket();

}
