function varopts = var_isol2var(opts, varargin)
% Parser that sets up the variational collocation problem
% given a initial solution guess for the corresponding ODE.

opts       = coll_isol2sol(opts, '', varargin{:}); 
[cdata x0] = coco_get_func_data(opts, 'coll', 'data', 'x0');
[data vx0] = var_system(cdata, x0);

data.tbid  = 'var';
varopts    = var_create(opts, data, vx0);

end