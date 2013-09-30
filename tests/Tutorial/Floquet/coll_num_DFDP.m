function J = coll_num_DFDP(F, x, p, pars, mode)

m = length(pars);
n = size(x,2);

idx1 = kron(1:n, ones(1,m));
x    = x(:,idx1);
p0   = p(:,idx1);

idx1 = repmat(pars, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([size(p0,1) m*n], idx1, idx2);

h    = 1.0e-8*(1.0 + abs(p0(idx)));

p    = p0;

p(idx) = p0(idx)+h;
fr     = F(x,p,mode);
p(idx) = p0(idx)-h;
fl     = F(x,p,mode);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);

end