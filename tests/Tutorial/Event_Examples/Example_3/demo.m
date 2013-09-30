switchpath('old');
addpath('../../alg/Pass_6')
fprintf('**************************\n\n');

opts = alg_start([], '', @cusp, 0, [0 ; 1]);
opts = coco_add_func(opts, 'fold', @fold, [], 'active', 'fold');
opts = coco_add_func(opts, 'rank', @range, [], 'regular', 'ran');

% opts = coco_add_event(opts, 'LP', 'fold', 0);
% opts = coco_add_event(opts, 'RN', 'ran', 0);
% opts = coco_add_event(opts, 'BP', 'fold', 0, 'ran', 0);
opts = coco_add_event(opts, @bphan, 'fold', 0, 'ran', 0);

figure(1)
clf
bd1 = coco(opts, 'run1', [], 'PAR(1)', [-1, 1]);
plot_bd(bd1, 1, 1)

bd2 = coco(opts, 'run2', [], 'PAR(2)', [-1, 1.1]);
plot_bd(bd2, 2, 2)

lab = coco_bd_labs(bd1, 'LP');

opts = alg_restart([], '', 'run1', lab(1));
opts = coco_add_func(opts, 'fold', @fold, [], 'active', 'fold');
opts = coco_add_func(opts, 'rank', @range, [], 'regular', 'ran');
opts = coco_xchg_pars(opts, 'fold', 'PAR(1)');

opts = coco_add_event(opts, 'BP', 'ran', 0);

bd3 = coco(opts, 'run3', [], {'PAR(2)' 'PAR(1)' 'ran'}, [-1, 1.1]);

figure(2)
clf
p      = coco_bd_col(bd3, 'PARS');
kappa  = p(1,:);
lambda = p(2,:);

plot(lambda, kappa, 'b-');
axis([-1 1 -1 1]);
grid on
idx = find(strcmp('BP', coco_bd_col(bd3, 'TYPE') ));
hold on
plot(lambda(idx), kappa(idx), 'rx', 'LineWidth', 2, 'MarkerSize', 6);
hold off