#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "timer.h"
#include "xmalloc.h"
#include "octave.h"
#include "histeq.h"

#if !defined(BATCH_SIZE)
//#define BATCH_SIZE (30)
#define BATCH_SIZE (1)
#endif

//#if INPUT_SIZE == INPUT_SIZE_SMALL
#define M 640  /* columns */
#define N 480  /* rows */
#define FILENAME "input_atomant.mat"
//#define FILENAME "../../input/input_small.mat"
#define SIZE "small"

//#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
//#define M 1920  /* columns */
//#define N 1080  /* rows */
//#define FILENAME "../../input/input_medium.mat"
//#define SIZE "medium"

//#elif INPUT_SIZE == INPUT_SIZE_LARGE
//#define M 3840  /* columns */
//#define N 2160  /* rows */
//#define FILENAME "../../input/input_large.mat"
//#define SIZE "large"

//#else
//#error "Unhandled value for INPUT_SIZE"
//#endif



int main (int argc, char * argv[])
{
  int * frame;
  int * output;
  int * histogram;
  int nBins = (1 << 8);
  int i;

  srand (time (NULL));

  STATS_INIT ();
  PRINT_STAT_STRING ("kernel", "histogram_equalization");
  PRINT_STAT_INT ("rows", N);
  PRINT_STAT_INT ("columns", M);
  PRINT_STAT_INT ("num_frames", BATCH_SIZE);

  frame = calloc (M * N * BATCH_SIZE, sizeof(algPixel_t));
  output = calloc (M * N * BATCH_SIZE, sizeof(algPixel_t));
  histogram = calloc (nBins * BATCH_SIZE, sizeof(int));

  if (!frame || !output || !histogram) {
    fprintf(stderr, "ERROR: Allocation failed.\n");
    exit(-1);
  }

  /* load image */
  tic ();
  read_array_from_octave (frame, N, M, FILENAME);
  PRINT_STAT_DOUBLE ("time_load_image", toc ());

  /* Make BATCH_SIZE-1 copies */
  tic ();
  for (i = 1; i < BATCH_SIZE; i++) {
    memcpy (&frame[i * M * N], frame, M * N * sizeof(algPixel_t));
  }
  PRINT_STAT_DOUBLE ("time_copy", toc ());

  /* Perform the histogram equalization */
  tic ();
  for (i = 0; i < BATCH_SIZE; i++) {
    hist (&frame[i * M * N], &histogram[i * nBins], N, M, 8);
    histEq (&frame[i * M * N], &output[i * M * N], &histogram[i * nBins], N, M, 8, 8);
  }
  PRINT_STAT_DOUBLE ("time_histogram_equalization", toc ());

  /* Write the results out to disk */
  for (i = 0; i < BATCH_SIZE; i++) {
    char buffer [30];
    sprintf (buffer, "histeq_output." SIZE ".%d.mat", i);
    write_array_to_octave (&output[i * M * N], N, M, buffer, "output");
  }
  PRINT_STAT_STRING ("output_file", "histeq_output." SIZE ".#.mat");

  STATS_END ();

  free (histogram);
  free (output);
  free (frame);
  return 0;
}
