% scale-free Hermite interpolation
% demonstrate fit to polynomial x-a1*x.^2-a2*x.^3 at 0 and s1

clf;

s1 = 1.7;

a1 = 0.3;
a2 = 0.2;

f  = @(x) (x-a1*x.^2-a2*x.^3);
fs = @(x) (ones(size(x))-2*a1*x-3*a2*x.^2);

x = linspace(-1,2,100);
plot(x,f(x))
grid on

x0 = [0 ;  f(0)];
t0 = [1 ; fs(0)];
al1 = norm(t0);
t0 = t0/al1;

x1 = [s1 ;  f(s1)];
t1 = [ 1 ; fs(s1)];
be1 = norm(t1);
t1 = t1/be1;

hold on

plot(x0(1), x0(2), 'r*');
x = [x0, x0+0.3*t0];
plot(x(1,:), x(2,:), 'r');

plot(x1(1), x1(2), 'r*');
x = [x1, x1+0.3*t1];
plot(x(1,:), x(2,:), 'r');

hold off

% [A B C D al] = sfh3coeff(x0, t0, x1, t1, [1.58, 0.93]);
[A B C D al] = sfh3coeff(x0, t0, x1, t1);
sqrt(sum(h3nrmeval(A,B,C,D,[0 1])))

x  = linspace(-1,2,100);
y  = h3eval(A, B, C, D, x);
ys = h3teval(A, B, C, D, x);

hold on
plot(y(1,:), y(2,:), 'g.');
hold off
axis([-1.5 2 -1.5 1])

COEFF = [A B C D]

[A B C D] = sfh3xcoeff(x0, t0, x1, t1);

x  = linspace(0,0.3,10);
y  = h3eval(A, B, C, D, x);

hold on
plot(y(1,:), y(2,:), 'm.');
hold off
