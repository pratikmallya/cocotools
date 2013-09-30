function y = cusp(x,p)
% CUSP   Cusp normal form.
%
%    CUSP(X,PAR) - Equation: x' = mu - x*(la - x*x)
%    X = x
%    P = [ mu la ]

x  = x(1,:);
mu = p(1,:);
la = p(2,:);

y(1,:) = mu - x.*(la-x.*x);
