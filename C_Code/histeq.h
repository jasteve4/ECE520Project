#ifndef _TAV_HISTEQ_
#define _TAV_HISTEQ_

#include <stdint.h>
#include <math.h>
#include <limits.h>

typedef float fltPixel_t;
typedef int algPixel_t;

int
histEq (algPixel_t *streamA, algPixel_t *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp);

int
hist (algPixel_t *streamA, int *h, int nRows, int nCols, int nBpp);

#endif /* _TAV_HISTEQ_ */
