#include <math.h>
#include "mex.h"

void bratu(double y[][2], double x[][2], double p[][1], mwSize ncols) {
  mwSize i;
  for(i=0; i<ncols; ++i) {
    y[i][0] = x[i][1];
    y[i][1] = -p[i][0]*exp(x[i][0]);
  }
}

/* function y = odefunc(x,p) */
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
  
  /* variable declarations here */
  
  double *x = mxGetPr(prhs[0]);
  double *p = mxGetPr(prhs[1]);
  mwSize ncols = mxGetN(prhs[1]);
  double *y;
  
  plhs[0] = mxCreateDoubleMatrix(2, ncols, mxREAL);
  y = mxGetPr(plhs[0]);
  
  bratu((void*)y, (void*)x, (void*)p, ncols);
}
