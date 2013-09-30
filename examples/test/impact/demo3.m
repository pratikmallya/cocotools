fprintf('**********************************\n\n');

%%
% plot: k-b

%   [ m ; Ff ; k ; om ; a ; b ; e ]
p = [ 1 ; 0.7961 ; 5.5 ; 1  ; 1 ; 0.8471 ; 0.9 ];

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

opts = coco_add_event(opts, 'UZ', 'PAR(3)', [0:.1:10]);

%%
load isol/isol4;

bd1 = coco(opts, '1', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, 'PAR(3)', [5.4 5.8]);

labs = [bd1{2:end,6}];
cla;
grid on;
hold on;
for lab=labs
	solfname = fullfile('data', '1', sprintf('sol%d', lab));
	load(solfname,'data','sol');
  sol1 = data{1,2}.sol;
  plot3(sol1.xcp(1,:)*sol.p(6)/sol.p(5), mod(sol1.xcp(3,:),2*pi), sol1.xcp(2,:),  'g.-');
end
hold off;


idx = find(strcmp('SS', { bd1{2:end,4} }));
solfname = fullfile('data', '1', sprintf('sol%d', bd1{idx+1,6}));
load(solfname, 'data','sol')
sol1 = data{1,2}.sol;
hold on
plot3(sol1.xcp(1,:)*sol.p(6)/sol.p(5), mod(sol1.xcp(3,:),2*pi), sol1.xcp(2,:),  'r.-');
hold off
p=sol.p(4:end);

%%
load isol/isol5;

bd2 = coco(opts, '2', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, {'PAR(6)' 'PAR(3)'}, [.5 .88]);

labs = [bd2{2:end,6}];
cla;
grid on;
hold on;
for lab=labs
	solfname = fullfile('data', '2', sprintf('sol%d', lab));
	load(solfname,'data','sol');
  sol1 = data{1,2}.sol;
  plot3(sol1.xcp(1,:)*sol.p(6)/sol.p(5), mod(sol1.xcp(3,:),2*pi), sol1.xcp(2,:),  'g.-');
end
hold off;

idx = find(strcmp('GZ', { bd2{2:end,4} }));
solfname = fullfile('data', '2', sprintf('sol%d', bd2{idx+1,6}));
load(solfname, 'data','sol')
sol1 = data{1,2}.sol;
hold on
plot3(sol1.xcp(1,:)*sol.p(6)/sol.p(5), mod(sol1.xcp(3,:),2*pi), sol1.xcp(2,:),  'r.-');
hold off
p=sol.p(4:end);

opts = coco_xchg_pars(opts, 'graze', 'switch');

%%
load isol/isol6;

bd3 = coco(opts, '3', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, {'PAR(6)' 'PAR(3)'}, [.5 0.661428093236418]);

labs = [bd3{2:end,6}];
cla;
grid on;
hold on;
for lab=labs
  solfname = fullfile('data', '3', sprintf('sol%d', lab));
  load(solfname,'data','sol');
  sol1 = data{1,2}.sol;
  sol.p(1:3)'
  plot3(sol1.xcp(1,:)*sol.p(6)/sol.p(5), mod(sol1.xcp(3,:),2*pi), sol1.xcp(2,:),  'g.-');
end
hold off;

%%
opts = coco_xchg_pars(opts, 'PAR(3)', 'switch');

bd4 = coco(opts, '4', 'hscont', 'iho', 'ho', @imp, ...
	seglist, p, {'PAR(4)' 'PAR(6)' 'PAR(3)'}, [1 1.1]);
