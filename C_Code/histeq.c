/**************************/
/***    UNCLASSIFIED    ***/
/**************************/

/***

ALL SOURCE CODE PRESENT IN THIS FILE IS UNCLASSIFIED AND IS
BEING PROVIDED IN SUPPORT OF THE DARPA PERFECT PROGRAM.

THIS CODE IS PROVIDED AS-IS WITH NO WARRANTY, EXPRESSED, IMPLIED,
OR OTHERWISE INFERRED. USE AND SUITABILITY FOR ANY PARTICULAR
APPLICATION IS SOLELY THE RESPONSIBILITY OF THE IMPLEMENTER.
NO CLAIM OF SUITABILITY FOR ANY APPLICATION IS MADE.
USE OF THIS CODE FOR ANY APPLICATION RELEASES THE AUTHOR
AND THE US GOVT OF ANY AND ALL LIABILITY.

THE POINT OF CONTACT FOR QUESTIONS REGARDING THIS SOFTWARE IS:

US ARMY RDECOM CERDEC NVESD, RDER-NVS-SI (JOHN HODAPP),
10221 BURBECK RD, FORT BELVOIR, VA 22060-5806

THIS HEADER SHALL REMAIN PART OF ALL SOURCE CODE FILES.

***/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>

#include "xmalloc.h"
#include "histeq.h"

#define MIN(A,B)	((A) < (B) ? (A) : (B))

int
hist (algPixel_t *streamA, int *h, int nRows, int nCols, int nBpp)
{
  int nBins = 1 << nBpp;
  int nPxls = nRows * nCols;
  int i = 0;

  if (h == (int *)NULL)
  {
    fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
    return -1;
  }

  memset((void *)h, 0, nBins * sizeof(int));

  for (i = 0; i < nPxls; i++)
  {
    if (streamA[i] >= nBins)
    {
      fprintf(stderr, "File %s, Line %d, Range Error in hist() -- using max val ---", __FILE__, __LINE__);
      h[nBins-1]++;
    }
    else
    {
      h[(int)streamA[i]]++;
    }
  }

  return 0;
}


int
histEq (algPixel_t *streamA, algPixel_t *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp)
{
  int nOutBins = (1 << nOutBpp);
  int nInpBins = (1 << nInpBpp);
  double *CDF = (double *)calloc(nInpBins, sizeof(double));
  double *LUT = (double *)calloc(nInpBins, sizeof(double));

  double CDFmin = DBL_MAX;
  double sum = 0.0;
  int nPxls = nRows * nCols;
  int i = 0;

  if (!(CDF && LUT))
  {	/* Ok to call free() on potentially NULL pointer */
    free(CDF);
    free(LUT);
    fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
    return -1;
  }

  for (i = 0; i < nInpBins; i++)
  {
    sum += (double) h[i];
    CDF[i] = sum;
    //printf("CDF[%d]: %lf",i,sum);
  }

  for (i = 0; i < nInpBins; i++)
  {
    CDFmin = MIN(CDFmin, CDF[i]);
  }

  for (i = 0; i < nInpBins; i++)
  {
    LUT[i] = ((CDF[i] - CDFmin) * (double)(nOutBins - 1)) / ((double)nPxls - CDFmin);
  }

  for (i = 0; i < nPxls; i++)
  {
    out[i] = LUT[(int)streamA[i]];
  }

  free(CDF);
  free(LUT);

  return 0;
}
