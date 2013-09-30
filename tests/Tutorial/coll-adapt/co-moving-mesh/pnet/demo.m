tbpaths = {'..', '../../../Atlas_Algorithms/new'};
% tbpaths = {'../../../coll/Pass_6', '../../../Atlas_Algorithms/new'};
addpath(tbpaths{:});

eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 2*pi], [0;1]);

clf;
plot(x0(:,1), x0(:,2), 'b.-');
grid on;

opts = coco_set('coll', 'NTST', 30, 'NCOL', 4);
opts = coco_set(opts, 'cont', 'PtMX', 120, 'bi_direct', false);
% opts = coco_set(opts, 'cont', 'atlas', @atlas1_3a.create, 'h', 0.5, 'PtMX', 200);

opts = coco_set(opts, 'cont', 'LogLevel', 1);
opts = coco_set(opts, 'cont', 'NAdapt', 1);
opts = coco_set(opts, 'coll', 'h0', 1);
% opts = coco_set(opts, 'corr', 'SubItMX', 3, 'ItMX', 30);

opts1 = coll_isol2sol(opts, '', @pneta, t0, x0, eps0);
data_ptr = coco_get_func_data(opts1, 'coll', 'data');
maps = data_ptr.data.maps;
opts1 = coco_add_func(opts1, 'bcs', @pneta_bc, [], 'zero', ...
  'xidx', [maps.x0idx ; maps.x1idx]);
opts1 = coco_add_pars(opts1, '', ...
  [maps.p_idx, maps.Tidx], {'eps', 'T'});

bd1  = coco(opts1, 'run1', [], 1, {'eps' 'T' 'coll.err' 'coll.NTST'}, [0.4 25]);

lab1  = coco_bd_labs(bd1, 'EP');
lab2  = coco_bd_labs(bd1, 'MXCL');
lab3  = coco_bd_labs(bd1, 'MX');
lab   = sort(union(union(lab1, lab2), lab3));
[t,x] = coll_read_sol('', 'run1', lab(end)); %#ok<ASGLU>
clf
% plot(t, x(2,:), 'b.-')
plot(x(1,:), x(2,:), 'b.-')
grid on
drawnow

opts = coco_set(opts, 'cont', 'PtMX', -125, 'bi_direct', false);
opts2 = coco_set(opts, 'coll', 'NTSTMX', 150, 'NCOL', 4);
opts2 = coll_sol2sol(opts2, '', 'run1', lab(end));
data_ptr = coco_get_func_data(opts2, 'coll', 'data');
maps = data_ptr.data.maps;
opts2 = coco_add_func(opts2, 'bcs', @pneta_bc, [], 'zero', ...
  'xidx', [maps.x0idx ; maps.x1idx]);
opts2 = coco_add_pars(opts2, '', ...
  [maps.p_idx, maps.Tidx], {'eps', 'T'});

bd2  = coco(opts2, 'run2', [], 1, {'eps' 'T' 'coll.err' 'coll.NTST'}, [0.5 25.1]);

lab1  = coco_bd_labs(bd2, 'EP');
lab2  = coco_bd_labs(bd2, 'MXCL');
lab3  = coco_bd_labs(bd2, 'MX');
lab   = sort(union(union(lab1, lab2), lab3));
[t,x] = coll_read_sol('', 'run2', lab1(1));
hold on
% plot(t, x(2,:), 'g.-')
plot(x(1,:), x(2,:), 'g.-')
grid on
hold off

rmpath(tbpaths{:});
