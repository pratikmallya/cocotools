clc % clear command window

%% set initial parameters and define test functions

%   [ m ;     Ff ;   k ; om ; a ;      b ;   e ]
p = [ 1 ; 0.7961 ; 5.5 ;  1 ; 1 ; 0.8471 ; 0.9 ];

opts = coco_set('cont', 'LogLevel', 1, 'ItMX', [100 100]);

opts = coco_add_func(opts, 'user:turning2', 'hybrid', @turning2, [], ...
  'active', 'graze', 'vectorised', 'on');
opts = coco_add_event(opts, 'GZ', 'graze',  0);

opts = coco_add_func(opts, 'user:switching', 'hybrid', @switching, [], ...
  'internal', 'switch', 'vectorised', 'on');
opts = coco_add_event(opts, 'SS', 'switch',  0);

opts = coco_add_func(opts, 'user:crossing', 'hybrid', @crossing, [], ...
  'active', 'cross', 'vectorised', 'on');
opts = coco_add_event(opts, 'CR', 'cross',  0);


% define general computational boundaries
% opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(3)', '<', 2.5 );
opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(3)', '>', 6.5 );
opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(4)', '<', 0.93);
opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(4)', '>', 1.1 );
opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(6)', '<', 0.5 );
% opts = coco_add_event(opts, 'GCB', 'BP', 'PAR(6)', '>', 0.9 );

%% compute initial hybrid periodic orbit

load isol/isol4;

bd1 = coco(opts, '1', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, {'PAR(3)' 'switch' 'PAR(6)' 'PAR(4)'}, [5.4 5.8]);

%% branch-switch at switching-sliding point, compute curve of
%  switching-sliding orbits

idx  = find(strcmp('SS', { bd1{2:end,4} }));
rlab = bd1{idx+1,6};

% set events for initial points of scans
opts = coco_add_event(opts, 'IPS', 'PAR(6)',  linspace(0.5, 0.9, 10));
opts = coco_add_event(opts, 'IPS', 'PAR(3)',  linspace(2.5, 6.5, 10));

bd2 = coco(opts, '2', 'hscont', 'ho', 'ho', ...
	'1', rlab, {'PAR(6)' 'PAR(3)' 'PAR(4)'}, [.5 .9]);

%% scan switching-sliding surface

idxs  = [1 find(strcmp('IPS', { bd2{2:end,4} }))] + 1;
rlabs = [bd2{idxs,6}];
i     = 1;

for rlab=rlabs
	run = sprintf('2_%d', rlab);
	bd2s1{i} = coco(opts, run, 'hscont', 'ho', 'ho', ...
		'2', rlab, {'PAR(4)' 'PAR(6)' 'PAR(3)'}, [0.9 1.1]);  %#ok<SAGROW>
	bd2s2{i} = coco(opts, run, 'hscont', 'ho', 'ho', ...
		'2', rlab, {'PAR(4)' 'PAR(3)' 'PAR(6)'}, [0.9 1.1]);  %#ok<SAGROW>
	i = i+1;
end

%% branch-switch at grazing point, compute curve of
%  grazing orbits

idx  = find(strcmp('GZ', { bd2{2:end,4} }));
rlab = bd2{idx+1,6};

% continue grazing curve
opts = coco_xchg_pars(opts, 'graze', 'switch');

bd3 = coco(opts, '3', 'hscont', 'ho', 'ho', ...
	'2', rlab, {'PAR(6)' 'PAR(3)' 'PAR(4)'}, [0.5 0.9]);

%% branch switch at grazing point again, compute curve of
%  grazing-switching-sliding orbits

% continue switching-sliding-grazing curve (codim-3)
opts = coco_xchg_pars(opts, 'PAR(3)', 'switch');

bd4 = coco(opts, '4', 'hscont', 'ho', 'ho', ...
	'2', rlab, {'PAR(4)' 'PAR(6)' 'PAR(3)'}, [0.93 1.5]);

%% scan grazing surface

% continue grazing curves
opts = coco_xchg_pars(opts, 'PAR(3)', 'switch');

