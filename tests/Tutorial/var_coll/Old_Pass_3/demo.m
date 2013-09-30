%% Test construction from initial solution guess.
addpath('../../po');
addpath('../../coll/Pass_2');

p0 = 1;
x0 = [0; 1; 0];
f  = @(t,x) linode(x,p0);

[t0 z0] = ode45(f, [0 2*pi], x0);

prob = coco_prob();
prob = coco_set(prob, 'corr', 'ItMX', 50);
funcargs = {@linode, @linode_DFDX, @linode_DFDP};
prob = coll_isol2seg(prob, '', funcargs{:}, t0, z0, 'p', p0);
data = coco_get_func_data(prob, 'coll', 'data');
prob = coco_add_func(prob, 'bcs', @per_bc, [], 'zero', ...
  'uidx', [data.x0_idx ; data.x1_idx]);
prob = varcoll_isol2seg(prob, '', @linode_DFDXDX, @linode_DFDXDP);
coco(prob, 'var1', [], 1, {'p', 'l1', 'l2', 'l3'}, [0.5 1.5]);
rmpath('../../coll/Pass_2');
rmpath('../../po');

addpath('../../coll/Pass_2');
addpath('../../po');
eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 40*pi], [0;1]);
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 6.306], x0(end,:));
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 40);
prob = coco_set(prob, 'cont', 'ItMX', 100);
prob = coco_set(prob, 'corr', 'ItMX', 50);
funcargs = {@pneta, @pneta_DFDX, @pneta_DFDP};
prob = po_isol2orb(prob, '', funcargs{:}, t0, x0, 'eps', eps0);
prob = varcoll_isol2seg(prob, 'po.seg', ...
  @pneta_DFDXDX, @pneta_DFDXDP);
bd   = coco(prob, 'run1', [], 1, {'eps', 'l1', 'l2', 'cond'}, [-10 10]);
rmpath('../../coll/Pass_2');
rmpath('../../po');
return

prob = floquet_start([], 'var1', 7);

floqbd = coco(prob, 'floq', [], 1, 'PAR(1)', [.5 2]);

labs = coco_bd_labs(floqbd, 'all');
for lab=labs
    [vardata sol] = coco_read_solution('floquet_save', 'floq', lab);
    data = vardata.data;
    mat=reshape(sol.x(data.u_idx),[numel(data.u_idx)/data.dim data.dim]);
    m0=mat(1:data.dim,1:data.dim);
    m1=mat(end-data.dim+1:end,1:data.dim);
    eigs(m1,m0)
    [exp(pi*(-1-sqrt(1-4*sol.x(data.p_idx)))); exp(pi*(-1+sqrt(1-4*sol.x(data.p_idx))))]
end

%% Test construction from previously computed solution.

p0 = [0.1631021 1250 0.046875 20 1.104 0.001 3 0.6 0.1175]';
x0 = [25 1.45468 0.01524586 0.1776113]';
f  = @(t,x) chemosz(x,p0);

[t z] = ode15s(f, [0 75], x0);
x0    = z(end,:)';
[t z] = ode15s(f, [0 14], x0);

seg.t0   = t;
seg.x0   = z;
seg.mode = [];

prob = coco_set([], 'coll', 'NTST', 40);
prob = po_isol2sol(prob, '', @chemosz, seg, p0);
coco(prob, 'run', [], 1, 'PAR(7)', [2, 4]);

prob = var_sol2var([], '', 'run', 14);
prob = coco_set(prob, 'cont', 'ItMX', 1000);
coco(prob, 'var2', [], 1, 'beta', [0 1]);

prob = floquet_start([], 'var2', 31);
floqbd = coco(prob, 'floq', [], 1, 'PAR(7)', [2 4]);

labs = coco_bd_labs(floqbd, 'all');
for lab=labs
    [vardata sol] = coco_read_solution('floquet_save', 'floq', lab);
    data = vardata.data;
    mat=reshape(sol.x(data.u_idx),[numel(data.u_idx)/data.dim data.dim]);
    m0=mat(1:data.dim,1:data.dim);
    m1=mat(end-data.dim+1:end,1:data.dim);
    eigs(m1,m0)
end

%% Test construction from Hopf bifurcation

s=10;
b=8/3;
r=470/19;
p0 = [s; r; b];
x0 = [-sqrt(b*(r-1)); -sqrt(b*(r-1)); r-1];
prob = po_Hopf2sol([], '', @lorentz, x0, p0);
bd1 = coco(prob, 'runHopf', [], 1, 'PAR(2)', [24.05 25]);

labs = coco_bd_labs(bd1, 'all');
cla;
grid on;
hold on;
for lab=labs
    [t x] = coll_read_sol('', 'runHopf', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'b.-')
end
hold off

prob = var_sol2var([], '', 'runHopf', 10);
prob = coco_set(prob, 'cont', 'ItMX', 1000);
prob = coco_set(prob, 'corr', 'ItMX', 30);
coco(prob, 'var2', [], 0);

prob = floquet_start([], 'var2', 1);
floqbd = coco(prob, 'floq', [], 1, 'PAR(2)', [24.05 25]);

labs = coco_bd_labs(floqbd, 'all');
for lab=labs
    [vardata sol] = coco_read_solution('floquet_save', 'floq', lab);
    data = vardata.data;
    mat=reshape(sol.x(data.u_idx),[numel(data.u_idx)/data.dim data.dim]);
    m0=mat(1:data.dim,1:data.dim);
    m1=mat(end-data.dim+1:end,1:data.dim);
    eigs(m1,m0)
end

