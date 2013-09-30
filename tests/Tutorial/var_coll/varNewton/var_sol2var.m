function varopts = var_sol2var(prefix, rrun, rlab)
% Parser that sets up the variational collocation problem
% given a previously computed solution for the corresponding ODE.

opts       = coll_sol2sol([], prefix, rrun, rlab);
fid        = coco_get_id(prefix, 'coll');
[cdata x0] = coco_get_func_data(opts, fid, 'data', 'x0');
[data vx0] = var_system(cdata, x0);

data.tbid  = coco_get_id(prefix, 'var');
varopts    = var_create(opts, data, vx0);

end