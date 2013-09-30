function demo_scan()
%DEMO_SCAN   Demonstrate 3d-scanning and codim-one continuation.

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

% add events for restart points evenly spaced in lambda
opts1 = coco_add_event(opts, 'UZ', 'PAR(2)', linspace(-1,1,10));

%% compute initial solutions for scan
bd = coco(opts1, 'scan', 'alcont', 'isol', 'sol', @cusp, ...
	x0, p0, 'PAR(2)', [-1.01, 1.01]);

% plot bifurcation diagram
plot_bd(bd)

%% perform scan of solution surface
% compute restart labels
uz_lab = coco_bd_labs(bd, 'UZ');
% opts = coco_set(opts, 'cont', 'LogLevel', 3);
% opts = coco_set(opts, 'cont', 'ItMX', [0]);

for lab=uz_lab
	run = sprintf('scan_%d', lab);
	bd  = coco(opts, run, 'alcont', 'sol', 'sol', ...
		'scan', lab, 'PAR(1)', [-1 1]);
	
	% add curve to bifurcation diagram
	plot_bd(bd);
end

%% locate fold points for lambda=1
% add event for limit points
opts = coco_add_event(opts, 'LP', 'fold', 0);

bd = coco(opts, 'scan_lp', 'alcont', 'isol', 'sol', @cusp, ...
	x0, p0, 'PAR(1)', [-1, 1]);

% extract label of limit points
lab = coco_bd_labs(bd, 'LP');

%% compute fold curve
% add event for branch points, note that branch points
% are generic along curves of folds
opts = coco_add_event(opts, 'BP', 'ran',  0);

% fix fold function and activate parameter mu
opts = coco_xchg_pars(opts, 'fold', 'PAR(1)');

bd = coco(opts, 'scan_lpc', 'alcont', 'sol', 'sol', ...
	'scan_lp', lab(1), {'PAR(2)' 'PAR(1)'}, [-1, 1]);

% add curve to bifurcation diagram
plot_bd(bd, 'r-', 2);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function for plotting bifurcation diagram
function plot_bd(bd, style, lw)

if nargin<2
	style = 'b-';
end

if nargin<3
	lw=1;
end

x  = coco_bd_col(bd, 'X');
p  = coco_bd_col(bd, 'PARS');
mu = p(1,:);
la = p(2,:);

hold on

plot3(mu, la, x, style, 'LineWidth', lw);

idx = find(strcmp('UZ', coco_bd_col(bd, 'TYPE') ));
plot3(mu(idx), la(idx), x(idx), 'gd', 'LineWidth', 2, 'MarkerSize', 6);

idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE') ));
plot3(mu(idx), la(idx), x(idx), 'ro', 'LineWidth', 2, 'MarkerSize', 6);

idx = find(strcmp('RN', coco_bd_col(bd, 'TYPE') ));
plot3(mu(idx), la(idx), x(idx), 'ms', 'LineWidth', 2, 'MarkerSize', 6);

idx = find(strcmp('BP', coco_bd_col(bd, 'TYPE') ));
plot3(mu(idx), la(idx), x(idx), 'kx', 'LineWidth', 2, 'MarkerSize', 8);

hold off
grid on
view([60 20])
drawnow
