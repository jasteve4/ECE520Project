#ifndef _TAV_OCTAVE_
#define _TAV_OCTAVE_

#include <stdint.h>
#include <math.h>
#include <limits.h>

int
write_array_to_octave (int * data, int nrows, int ncols, char * filename, char * name);

int
read_array_from_octave (int * data, int nrows, int ncols, char * filename);

#endif /* _TAV_OCTAVE_ */
