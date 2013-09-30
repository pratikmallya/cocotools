function [ y ] = poly_eval( A, B, C, D, x )
%POLY_EVAL Evaluate Hermite polynomial at X.

rows = size(A,1);
cols = numel(x);

or = ones(rows,1);
oc = ones(1,cols);

x  = x(:)';
x  = x(or,:);

y = A(:,oc) + x.*(B(:,oc) + x.*(C(:,oc) + x.*D(:,oc)));
