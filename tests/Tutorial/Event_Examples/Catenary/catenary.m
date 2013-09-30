function [data y] = catenary(opts, data, xp)

a = xp(1);
b = xp(2);
Y = xp(3);

y  = [ 1/a*cosh(a*b)-1; 1/a*cosh(a*(1+b))-Y ];

end