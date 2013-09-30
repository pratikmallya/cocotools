function y = f1(x,p)
% CONE   Equation for double cone around z-axis.
%
%    CONE(X,PAR) - Equation: z^2 = x^2 + y^2
%    X = z
%    P = [ x ; y ; alpha ]

z = x(1,:);
x = p(1,:);
y = p(2,:);

y(1,:) = z.^2 - x.^2 - y.^2;