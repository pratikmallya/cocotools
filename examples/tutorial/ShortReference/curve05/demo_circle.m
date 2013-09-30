f = @(x,p) x^2 + p^2 - 1;

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 0);
opts = coco_set(opts, 'curve', 'BP', 0);
opts = coco_set(opts, 'curve', 'ParNames', {'y'});

opts = curve_create(opts, f, 1, 0);

bd = coco(opts, '1', [], 'y', [-2 2]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
plot(x,y)
