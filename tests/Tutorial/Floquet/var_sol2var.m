function opts = var_sol2var(opts, prefix, rrun, rlab)
% Parser that sets up the variational collocation problem
% given a previously computed solution for the corresponding ODE.

opts = coll_restart(opts, prefix, rrun, rlab);
fid       = coco_get_id(prefix, 'coll_fun');
[data x0] = coco_get_func_data(opts, fid, 'data', 'x0');

[data x0] = var_system(data, x0);
opts      = var_create(opts, prefix, data, x0);

end