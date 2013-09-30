function J = cusp_DFDX(x, p)

x  = x(1,:);
la = p(2,:);

J = 3*x.^2-la;

end