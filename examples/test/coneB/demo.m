% par = [ z ; x ; y ; alpha ]

fprintf('********************\n\n');
clf;

opts = [];

opts = coco_add_func(opts, 'user:cone', 'alcont', @cone, [], ...
  'active', 'G', 'vectorised', 'on');

% G = 0 is a zero-problem
opts = coco_set_parival(opts, 'G', 0);
opts = coco_xchg_pars(opts, 'G', 'PAR(1)');

opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
  'active', 'H', 'vectorised', 'on');

opts = coco_add_event(opts, 'UZ', 'H', 0);
opts = coco_set(opts, 'cont', 'LogLevel', 1);

bd1 = coco(opts, 'ray1', 'alcont', 'isol', 'sol', [], ...
	[], [0.4;0;0.5;0], {'PAR(3)' 'H' 'G'}, [0.1, 2]);

% reset initial values for subsequent runs
opts = coco_set_parival(opts, []);

p = coco_bd_col(bd1, 'PARS');
z = p(1,:);
x = p(2,:);
y = p(3,:);
plot3(x, y, z, 'b.-');
grid on
drawnow

idx = find(strcmp('UZ', coco_bd_col(bd1, 'TYPE') ));
lab = coco_bd_labs(bd1, 'UZ');
hold on
plot3(x(idx), y(idx), z(idx), 'go', 'LineWidth', 2);
hold off
drawnow

opts = coco_xchg_pars(opts, 'G', 'H');
opts = coco_add_event(opts, 'UZ', 'G', 0);

bd2 = coco(opts, 'sec', 'alcont', 'sol', 'sol', ...
	'ray1', lab, {'PAR(3)' 'H' 'G'}, [-2 2]);

p = coco_bd_col(bd2, 'PARS');
z = p(1,:);
x = p(2,:);
y = p(3,:);
hold on
plot3(x, y, z, 'k.-');
hold off

idx = find(strcmp('UZ', coco_bd_col(bd2, 'TYPE') ));
lab = coco_bd_labs(bd2, 'UZ');
hold on
plot3(x(idx), y(idx), z(idx), 'ro', 'LineWidth', 2);
hold off
drawnow

opts = coco_xchg_pars(opts, 'G', 'H');

bd3 = coco(opts, 'ray2', 'alcont', 'sol', 'sol', ...
	'sec', lab(1), {'PAR(3)' 'H' 'G'}, [-2 -0.1]);

p = coco_bd_col(bd3, 'PARS');
z = p(1,:);
x = p(2,:);
y = p(3,:);
hold on
plot3(x, y, z, 'b.-');
hold off
drawnow
