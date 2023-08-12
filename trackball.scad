
// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

trackball();

// ### Module ########################################################

module trackball( d = 34 ) {
  color( "DarkRed" )
  sphere( r = d/2 );
}
