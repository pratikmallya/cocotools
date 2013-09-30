fprintf('\n**************** starting %s ****************\n',mfilename);
addpath('..');

%% Forward simulation to generate approximate non-impacting limit cycle
% p = [m; A; c; k; om; qc; e]
p0 = [1; 3; 0.1; 1; 2; 1; 0.8];
x0 = [-0.998; 0.133; 0];

f = @(t,x) field(x, p0, 'all');
h = @(t,x) event(x, p0, 'all');
ode_opts = odeset('RelTol', 1.0e-8, 'AbsTol', 1.0e-8, 'NormControl', 'on', 'Events', h);
T = [];
Y = [];
TE = [];
YE = [];
IE = [];
tstart = 0;
tfinal = 100;
while tstart<tfinal
    [t, y, te, ye, ie] = ode45(f, [tstart tfinal], x0, ode_opts);
    T = [T; t];
    Y = [Y; y];
    TE = [TE; te];
    YE = [YE; ye];
    IE = [IE; ie];
    tstart=t(end);
    x0 = y(end,:);
    if ~isempty(ie)
        x0 = jump(x0, p0, ie);
    end
end
                
%% Initial continuation of branch of non-impacting limit cycles

p0 = [1; 3; 0.1; 1; 2; 1; 0.8];
signature = [3,2];
x0 = [ -0.9956 0.9978; 0.1327 0; 0 3.075];

opts = [];
opts = coco_set(opts, 'mshoot', 'bifus', true);
opts = multishoot_create(opts, @field, @field_dx, @field_dp, ...
    @event, @event_dx, @event_dp, ...
    @jump,  @jump_dx,  @jump_dp, [], [], ...
    x0, {'m' 'A' 'c' 'k' 'om' 'qc' 'e'}, p0, ...
    signature);
opts = coco_add_func(opts, 'grazing', @grazing, [], 'active', 'graze', 'xidx', [4, 12]);
opts = coco_add_event(opts, 'GZ', 'graze', 0);
cont_pars = {'om' 'graze'};
opts = coco_set(opts, 'cont', 'covering', @cover_1d_min_ev.create);
tic
bd1 = coco(opts, '1', [], cont_pars, [2 8]);
toc

plot_bd(bd1, 5, 4)

%% Continuation of grazing bifurcation curve

lab = coco_bd_labs(bd1,'GZ');
[~, sol] = coco_read_solution('','1',lab);
x0 = reshape(sol.x(1:6), [3 2]);
p0 = sol.x(7:13);
signature = [3,2];
opts = [];
opts = coco_set(opts, 'multishoot', 'ParNames', {'m' 'A' 'c' 'k' 'om' 'qc' 'e'});
opts = multishoot_create2(opts, @field, @field_dx, @field_dp, ...
    @event, @event_dx, @event_dp, ...
    @jump,  @jump_dx,  @jump_dp, x0, p0, ...
    signature);
opts = coco_add_func(opts, 'grazing', @grazing, [], 'active', 'graze', 'xidx', [4, 12]);
opts = coco_add_event(opts, 'GZ', 'graze', 0);
opts = coco_xchg_pars(opts, 'graze', 'A');

cont_pars = {'om' 'A' 'graze'};
bd2 = coco(opts, '2', [], cont_pars, [0.05 2.25]);

p = coco_bd_col(bd2, 'p');
figure(2)
plot(p(5,:),p(2,:),'b')

%% Forward simulation to generate approximate impacting limit cycle
% p = [m; A; c; k; om; qc; e]
p0 = [ 1; 3.2; 0.1; 1; 2; 1; 0.8 ];
x0 = [-0.998; 0.133; 0];

f = @(t,x) field(x, p0, 'all');
h = @(t,x) event(x, p0, 'all');
ode_opts = odeset('RelTol', 1.0e-8, 'AbsTol', 1.0e-8, 'NormControl', 'on', 'Events', h);
T = [];
Y = [];
TE = [];
YE = [];
IE = [];
tstart = 0;
tfinal = 100;
while tstart<tfinal
    [t, y, te, ye, ie] = ode45(f, [tstart tfinal], x0, ode_opts);
    T = [T; t];
    Y = [Y; y];
    TE = [TE; te];
    YE = [YE; ye];
    IE = [IE; ie];
    tstart=t(end);
    x0 = y(end,:);
    if ~isempty(ie)
        x0 = jump(x0, p0, ie);
    end
end
                
%% Continuation of branch of impacting limit cycles

p0 = [ 1; 3.2; 0.1; 1; 2; 1; 0.8 ];
x0 = [ -4.585 1; 1.022 -3.231; 0 2.746];
signature = [1,2];
opts = [];
opts = coco_set(opts, 'multishoot', 'LP', 1);
opts = coco_set(opts, 'multishoot', 'PD', 1);
opts = coco_set(opts, 'multishoot', 'NS', 1);
opts = coco_set(opts, 'multishoot', 'ParNames', {'m' 'A' 'c' 'k' 'om' 'qc' 'e'});
opts = multishoot_create(opts, @field, @field_dx, @field_dp, ...
    @event, @event_dx, @event_dp, ...
    @jump,  @jump_dx,  @jump_dp, x0, p0, ...
    signature);
opts = coco_add_parameters(opts, 'velocity', 5, 'vel');
opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'h_min', 1e-5);
opts = coco_set(opts, 'corr', 'TOL', 1e-10);
cont_pars = {'A' 'vel' 'test_PD' 'stab'};
bd3 = coco(opts, '3', [], cont_pars, {[2.9 3.2], [-10 -1e-4]});

p = coco_bd_col(bd3,'A');
v = coco_bd_col(bd3,'vel');
lab = coco_bd_labs(bd3,'PD');
pb = coco_bd_val(bd3, lab, 'A');
vb = coco_bd_val(bd3, lab, 'vel');


clf
hold on
plot(p,v,'r.')
plot(p,v,'g')
plot(pb,vb,'bo')
hold off

%% shoot past impact to evaluate penetrations

labs = coco_bd_labs(bd3,'all');
X = zeros(length(labs),3);
P = zeros(length(labs),7);
for i=1:length(labs)
    lab=labs(i);
    [data sol] = coco_read_solution('','3',lab);
    x0 = reshape(sol.x(1:6), [3 2]);
    p0 = sol.x(7:13);
    f = @(t,x) field(x, p0, 3);
    h = @(t,x) event(x, p0, 3);
    ode_opts = odeset('RelTol', 1.0e-8, 'AbsTol', 1.0e-8, 'NormControl', 'on', 'Events', h);
    [t, y, te, ye, ie] = ode45(f, [0 2*pi], x0(:,1), ode_opts);
    P(i,:) = p0;
    X(i,:) = ye(end,:);
end

clf
hold on
plot(P(:,2),X(:,1)-1,'b')
plot(P(:,2),X(:,1)-1,'r.')
hold off

%% finish
rmpath('..');
