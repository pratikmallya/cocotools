function scan_demo()
%DEMO2   Demonstrate 3d-scanning and codim-one continuation.

%% initialise continuations for cusp manifold
opts = [];
x0   = -1;
p0   = [ 1 ; 1 ];
N    = 20; % use 20 <= N <= 200

% enable cleaning of data directory prior to computation
opts = coco_set(opts, 'all', 'CleanData', 1);

% add monitor functions for fold and degeneracy
opts = coco_add_func(opts, 'user:fold', 'alcont', @fold, [], ...
  'active', 'fold', 'vectorised', 'on');
opts = coco_add_func(opts, 'user:range', 'alcont', @range, [], ...
  'regular', 'ran', 'vectorised', 'on');

data_file = fullfile('data', 'cusp.mat');
if ~exist(data_file, 'file')
	% add events for restart points evenly spaced in lambda
	opts1 = coco_add_event(opts, 'UZ', 'PAR(2)', linspace(-1.5,1.5,N));
	opts1 = coco_set(opts1, 'cont', 'al_max',    1);
	opts1 = coco_set(opts1, 'cont', 'ItMX',   1000);
	opts1 = coco_set(opts1, 'cont', 'NPR',     100);

	%% compute initial solutions for scan
	bd = coco(opts1, 'scan', 'alcont', 'isol', 'sol', @cusp, ...
		x0, p0, 'PAR(2)', [-1.5001, 1.5]);

	%% perform scan of solution surface
	% compute restart labels
	idx = find(strcmp('UZ', { bd{2:end,4} }));
	uz_lab = [ bd{idx+1,6} ];

	X = []; Y = []; Z = [];
	for lab=uz_lab
		run = sprintf('scan_%d', lab);
		bd  = coco(opts1, run, 'alcont', 'sol', 'sol', ...
			'scan', lab, 'PAR(1)', [-1 1]);

		% add curve to surface data
		[xx yy zz] = interp_bd(bd, 200);
		X = [X ; xx]; %#ok<AGROW>
		Y = [Y ; yy]; %#ok<AGROW>
		Z = [Z ; zz]; %#ok<AGROW>
	end
	save(data_file, 'X', 'Y', 'Z');
else
	load(data_file, 'X', 'Y', 'Z');
end

%% illustration of pitchfork normal form
% plot mu=0 plane

clf;
plot_cuspm(X,Y,Z);

YP = linspace(-1.5, 1.5, N);
[YP ZP] = meshgrid(YP, YP);
XP = zeros(size(YP));

hold on
surf(XP, YP, ZP, 'FaceColor', 0.2*[1 1 1], ... %'b', ...
	'FaceAlpha', 0.8, 'LineStyle', 'none')
