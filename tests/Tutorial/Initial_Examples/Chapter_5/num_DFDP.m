function J = num_DFDP(F, x, p)

x   = x(:,:);
p   = p(:,:);
m   = size(p, 1);
n   = size(x, 2);
idx = repmat(1:n, [m 1]);
x0  = x(:,idx);
p0  = p(:,idx);

idx = repmat(1:m, [1 n]);
idx = sub2ind([m m*n], idx, 1:m*n);

h = 1.0e-8*(1.0+abs(p0(idx)));
p = p0;

p(idx) = p0(idx)+h;
fr     = F(x0, p);
p(idx) = p0(idx)-h;
fl     = F(x0, p);

l  = size(fr, 1);
hi = repmat(0.5./h, [l  1]);
J  = reshape(hi.*(fr-fl), [l m n]);

end