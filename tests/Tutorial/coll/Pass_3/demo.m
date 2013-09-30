%% plots of the error function w_n(sigma) for different orders n

figure(1)
clf
N=[3 4 5 10 15 20];

for i=1:6
  subplot(2,3,i)
  
  tk = linspace(-1,1,N(i));
  x  = linspace(-1,1,1000);
  f  = @(x) prod(x-tk);
  y  = arrayfun(f, x);
  plot(x,y,'-', 'LineWidth', 2);
  grid on;
  drawnow
end

%% runs with brute force method
addpath('../../po');
t0 = linspace(0, 2*pi, 100)';
x0 = [sin(t0) cos(t0)];
prob  = coco_set(coco_prob(), 'cont', 'ItMX', [0 200]);
echo on
%!tkn1
prob  = coco_set(prob, 'coll', 'TOL', 1.0e-3);
prob2 = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', 0.1);
coco(prob2, 'run1', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn2
prob  = coco_set(prob, 'coll', 'NTST', 20, 'NCOL', 4);
prob2 = po_sol2orb(prob, '', 'run1', 2);
coco(prob2, 'run2', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn3
prob  = coco_set(prob, 'coll', 'NTST', 150, 'NCOL', 5);
prob2 = po_sol2orb(prob, '', 'run2', 3);
coco(prob2, 'run3', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn4
echo off
figure(2)
clf

subplot(2,2,[1 2])

bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'MXCL');
sol1 = po_read_solution('', 'run1', lab);

bd  = coco_bd_read('run2');
lab = coco_bd_labs(bd, 'MXCL');
sol2 = po_read_solution('', 'run2', lab);

bd  = coco_bd_read('run3');
lab = coco_bd_labs(bd, 'EP');
sol3 = po_read_solution('', 'run3', lab(end));

plot(sol3.x(:,1), sol3.x(:,2), 'k.-', sol2.x(:,1), sol2.x(:,2), 'r.-', ...
  sol1.x(:,1), sol1.x(:,2), '.-');
grid on
drawnow

subplot(2,2,3)
plot(sol3.t/sol3.t(end), sol3.x(:,2), '.-');
grid on
drawnow



subplot(2,2,4)

bd = coco_bd_read('run1');
p = coco_bd_col(bd, 'eps');
err = coco_bd_col(bd, 'po.seg.coll.err');
plot(p,err, '.-');

hold on
bd = coco_bd_read('run2');
p = coco_bd_col(bd, 'eps');
err = coco_bd_col(bd, 'po.seg.coll.err');
plot(p,err, '.-');
bd = coco_bd_read('run3');
p = coco_bd_col(bd, 'eps');
err = coco_bd_col(bd, 'po.seg.coll.err');
plot(p,err, '.-');
hold off

grid on
drawnow

rmpath('../../po');
