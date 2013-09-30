%% define ODE of Lorenz system
f = @(x,mu) [
  mu(1) * ( x(2)-x(1) )
  mu(3) * x(1) - x(2) - x(1)*x(3)
  x(1)*x(2) - mu(2)*x(3)
  ];

fx = @(x,mu) [
      -mu(1)  mu(1)      0
  mu(3)-x(3)     -1  -x(1)
        x(2)   x(1) -mu(2)
  ];

fp = @(x,mu) [
  x(2)-x(1)       0      0
          0       0   x(1)
          0   -x(3)      0
  ];

%% first continuation run computes part of the branches
%    [ si   be ro ]
mu = [ 10; 8/3; 2 ];
x0 = [ sqrt(mu(2)*(mu(3)-1)); sqrt(mu(2)*(mu(3)-1)); mu(3)-1 ];
% x0 = [ 0 ; 0 ; 0 ];

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'si' 'be' 'ro'});
opts = coco_set(opts, 'cont', 'ItMX', 50);

% run continuation, name branch '1'
bd1 = coco(opts, '1', 'ep_curve', 'isol', 'sol', ...
  f, fx, fp, x0, mu, ...
  {'ro' 'test_FP' 'test_BP'}, [0 30]);

% plot branch
ro = coco_bd_col(bd1, 'ro');
x  = coco_bd_col(bd1, 'x');
plot(ro, x(1,:), '.-')
drawnow

%% successive restarted continuation runs compute remaining parts

labs = coco_bd_labs(bd1, 'EP');
opts = coco_set(opts, 'cont', 'ItMX', [0 100]);

% run continuation, name branch '2'
bd2 = coco(opts, '2', 'ep_curve', 'sol', 'sol', ...
  '1', labs(1), ...
  {'ro' 'test_FP' 'test_BP'}, [0 30]);

% plot branch
ro = coco_bd_col(bd2, 'ro');
x  = coco_bd_col(bd2, 'x');
hold on
plot(ro, x(1,:), 'r.-')
hold off
drawnow

% run continuation, name branch '3'
bd3 = coco(opts, '3', 'ep_curve', 'sol', 'sol', ...
  '1', labs(end), ...
  {'ro' 'test_FP' 'test_BP'}, [0 30]);

% plot branch
ro = coco_bd_col(bd3, 'ro');
x  = coco_bd_col(bd3, 'x');
hold on
plot(ro, x(1,:), 'r.-')
hold off
drawnow

%% switch branches at branch point

labs = coco_bd_labs(bd1, 'BP');
opts = coco_set(opts, 'cont', 'ItMX', 100);

% run continuation, name branch '4'
bd4 = coco(opts, '4', 'ep_curve', 'BP', 'sol', ...
  '1', labs(1), ...
  {'ro' 'test_FP' 'test_BP'}, [0 30]);

% plot branch
ro = coco_bd_col(bd4, 'ro');
x  = coco_bd_col(bd4, 'x');
hold on
plot(ro, x(1,:), 'k.-')
hold off
drawnow
