function prob = huxley_sol2het(prob, rrun, rlab)

prob = coll_sol2seg(prob, 'huxley1', rrun, rlab);
prob = coll_sol2seg(prob, 'huxley2', rrun, rlab);

[data chart] = coco_read_solution('bcs', rrun, rlab);
epsv = chart.x(data.eps_idx);

prob = huxley_close_het(prob, epsv);

end