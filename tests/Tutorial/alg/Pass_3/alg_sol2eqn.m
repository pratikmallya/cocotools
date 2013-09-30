function prob = alg_sol2eqn(run, lab)

[sol data] = alg_read_solution(run, lab);
prob       = alg_construct_eqn(data, sol);

end