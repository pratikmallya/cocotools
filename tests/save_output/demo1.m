echo on
%start1
f = @(x,p) (p(1)^2+p(2)^2-1)*((p(1)-1)^2+p(2)^2-1);
opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'x' 'y'});
opts = coco_set(opts, 'cont', 'ItMX', 25);
bd1  = coco(opts, {'circle' '1'}, 'curve', 'sol', 'sol', ...
  f, [], [0 ; 1], {'x' 'y'}, [-2 2]);
u  = coco_bd_col(bd1, {'x' 'y'});
clf
plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow
%end1

%start2
f = @(x,p) (p(1)^2+p(2)^2-1)*((p(1)-1)^2+p(2)^2-1);
opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'x' 'y'});
opts = coco_set(opts, 'cont', 'ItMX', 25);
bd1  = coco(opts, {'circle' '1'}, 'curve', 'sol', 'sol', ...
  f, [], [0 ; 1], {'x' 'y'}, [-2 2]);
u  = coco_bd_col(bd1, {'x' 'y'});
clf
plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow
%end2
echo off

