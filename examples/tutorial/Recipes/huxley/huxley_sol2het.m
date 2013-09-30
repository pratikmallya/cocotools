function prob = huxley_sol2het(prob, run, lab)

prob = coll_sol2seg(prob, 'huxley1', run, lab);
prob = coll_sol2seg(prob, 'huxley2', run, lab);

[data chart] = coco_read_solution('bcs', run, lab);
epsv = chart.x(data.eps_idx);

prob = huxley_close_het(prob, epsv);

end