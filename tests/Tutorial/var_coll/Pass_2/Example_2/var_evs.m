function [data y] = var_evs(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid, 'data');

M  = reshape(u(1:end-4), fdata.u_shp);
M1 = M(fdata.M1_idx,:);

vec = u(end-3:end-1);
lam = u(end);

y = [M1*vec-lam*vec; vec'*vec-1];

end