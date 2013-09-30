function J = coll_num_DFDX(F, x, p, model)

x     = x(:,:);
p     = p(:,:);
[m n] = size(x);
idx   = repmat(1:n, [m 1]);
x0    = x(:,idx);
p0    = p(:,idx);

idx = repmat(1:m, [1 n]);
idx = sub2ind([m m*n], idx, 1:m*n);

h = 1.0e-8*(1.0 + abs(x0(idx)));
x = x0;

x(idx) = x0(idx)+h;
fr     = F(x,p0,model);
x(idx) = x0(idx)-h;
fl     = F(x,p0,model);

l  = size(fr, 1);
hi = repmat(0.5./h, [l 1]);
J  = reshape(hi.*(fr-fl), [l m n]);

end