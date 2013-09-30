addpath('..');

eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 2*pi], [0;1]);

clf;
plot(x0(:,1), x0(:,2), 'b.-');
grid on;

opts = coco_set('coll', 'NTST', 40, 'NCOL', 4, 'TOL', 1.0e-4);
opts = coco_set(opts, 'cont', 'ItMX', [0 150]);
opts = coco_set(opts, 'cont', 'LogLevel', 3);

opts1 = coll_isol2sol(opts, '', @pneta, t0, x0, eps0);
data = coco_get_func_data(opts1, 'coll', 'data');
opts1 = coco_add_func(opts1, 'bcs', @pneta_bc, [], 'zero', ...
  'xidx', [data.x0idx ; data.x1idx]);
opts1 = coco_add_pars(opts1, '', ...
  [data.p_idx, data.Tidx], {'eps', 'T'});

bd1  = coco(opts1, 'run1', [], 1, {'eps' 'T' 'coll.err'}, [0 25]);

lab1  = coco_bd_labs(bd1, 'EP');
lab2  = coco_bd_labs(bd1, 'MXCL');
lab   = sort(union(lab1, lab2));
[t,x] = coll_read_sol('', 'run1', lab(end)); %#ok<ASGLU>
clf
% plot(t, x(2,:), 'b.-')
plot(x(1,:), x(2,:), 'b.-')
grid on

opts2 = coco_set(opts, 'coll', 'NTST', 60, 'NCOL', 5);
opts2 = coll_sol2sol(opts2, '', 'run1', lab(end));
data = coco_get_func_data(opts2, 'coll', 'data');
opts2 = coco_add_func(opts2, 'bcs', @pneta_bc, [], 'zero', ...
  'xidx', [data.x0idx ; data.x1idx]);
opts2 = coco_add_pars(opts2, '', ...
  [data.p_idx, data.Tidx], {'eps', 'T'});

bd2  = coco(opts2, 'run2', [], 1, {'eps' 'T' 'coll.err'}, [0 25]);

lab1  = coco_bd_labs(bd2, 'EP');
lab2  = coco_bd_labs(bd2, 'MXCL');
lab   = sort(union(lab1, lab2));
[t,x] = coll_read_sol('', 'run2', lab(end));
hold on
% plot(t, x(2,:), 'b.-')
plot(x(1,:), x(2,:), 'g.-')
grid on
hold off

rmpath('..');
