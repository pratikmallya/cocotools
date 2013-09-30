% scale-free Hermite interpolation
% demonstrate fit to helix over unit circle

clf;

s1 = pi/4+2*pi/4;

f  = @(x) [-cos(x); sin(x); x];
fs = @(x) [ sin(x); cos(x); 1];

x = linspace(-pi/4, 5*pi/4, 100);
y = f(x);
plot3(y(1,:),y(2,:),y(3,:))
grid on

x0 = f(pi/4);
t0 = fs(pi/4);
al1 = norm(t0);
t0 = t0/al1;

x1 = f(s1);
t1 = fs(s1);
be1 = norm(t1);
t1 = t1/be1;

hold on

plot3(x0(1), x0(2), x0(3), 'r*');
x = [x0-0.3*t0, x0+0.3*t0];
plot3(x(1,:), x(2,:), x(3,:), 'r');

plot3(x1(1), x1(2), x1(3), 'r*');
x = [x1-0.3*t1, x1+0.3*t1];
plot3(x(1,:), x(2,:), x(3,:), 'r');

hold off

%[A B C D] = sh3coeff(x0, t0, x1, t1, al1, be1);
[A B C D al] = sfh3coeff(x0, t0, x1, t1);

x  = linspace(-1,2,100);
y  = h3eval(A, B, C, D, x);

hold on
plot3(y(1,:), y(2,:), y(3,:), 'g.');
hold off

COEFF = [A B C D]

[A B C D] = sfh3xcoeff(x0, t0, x1, t1);

x  = linspace(0,0.3/norm(x1-x0),10);
y  = h3eval(A, B, C, D, x);

hold on
plot3(y(1,:), y(2,:), y(3,:), 'm.');
hold off
