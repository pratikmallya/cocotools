function opts = floquet_restart(opts, rrun, rlab)
% Parser that sets up the variational collocation problem
% given a previously computed solution for the corresponding ODE.

[data_ptr sol] = coco_read_solution('floquet_save', rrun, rlab);
data           = data_ptr.data;
x0             = sol.x(data.xidx);
opts           = floquet_create(opts, data, x0);

end