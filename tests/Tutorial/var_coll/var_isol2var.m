function varopts = var_isol2var(varargin)

opts       = coll_isol2sol([], '', varargin{:}); 
[cdata u0] = coco_get_func_data(opts, 'coll', 'data', 'u0');
data       = var_init_data(cdata, u0);
sol.u      = [data.init(:); 0];

tbid       = 'var';
varopts    = var_add_func(tbid, data, sol);

end