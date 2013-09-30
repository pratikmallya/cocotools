%DEMO PITCHFORK   Demonstrate handling of group events.

%% initialise continuation
clf;
opts = [];
mu   = 0.5;
al   = 0.1;
x0   = al+sqrt(mu);
p0   = [ mu ; al ];

opts = coco_set(opts, 'cont', 'LogLevel', 2);

% enable cleaning of data directory prior to computation
opts = coco_set(opts, 'all', 'CleanData', 1);

% add monitor functions for fold and degeneracy
opts = coco_add_func(opts, 'user:fold', 'alcont', @fold, [], ...
  'active', 'fold', 'vectorised', 'on');
opts = coco_add_func(opts, 'user:range', 'alcont', @range, [], ...
  'regular', 'ran', 'vectorised', 'on');

% add events for fold, degeneracy and branch points,
% use function bphan to communicate actions to be taken
opts = coco_add_event(opts, @bphan, 'fold', 0, 'ran', 0);

%% continuation in mu
bd = coco(opts, 'bp1', 'alcont', 'isol', 'sol', @pitchfork, ...
	x0, p0, {'PAR(1)' 'fold' 'ran'}, [-1, 1]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'X');
p = coco_bd_col(bd, 'PARS');
p = p(1,:);

plot(p, x, 'b-');
grid on

idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'ro', 'LineWidth', 2, 'MarkerSize', 6);
hold off

idx = find(strcmp('RN', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'ms', 'LineWidth', 2, 'MarkerSize', 6);
hold off

idx = find(strcmp('BP', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'kx', 'LineWidth', 2, 'MarkerSize', 6);
hold off

drawnow
