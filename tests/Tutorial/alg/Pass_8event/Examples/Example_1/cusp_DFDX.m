function J = cusp_DFDX(x, p)

lambda = p(2,:);
x      = x(1,:);

J = 3*x.^2-lambda;

end
