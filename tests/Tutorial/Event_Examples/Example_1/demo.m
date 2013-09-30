echo on
%!tkn1
prob = coco_add_func(coco_prob(), 'circ', @circ, [], 'zero', ...
  'u0', [1; 1.1]);
prob = coco_add_func(prob, 'fun2', @dist, [], 'inactive', 'p', ...
  'uidx', [1; 2]);
%!tkn4
prob = coco_add_event(prob, 'UZ', 'p', 0.5:0.5:2);
%!tkn5
coco(prob, 'run', [], 1, 'p', [0.5, 3]);
%!tkn6
prob = coco_add_pars(prob, 'vars', [1, 2], {'u1', 'u2'}, 'active');
bd = coco(prob, 'run', [], 1, {'p', 'u1', 'u2'}, [0.1, 5]);
figure(1)
clf
hold on
th=0:0.01:2*pi;
plot(cos(th),1+sin(th),'g')

x   = coco_bd_col(bd, 'u1');
y   = coco_bd_col(bd, 'u2');
idx = coco_bd_idxs(bd, 'UZ');
plot(x(idx), y(idx), 'go', 'LineWidth', 2, 'MarkerSize', 10);

for r = 0.5:0.5:2
    thmin=atan2(r/2,sqrt(4-r^2)/2);
    thmax=atan2(r/2,-sqrt(4-r^2)/2);
    th=thmin:0.01:thmax;
    plot(r*cos(th),r*sin(th),'k-', 'LineWidth', 2)
end
hold off
axis equal
%!tkn7
echo off