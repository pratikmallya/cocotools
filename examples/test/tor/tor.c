#include <math.h>
#include "mex.h"

void tor(double y[][3], double x[][3], double p[][6], mwSize ncols) {
  mwSize i;
  double x3, bxy3;
  for(i=0; i<ncols; ++i) {
    x3      = x[i][0]*x[i][0]*x[i][0];
    bxy3    = p[i][5]*(x[i][1]-x[i][0])*(x[i][1]-x[i][0])*(x[i][1]-x[i][0]);
    y[i][0] = ( -(p[i][1]+p[i][0])*x[i][0] 
            + p[i][1]*x[i][1] - p[i][4]*x3 + bxy3 )/p[i][3];
    y[i][1] = p[i][1]*x[i][0] - (p[i][1]+p[i][2])*x[i][1] 
            - x[i][2] - bxy3;
    y[i][2] = x[i][1];
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
  
  plhs[0] = mxCreateDoubleMatrix(3, ncols, mxREAL);
  y = mxGetPr(plhs[0]);
  
  tor((void*)y, (void*)x, (void*)p, ncols);
}
