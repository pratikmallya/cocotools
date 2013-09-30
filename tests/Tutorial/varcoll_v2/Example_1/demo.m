echo on
addpath('../../coll/Pass_1');
addpath('../../po');
addpath('../');

%% Test construction from initial solution guess.
%!tkn1
p0 = 1;
[t0 x0] = ode45(@(t,x) linearode(x, p0), [0 2*pi], [0; 1; 0]);
prob = coco_prob();
varprob = var_isol2var(prob, @linearode, t0, x0, p0);
varprob = coco_set(varprob, 'cont', 'ItMX', 100);
coco(varprob, 'var1', [], 1, 'beta', [0 1]);
[data chart] = coco_read_solution('var', 'var1', 7);
mat = reshape(chart.x(data.x_idx), ...
  [numel(data.x_idx)/data.dim data.dim]);
m0 = mat(1:data.dim,1:data.dim);
m1 = mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)
%!tkn2
exp(pi*(-1-sqrt(3)*1i))
exp(pi*(-1+sqrt(3)*1i))

%% Test construction from previously computed solution.
%!tkn3
p0 = [0.1631021; 1250; 0.046875; 20; 1.104; 0.001; 3; 0.6; 0.1175];
f  = @(t,x) chemosz(x, p0);
[t z] = ode15s(f, [0 75], [25; 1.45468; 0.01524586; 0.1776113]);
[t z] = ode15s(f, [0 14], z(end,:)');
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 40);
prob = po_isol2orb(prob, '', @chemosz, t, z, p0, ...
  {'a', 'b', 'c', 'd', 'e', 'f','g', 'h', 'i'});
coco(prob, 'run', [], 1, 'g', [2, 4]);
%!tkn4
prob    = coco_prob();
varprob = var_sol2var(prob, 'po.seg', 'run', 12);
varprob = coco_set(varprob, 'cont', 'ItMX', 1000);
coco(varprob, 'var2', [], 1, 'beta', [0 1]);
labs = coco_bd_labs(coco_bd_read('var2'), 'EP');
[data chart] = coco_read_solution('po.seg.var', 'var2', labs(end));
mat = reshape(chart.x(data.x_idx), ...
  [numel(data.x_idx)/data.dim data.dim]);
m0 = mat(1:data.dim,1:data.dim);
m1 = mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)
%!tkn5
rmpath('../../coll/Pass_1');
rmpath('../../po');
rmpath('../');

echo offw