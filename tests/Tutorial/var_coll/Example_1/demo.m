echo on
addpath('../../coll');
addpath('../../po');
addpath('../');

%% Test construction from initial solution guess.
%!tkn1
p0 = 1;
[t0 x0] = ode45(@(t,x) linearode(x, p0), [0 2*pi], [0; 1; 0]);
opts = var_isol2var(@linearode, t0, x0, p0);
opts = coco_set(opts, 'cont', 'ItMX', 100);
coco(opts, 'var1', [], 1, 'beta', [0 1]);
[data chart] = coco_read_solution('var', 'var1', 7);
mat=reshape(chart.x(data.x_idx),[numel(data.x_idx)/data.dim data.dim]);
m0=mat(1:data.dim,1:data.dim);
m1=mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)
%!tkn2
exp(pi*(-1-sqrt(3)*1i))
exp(pi*(-1+sqrt(3)*1i))

%% Test construction from previously computed solution.
%!tkn3
p0 = [0.1631021; 1250; 0.046875; 20; 1.104; 0.001; 3; 0.6; 0.1175];
f  = @(t,x) chemosz(x, p0);
[t, z] = ode15s(f, [0 75], [25; 1.45468; 0.01524586; 0.1776113]);
[t z] = ode15s(f, [0 14], z(end,:)');
opts = coco_set('coll', 'NTST', 40);
opts = coco_set(opts, 'cont', 'ItMX', 100);
opts = po_isol2sol(opts, '', @chemosz, t, z, {'a', 'b', 'c', 'd', 'e', 'f','g', 'h', 'i'}, p0);
coco(opts, 'run', [], 1, 'g', [2, 4]);
vopts = var_sol2var('po.seg', 'run', 14);
vopts  = coco_set(vopts, 'cont', 'ItMX', 1000);
coco(vopts, 'var2', [], 1, 'beta', [0 1]);
[data chart] = coco_read_solution('po.seg.var', 'var2', 31);
mat=reshape(chart.x(data.x_idx),[numel(data.x_idx)/data.dim data.dim]);
m0=mat(1:data.dim,1:data.dim);
m1=mat(end-data.dim+1:end,1:data.dim);
eig(m1,m0)
%!tkn4
rmpath('../../coll');
rmpath('../../po');
rmpath('../');

echo offw