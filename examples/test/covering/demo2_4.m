%% Cylinder (test EP boundary)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'h', .5);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'PtMX', 200);
prob = coco_add_func(prob, 'cylinder', @cylinder, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'cylinder', [], 2, {'y' 'z' 'x'}, {[] [-1 1] []});

bd = coco_bd_read('cylinder');
x  = coco_bd_col(bd, {'x' 'y' 'z'});
figure(1)
clf
plot3(x(1,:), x(2,:), x(3,:), '.');
axis equal
view(60,30)
drawnow

%% Sphere Ndirs = 6 (works fine now)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'PtMX', 100);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'sphere', [], 2, {'x' 'y' 'z'});

bd = coco_bd_read('sphere');
x  = coco_bd_col(bd, {'x' 'y' 'z'});
figure(1)
clf
plot3(x(1,:), x(2,:), x(3,:), '.');
axis equal
view(60,30)
drawnow

%% Singular (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_add_func(prob, 'singular', @singular, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Empty (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_add_func(prob, 'empty', @empty, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Sphere (test EP PtMX=0)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'PtMX', 0);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

%% Sphere (test EP PtMX=30)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'PtMX', 30);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

%% Ellipsoid (test MX)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'h', .25);
prob = coco_set(prob, 'cont', 'PtMX', 200);
data.MX = true;
prob = coco_add_func(prob, 'ellipsoid', @ellipsoid, data, 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'ellipsoid', [], 2, {'y' 'z' 'x'});

%% Ellipsoid (test DROP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'h', .25);
prob = coco_set(prob, 'cont', 'PtMX', 200);
prob = coco_add_func(prob, 'ellipsoid', @ellipsoid, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'ellipsoid', [], 2, {'y' 'z' 'x'});
