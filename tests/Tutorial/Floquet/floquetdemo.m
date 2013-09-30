%% Test construction from initial solution guess.

p0 = 1;
x0 = [0 1 0]';
f  = @(t,x) linearode(x,p0);

[t z] = ode45(f, [0 2*pi], x0);

seg.t0   = t;
seg.x0   = z;
seg.mode = [];

opts = var_isol2var([], '', @linearode, seg, p0);
coco(opts, 'var1', [], 1, 'beta', [0 1]);

opts = floquet_start([], 'var1', 7);

floqbd = coco(opts, 'floq', [], 1, 'PAR(1)', [.5 2]);

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

opts = coco_set([], 'coll', 'NTST', 40);
opts = po_isol2sol(opts, '', @chemosz, seg, p0);
coco(opts, 'run', [], 1, 'PAR(7)', [2, 4]);

opts = var_sol2var([], '', 'run', 14);
opts = coco_set(opts, 'cont', 'ItMX', 1000);
coco(opts, 'var2', [], 1, 'beta', [0 1]);

opts = floquet_start([], 'var2', 31);
floqbd = coco(opts, 'floq', [], 1, 'PAR(7)', [2 4]);

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
opts = po_Hopf2sol([], '', @lorentz, x0, p0);
bd1 = coco(opts, 'runHopf', [], 1, 'PAR(2)', [24.05 25]);

labs = coco_bd_labs(bd1, 'all');
cla;
grid on;
hold on;
for lab=labs
    [t x] = coll_read_sol('', 'runHopf', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'b.-')
end
hold off

opts = var_sol2var([], '', 'runHopf', 10);
opts = coco_set(opts, 'cont', 'ItMX', 1000);
coco(opts, 'var2', [], 1, 'beta', [0 1]);

opts = floquet_start([], 'var2', 14);
floqbd = coco(opts, 'floq', [], 1, 'PAR(2)', [24.05 25]);

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

opts = riess_start(data, floqx0, segs0, p0, vec0, lam0, eps0);

opts = coco_set(opts, 'cont', 'ItMX',[500 0]);
opts = coco_set(opts, 'cont', 'NPR', 50);
opts = coco_add_event(opts, 'bing', 'sigma2', 0);
bd1  = coco(opts, 'run1', [], 1, {'T2' 'sigma2' 'T1'}, {[0 1], [-1 30]});

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

opts = riess_restart([], 'run1', lab);
opts = coco_set(opts, 'cont', 'ItMX',[500 0]);
opts = coco_set(opts, 'cont', 'NPR', 50);
opts = coco_add_event(opts, 'bing', 'sigma1', 0);
bd2  = coco(opts, 'run2', [], 1, {'T1' 'sigma1' 'T2'}, {[0 1], [-30 1]});

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

opts = riess_restart([], 'run2', lab);
opts = coco_set(opts, 'cont', 'ItMX', 300);
bd3  = coco(opts, 'run3', [], 1, {'eps2' 'T2' 'T1'}, [0.000001 .02]);

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

opts = riess_restart([], 'run3', labels(i1));
[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
opts = coco_add_event(opts, 'bing', 'lingap', 0);
opts = coco_set(opts, 'cont', 'ItMX', 500);
bd4  = coco(opts, 'run4', [], 1, {'lingap' 'T2' 'T1' 'PAR(2)' 'eps2'}, [-1 0.1]);

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

opts = riess_restart([], 'run4', lab);
[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
opts = coco_set(opts, 'cont', 'ItMX', 500);
bd5  = coco(opts, 'run5', [], 1, {'PAR(2)' 'T2' 'eps1' 'PAR(3)' 'eps2' 'zcond' 'lingap'}, [10 40]);

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
