function demo_bifpoints()
%DEMO_BIFPOINTS   Demonstrate handling of group events.

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

% add events for fold, degeneracy and branch points,
% use function bphan to communicate actions to be taken
opts = coco_add_event(opts, @bphan, 'fold', 0, 'ran', 0);

%% continuation in mu
bd = coco(opts, 'bp1', 'alcont', 'isol', 'sol', @cusp, ...
	x0, p0, 'PAR(1)', [-1, 1]);

% plot bifurcation diagram
plot_bd(bd, 1, 1)

%% continuation in lambda
bd = coco(opts, 'bp2', 'alcont', 'isol', 'sol', @cusp, ...
	x0, p0, 'PAR(2)', [-1, 1]);

% plot bifurcation diagram
plot_bd(bd, 2, 2)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function for plotting bifurcation diagram
function plot_bd(bd, pidx, pw)

subplot(2,1,pw)

x = coco_bd_col(bd, 'X');
p = coco_bd_col(bd, 'PARS');
p = p(pidx,:);

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
