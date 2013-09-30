% echo on
addpath('../../../coll/Pass_1')
addpath('../../../bvp')
addpath('..')
%!tkn1
% compute approximation of 1:3 phase locked periodic orbit
p0 = [3.5;0.35;0];
[t x0] = ode45(@(t,x) lang(x,p0), [0 5.3], [0.3;0;0.4]);
plot3(x0(:,1), x0(:,2), x0(:,3), 'k-o')

% construct BVP
prob = coco_prob();
prob = bvp_isol2seg(prob, '', @lang, t, x0, {'om' 'ro' 'eps'}, p0, ...
  @po_bc, @po_bc_DFDX);
[fdata uidx] = coco_get_func_data(prob, 'bvp.seg.coll', 'data', 'uidx');
x0idx = uidx(fdata.x0_idx);
prob = coco_add_pars(prob, 'x0idx', x0idx, {'x' 'y' 'z'});

% define atlas properties
prob = coco_set(prob, 'cont', 'atlas', @atlas2_4.create);
prob = coco_set(prob, 'cont', 'h', .25);
prob = coco_set(prob, 'cont', 'PtMX', 5000);
prob = coco_set(prob, 'cont', 'NPR', 50);

% cover 1:3 resonance surface
bd = coco(prob, 'run1', [], 2, {'ro' 'eps' 'x' 'y' 'z'}, ...
  {[] [-0.5 0.5]});

X = coco_bd_col(bd, 'ro');
Y = coco_bd_col(bd, 'eps');
Z = coco_bd_col(bd, 'x');

figure(1)
clf
plot3(X,Y,Z, '.');
axis equal
axis tight
view(60,30)
drawnow

rmpath('..')
rmpath('../../../bvp')
rmpath('../../../coll/Pass_1')
