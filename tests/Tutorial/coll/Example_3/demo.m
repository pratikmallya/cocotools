% changes made to demo:
% - enlarged eps0
% - actual (!) Euler step with h=1 for initial solution guess
% - adapted restart labels
% - changed pause statement - book demos are executed within plot scripts,
%   please never pause infinitely long

echo on
addpath('../Pass_1')
addpath('../../alg/Pass_8')
%!tkn1
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
%!tkn2
prob = coco_prob();
prob = doedel_isol2het(prob, segs, algs, eps0, th0, vec0, lam0);
coco(prob, 'run1', [], 1, 'y12e', [0 0.99]);
%!tkn3
prob = doedel_sol2het(coco_prob(), 'run1', 3);
coco(prob, 'run2', [], 1, 'y22e', [-0.995 0]);
prob = doedel_sol2het(coco_prob(), 'run2', 5);
coco(prob, 'run3', [], 1, 'gap', [-2 0]);
prob = doedel_sol2het(coco_prob(), 'run3', 5);
coco(prob, 'run4', [], 1, 'eps1', [1e-3 eps0(1)]);
prob = doedel_sol2het(coco_prob(), 'run4', 3);
coco(prob, 'run5', [], 1, 'eps2', [1e-3 eps0(2)]);
%!tkn4
prob = doedel_sol2het(coco_prob(), 'run5', 2);
coco(prob, 'run6', [], 1, 'p2', [0.5 8]);
%!tkn5
bd6 = coco_bd_read('run6');
labs = coco_bd_labs(bd6, 'ALL');
for lab=labs
  clf
  hold on
  sol = coll_read_solution('doedel1', 'run6', lab);
  plot(sol.x(:,1), sol.x(:,2), 'r.')
  sol = coll_read_solution('doedel2', 'run6', lab);
  plot(sol.x(:,1), sol.x(:,2), 'r.')
  hold off
  drawnow
  pause(0.1)
end

rmpath('../Pass_1')
rmpath('../../alg/Pass_8')
echo off