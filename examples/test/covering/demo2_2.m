%% Sphere Ndirs = 6 (leaves hole)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
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

%% Sphere Ndirs = 4 (may leave hole)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_set(prob, 'cont', 'PtMX', 200);
prob = coco_set(prob, 'cont', 'Ndirs', 4);
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
subplot(1,2,1)
y = atlas2_1.sproject([1;0;-1], 1, x);
plot(y(1,51:end), y(2,51:end), 'g.-', y(1,1:51), y(2,1:51), 'b.-');
axis([-3.1 5.1 -4.1 4.1])
axis equal
grid on
subplot(1,2,2)
plot3(x(1,:), x(2,:), x(3,:), '.');
view(60,30)
grid on
axis tight
axis equal
drawnow

%% Singular (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_add_func(prob, 'singular', @singular, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Empty (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_add_func(prob, 'empty', @empty, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Sphere (test EP PtMX=0)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_set(prob, 'cont', 'PtMX', 0);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

%% Sphere (test EP PtMX=30)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_set(prob, 'cont', 'PtMX', 30);
prob = coco_set(prob, 'cont', 'Ndirs', 4);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

%% Ellipsoid (test MX)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_set(prob, 'cont', 'h', .15);
prob = coco_set(prob, 'cont', 'PtMX', 200);
data.MX = true;
prob = coco_add_func(prob, 'ellipsoid', @ellipsoid, data, 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'ellipsoid', [], 2, {'y' 'z' 'x'});

%% Ellipsoid (test DROP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_2.create);
prob = coco_set(prob, 'cont', 'h', .15);
prob = coco_set(prob, 'cont', 'PtMX', 200);
prob = coco_add_func(prob, 'ellipsoid', @ellipsoid, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'ellipsoid', [], 2, {'y' 'z' 'x'});
