f = @(x,p) (p(1)^2+p(2)^2-1)*((p(1)-1)^2+p(2)^2-1);

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'x' 'y'});

%% compute first circle, branch '1'
opts = coco_set(opts, 'cont', 'ItMX', 25);
bd1  = coco(opts, {'circle' '1'}, 'curve', 'sol', 'sol', ...
  f, [], [0 ; 1], {'x' 'y'}, [-2 2]);

% plot bifurcation diagram
u  = coco_bd_col(bd1, {'x' 'y'});
clf
plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow

%% compute remaining part of circle, branch '2'
labs = coco_bd_labs(bd1, 'EP');
opts = coco_set(opts, 'cont', 'ItMX', [0 30]);
bd2  = coco(opts, {'circle' '2'}, 'curve', 'sol', 'sol', ...
  {'circle' '1'}, labs(end), {'x' 'y'}, [-2 2]);

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'x' 'y'});
hold on
plot(u(1,:), u(2,:), 'g.-')
hold off
grid on
drawnow

%% compute intersecting circle, branch '3'
labs = coco_bd_labs(bd1, 'BP');
opts = coco_set(opts, 'cont', 'ItMX', 50);
bd3  = coco(opts, {'circle' '3'}, 'curve', 'BP', 'sol', ...
  {'circle' '1'}, labs(1), {'x' 'y'}, [-2 2]);

% plot bifurcation diagram
u  = coco_bd_col(bd3, {'x' 'y'});
hold on
plot(u(1,:), u(2,:), '.-')
hold off
grid on
drawnow
