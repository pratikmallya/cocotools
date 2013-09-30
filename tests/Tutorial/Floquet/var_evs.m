function [data y] = var_evs(opts, data, xp) %#ok<INUSL>

mat = reshape(xp(1:end-4), [numel(data.u_idx)/data.dim data.dim]);
m0  = mat(1:data.dim,1:data.dim);
m1  = mat(end-data.dim+1:end,1:data.dim);

vec = xp(end-3:end-1,:);
lam = xp(end,:);

y = [m1*vec - m0*lam*vec; vec'*vec - 1];

end

