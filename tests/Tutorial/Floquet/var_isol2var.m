function opts = var_isol2var(opts, varargin)
% Parser that sets up the variational collocation problem
% given a initial solution guess for the corresponding ODE.

argidx = 1;
prefix = varargin{argidx};

opts      = coll_start(opts, varargin{:}); 
fid       = coco_get_id(prefix, 'coll_fun');
[data x0] = coco_get_func_data(opts, fid, 'data', 'x0');

[data x0] = var_system(data, x0);
opts      = var_create(opts, prefix, data, x0);

end