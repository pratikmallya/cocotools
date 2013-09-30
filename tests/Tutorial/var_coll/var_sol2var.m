function varopts = var_sol2var(oid, rrun, rlab)

opts       = coll_sol2sol([], oid, rrun, rlab);
tbid       = coco_get_id(oid, 'coll');
[cdata u0] = coco_get_func_data(opts, tbid, 'data', 'u0');
data       = var_init_data(cdata, u0);
sol.u      = [data.init(:); 0];

tbid       = coco_get_id(oid, 'var');
varopts    = var_add_func(tbid, data, sol);

end