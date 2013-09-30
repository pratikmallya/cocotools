fprintf('**********************************\n\n');

%   [   m ;   Ff ; k ; om ;    a ;   b ;   e ]
p = [ 0.1 ; 0.05 ; 1 ; 10 ; 0.16 ; 0.1 ; 0.9 ];

load isol/isol1;

opts = coco_set('cont', 'LogLevel', 1, 'ItMX', 100);
opts = coco_set(opts, 'coll', 'vareqn', 'off');

opts = coco_add_func(opts, 'user:epval', 'hybrid', @epval, [], ...
  'active', 'x1', 'vectorised', 'on');
opts = coco_add_event(opts, 'UZ', 'x1', [0.6 0.7 0.8 0.9 1.0]);

bd = coco(opts, '1', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, 'PAR(5)', [0.15 0.5]); % [0.16 0.5]

par  = coco_bd_col(bd, 'PAR(5)');
nrmx = coco_bd_col(bd, '||U||');
subplot(2,1,1);
plot(par, nrmx, 'b.-');
grid on;
drawnow

subplot(2,1,2);
coll_plot('1', '', 'UZ', [1 2]);
grid on;
drawnow

%% test restart

opts = coco_set(opts, 'coll', 'vareqn', 'off');

bd = coco(opts, '2', 'hscont', 'ho', 'ho', ...
	'1', 8, 'PAR(5)', [0.16 0.5]);
