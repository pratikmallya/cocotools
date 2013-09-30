% par = [ x ; y ; alpha ]

fprintf('********************\n');
clf;
% rmdir('data', 's');

opts = [];
opts = coco_set(opts, 'all', 'CleanData', 1);

opts = coco_add_func_after(opts, 'alcont', @add_plane);

opts = coco_add_event(opts, 'UZ', 'H',  0);

% opts = coco_set(opts, 'cont', 'corrector', 'fsolve');
% opts = coco_set(opts, 'cont', 'corrector', 'broyden');
% opts = coco_set(opts, 'cont', 'fsm_debug', 'on');
% opts = coco_set(opts, 'cont', 'LogLevel', 1);
% opts = coco_set(opts, 'cont', 'NPR', 1);

bd1 = coco(opts, 'x', 'alcont', 'isol', 'sol', @cone, ...
	[0.4], [0;0.5;0], 'PAR(2)', [0.1, 2]); %#ok<NBRAK>

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

opts = coco_add_event(opts, 'UZ', 'PAR(3)', (-3:3)*pi/32);

bd2 = coco(opts, 'sec', 'alcont', 'sol', 'sol', ...
	'x', lab, {'PAR(3)' 'PAR(2)'}, [-pi/8 pi/8]);

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
	run = sprintf('sec_%d', lab(i));
	
	bd3 = coco(opts, run, 'alcont', 'sol', 'sol', ...
		'sec', lab(i), {'PAR(1)' 'PAR(2)'}, [-2 2]);

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
