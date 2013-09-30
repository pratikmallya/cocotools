function [ y ] = h3nrmeval( A, B, C, D, x )
%H3EVAL Evaluate Hermite polynomial at X.

rows = size(A,1);
cols = numel(x);

or = ones(rows,1);
oc = ones(1,cols);

x  = x(:)';
x  = x(or,:);

nrm = x.*(x.*(C(:,oc) + x.*D(:,oc)));
y   = sum(nrm.*nrm,1);

nrm = x.*(2*C(:,oc) + x.*(3*D(:,oc)));
y   = y + sum(nrm.*nrm,1);

nrm = 2*C(:,oc) + x.*(6*D(:,oc));
y   = y + sum(nrm.*nrm,1);

nrm = 6*D(:,oc);
y   = y + sum(nrm.*nrm,1);
