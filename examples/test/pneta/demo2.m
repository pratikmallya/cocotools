% switchpath
clf

eps0 = -0.05;
N = 8;
segs = create_isol(N, 80/N, 4, eps0, 100);

hold on
for i=1:length(segs)
	plot(segs(i).x0(1,:), segs(i).x0(2,:), 'b.-');
end
hold off
grid on

opts = coco_set('coll', 'NTST', 80, 'NCOL', 4);
% opts = coco_set(opts, 'pocont', 'bifurcations', 'on');
opts = coco_set(opts, 'coll', 'vareqn', 'track');
% opts = coco_set(opts, 'coll', 'vareqn', 'on');

opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'NSV', 200);
% opts = coco_set(opts, 'cont', 'ItMX', 300);
opts = coco_set(opts, 'cont', 'ItMX', [1 0]);
% opts = coco_set(opts, 'cont', 'ItMX', 1);
opts = coco_set(opts, 'cont', 'LogLevel', 1);
opts = coco_set(opts, 'nwtn', 'TOL', 1.0e-5);
opts = coco_set(opts, 'nwtn', 'SubItMX', 3);

opts = coco_add_event(opts, 'UZ', 'PAR(1)', -12:2:12);

bd1 = coco(opts, 'numdat', 'pocont', 'ipo', 'po', @pneta, ...
	segs, eps0, {'PAR(1)' 'Period'}, [-12, 12]);

% eps = x(2409)
