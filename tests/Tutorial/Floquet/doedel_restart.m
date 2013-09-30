function opts = doedel_restart(opts, rrun, rlab)

opts = coll_restart(opts, 'col1', rrun, rlab);
opts = coll_restart(opts, 'col2', rrun, rlab);
opts = alg_sol2sol(opts, 'alg1', rrun, rlab);
opts = alg_sol2sol(opts, 'alg2', rrun, rlab);

[data sol] = coco_read_solution('doedel_save', rrun, rlab);
eps  = sol.x(data.eps_idx);
th   = sol.x(data.th_idx);
vec = sol.x(data.vec_idx);
lam  = sol.x(data.lam_idx);

opts = doedel_create(opts, eps, th, vec, lam);

end