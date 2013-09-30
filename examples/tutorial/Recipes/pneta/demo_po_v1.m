coco_use_recipes_toolbox po_v1 coll_v1

eps0 = 0.1;
t0   = linspace(0, 2*pi, 100)';
x0   = [sin(t0) cos(t0)];
prob  = coco_prob();
prob1 = coco_set(prob, 'cont', 'ItMX', [0 200]);
prob1 = po_isol2orb(prob1, '', @pneta, t0, x0, 'eps', eps0);
coco(prob1, 'po1', [], 1, 'eps', [0.1 20]);

prob2 = coco_set(prob, 'coll', 'NTST', 150, 'NCOL', 5);
prob2 = po_isol2orb(prob2, '', @pneta, t0, x0, 'eps', eps0);
coco(prob2, 'po2', [], 1, 'eps', [0.1 20]);

figure(1)
clf
bd  = coco_bd_read('po1');
lab = coco_bd_labs(bd, 'EP');
sol1 = po_read_solution('', 'po1', lab(end));
bd  = coco_bd_read('po2');
lab = coco_bd_labs(bd, 'EP');
sol2 = po_read_solution('', 'po2', lab(end));
plot(sol2.x(:,1), sol2.x(:,2), 'r.-', sol1.x(:,1), sol1.x(:,2), '.-');
grid on

coco_use_recipes_toolbox
