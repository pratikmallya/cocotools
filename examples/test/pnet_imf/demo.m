clf;
fprintf('\n******************************************\n');
fprintf('*** running demo pnet (invariant tori)\n\n');

%% 1:4 resonance surface

% p  = [ eps    B      T  ];
p0   = [11.5 ; 0.1 ; 4*pi ];

N    = 4;
segs = create_isol([0;1;0;1], p0, 1, 4, N, 120/N, 4);

clf
hold on
for i=1:length(segs)
	plot(segs(i).x0(1,:), segs(i).x0(2,:), 'b.-');
  plot(segs(i).x0(1,1), segs(i).x0(2,1), 'ro');
end
plot(segs(1).x0(1,1), segs(1).x0(2,1), 'y*');
hold off
grid on

opts = coco_set('coll', 'NTST', 80, 'NCOL', 4);

opts = coco_set(opts, 'cont', 'NPR' , 10);
opts = coco_set(opts, 'cont', 'ItMX', 70);

% opts = coco_set(opts, 'nwtn', 'TOL',      1.0e-5);
% opts = coco_set(opts, 'nwtn', 'SubItMX',  3);

bd1 = coco(opts, 'po14', 'mh_imfcont', 'imf', 'mf', ...
  @pnet, segs, p0, ...
  {'PAR(1)' 'PAR(2)'}, {[0 20]});

subplot(2,1,1)
p = coco_bd_col(bd1, 'PAR(1)');
x = coco_bd_col(bd1, '||U||');
plot(p, x, 'b.');
grid on

subplot(2,1,2)
coll_plot('po14', '', 1, [1 2 3]);
grid on
view([-20 45])

%% test restart constructor, start at initial solution again
opts = coco_set(opts, 'cont', 'ItMX', 10 );
bd2 = coco(opts, 'po14b', 'mh_imfcont', 'mf', 'mf', ...
  'po14', 1, ...
  {'PAR(1)' 'PAR(2)'}, {[0 20]});
