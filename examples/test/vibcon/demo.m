
p0 = [0.1 0.1 0.1 sqrt(2.1) 4 0.95 0.2 0.5 0.13]';
x0 = [0 0 0 0 0 1]';
f  = @(t,x) vibcon(x,p0);

% p0 = [0.1 0.1 0.1 sqrt(2.1) 4 0.95 0.2 0.5 0.1]';
% x0 = [0.001*rand(1,4) 0 1]';
% ode15s(f, [0 1000], x0)

[t z] = ode15s(f, [0 2*pi/p0(8)], x0);

t0    = t';
x0    = z';

opts = coco_set('coll', 'NTST', 10, 'NCOL', 4);
opts = coco_set(opts, 'pocont', 'bifurcations', 'on');

% opts = coco_set(opts, 'cont', 'NPR', 200);
opts = coco_set(opts, 'cont', 'ItMX', [50 50]);
opts = coco_set(opts, 'cont', 'LogLevel', 1);
opts = coco_set(opts, 'nwtn', 'TOL', 1.0e-5);
opts = coco_set(opts, 'nwtn', 'SubItMX', 3);

bd1 = coco(opts, 'pocont', @vibcon, 'po1', 'ipo', 'po', ...
	t0, x0, p0, {'PAR(9)' 'Period' 'LP' 'PD' 'TR'}, [0.1 0.15]);

% pars = [ bd1{2:end,7} ];
% pars = [ pars ; p0(2)*ones(size(pars)) ; bd1{2:end,8}];
% plot3(pars(1,:), pars(2,:), pars(end,:), 'b.-');
% axis([0 7 0.3 1 0 10]);
% grid on

%%
return %#ok<*UNRCH>

%%
p0 = [-5.90624e-01 ; 0.5 ; -0.6 ; 0.6 ; 0.328578 ; 0.933578];
opts = coco_set(opts, 'cont', 'ItMX', [50 50]);

bd2 = coco(opts, 'pocont', @tor, 'po2', 'ipo', 'po', ...
	@stpnt2, p0, {'PAR(1)' 'Period' 'LP' 'PD' 'TR'}, [-0.65, -0.55]);

pars = [ bd2{2:end,7} ];
pars = [ pars ; p0(2)*ones(size(pars)) ; bd2{2:end,8}];
hold on
plot3(pars(1,:), pars(2,:), pars(end,:), 'r.-');
hold off

%%
opts = coco_set(opts, 'cont', 'NPR', 1, 'NSV', 10);
PDlabs = [bd2{ 1+find(strcmp('PD', {bd2{2:end,4}})) , 6}];
bd3 = coco(opts, 'pocont', @tor, 'pd1', 'po', 'PD', ...
	'po2', PDlabs(1), {'PAR(1)' 'Period' 'PAR(2)' 'LP' 'PD' 'TR'}, [-0.65, -0.55]);

pars = [bd3{2:end,9} ; bd3{2:end,8}];
hold on
plot3(pars(1,:), pars(3,:), pars(end,:), 'g.-');
hold off

%%
opts = coco_set(opts, 'cont', 'NPR', 1, 'NSV', 10);
LPlabs = [bd1{ 1+find(strcmp('LP', {bd1{2:end,4}})) , 6}];
bd4 = coco(opts, 'pocont', @tor, 'lp1', 'po', 'LP', ...
	'po1', LPlabs(1), {'PAR(1)' 'Period' 'PAR(2)' 'LP' 'PD' 'TR'}, [-0.65, -0.55]);

pars = [bd4{2:end,9} ; bd4{2:end,8}];
hold on
plot3(pars(1,:), pars(3,:), pars(7,:), 'm.-');
hold off

%%
opts = coco_set(opts, 'cont', 'NPR', 1, 'NSV', 10);
TRlabs = [bd2{ 1+find(strcmp('TR', {bd2{2:end,4}})) , 6}];
bd5 = coco(opts, 'pocont', @tor, 'tr1', 'po', 'TR', ...
	'po2', TRlabs(1), {'PAR(1)' 'Period' 'PAR(2)' 'LP' 'PD' 'TR'}, [-0.65, -0.55]);

pars = [bd5{2:end,9} ; bd5{2:end,8}];
hold on
plot3(pars(1,:), pars(3,:), pars(7,:), 'c.-');
hold off
