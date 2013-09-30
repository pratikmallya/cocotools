echo on
addpath('../../coll/Pass_1')
addpath('../')
%!tkn1
p0 = [0.1631021; 1250; 0.046875; 20; 1.104; 0.001; 3; 0.6; 0.1175];
f  = @(t,x) chemosz(x, p0);
[t0 x0] = ode15s(f, [0 75], [25; 1.45468; 0.01524586; 0.1776113]);
[t0 x0] = ode15s(f, [0 14], x0(end,:)');
prob = coco_prob();
prob = coco_set(prob, 'po.coll', 'NTST', 40);
prob = po_isol2orb(prob, '', @chemosz, t0, x0, ...
  {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'}, p0);
bd1  = coco(prob, 'run1', [], 1, {'g', 'po.period'}, [2, 4]);
%!tkn2
cla;
grid on;
%!tkn3
labs = coco_bd_labs(bd1, 'all');
hold on;
for lab=labs
  sol = po_read_solution('', 'run1', lab);
  plot3(sol.x(:,1), sol.x(:,2), sol.x(:,3), 'b.-')
end
hold off
%!tkn4

%% test restart of po

%!tkn5
prob = coco_prob();
prob = po_sol2orb(prob, '', 'run1', 10);
prob = coco_xchg_pars(prob, 'po.period', 'g');
bd2  = coco(prob, 'run2', [], 1, {'a' 'po.period'}, [0.15 0.18]);
%!tkn6
labs = coco_bd_labs(bd2, 'all');
hold on;
for lab=labs
  sol = po_read_solution('', 'run2', lab);
  plot3(sol.x(:,1), sol.x(:,2), sol.x(:,3), 'r.-')
end
hold off;

rmpath('../../coll/Pass_1')
rmpath('../')
echo off