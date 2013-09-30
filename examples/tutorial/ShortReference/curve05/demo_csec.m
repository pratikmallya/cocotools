f = @(x,p) [
  x(1)^2+x(2)^2-p(1)^2
  [sin(p(2)) 0 cos(p(2))]*[x(1);x(2);p(1)-1]
  ];

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'r' 'alpha'});

opts = curve_create(opts, f, [sqrt(0.5);sqrt(0.5)], [1;0.1]);

bd = coco(opts, '1', [], 'r', [-2 2]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
plot(x(1,:), x(2,:))
axis equal
