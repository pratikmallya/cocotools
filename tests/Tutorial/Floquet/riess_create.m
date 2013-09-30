function opts = riess_create(opts, data, vec, lam, eps)

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');
[data3_ptr xidx3] = coco_get_func_data(opts, 'floquet_fun', 'data', 'xidx');
data3 = data3_ptr.data;

opts = coco_add_functionals(opts, '', 'shared_pars', ...
    [1, -1; 1, -1; 1, -1; 1, -1; 1, -1; 1, -1], [0; 0; 0; 0; 0; 0], ...
    [xidx1(data1.p_idx) xidx1(data1.p_idx)...
    xidx2(data2.p_idx) xidx3(data3.p_idx)]);

evsdata.dim   = data3.dim;
evsdata.u_idx = data3.u_idx;
[opts xidx] = coco_add_func(opts, 'evs', @var_evs, evsdata, 'zero', 'xidx', ...
    xidx3(data.u_idx), 'x0', ...
    [vec; lam]);

data.vec_idx = xidx(end-3:end-1);
data.lam_idx  = xidx(end);

[opts xidx] = coco_add_func(opts, 'bcs1', @eig_bcs, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx3(data3.x0idx) xidx3(data3.p_idx(1:2)) ...
    data.vec_idx], 'x0', eps);

data.eps_idx = xidx(end-1:end);

opts = coco_add_slot(opts, 'riess_save', @coco_save_data, data, 'save_full');

opts = coco_add_func(opts, 'bcs2', @proj_bcs, [], 'inactive', {'sigma1', 'sigma2'}, 'xidx', ...
    [xidx1(data1.x1idx)  xidx2(data2.x1idx)]);

opts = coco_add_parameters(opts, '', [data.eps_idx xidx1(data1.Tidx) xidx2(data2.Tidx)], {'eps1', 'eps2', 'T1', 'T2'});

end