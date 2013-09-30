void catenary(double *y, const double *x, const double *p) {
	y[0] = x[1];
	y[1] = (1.0+x[1]*x[1])/x[0];
}

void catenary_v(const long int N, double *y, const double *x, const double *p) {
	long int i=0;
	for(i=0; i<N; i++, y+=2,x+=2) {
		y[0] = x[1];
		y[1] = (1.0+x[1]*x[1])/x[0];
	}
}

