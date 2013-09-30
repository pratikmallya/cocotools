function y = caty(x, p)
% 7.3.1  A shooting method for boundary-value problems
%
% Y = CATY(X, P)
%
% Evaluate right-hand side of Euler-Lagrange equation of catehary problem.
%
%   See also: catenary

x1 = x(1,:);
x2 = x(2,:);

y(1,:) = x2;
y(2,:) = (1+x2.^2)./x1;

end
