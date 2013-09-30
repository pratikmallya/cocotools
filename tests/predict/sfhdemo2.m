% scale-free Hermite interpolation
% demonstrate fit to unit circle

clf;

s1 = pi/4+2*pi/4;

f  = @(x) [-cos(x); sin(x)];
fs = @(x) [ sin(x); cos(x)];

x = linspace(0, pi, 100);
y = f(x);
plot(y(1,:),y(2,:))
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

plot(x0(1), x0(2), 'r*');
x = [x0-0.3*t0, x0+0.3*t0];
plot(x(1,:), x(2,:), 'r');

plot(x1(1), x1(2), 'r*');
x = [x1-0.3*t1, x1+0.3*t1];
plot(x(1,:), x(2,:), 'r');

hold off

%[A B C D] = sh3coeff(x0, t0, x1, t1, al1, be1);
[A B C D] = sfh3coeff(x0, t0, x1, t1);

x  = linspace(-1,2,100);
y  = h3eval(A, B, C, D, x);

hold on
plot(y(1,:), y(2,:), 'g.');
hold off
axis([-1.5 1.5 -0.5 1.5]);

COEFF = [A B C D]

[A B C D] = sfh3xcoeff(x0, t0, x1, t1);

x  = linspace(0,0.3/norm(x1-x0),10);
y  = h3eval(A, B, C, D, x);

hold on
plot(y(1,:), y(2,:), 'm.');
hold off
