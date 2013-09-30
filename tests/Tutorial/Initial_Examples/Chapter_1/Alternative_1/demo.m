prob = coco_prob();
prob = coco_add_func(prob, 'fun', @catenary, [], 'zero', ...
  'u0', [1; 0; cosh(1)]);
prob = coco_add_pars(prob, '', 1:3, {'a', 'b', 'Y'});
prob = coco_add_event(prob, 'UZ', 'Y', 0:0.5:5);
bd   = coco(prob, 'run', [], 1, {'Y', 'a', 'b'}, [0.1, 5]);

Y   = coco_bd_col(bd, 'Y');
a   = coco_bd_col(bd, 'a');
b   = coco_bd_col(bd, 'b');
idx = coco_bd_idxs(bd, 'UZ');

figure(1)
clf
hold on
plot3(Y,a,b,'r')
plot3(Y(idx),a(idx),b(idx),'rs')
hold off

figure(2)
clf
hold on
x=0:.01:1;
for i=1:numel(idx)
    plot(x,1/a(idx(i))*cosh(a(idx(i))*(x+b(idx(i)))),'r');
    drawnow
end
hold off