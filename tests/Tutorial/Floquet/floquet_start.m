function opts = floquet_start(opts, rrun, rlab)
% Parser that sets up the variational collocation problem
% given a previously computed solution for the corresponding ODE.

[data_ptr sol] = coco_read_solution('var_save', rrun, rlab);
data           = data_ptr.data;
x0             = [data.x0; sol.x(data.varu_idx)];
data           = floquet_system(data, x0);
opts           = floquet_create(opts, data, x0);

end