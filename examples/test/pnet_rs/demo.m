clf;
fprintf('\n******************************************\n');
fprintf('*** running demo pnet (resonance surfaces)\n\n');

%% 1:4 resonance surface

% p  = [ eps    B      T  ];
p0   = [11.5 ; 0.1 ; 4*pi ];

N    = 1;
segs = create_isol([0;1;0], p0, 1, 4, N, 40/N, 8);

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
% opts = coco_set(opts, 'pocont', 'bifurcations', 'on');
% opts = coco_set(opts, 'coll', 'vareqn', 'track');

opts = coco_set(opts, 'all', 'ContAlg' , @coverkd);

clf
grid on
axis([8 20 -2 2 0 0.5]);
% axis([-2 2 -1 1 0 0.5]);
view([30 30])
data.lt = 'b.';
data.mode = 1;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_ecb_update');
% data.lt = 'r.';
% data.mode = 2;
% opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
%   'fsm_ecb_predict');

opts = coco_set(opts, 'cont'    , 'NPR'      , 100  );
opts = coco_set(opts, 'cont'    , 'NSV'      , 200  );
opts = coco_set(opts, 'cont'    , 'ItMX'     , 6000 );
opts = coco_set(opts, 'cont'    , 'MaxRes'   , 2.0  );
opts = coco_set(opts, 'cont'    , 'al_max'   , 15   );
opts = coco_set(opts, 'cont'    , 'h0'       , 0.1  );
opts = coco_set(opts, 'cont'    , 'h_max'    , 2.0  );
opts = coco_set(opts, 'cont'    , 'h_min'    , 0.01 );

opts = coco_set(opts, 'cont', 'LogLevel', 4);
opts = coco_set(opts, 'nwtn', 'TOL',      1.0e-5);
opts = coco_set(opts, 'nwtn', 'SubItMX',  3);

% opts = coco_add_event(opts, 'UZ', 'PAR(1)', -12:2:12);

% [bd1 atlas1] = coco(opts, 'rs14', 'pocont', 'ipo', 'po', ...
%   @pnet, segs, p0, ...
%   2, {'PAR(1)' 'PAR(2)' 'Period'}, {[0 20] [0, 0.15] []});

[bd1 atlas1] = coco(opts, 'rs14', 'bvp', 'isol', 'sol', ...
  @pnet, segs, p0, ...
  2, {'PAR(1)' 'PAR(2)'}, {[0 20] [0 0.5]});

save rs14data bd1 atlas1

% coverkd_plotCovering(atlas1, 1, 1803, 2);

clf
[Tri X] = coverkd_triangulate(atlas1);
trimesh(Tri, X(:,1), X(:,1082), X(:,1083), ...
  'facecolor', 'interp', 'edgecolor', 'none');
% trimesh(Tri, X(:,1), X(:,2), X(:,1083), X(:,1082), ...
%   'facecolor', 'interp', 'edgecolor', 'none');

% z   = [bd1{2:end,8}];
% p   = [bd1{2:end,9}];
% nx  = z-mean(z);
% eps = p(1,:);
% B   = p(2,:);
% 
% clf
% plot3(nx, eps, B, 'g.');
% grid on
% 
% hold on
% idx = strcmp('EP', bd1(2:end,4));
% plot3(nx(idx), eps(idx), B(idx), 'r*');
% idx = strcmp('UZ', bd1(2:end,4));
% plot3(nx(idx), eps(idx), B(idx), 'y*');
% idx = strcmp('RO', bd1(2:end,4)); % | cellfun('isempty', bd1(2:end,4));
% plot3(nx(idx), eps(idx), B(idx), 'b*');
% hold off
% drawnow

%% 1:3 resonance surface

% p  = [ eps    B      T  ];
p0   = [7.05 ; 0.1 ; 3*pi ];

N    = 1;
segs = create_isol([0;1;0], p0, 1, 3, N, 20/N, 8);

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
% opts = coco_set(opts, 'pocont', 'bifurcations', 'on');
% opts = coco_set(opts, 'coll', 'vareqn', 'track');

opts = coco_set(opts, 'all', 'ContAlg' , @coverkd);

clf
grid on
axis([6.5 9 -2 2 0 0.5]);
% axis([-2 2 -1 1 0 0.5]);
view([30 30])
data.lt = 'b.';
data.mode = 1;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_ecb_update');
% data.lt = 'r.';
% data.mode = 2;
% opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
%   'fsm_ecb_predict');

opts = coco_set(opts, 'cont'    , 'NPR'      , 100  );
opts = coco_set(opts, 'cont'    , 'NSV'      , 200  );
opts = coco_set(opts, 'cont'    , 'ItMX'     , 6000 );
opts = coco_set(opts, 'cont'    , 'MaxRes'   , 2.0  );
opts = coco_set(opts, 'cont'    , 'al_max'   , 10   );
opts = coco_set(opts, 'cont'    , 'h0'       , 0.1  );
opts = coco_set(opts, 'cont'    , 'h_max'    , 1.0  );
opts = coco_set(opts, 'cont'    , 'h_min'    , 0.01 );

opts = coco_set(opts, 'cont', 'LogLevel', 4);
opts = coco_set(opts, 'nwtn', 'TOL',      1.0e-5);
opts = coco_set(opts, 'nwtn', 'SubItMX',  4);
opts = coco_set(opts, 'nwtn', 'ItMX',     15);

% opts = coco_add_event(opts, 'UZ', 'PAR(1)', -12:2:12);

% [bd1 atlas1] = coco(opts, 'rs14', 'pocont', 'ipo', 'po', ...
%   @pnet, segs, p0, ...
%   2, {'PAR(1)' 'PAR(2)' 'Period'}, {[0 20] [0, 0.15] []});

[bd1 atlas1] = coco(opts, 'rs13', 'bvp', 'isol', 'sol', ...
  @pnet, segs, p0, ...
  2, {'PAR(1)' 'PAR(2)'}, {[0 20] [0 0.5]});

save rs13data bd1 atlas1

% coverkd_plotCovering(atlas1, 1, 1803, 2);

clf
[Tri X] = coverkd_triangulate(atlas1);
trimesh(Tri, X(:,1), X(:,542), X(:,543), ...
  'facecolor', 'interp', 'edgecolor', 'none');
view([65 25])
