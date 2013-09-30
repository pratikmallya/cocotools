eps0 = 0.1;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 6.2893], [0;0.8167]);

clf;
plot(x0(:,1), x0(:,2), 'r.-');
grid on;
hold on
drawnow

addpath('../../po');
addpath('../Pass_1');
prob  = coco_prob();
prob  = coco_set(prob, 'cont', 'ItMX', [0 200]);
prob1 = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
coco(prob1, 'run1', [], 1, 'eps', [0 20]);
bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'EP');
sol = po_read_solution('', 'run1', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'k.-')
drawnow
rmpath('../Pass_1');
rmpath('../../po');

addpath('../Pass_3');
prob = coco_set(prob, 'coll', 'TOL', 1.0e-3);
prob2 = coll_isol2seg(prob, '', @pneta, t0, x0, eps0);
data  = coco_get_func_data(prob2, 'coll', 'data');
prob2 = coco_add_func(prob2, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.x0_idx; data.x1_idx]);
prob2 = coco_add_pars(prob2, '', ...
[data.p_idx, data.T_idx], {'eps', 'T'});
coco(prob2, 'run2', [], 1, {'eps' 'T' 'coll.err'}, [0 20]);
bd  = coco_bd_read('run2');
lab = coco_bd_labs(bd, 'MXCL');
sol = coll_read_solution('', 'run2', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'b.-')
drawnow

prob = coco_set(prob, 'coll', 'NTST', 20, 'NCOL', 5);
prob3 = coll_sol2seg(prob, '', 'run2', lab(end));
data = coco_get_func_data(prob3, 'coll', 'data');
prob3 = coco_add_func(prob3, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.x0_idx; data.x1_idx]);
prob3 = coco_add_pars(prob3, '', ...
  [data.p_idx, data.T_idx], {'eps', 'T'});
coco(prob3, 'run3', [], 1, {'eps' 'T' 'coll.err'}, [0 20]);
bd  = coco_bd_read('run3');
lab = coco_bd_labs(bd, 'MXCL');
sol = coll_read_solution('', 'run3', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'g.-')
drawnow

prob = coco_set(prob, 'coll', 'NTST', 150, 'NCOL', 5);
prob4 = coll_sol2seg(prob, '', 'run3', lab(end));
data = coco_get_func_data(prob4, 'coll', 'data');
prob4 = coco_add_func(prob4, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.x0_idx; data.x1_idx]);
prob4 = coco_add_pars(prob4, '', ...
  [data.p_idx, data.T_idx], {'eps', 'T'});
coco(prob4, 'run4', [], 1, {'eps' 'T' 'coll.err'}, [0 20]);
bd  = coco_bd_read('run4');
lab = coco_bd_labs(bd, 'EP');
sol = coll_read_solution('', 'run4', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'k.-')
drawnow
rmpath('../Pass_3');

addpath('../Pass_4');
prob = coco_set(prob, 'coll', 'NTST', 15, 'NCOL', 4);
prob = coco_set(prob, 'cont', 'NAdapt', 1);
prob5 = coll_isol2seg(prob, '', @pneta, t0, x0, eps0);
data  = coco_get_func_data(prob5, 'coll', 'data');
prob5 = coco_add_func(prob5, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.maps.x0_idx; data.maps.x1_idx]);
prob5 = coco_add_pars(prob5, '', ...
  [data.maps.p_idx, data.maps.T_idx], {'eps', 'T'});
coco(prob5, 'run5', [], 1, {'eps' 'T' 'coll.err'}, [0 20]);
bd  = coco_bd_read('run5');
lab = coco_bd_labs(bd, 'EP');
sol = coll_read_solution('', 'run5', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'r.-')
drawnow
rmpath('../Pass_4');

addpath('../Pass_5');
prob = coco_set(prob, 'coll', 'NTST', 10, 'NCOL', 4);
prob = coco_set(prob, 'cont', 'NAdapt', 1);
prob6 = coll_isol2seg(prob, '', @pneta, t0, x0, eps0);
data  = coco_get_func_data(prob6, 'coll', 'data');
prob6 = coco_add_func(prob6, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.maps.x0_idx ; data.maps.x1_idx]);
prob6 = coco_add_pars(prob6, '', ...
  [data.maps.p_idx, data.maps.T_idx], {'eps', 'T'});
coco(prob6, 'run6', [], 1, {'eps' 'T' 'coll.err' 'coll.NTST'}, [0 20]);
bd  = coco_bd_read('run6');
lab = coco_bd_labs(bd, 'EP');
sol = coll_read_solution('', 'run6', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'ms', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y')
drawnow
rmpath('../Pass_5');

addpath('../Pass_6');
prob = coco_set(prob, 'coll', 'NTST', 20, 'NCOL', 2, 'TOL', 0.01);
prob = coco_set(prob, 'cont', 'NAdapt', 1);
prob7 = coll_isol2seg(prob, '', @pneta, t0, x0, eps0);
data  = coco_get_func_data(prob7, 'coll', 'data');
prob7 = coco_add_func(prob7, 'bcs', @pneta_bc, [], 'zero', ...
  'uidx', [data.maps.x0_idx ; data.maps.x1_idx]);
prob7 = coco_add_pars(prob7, '', ...
  [data.maps.p_idx, data.maps.T_idx], {'eps', 'T'});
coco(prob7, 'run7', [], 1, {'eps' 'T' 'coll.err' 'coll.NTST'}, [0 20]);
bd  = coco_bd_read('run7');
lab = coco_bd_labs(bd, 'EP');
sol = coll_read_solution('', 'run7', lab(end));
plot(sol.x(:,1), sol.x(:,2), 'm^', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
drawnow
rmpath('../Pass_6');

animate('run7', 'm^-', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
