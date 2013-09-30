function prob = doedel_sol2het(prob, run, lab)

prob = coll_sol2seg(prob, 'doedel1', run, lab);
prob = coll_sol2seg(prob, 'doedel2', run, lab);
prob = alg_sol2eqn(prob, 'doedel3', run, lab);
prob = alg_sol2eqn(prob, 'doedel4', run, lab);

[data chart] = coco_read_solution('evs', run, lab);
vec  = chart.x(data.vec_idx);
lam  = chart.x(data.lam_idx);

[data chart] = coco_read_solution('bcs', run, lab);
eps  = chart.x(data.eps_idx);
th   = chart.x(data.th_idx);

prob = doedel_close_het(prob, eps, th, vec, lam);

end