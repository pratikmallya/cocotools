function [data J] = catenary_DFDX(opts, data, xp)

a = xp(1);
b = xp(2);

J = [-1/a^2*cosh(a*b)+b/a*sinh(a*b) sinh(a*b) 0;...
    -1/a^2*cosh(a*(1+b))+(1+b)/a*sinh(a*(1+b)) sinh(a*(1+b)) -1];

end