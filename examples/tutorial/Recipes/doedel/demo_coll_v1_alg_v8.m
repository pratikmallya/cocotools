%7.3.3  Coupling 'coll' and 'alg'.

coco_use_recipes_toolbox coll_v1 alg_v8

p0 = [1; 1];
eps0 = [0.05; 0.05];
th0 = -pi/2;
eqs10 = [-1; 1];
eqs20 = [1; -1];
vec0 = [-3/sqrt(10); 1/sqrt(10)];
lam0 = -2;
segs(1).t0 = [0; 1];
x0         = eqs10+eps0(1)*[cos(th0); sin(th0)];
segs(1).x0 = [x0  x0+doedel(x0, p0)]';
segs(1).p0 = p0;
segs(2).t0 = [0; 1];
x0         = eqs20+eps0(2)*vec0;
segs(2).x0 = [x0-doedel(x0, p0) x0]';
segs(2).p0 = p0;
algs(1).x0 = eqs10;
algs(1).p0 = p0;
algs(2).x0 = eqs20;
algs(2).p0 = p0;

prob = coco_prob();
prob = doedel_isol2het(prob, segs, algs, eps0, th0, vec0, lam0);
coco(prob, 'coll1', [], 1, 'y12e', [0 0.99]);

prob = doedel_sol2het(coco_prob(), 'coll1', 3);
coco(prob, 'coll2', [], 1, 'y22e', [-0.995 0]);
prob = doedel_sol2het(coco_prob(), 'coll2', 5);
coco(prob, 'coll3', [], 1, 'gap', [-2 0]);
prob = doedel_sol2het(coco_prob(), 'coll3', 5);
coco(prob, 'coll4', [], 1, 'eps1', [1e-3 eps0(1)]);
prob = doedel_sol2het(coco_prob(), 'coll4', 3);
coco(prob, 'coll5', [], 1, 'eps2', [1e-3 eps0(2)]);

prob = doedel_sol2het(coco_prob(), 'coll5', 2);
coco(prob, 'coll6', [], 1, 'p2', [0.5 8]);

bd6 = coco_bd_read('coll6');
labs = coco_bd_labs(bd6, 'ALL');
for lab=labs
  clf
  hold on
  sol = coll_read_solution('doedel1', 'coll6', lab);
  plot(sol.x(:,1), sol.x(:,2), 'r.')
  sol = coll_read_solution('doedel2', 'coll6', lab);
  plot(sol.x(:,1), sol.x(:,2), 'r.')
  hold off
  drawnow
  pause(0.1)
end

coco_use_recipes_toolbox
