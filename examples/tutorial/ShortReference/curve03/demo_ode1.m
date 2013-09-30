f  = @(x,p) (p+x-x^3)*((x-2)^2-p+2);

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'mu'});

bd = coco(opts,'1' , 'curve','isol','sol',f,0,0 , 'mu',[-2 4]);
%    coco(opts,'2' , 'curve','sol','sol','1',12 , 'mu',[-2 4]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
p = coco_bd_col(bd, 'p');
plot(p,x)

% plot limit points
labs = coco_bd_labs(bd, 'LP');
hold on
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p,x,'bx')
end
hold off

% plot branch points
labs = coco_bd_labs(bd, 'BP');
hold on
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p,x,'r*')
end
hold off
