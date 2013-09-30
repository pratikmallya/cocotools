%% Singular (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_add_func(prob, 'singular', @singular, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Empty (test MX on IP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_add_func(prob, 'empty', @empty, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, '1', [], 2);

%% Sphere (test EP PtMX=0)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'PtMX', 0);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

%% Sphere (test EP on closedness)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
coco(prob, 'sphere', [], 2);

atlas = coco_bd_read('sphere', 'atlas');
figure(1)
clf
atlas2_x.trisurf(atlas, 1, 2, 3);
axis equal
axis tight
view(60,30)
drawnow

%% Cylinder (test EP boundary)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'h', .5);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'PtMX', 200);
prob = coco_add_func(prob, 'cylinder', @cylinder, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'cylinder', [], 2, {'y' 'z' 'x'}, {[] [-1 1] []});

atlas = coco_bd_read('cylinder', 'atlas');
figure(2)
clf
atlas2_x.trisurf(atlas, 1, 2, 3);
axis equal
axis tight
view(60,30)
drawnow

%% Ellipsoid (test MX and DROP)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'h', .15);
prob = coco_set(prob, 'cont', 'PtMX', 200);
data.MX = true;
prob = coco_add_func(prob, 'ellipsoid', @ellipsoid, data, 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
coco(prob, 'ellipsoid', [], 2, {'y' 'z' 'x'}, {[0 1] [0 1] []});

atlas = coco_bd_read('ellipsoid', 'atlas');
figure(3)
clf

subplot(1,2,1)
atlas2_x.plot_charts(atlas, 1, 2, 3);
axis equal
axis tight
view(60,30)
drawnow

subplot(1,2,2)
atlas2_x.trisurf(atlas, 1, 2, 3);
axis equal
axis tight
view(60,30)
drawnow

%% Sphere (test event location)
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'almax', 35);
prob = coco_set(prob, 'cont', 'h', 0.5);
prob = coco_add_func(prob, 'sphere', @sphere, [], 'zero', ...
  'x0', [2;0;0] );
prob = coco_add_pars(prob, '', [1 2 3], {'x' 'y' 'z'});
prob = coco_add_event(prob, 'UZ', 'z', 0.5);
coco(prob, 'sphere', [], 2, {'x' 'y' 'z'});

[atlas bd] = coco_bd_read('sphere', 'atlas', 'bd');
figure(4)
clf
atlas2_x.trisurf(atlas, 1, 2, 3);
idx = coco_bd_idxs(bd, 'UZ');
x   = coco_bd_col(bd, {'x' 'y' 'z'});
hold on
plot3(x(1,idx), x(2,idx), x(3,idx), 'w.', 'MarkerSize', 21);
hold off
axis equal
axis tight
view(60,30)
drawnow
