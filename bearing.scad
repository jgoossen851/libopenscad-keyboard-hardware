
// ### Usage #########################################################
bearing();


// ### Module ########################################################

$fa = $preview ? 10 : 1;    // minimum angle for a fragment

module bearing(d = 3) {
  sphere(d = d, $fs = 0.1 );
}
