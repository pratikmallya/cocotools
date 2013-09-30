addpath('../../coll');
addpath('../../po');

%% Test construction from initial solution guess.

p0 = 1;
x0 = [0 1 0]';
f  = @(t,x) linearode(x,p0);

[t z] = ode45(f, [0 2*pi], x0);

seg.t0   = t;
seg.x0   = z;
seg.mode = [];

opts = var_isol2var([], @linearode, seg, p0);
opts = coco_set(opts, 'corr', 'ItMX', 100);
opts = coco_set(opts, 'cont', 'ItMX', 0);
coco(opts, 'var1', [], 0);

[data sol] = coco_read_solution('var', 'var1', 1);
mat=reshape(sol.x(1:numel(data.x_idx)),[numel(data.x_idx)/data.dim data.dim]);
m0=mat(1:data.dim,1:data.dim);
m1=mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)
exp(pi*(-1-sqrt(3)*1i))
exp(pi*(-1+sqrt(3)*1i))

%% Test construction from previously computed solution.

p0 = [0.1631021 1250 0.046875 20 1.104 0.001 3 0.6 0.1175]';
x0 = [25 1.45468 0.01524586 0.1776113]';
f  = @(t,x) chemosz(x,p0);

[~, z] = ode15s(f, [0 75], x0);
x0     = z(end,:)';
[t z]  = ode15s(f, [0 14], x0);

seg.t0   = t;
seg.x0   = z;
seg.mode = [];

opts = coco_set('coll', 'NTST', 40);
opts = po_isol2sol(opts, '', @chemosz, seg, p0);
coco(opts, 'run', [], 1, 'PAR(7)', [2, 4]);

opts = var_sol2var('po.seg', 'run', 14);
opts = coco_set(opts, 'corr', 'ItMX', 300);
coco(opts, 'var2', [], 0);

[data sol] = coco_read_solution('po.seg.var', 'var2', 1);
mat=reshape(sol.x(1:numel(data.x_idx)),[numel(data.x_idx)/data.dim data.dim]);
m0=mat(1:data.dim,1:data.dim);
m1=mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)

rmpath('../../coll');
rmpath('../../po');