plot3(XP(:,end), YP(:,end), ZP(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(:,1), YP(:,1), ZP(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(end,:), YP(end,:), ZP(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(1,:), YP(1,:), ZP(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

YP = linspace(0, 1.5, round(N/2));
XP = zeros(size(YP));
ZP = sqrt(YP);
plot3(XP, YP, ZP, 'k-', 'LineWidth', 2.0);
plot3(XP, YP, -ZP, 'k-', 'LineWidth', 2.0);
plot3([0 0], [-1.5 1.5], [0 0], 'k-', 'LineWidth', 2.0);
hold off

drawnow

fprintf(2, '\npress any key to run two-parameter continuation\n');
pause

%% continuation of LP curve
clf;
plot_cuspm(X,Y,Z);

%% locate fold points for lambda=1
% add event for limit points
opts = coco_add_event(opts, 'LP', 'fold', 0);

bd = coco(opts, 'scan_lp', 'alcont', 'isol', 'sol', @cusp, ...
	0, [0 ; 1], 'PAR(1)', [-1, 1]);

plot_bd(bd, 'k-', 2);

% extract label of limit points
idx = find(strcmp('LP', { bd{2:end,4} }));
lab = [ bd{idx+1,6} ];

%% compute fold curve
% add event for branch points, note that branch points
% are generic along curves of folds
opts = coco_add_event(opts, 'BP', 'ran',  0);

% fix fold function and activate parameter mu
opts = coco_xchg_pars(opts, 'fold', 'PAR(1)');

bd = coco(opts, 'scan_lpc', 'alcont', 'sol', 'sol', ...
	'scan_lp', lab(1), {'PAR(2)' 'PAR(1)'}, [-1.5, 1.5]);

% add curve to bifurcation diagram
plot_bd(bd, 'k-', 3);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function for interpolating bifurcation diagram
function [mu la x] = interp_bd(bd, N)

idx = 1:size(bd,1);
% for i=idx(2:end)
% 	if bd{i,1}==2 && bd{i+1,1}==1
% 		idx = [idx(1:i) idx(i+2:end)];
% 		break
% 	end
% end
idx = idx(2:end);

x  = [bd{idx,10}];
p  = [bd{idx,11}];
mu = p(1,:);
la = p(2,:);

xx = [x ; la ; mu];
ds = xx(:,2:end)-xx(:,1:end-1);
ds = sqrt(sum(ds.*ds,1));
s  = [0 cumsum(ds,2)];
s  = s./s(end);

xx = interp1(s, xx', linspace(0,1,N))';

x  = xx(1,:);
la = xx(2,:);
mu = xx(3,:);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function for plotting bifurcation diagram
function plot_bd(bd, style, lw)

if nargin<2
	style = 'b-';
end

if nargin<3
	lw=1;
end

x  = [bd{2:end,10}];
p  = [bd{2:end,11}];
mu = p(1,:);
la = p(2,:);

hold on

plot3(mu, la, x, style, 'LineWidth', lw);

% idx = find(strcmp('UZ', { bd{2:end,4} }));
% plot3(mu(idx), la(idx), x(idx), 'gd', 'LineWidth', 2, 'MarkerSize', 6);
% 
% idx = find(strcmp('LP', { bd{2:end,4} }));
% plot3(mu(idx), la(idx), x(idx), 'ro', 'LineWidth', 2, 'MarkerSize', 6);
% 
% idx = find(strcmp('RN', { bd{2:end,4} }));
% plot3(mu(idx), la(idx), x(idx), 'ms', 'LineWidth', 2, 'MarkerSize', 6);

% idx = find(strcmp('BP', { bd{2:end,4} }));
% plot3(mu(idx), la(idx), x(idx), 'k+', 'LineWidth', 2, 'MarkerSize', 13);

hold off

drawnow

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function for plotting cusp manifold
function plot_cuspm(X,Y,Z)

surf(X, Y, Z, 'FaceColor', 0.8*[1 1 1], ... %'g', ...
	'FaceAlpha', 0.85, 'LineStyle', 'none')

hold on

plot3(X(:,end), Y(:,end), Z(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(:,1), Y(:,1), Z(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(end,:), Y(end,:), Z(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(1,:), Y(1,:), Z(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

meshidx = round(linspace(1,size(X,2),20));
meshidx = meshidx(2:end-1);
for i=meshidx
	plot3(X(:,i), Y(:,i), Z(:,i), 'Color', 0.7*[1 1 1], ...
		'LineWidth', 0.5);
end

meshidx = round(linspace(1,size(X,1),20));
meshidx = meshidx(2:end-1);
for i=meshidx
	plot3(X(i,:), Y(i,:), Z(i,:), 'Color', 0.7*[1 1 1], ...
		'LineWidth', 0.5);
end

hold off

view([60 15]);
axis([-1 1 -1.5 1.5 -1.5 1.5]);

lighting phong; % flat gouraud phong
light('Position',[0.5 0.5 0], 'Color',   0.5*[1 1 1],'Style','local');
light('Position',[1 1.5 -0.5], 'Color',   0.5*[1 1 1],'Style','infinite');
light('Position',[-1 -1.5 1], 'Color',   0.5*[1 1 1],'Style','infinite');
light('Position',[1 -1.5 0.5], 'Color',   0.7*[1 1 1],'Style','infinite');

drawnow;