idxs  = [1 find(strcmp('IPS', { bd4{2:end,4} }))] + 1;
rlabs = [bd4{idxs,6}];
i     = 1;

for rlab=rlabs
	run  = sprintf('2_%d', rlab);
	pars = bd4{idxs(i), 9};
	bd4s1{i} = coco(opts, run, 'hscont', 'ho', 'ho', ...
		'4', rlab, {'PAR(4)' 'PAR(6)' 'PAR(3)'}, [0.9 1.1]); %#ok<SAGROW>
	bd4s2{i} = coco(opts, run, 'hscont', 'ho', 'ho', ...
		'4', rlab, {'PAR(4)' 'PAR(3)' 'PAR(6)'}, [0.9 1.1]); %#ok<SAGROW>
	i = i+1;
end

%% extract data from bifurcation diagrams and plot curves and surfaces

clf

cpo    = [ bd1{2:end,9} ; bd1{2:end,8} ]; % k switch b om ||x||
cpo_pt = { bd1{2:end,4} };
idx    = find(strcmp('SS', cpo_pt));
p0     = cpo([1 3 4], idx(1));

css    = [ bd2{2:end,9} ]; % b k om
css_pt = { bd2{2:end,4} };
idx    = find(strcmp('GZ', css_pt));
cgz    = [ bd3{2:end,9} ]; % b k om
cgz_pt = { bd3{2:end,4} };

ccd3   = [ bd4{2:end,9} ]; % om b k

[k  b  om ] = rec_srf(bd2s1, bd2s2, 200);
[k2 b2 om2] = rec_srf(bd4s1, bd4s2, 200);

XP      = linspace(2.5, 6.5, 200);
YP      = linspace(0.5, 0.9, 200);
[XP YP] = meshgrid(XP, YP);
ZP      = ones(size(XP,1),size(YP,2));

% plot k-b-om
plot3(css(2,:),  css(1,:),  css(3,:),  'k-',  'linewidth', 1)
hold on
plot3(cgz(2,:),  cgz(1,:),  cgz(3,:),  'k--', 'linewidth', 1)
plot3(ccd3(3,:), ccd3(2,:), ccd3(1,:), 'k-',  'linewidth', 2)
hold off
axis([2.3 6.7 0.45 0.95 0.9 1.13]);
% view(-30, 15)
% view(-10, 15)
% view(-15, 30)
view(55, 60)
grid on

% hold on
% plot_crv(bd2s1, bd2s2);
% plot_crv(bd4s1, bd4s2);
% hold off

hold on
surf(XP, YP, ZP, 'FaceColor', 0.1*[1 1 1], ... %'b', ...
	'FaceAlpha', 0.6, 'LineStyle', 'none')
plot3(XP(:,end), YP(:,end), ZP(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(:,1), YP(:,1), ZP(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(end,:), YP(end,:), ZP(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XP(1,:), YP(1,:), ZP(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

surf(k, b, om, 'FaceColor', 0.65*[1 1 1], ...
	'FaceAlpha', 0.8, 'LineStyle', 'none');
plot3(k(:,end), b(:,end), om(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k(:,1), b(:,1), om(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k(end,:), b(end,:), om(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k(1,:), b(1,:), om(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

surf(k2, b2, om2, 'FaceColor', 0.9*[1 1 1], ...
	'FaceAlpha', 0.8, 'LineStyle', 'none');
plot3(k2(:,end), b2(:,end), om2(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k2(:,1), b2(:,1), om2(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k2(end,:), b2(end,:), om2(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(k2(1,:), b2(1,:), om2(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

hold off

% lighting phong; % flat gouraud phong
% light('Position', [8 0.7 1.00], 'Color', 0.5*[1 1 1], 'Style', 'local');
% light('Position', [8 0.7 1.05], 'Color', 0.3*[1 1 1], 'Style', 'local');
% light('Position', [3 0.9 0.94], 'Color', 0.2*[1 1 1], 'Style', 'local');

% print('-depsc', '-r150', 'impact_codim3.eps');
