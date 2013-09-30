addpath('../../po/adapt');

eps0 = 0.1;
t0   = linspace(0, 2*pi, 100)';
x0   = [sin(t0) cos(t0)];
prob  = coco_set(coco_prob(), 'cont', 'ItMX', [0 200]);
prob  = coco_set(prob, 'coll', 'TOL', 1.0e-3);
echo on
%!tkn1
prob2 = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
coco(prob2, 'run1', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn2
bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'MXCL');
prob  = coco_set(prob, 'coll', 'NTST', 20, 'NCOL', 4);
prob2 = po_sol2orb(prob, '', 'run1', lab);
coco(prob2, 'run2', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn3
bd  = coco_bd_read('run2');
lab = coco_bd_labs(bd, 'MXCL');
prob  = coco_set(prob, 'coll', 'NTST', 50, 'NCOL', 5);
prob2 = po_sol2orb(prob, '', 'run2', lab);
coco(prob2, 'run3', [], 1, {'eps' 'po.seg.coll.err'}, [0.1 20]);
%!tkn4
echo off
figure(1)
clf

subplot(1,2,1)

bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'MXCL');
sol1 = po_read_solution('', 'run1', lab);

bd  = coco_bd_read('run2');
lab = coco_bd_labs(bd, 'MXCL');
sol2 = po_read_solution('', 'run2', lab);

bd  = coco_bd_read('run3');
lab = coco_bd_labs(bd, 'EP');
sol3 = po_read_solution('', 'run3', lab(end));

plot(sol3.x(:,1), sol3.x(:,2), 'g.-', sol2.x(:,1), sol2.x(:,2), 'r.-', ...
  sol1.x(:,1), sol1.x(:,2), '.-');
grid on
drawnow

subplot(1,2,2)

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

rmpath('../../po/adapt');
