function varprob = var_sol2var(prob, oid, rrun, rlab)

prob       = coll_sol2seg(prob, oid, rrun, rlab);
tbid       = coco_get_id(oid, 'coll');
[cdata u0] = coco_get_func_data(prob, tbid, 'data', 'u0');
data       = var_init_data(cdata, u0);
sol.u      = [data.M0(:); 1];

tbid       = coco_get_id(oid, 'var');
varprob    = var_add_func(tbid, data, sol);

end