
// ### Usage #########################################################

$fa = $preview ? 20 : 1;    // minimum angle for a fragment
$fs = $preview ? 1 : 0.25;  // minimum size of a fragment

w = [1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 6, 6.25, 6.5, 6.75, 7, 8];

for (ww = w)
echo("For key ", ww, " Stabilizer: ", stabilizer_spacing(ww));


// ### Module ########################################################

function stabilizer_spacing(w =1) =
      w < 2     ? 0       // No stabilizer
    : w < 3     ? 24      // mm, 0.94" (2u stabilizer)
    : w < 6.25  ? 38.1    // mm, 1.5" (3u stabilizer)
    : w < 7     ? 100     // mm, 3.94" (6.25u stabilizer)
    : w < 8     ? 114.3   // mm, 4.5" (7u stabilizer)
    :             133.35; // mm, 5.25" (8u stabilizer)
