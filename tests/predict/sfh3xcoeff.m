function [ A B C D ] = sfh3xcoeff( x0, t0, x1, t1 )
%SFH3XCOEFF Scale free Hermite polynomial coefficients.

dx = x1-x0;

t00 = t0'*t0;
t01 = t0'*t1;
t11 = t1'*t1;
dx0 = dx'*t0;
dx1 = dx'*t1;

%% qubic spline with norm minimal nonlinear part
%  h(s) = C*s^2+D*s^3
%  Dk   = (d/ds)^k
%  sum_{i=0,1,2,3} ||(Dk h)(0)||^2 + ||(Dk h)(1)||^2 = Min!
%  the coefficients C and D depend on two scaling factors

AA = [ 27*t00 25*t01 ; 25*t01 32*t11 ];
bb = [ 52*dx0 ; 57*dx1 ];
al = AA\bb;

A = x1;
B = al(2)*t1;
D = al(1)*t0 + B - 2*dx;
C = B + D - dx;
