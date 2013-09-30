fprintf('**********************************\n\n');

%   [   m ;   Ff   ; k ; om ;    a ;   b    ;   e ]
p = [   1 ; 0.7961 ; 8 ; 1  ;    1 ; 0.8471 ; 0.9 ];

load isol/isol3;

opts = coco_set('cont', 'LogLevel', 1, 'ItMX', [100 100]);

opts = coco_add_func(opts, 'user:turning2', 'hybrid', @turning2, [], ...
  'active', 'graze', 'vectorised', 'on');
opts = coco_add_event(opts, 'GZ', 'graze',  0);

opts = coco_add_func(opts, 'user:switching', 'hybrid', @switching, [], ...
  'singular', 'switch', 'vectorised', 'on');
opts = coco_add_event(opts, 'SS', 'switch',  0);

bd = coco(opts, '1', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, 'PAR(3)', [3 10]);

par  = [bd{2:end,7}];
nrmx = [bd{2:end,8}];
subplot(2,1,1);
plot(par, nrmx, 'b.-');
grid on;
drawnow

labs = [bd{2:end,6}];
subplot(2,1,2);
cla;
grid on;
hold on;
for lab=9
	solfname = fullfile('data', '1', sprintf('sol%d', lab));
	load(solfname, 'data');
  sol = data{1,2}.sol;
% 	plot(sol.xcp(1,:), sol.xcp(2,:), 'b.-');
    plot3(sol.xcp(1,:), mod(sol.xcp(3,:),2*pi), sol.xcp(2,:),  'g.-');
end
hold off;
