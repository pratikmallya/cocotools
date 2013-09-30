function prob = riess_restart_1(prob, run, lab)

prob = povar_sol2orb(prob, '', run, lab);
prob = coll_sol2seg(prob, 'col1', run, lab);
prob = coll_sol2seg(prob, 'col2', run, lab);

[data sol] = coco_read_solution('riess_save_1', run, lab);
eps = sol.x(data.eps_idx);
vec = sol.x(data.vec_idx);
lam = sol.x(data.lam_idx);

prob = riess_close_het_1(prob, data, vec, lam, eps);

end