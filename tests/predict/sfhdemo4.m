% scale-free Hermite interpolation
% demonstrate fit to qubic polynomial around inflexion point

clf;

x0 = -0.3;
x1 =  0.4;

a  = -0.1;
b  =  1.0;
c  =  0.0;

f  = @(x) [ x ; a*x+b*x.^3 ; c*x.^2 ];
fs = @(x) [ones(size(x)) ; a*ones(size(x)) + 3*b*x.^2 ; 2*c*x ];

dx = x1-x0;
xm = 0.5*(x0+x1);
z0 = xm-dx;
z1 = xm+dx;
x = linspace(z0,z1,100);
y = f(x);
figure(1)
plot3(y(1,:), y(2,:), y(3,:))
grid on

u0 = f(x0);
t0 = fs(x0);
t0 = t0/norm(t0);

u1 = f(x1);
t1 = fs(x1);
t1 = t1/norm(t1);

dx = u1-u0;
dx = dx/norm(dx);

hold on

plot3(u0(1), u0(2), u0(3), 'r*');
x = [u0, u0+0.3*t0];
plot3(x(1,:), x(2,:), x(3,:), 'r');

plot3(u1(1), u1(2), u1(3), 'r*');
x = [u1, u1+0.3*t1];
plot3(x(1,:), x(2,:), x(3,:), 'r');

hold off

% [A B C D al] = sfh3coeff(u0, t0, u1, t1, [1.124 ; 1]);
% [A B C D al] = sfh3coeff(u0, t0, u1, t1, [1.25 ; 1.25]);
[A B C D al] = sfh3coeff(u0, t0, u1, t1);

x  = linspace(-1,2,100);
y  = h3eval(A, B, C, D, x);
ys = h3teval(A, B, C, D, x);
nrm = h3nrmeval(A, B, C, D, x);

hold on
plot3(y(1,:), y(2,:), y(3,:), 'g.');
hold off

%axis equal
view(2)

delta = 4;
TOL   = 1.0e-8;

% GCOND = [(t0-dx)'*(t1-dx)-delta*TOL ...
% 	(norm(t1-dx)-TOL)/delta-norm(t0-dx) ...
% 	norm(t0-dx)-delta*(norm(t1-dx)+TOL) ...
% 	180*(acos(t0'*t1))/pi];
% fprintf(' % .4e', GCOND);
% fprintf('\n');
COEFF = [A B C D; norm(A) norm(B) norm(C) norm(D)] %#ok<NOPTS>

figure(2)
plot(x,nrm)
