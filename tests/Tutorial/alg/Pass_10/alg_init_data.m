function data = alg_init_data(data, x0, p0)

xdim       = numel(x0);
pdim       = numel(p0);
data.x_idx = (1:xdim)';
data.p_idx = xdim+(1:pdim)';

Jx           = alg_fhan_DFDX(data, x0, p0);
[data.b, ~, data.c] = svds(Jx,1,0);
data.rhs     = [zeros(xdim,1); 1];
I            = triu(true(xdim),1);
A            = repmat((1:xdim)', [1 xdim]);
data.la_idx1 = A(I);
A            = A';
data.la_idx2 = A(I);

end