function data = alg_init_data(data, x0, p0)

xdim       = numel(x0);
pdim       = numel(p0);
data.x_idx = (1:xdim)';
data.p_idx = xdim+(1:pdim)';

end