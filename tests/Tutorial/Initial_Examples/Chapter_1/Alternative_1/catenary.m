function [data y] = catenary(prob, data, u)

a = u(1);
b = u(2);
Y = u(3);

y  = [1/a*cosh(a*b)-1; 1/a*cosh(a*(1+b))-Y];

end