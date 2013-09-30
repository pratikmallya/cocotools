f = @(x,mu) [
  -x(2)-x(3)
  x(1) + mu(1)*x(2)
  mu(2) + x(3)*(x(1)-mu(3))
  ];

fx = @(x,mu) [
     0      -1           -1
     1   mu(1)            0
  x(3)       0   x(1)-mu(3)
  ];

fp = @(x,mu) [
     0   0       0
  x(2)   0       0
     0   1   -x(3)
  ];

%    [  al    be   ga ]
mu = [ 0.1; 0.25; 6.2 ];
D  = sqrt(mu(3)^2/4 - mu(2)*mu(1));
x0 = [ mu(3)/2 - D ; (-mu(3)/2 + D)/mu(1) ; (mu(3)/2 - D)/mu(1) ];

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'al' 'be' 'ga'});
opts = coco_set(opts, 'cont', 'ItMX', 200);

bd = coco(opts, '1', 'ep_curve', 'isol', 'sol', ...
  f, fx, fp, x0, mu, ...
  {'al' 'test_FP' 'test_BP'}, [-0.4 0.4]);

% plot circle
ro = coco_bd_col(bd, 'al');
x  = coco_bd_col(bd, 'x');
plot(ro, x(3,:), '.-')
