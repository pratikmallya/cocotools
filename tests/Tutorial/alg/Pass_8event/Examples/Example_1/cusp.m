function y = cusp(x, p)

kappa  = p(1,:);
lambda = p(2,:);
x      = x(1,:);

y = kappa-x.*(lambda-x.^2);

end