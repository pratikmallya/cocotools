
fprintf('********************\n\n');
clf;

opts = [];

% opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
%   'internal', 'H', 'vectorised', 'on');
% 
% opts = coco_add_event(opts, 'UZ', 'H',  0);

opts = coco_set(opts, 'all', 'CleanData', 1);

bd1 = coco(opts, '1', 'cac', 'isol', 'sol', {@f1,@f2}, ...
	{[0.4],[-0.4]}, {[],[],[0;0.5;0]}, 'PAR(2)', [0.1, 2]); %#ok<NBRAK>

z = coco_bd_col(bd1, 'item1.X');
p = coco_bd_col(bd1, 'item1.PARS');
x = p(1,:);
y = p(2,:);
plot3(x, y, z, 'b.-');
grid on
view([90 0]);
axis([-4 4 0 4 -4 4])
drawnow

z = coco_bd_col(bd1, 'item2.X');
p = coco_bd_col(bd1, 'item2.PARS');
x = p(1,:);
y = p(2,:);
hold on
plot3(x, y, z, 'b.-');
hold off
drawnow

bd2 = coco(opts, '2', 'cac', 'sol', 'sol', ...
  '1', 2, ...
  'PAR(2)', [2 4]);

z = coco_bd_col(bd2, 'item1.X');
p = coco_bd_col(bd2, 'item1.PARS');
x = p(1,:);
y = p(2,:);
hold on
plot3(x, y, z, 'r.-');
hold off
drawnow

z = coco_bd_col(bd2, 'item2.X');
p = coco_bd_col(bd2, 'item2.PARS');
x = p(1,:);
y = p(2,:);
hold on
plot3(x, y, z, 'r.-');
hold off
drawnow

% idx = find(strcmp('UZ', { bd1{2:end,4} }));
% lab = [ bd1{idx+1,6} ];
% hold on
% plot3(x(idx), y(idx), z(idx), 'go', 'LineWidth', 2, 'MarkerSize', 10);
% hold off
% drawnow
% 
% fprintf('\n');
% 
% opts = coco_add_event(opts, 'UZ', 'PAR(3)', (-3:3)*pi/32);
% 
% bd2 = coco(opts, 'sec', 'alcont', 'sol', 'sol', ...
% 	'x', lab, {'PAR(3)' 'PAR(2)'}, [-pi/8 pi/8]);
% 
% z = [bd2{2:end,10}];
% p = [bd2{2:end,11}];
% x = p(1,:);
% y = p(2,:);
% idx = find(strcmp('UZ', { bd2{2:end,4} }));
% lab = [ bd2{idx+1,6} ];
% hold on
% plot3(x(idx), y(idx), z(idx), 'ro', 'LineWidth', 2);
% hold off
% drawnow
% 
% opts = coco_set(opts, 'cont', 'ItMX', [30 30]);
% 
% for i=1:numel(lab)
% 	fprintf('\n');
% 	run = sprintf('sec_%d', lab(i));
% 	
% 	bd3 = coco(opts, run, 'alcont', 'sol', 'sol', ...
% 		'sec', lab(i), {'PAR(1)' 'PAR(2)'}, [-2 2]);
% 
% 	z = [bd3{2:end,10}];
% 	p = [bd3{2:end,11}];
% 	x = p(1,:);
% 	y = p(2,:);
% 	hold on
% 	plot3(x, y, z, 'g.-');
% 	hold off
% 	grid on;
% 	drawnow
% end
