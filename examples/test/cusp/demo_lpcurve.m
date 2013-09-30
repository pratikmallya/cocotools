function demo_lpcurve()
%DEMO_LPCURVE   Demonstrate codim-one continuation.

%% initialise continuation
clf;
opts = [];
x0   = 0;
p0   = [ 0 ; 1 ];

% enable cleaning of data directory prior to computation
opts = coco_set(opts, 'all', 'CleanData', 1);

% add monitor functions for fold and degeneracy
opts = coco_add_func(opts, 'user:fold', 'alcont', @fold, [], ...
  'active', 'fold', 'vectorised', 'on');
opts = coco_add_func(opts, 'user:range', 'alcont', @range, [], ...
  'regular', 'ran', 'vectorised', 'on');

% add events for fold and degeneracy, note that branch points
% are generic along curves of folds
opts = coco_add_event(opts, 'LP', 'fold', 0);
opts = coco_add_event(opts, 'BP', 'ran',  0);

%% continuation in mu, locate limit points
bd = coco(opts, 'lpc1', 'alcont', 'isol', 'sol', @cusp, ...
	x0, p0, 'PAR(1)', [-1, 1]);

% extract label of limit points
lab = coco_bd_labs(bd, 'LP');

%% continuation in lambda and mu
% fix fold function and activate parameter mu
opts = coco_xchg_pars(opts, 'fold', 'PAR(1)');

bd = coco(opts, 'lpc2', 'alcont', 'sol', 'sol', ...
	'lpc1', lab(1), {'PAR(2)' 'PAR(1)' 'ran'}, [-1, 1]);

%% plot bifurcation diagram in lambda-mu parameter plane
p  = coco_bd_col(bd, 'PARS');
mu = p(1,:);
la = p(2,:);

plot(la, mu, 'b-');
axis([-1 1 -1 1]);
grid on

idx = find(strcmp('BP', coco_bd_col(bd, 'TYPE') ));
hold on
plot(la(idx), mu(idx), 'rx', 'LineWidth', 2, 'MarkerSize', 6);
hold off

drawnow
