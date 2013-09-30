addpath ('../po');
s=10;
b=8/3;
r=470/19;
p0 = [s; r; b];
x0 = [-sqrt(b*(r-1)); -sqrt(b*(r-1)); r-1];

%% Step 1:
% Continue periodic orbit from Hopf bifurcation
opts = po_Hopf2sol([], '', @lorentz, x0, p0);
coco(opts, 'runHopf', [], 1, 'PAR(2)', [24.05 25]);

%% Step 2:
% Grow solution to variational equation
opts = var_sol2var([], '', 'runHopf', 10);
opts = coco_set(opts, 'cont', 'ItMX', 1000);
coco(opts, 'var2', [], 1, 'beta', [0 1]);

%% Step 3:
% Continue periodic orbit and solution to variational equation
opts = floquet_start([], 'var2', 14);
floqbd = coco(opts, 'floq', [], 1, 'PAR(2)', [24.05 25]);

%% Step 4:
% Grow orbit in stable manifold of periodic orbit
[vardata sol] = coco_read_solution('floquet_save', 'floq', 8);
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

%% Step 5:
% Grow orbit in unstable manifold of equilibrium
opts = riess_restart([], 'run1', 11);
opts = coco_set(opts, 'cont', 'ItMX',[500 0]);
opts = coco_set(opts, 'cont', 'NPR', 50);
opts = coco_add_event(opts, 'bing', 'sigma1', 0);
bd2  = coco(opts, 'run2', [], 1, {'T1' 'sigma1' 'T2'}, {[0 1], [-30 1]});

%% Step 6:
% Sweep family of orbits in stable manifold of periodic orbit
opts = riess_restart([], 'run2', 6);
opts = coco_set(opts, 'cont', 'ItMX', 300);
bd3  = coco(opts, 'run3', [], 1, {'eps2' 'T2' 'T1'}, [0.000001 .02]);

labs3 = coco_bd_labs(bd3, 'ALL');
endpoints = [];
labels = [];
for lab3=labs3
    [t,x]  = coll_read_sol('col2', 'run3', lab3); %#ok<ASGLU>
    endpoints = [endpoints; x(:,end)']; %#ok<AGROW>
    labels = [labels; lab3]; %#ok<AGROW>
end
[t,x]  = coll_read_sol('col1', 'run2', 6); 
pt = repmat(x(:,end)', [size(endpoints,1) 1]);
[m1,i1] = min(sqrt(sum((endpoints-pt).*(endpoints-pt),2)));

%% Step 7:
% Pick orbit in stable manifold of periodic orbit with smallest
% distance in section, fix end point to line through end points
% and shrink gap along line through end points
opts = riess_restart([], 'run3', labels(i1));
[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
opts = coco_add_event(opts, 'bing', 'lingap', 0);
opts = coco_set(opts, 'cont', 'ItMX', 500);
bd4  = coco(opts, 'run4', [], 1, {'lingap' 'T2' 'T1' 'PAR(2)' 'eps2'}, [-1 0.1]);

%% Step 8:
% Continue in parameters
opts = riess_restart([], 'run4', 2);
[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'gap', @lingap, [], 'inactive', {'zcond', 'lingap'}, 'xidx', [xidx1(data1.x1idx) xidx2(data2.x1idx)]);
opts = coco_set(opts, 'cont', 'ItMX', 500);
bd5  = coco(opts, 'run5', [], 1, {'PAR(2)' 'T2' 'eps1' 'PAR(3)' 'eps2' 'zcond' 'lingap'}, [20 30]);