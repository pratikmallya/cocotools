f = @(x,p) p(1) - x*(p(2)-x*x);

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'mu' 'la'});
opts = coco_set(opts, 'cont', 'ItMX', 500);

%% run continuation, name branch '1'
bd1 = coco(opts, {'fold' '1'}, 'curve', 'sol', 'sol', ...
  f, -1, [0 ; 1], 'mu', [-2 2]);

% plot bifurcation diagram
u  = coco_bd_col(bd1, {'mu' 'x'});
subplot(1,2,1);
plot(u(1,:), u(2,:), '.-')
grid on
drawnow

%% compute fold curve

labs = coco_bd_labs(bd1, 'FP');

% run continuation, name branch '2'
bd2 = coco(opts, {'fold' '2'}, 'curve', 'LP', 'LP', ...
  {'fold' '1'}, labs(1), {'mu' 'la'}, {[-2 2] [-2 2]});

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'mu' 'la' 'x'});
subplot(1,2,2);
plot3(u(1,:), u(2,:), u(3,:), '.-')
view(2)
grid on
drawnow
