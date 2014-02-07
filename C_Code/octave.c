#include <stdio.h>
#include <stdlib.h>
#include "octave.h"

int
write_array_to_octave (int * data, int nrows, int ncols, char * filename, char * name)
{
  FILE *fp = fopen(filename, "w");
  int i, j;
  int n = nrows;
  int m = ncols;

  fprintf(fp, "%% Created by PERFECT 2D Convolution Benchmark\n");
  fprintf(fp, "%% name: %s\n", name);
  fprintf(fp, "%% type: matrix\n");
  fprintf(fp, "%% rows: %d\n", n);
  fprintf(fp, "%% columns: %d\n", m);

  for (i = 0; i < n; i++) {
    for (j = 0; j < m; j++) {
      fprintf(fp, " %d", data[i*m+j]);
    }
    fprintf(fp, "\n");
  }

  fclose(fp);

  return 0;
}

int
read_array_from_octave (int * data, int nrows, int ncols, char * filename)
{
  FILE *fp = fopen(filename, "r");
  int i, j;
  int n = nrows;
  int m = ncols;
  char buffer[100];
  char comment;

  if (!fp) {
    fprintf(stderr, "File not found: %s\n", filename);
    exit(-1);
  }

  fscanf(fp, "%c", &comment);
  while (comment == '%') {
    fgets(buffer, 100, fp);
    fscanf(fp, "%c", &comment);
  }

  for (i = 0; i < n; i++) {
    for (j = 0; j < m; j++) {
      int tmp;
      fscanf(fp, "%d", &tmp);
      data[i*m+j] = (int) tmp;
    }
    fscanf(fp, "\n");
  }

  fclose(fp);

  return 0;
}
