function [ y ] = h3teval( A, B, C, D, x )
%POLY_EVAL Evaluate tangent at Hermite polynomial at X.

rows = size(A,1);
cols = numel(x);

or = ones(rows,1);
oc = ones(1,cols);

x  = x(:)';
x  = x(or,:);

y = B(:,oc) + x.*((2*C(:,oc)) + x.*(3*D(:,oc)));

ny = sqrt(sum(y.*y,1));
y  = y./ny(or,:);
