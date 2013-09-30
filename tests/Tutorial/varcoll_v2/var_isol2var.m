function varprob = var_isol2var(prob, varargin)

prob       = coll_isol2seg(prob, '', varargin{:}); 
[cdata u0] = coco_get_func_data(prob, 'coll', 'data', 'u0');
data       = var_init_data(cdata, u0);
sol.u      = [data.M0(:); 0];

tbid       = 'var';
varprob    = var_add_func(tbid, data, sol);

end