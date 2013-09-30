/*
compile:

gcc -O -funroll-loops -c -o run_test.o run_test.c ; gcc -O -funroll-loops -c -o catenary.o catenary.c ; gcc -O -funroll-loops -o main main.c catenary.o run_test.o

sample output:

running test with arrays of size N=3000000, repetitions=1000
elapsed cpu time non-vectorised = 113.07 seconds
elapsed cpu time     vectorised = 96.22 seconds

*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void run_test(int num, long int N, double *y, double *x, double *p);

int main() {
	double *y=NULL, *x=NULL, *p=NULL;
	long int i, k, N=3000000L, rep=1000;
	clock_t t0;
	
	y = calloc(2*N,sizeof(double));
	x = calloc(2*N,sizeof(double));
	p = calloc(  N,sizeof(double));
	for(i=0; i<2*N; i++) x[i] = 2.0*((double)rand())/((double)RAND_MAX)-1;
	for(i=0; i<  N; i++) p[i] = 2.0*((double)rand())/((double)RAND_MAX)-1;

	printf("running test with arrays of size N=%ld, repetitions=%ld\n", N, rep);
	
	t0 = clock();
	for(k=0; k<rep; ++k) run_test(1, N, y, x, p);
	printf("elapsed cpu time non-vectorised = %.2f seconds\n",
		((double)(clock()-t0))/((double)CLOCKS_PER_SEC));
	
	t0 = clock();
	for(k=0; k<rep; ++k) run_test(2, N, y, x, p);
	printf("elapsed cpu time     vectorised = %.2f seconds\n",
		((double)(clock()-t0))/((double)CLOCKS_PER_SEC));
	
	return 0;
}


