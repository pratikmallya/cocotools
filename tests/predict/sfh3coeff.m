function [ A B C D al ] = sfh3coeff( x0, t0, x1, t1, al )
%SFH3COEFF Scale free Hermite polynomial coefficients.

dx = x1-x0;

t00 = t0'*t0;
t01 = t0'*t1;
t11 = t1'*t1;
dx0 = dx'*t0;
dx1 = dx'*t1;
dx2 = dx'*dx;

% tx  = dx/norm(dx);
% [ acos(t0'*tx)+acos(t1'*tx) acos(t0'*t1)]*180/pi 

% %% qubic spline with
% % [C^2/a^2 + D^2/a^2](al) = Min!
% if nargin<5
%   AA = [ 8*dx0 15*dx1 ; 3*t01 2*t11 ];
%   bb = [ 13*dx2 ; 5*dx1 ];
%   al = AA\bb;
% end
% 
% A = x0;
% B = al(1)*t0;
% D = al(2)*t1 + B - 2*dx;
% C = dx - B - D;

%% qubic spline with
% [2*C^2 + 36*D^2 + 2*(C+3*D)^2 + (C+D)^2/2 + (2C+3D)^2/2](al) = Min!
if nargin<5
  AA = [ 26*t00 23*t01 ; 23*t01 28*t11 ];
  bb = [ 49*dx0 ; 51*dx1 ];
  al = AA\bb;
end

A = x0;
B = al(1)*t0;
D = al(2)*t1 + B - 2*dx;
C = dx - B - D;

% %% qubic spline with
% % [C^2 + (C+3*D)^2](al) = Min!
% AA = [ 6*t00 6*t01 ; 6*t01 9*t11 ];
% bb = [ 12*dx0 ; 15*dx1 ];
% al = AA\bb;
% 
% A = x0;
% B = al(1)*t0;
% D = al(2)*t1 + B - 2*dx;
% C = dx - B - D;

% %% qubic spline with
% % [C'*C + 18*D'*D + (C+3*D)'*(C+3*D)](al) = Min!
% AA = [ 24*t00 24*t01 ; 24*t01 27*t11 ];
% bb = [ 48*dx0 ; 51*dx1 ];
% al = AA\bb;
% 
% A = x0;
% B = al(1)*t0;
% D = al(2)*t1 + B - 2*dx;
% C = dx - B - D;

% %% qubic spline with
% % [C'*C + 9*D'*D](al) = Min!
% AA = [ 13*t00 11*t01 ; 11*t01 10*t11 ];
% bb = [ 24*dx0 ; 21*dx1 ];
% al = AA\bb;
% 
% A = x0;
% B = al(1)*t0;
% D = al(2)*t1 + B - 2*dx;
% C = dx - B - D;
