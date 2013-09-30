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

% define atlas properties
prob = coco_set(prob, 'cont', 'atlas', @atlas2_x.create);
prob = coco_set(prob, 'cont', 'h', .25);
prob = coco_set(prob, 'cont', 'PtMX', 5000);
prob = coco_set(prob, 'cont', 'NPR', 50);

% cover 1:3 resonance surface
bd = coco(prob, 'run1', [], 2, {'ro' 'eps'}, {[] [-0.5 0.5]}); % [-1 1] looks really cool

[fdata uidx] = coco_get_func_data(prob, 'bvp.seg.coll', 'data', 'uidx');
ix = uidx(fdata.p_idx(2));
iy = uidx(fdata.p_idx(3));
iz = uidx(fdata.x0_idx(1));
atlas = coco_bd_read('run1', 'atlas');

figure(1)
clf
col = gray(1000);
colormap(col(end-200:end,:))

subplot(1,2,1)
[tri X] = atlas2_x.plot_charts(atlas, ix, iy, iz);
trisurf(tri, X(:,1), X(:,2), X(:,3), 'edgecolor', 0.75*[1 1 1]);
axis equal
axis tight
view(60,30)
drawnow

subplot(1,2,2)
[tri X] = atlas2_x.trisurf(atlas, ix, iy, iz);
% [tri X] = atlas2_5.trisurf(atlas, 153, 154, 1);
trisurf(tri, X(:,1), X(:,2), X(:,3), 'edgecolor', 0.75*[1 1 1]);
axis equal
axis tight
view(60,30)
drawnow

rmpath('..')
rmpath('../../../bvp')
rmpath('../../../coll/Pass_1')