lab = labs(end);
[vardata sol] = coco_read_solution('floquet_save', 'floq', lab);
data = vardata.data;
mat=reshape(sol.x(data.u_idx),[numel(data.u_idx)/data.dim data.dim]);
m0=mat(1:data.dim,1:data.dim);
m1=mat(end-data.dim+1:end,1:data.dim);
[v,d] = eigs(m1,m0);
vec0          = -v(:,3);
lam0          = d(3,3);
eps0          = [0.01; 0.01];

segs0(1).mode = [];
segs0(1).t0   = 0;
segs0(1).x0   = 0.01*[(1-s+sqrt((1-s)^2+4*r*s))/2/r; 1; 0]';

segs0(2).mode = 1;
segs0(2).t0   = 0;
segs0(2).x0   = [-6.1730; -7.4554; 18.9417]' + 0.01*vec0';

floqx0        = sol.x(1:end-1);
p0            = sol.x(data.p_idx);

prob = riess_start(data, floqx0, segs0, p0, vec0, lam0, eps0);

prob = coco_set(prob, 'cont', 'ItMX',[500 0]);
prob = coco_set(prob, 'cont', 'NPR', 50);
prob = coco_add_event(prob, 'bing', 'sigma2', 0);
bd1  = coco(prob, 'run1', [], 1, {'T2' 'sigma2' 'T1'}, {[0 1], [-1 30]});

labs = coco_bd_labs(bd1, 'bing');
lab = labs(2);
clf
hold on
[t,x]  = coll_read_sol('col1', 'run1', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'r.')
[t,x]  = coll_read_sol('col2', 'run1', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'b.')
[t,x]  = floquet_read_sol('', 'run1', lab);  %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'g.')
hold off

prob = riess_restart([], 'run1', lab);
prob = coco_set(prob, 'cont', 'ItMX',[500 0]);
prob = coco_set(prob, 'cont', 'NPR', 50);
prob = coco_add_event(prob, 'bing', 'sigma1', 0);
bd2  = coco(prob, 'run2', [], 1, {'T1' 'sigma1' 'T2'}, {[0 1], [-30 1]});

labs = coco_bd_labs(bd2, 'bing');
lab = labs(1);
clf
hold on
[t,x]  = coll_read_sol('col1', 'run2', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'r.')
[t,x]  = coll_read_sol('col2', 'run2', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'b.')
[t,x]  = floquet_read_sol('', 'run2', lab);
plot3(x(1,:), x(2,:), x(3,:), 'g.')
hold off

prob = riess_restart([], 'run2', lab);
prob = coco_set(prob, 'cont', 'ItMX', 300);
bd3  = coco(prob, 'run3', [], 1, {'eps2' 'T2' 'T1'}, [0.000001 .02]);

labs3 = coco_bd_labs(bd3, 'ALL');
endpoints = [];
labels = [];
hold on
for lab3=labs3
    [t,x]  = coll_read_sol('col2', 'run3', lab3); %#ok<ASGLU>
    plot3(x(1,:), x(2,:), x(3,:), 'b')
    endpoints = [endpoints; x(:,end)'];
    labels = [labels; lab3];
end
hold off
[t,x]  = coll_read_sol('col1', 'run2', lab); %#ok<ASGLU>
pt = repmat(x(:,end)', [size(endpoints,1) 1]);
[m1,i1] = min(sqrt(sum((endpoints-pt).*(endpoints-pt),2)));

prob = riess_restart([], 'run3', labels(i1));
[data1 xidx1] = coco_get_func_data(prob, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(prob, 'col2.coll_fun', 'data', 'xidx');

prob = coco_add_func(prob, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
prob = coco_add_event(prob, 'bing', 'lingap', 0);
prob = coco_set(prob, 'cont', 'ItMX', 500);
bd4  = coco(prob, 'run4', [], 1, {'lingap' 'T2' 'T1' 'PAR(2)' 'eps2'}, [-1 0.1]);

labs = coco_bd_labs(bd4, 'bing');
lab = labs(1);
clf
hold on
[t,x]  = coll_read_sol('col1', 'run4', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'r.')
plot3(x(1,end),x(2,end),x(3,end), 'ko');
[t,x]  = coll_read_sol('col2', 'run4', lab); %#ok<ASGLU>
plot3(x(1,:), x(2,:), x(3,:), 'b.')
plot3(x(1,end),x(2,end),x(3,end), 'ks');
[t,x]  = floquet_read_sol('', 'run4', lab);
plot3(x(1,:), x(2,:), x(3,:), 'g.')
hold off

prob = riess_restart([], 'run4', lab);
[data1 xidx1] = coco_get_func_data(prob, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(prob, 'col2.coll_fun', 'data', 'xidx');

prob = coco_add_func(prob, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
prob = coco_set(prob, 'cont', 'ItMX', 500);
bd5  = coco(prob, 'run5', [], 1, {'PAR(2)' 'T2' 'eps1' 'PAR(3)' 'eps2' 'zcond' 'lingap'}, [10 40]);

labs = coco_bd_labs(bd5, 'ALL');
clf
view(-60,50)
for lab=labs  
    hold on
    [t,x]  = coll_read_sol('col1', 'run5', lab); %#ok<ASGLU>
    plot3(x(1,:), x(2,:), x(3,:), 'r')
    plot3(x(1,end),x(2,end),x(3,end), 'ko');
    [t,x]  = coll_read_sol('col2', 'run5', lab); %#ok<ASGLU>
    plot3(x(1,:), x(2,:), x(3,:), 'b')
    plot3(x(1,end),x(2,end),x(3,end), 'ks');
    [t,x]  = floquet_read_sol('', 'run5', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'g')
    hold off
%     pause
end

p3 = coco_bd_col(bd5, 'PAR(3)');
p2 = coco_bd_col(bd5, 'PAR(2)');
figure(3)
plot(p2,p3,'r')
