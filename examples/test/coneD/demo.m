% par = [ x ; y ; alpha ]

fprintf('********************\n\n');
clf;
% rmdir('data', 's');

opts = [];

opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
  'internal', 'H', 'vectorised', 'on');

opts = coco_add_event(opts, 'UZ', 'H',  0);
opts = coco_set(opts, 'all', 'CleanData', 1);

opts1 = alcont_isol2sol(opts, '', @cone, [0.4], [0;0.5;0]); %#ok<NBRAK>
bd1   = coco(opts1, 'x', [], 'PAR(2)', [0.1, 2]);

z = coco_bd_col(bd1, 'X');
p = coco_bd_col(bd1, 'PARS');
x = p(1,:);
y = p(2,:);
plot3(x, y, z, 'b.-');
grid on
view([95 10]);
drawnow

idx = find(strcmp('UZ', coco_bd_col(bd1, 'TYPE') ));
lab = coco_bd_labs(bd1, 'UZ');
hold on
plot3(x(idx), y(idx), z(idx), 'go', 'LineWidth', 2, 'MarkerSize', 10);
hold off
drawnow

opts  = coco_add_event(opts, 'UZ', 'PAR(3)', (-3:3)*pi/32);

opts2 = alcont_sol2sol(opts, '', 'x', lab);
bd2   = coco(opts2, 'sec', [], {'PAR(3)' 'PAR(2)'}, [-pi/8 pi/8]);

z = coco_bd_col(bd2, 'X');
p = coco_bd_col(bd2, 'PARS');
x = p(1,:);
y = p(2,:);
idx = find(strcmp('UZ', coco_bd_col(bd2, 'TYPE') ));
lab = coco_bd_labs(bd2, 'UZ');
hold on
plot3(x(idx), y(idx), z(idx), 'ro', 'LineWidth', 2);
hold off
drawnow

opts = coco_set(opts, 'cont', 'ItMX', [40 40]);

for i=1:numel(lab)
	fprintf('\n');
	run = sprintf('sec_%d', lab(i));
	
  opts3 = alcont_sol2sol(opts, '', 'sec', lab(i));
	bd3   = coco(opts3, run, [], {'PAR(1)' 'PAR(2)'}, [-2 2]);

  z = coco_bd_col(bd3, 'X');
  p = coco_bd_col(bd3, 'PARS');
	x = p(1,:);
	y = p(2,:);
	hold on
	plot3(x, y, z, 'g.-');
	hold off
	grid on;
	drawnow
end
