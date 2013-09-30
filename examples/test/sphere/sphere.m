function y = sphere(x,p)
% CONE   Equation for double cone around z-axis.
%
%    SPHERE(X,PAR) - Equation: x^2 + (ay)^2 + (bz)^2 = 1
%    X = z
%    P = [ x ; y ; a, b ]

z = x(1,:);
x = p(1,:);
y = p(2,:);
a = p(3,:);
b = p(4,:);

y(1,:) = x.^2 + (a.*y).^2 + (b.*z).^2 - 1;
