function y = pitchfork(x,p)
% PITCHFORK   Unfolded pitchfork normal form
%
%    PITCHFORK(X,PAR) - Equation: x' = x*(mu - (x-al)^2)
%    X = x
%    P = [ mu al ]

x  = x(1,:);
mu = p(1,:);
al = p(2,:);

y(1,:) = x .* (mu - (x-al).*(x-al));
