clf;

N = 8;
segs = create_isol(N, 80/N, 4);

hold on
for i=1:length(segs)
	plot(segs(i).x0(1,:), segs(i).x0(2,:), 'b.-');
end
hold off
grid on

opts = coco_set('coll', 'NTST', 80, 'NCOL', 4);
opts = coco_set(opts, 'pocont', 'bifurcations', 'on');
% opts = coco_set(opts, 'coll', 'vareqn', 'track');
% opts = coco_set(opts, 'coll', 'vareqn', 'on');

opts = coco_set(opts, 'cont', 'NPR', 200);
opts = coco_set(opts, 'cont', 'NSV', 200);
opts = coco_set(opts, 'cont', 'ItMX', 300);
% opts = coco_set(opts, 'nwtn', 'TOL', 1.0e-5);
% opts = coco_set(opts, 'nwtn', 'SubItMX', 3);
opts = coco_set(opts, 'corr', 'TOL', 1.0e-5);
opts = coco_set(opts, 'corr', 'SubItMX', 3);
% opts = coco_set(opts, 'cont', 'LogLevel', 3, 'NPR', 1);
% opts = coco_set(opts, 'cont', 'LogLevel', 3);

opts = coco_add_event(opts, 'UZ', 'PAR(1)', -12:2:12);

opts = coco_set(opts, 'cont', 'covering', @cover_1d_min_ev.create);

hom_opts = [];
hom_opts = coco_set(hom_opts, 'cont', 'beta0', 1);
hom_opts = coco_set(hom_opts, 'cont', 'beta_int', [0 1]);
hom_opts = coco_set(hom_opts, 'cont', 'ItMX', 1000);
hom_opts = coco_set(hom_opts, 'cont', 'h'   ,    1);
hom_opts = coco_set(hom_opts, 'cont', 'LogLevel', 3, 'NPR', 1);
coco_set(opts, 'cont', 'hom_opts', hom_opts);

bd1 = coco(opts, 'numdat', 'pocont', 'ipo', 'po', @pneta, ...
	segs, 0.5, {'PAR(1)' 'Period'}, [-12, 12]);

t2 = linspace(0,1,100);
x2 = stpnt(1, t2);
hold on
plot(x2(1,:), x2(2,:), 'r.-');
hold off
drawnow
return

bd2 = coco(opts, 'stpnt', 'pocont', 'ipo', 'po', @pneta, ...
	@stpnt, 0.5, 'PAR(1)', [-12, 12]);

par  = coco_bd_col(bd2, 'PAR(1)');
nrmx = coco_bd_col(bd2, '||U||');
subplot(2,1,1);
plot(par, nrmx, 'b.-');
grid on;
drawnow

subplot(2,1,2);
coll_plot('numdat', '', 'all', [1 2]);
grid on;
drawnow

%% test restart

opts = coco_set(opts, 'pocont', 'bifurcations', 'off');
opts = coco_set(opts, 'coll', 'vareqn', 'off');

bd3 = coco(opts, 'restart', 'pocont', 'po', 'po', ...
	'numdat', 3, 'PAR(1)', [3 10]);

%% print multipliers

multipliers(bd1, 'numdat');
multipliers(bd2, 'stpnt');
