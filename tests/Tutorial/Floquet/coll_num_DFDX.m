function J = coll_num_DFDX(F, x, p, mode)

[m n] = size(x);

idx1 = kron(1:n, ones(1,m));
x0   = x(:,idx1);
p    = p(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

h    = 1.0e-8*(1.0 + abs(x0(idx)));

x    = x0;

x(idx) = x0(idx)+h;
fr     = F(x,p,mode);
x(idx) = x0(idx)-h;
fl     = F(x,p,mode);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);

end