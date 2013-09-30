addpath('..');
echo on
%!tkn1
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_9.create);
prob = coco_set(prob, 'cont', 'PtMX', 1500);
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', ...
  'x0', [2;0.5;0] );
pprob = coco_add_pars(pprob, '', [1 2 3], {'x' 'y' 'z'});
bd = coco(pprob, '1', [], 2, {'y' 'x' 'z'}, {[],[],[-0.25 0.25]});
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
z = coco_bd_col(bd, 'z');
plot3(x,y,z, 'b.');
drawnow
%!tkn2
pprob = coco_add_func(prob, 'ellipsoid', @ellipsoid, [], 'zero', ...
  'x0', [2;0.5;0] );
pprob = coco_add_pars(pprob, '', [1 2 3], {'x' 'y' 'z'});
bd = coco(pprob, '1', [], 2, {'y' 'x' 'z'});
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
z = coco_bd_col(bd, 'z');
plot3(x,y,z, 'b.');
axis equal
drawnow
%!tkn3
echo off
rmpath('..');
