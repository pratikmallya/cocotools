function y = cusp(x, p)

kappa  = p(1);
lambda = p(2);

y = kappa - x * (lambda - x * x);
