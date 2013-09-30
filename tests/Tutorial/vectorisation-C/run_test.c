#include <stdio.h>

void catenary(double *y, const double *x, const double *p);
void catenary_v(const int N, double *y, const double *x, const double *p);

void run_test(int num, long int N, double *y, double *x, double *p) {
	long int i;
	
	switch (num) {
		case 1:
			for(i=0; i<N; i++, y+=2,x+=2) catenary(y, x, p);
			break;
		
		case 2:
			catenary_v(N, y, x, p);
	}
}

