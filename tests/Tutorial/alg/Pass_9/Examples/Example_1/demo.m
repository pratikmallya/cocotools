% - examples slightly changed to agree with parameters used in plots in
%   theory section, curves still look very different but results should be
%   comparable at this point
% - demos are reordered to match sequence in text

addpath('../../')
echo on
clf
hold on
grid on
axis equal
view(60,30)
%% First run with bordered matrix event function
%!tkn1
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka' 'la'}, ...
  [0; 0.5]};
prob = alg_isol2eqn(coco_prob(), '', alg_args{:});
coco(prob, 'regular', [], 1, {'ka' 'la' 'alg.test.FO'}, [-0.5 0.5]);
%!tkn4
% plot bifurcation diagrams
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka', 'la'}, ...
  [0; 0.5]};
prob = coco_set(coco_prob(), 'alg', 'norm', true);
prob = alg_isol2eqn(prob, '', alg_args{:});
coco(prob, 'regular', [], 1, {'ka' 'la' 'alg.test.FO'}, [-0.5 0.5]);
bd1 = coco_bd_read('regular');
figure(1)
clf
subplot(1,3,1)
x  = coco_bd_col(bd1, '||U||');
ka = coco_bd_col(bd1, 'ka');
plot(ka, x, '.-')
hold on
idx = coco_bd_idxs(bd1, 'EP');
plot(ka(idx),x(idx),'go');
idx = coco_bd_idxs(bd1, 'FO');
plot(ka(idx),x(idx),'ko');
hold off
grid on
drawnow

%% Second run with bordered matrix event function
%!tkn5
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka' 'la'}, ...
  [0; 0.5]};
prob = coco_set(coco_prob(), 'alg', 'FO', 'active');
prob = alg_isol2eqn(prob, '', alg_args{:});
coco(prob, 'active', [], 1, {'ka' 'la' 'alg.test.FO'}, [-0.5 0.5]);
%!tkn6
% plot bifurcation diagrams
bd2 = coco_bd_read('active');
x  = coco_bd_col(bd2, '||U||');
ka = coco_bd_col(bd2, 'ka');
subplot(1,3,2)
plot(ka, x, '.-')
hold on
idx = coco_bd_idxs(bd2, 'EP');
plot(ka(idx),x(idx),'go');
idx = coco_bd_idxs(bd2, 'FO');
plot(ka(idx),x(idx),'ko');
hold off
grid on
drawnow

%% Fourth run, restarting from fold point
%!tkn9
prob = coco_set(coco_prob(), 'alg', 'FO', 'active');
labs = coco_bd_labs(bd1, 'FO');
prob = alg_sol2eqn(prob, '', 'regular', labs(1));
prob = coco_xchg_pars(prob, 'la', 'alg.test.FO');
coco(prob, 'cusp', [], 1, {'ka' 'la' 'alg.test.FO'}, [-0.5 0.5]);
%!tkn10
% plot bifurcation diagrams
pprob = coco_set(coco_prob(), 'alg', 'norm', true, 'FO', 'active');
labs = coco_bd_labs(bd1, 'FO');
pprob = alg_sol2eqn(pprob, '', 'regular', labs(1));
pprob = coco_xchg_pars(pprob, 'la', 'alg.test.FO');
coco(pprob, 'cusp', [], 1, {'ka' 'la' 'alg.test.FO'}, [-0.5 0.5]);
subplot(1,3,3)
bd = coco_bd_read('cusp');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
plot(ka, la, '.-')
hold on
idx = coco_bd_idxs(bd, 'EP');
plot(ka(idx),la(idx),'go');
hold off
grid on
drawnow

%% Third run, two-dimensional atlas algorithm with bordered matrix event function
addpath('../../../../Atlas_Algorithms/Pass_10');
%!tkn7
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka' 'la'}, ...
  [0; 0.5]};
prob = alg_isol2eqn(coco_prob(), '', alg_args{:});
prob = coco_set(prob, 'cont', 'atlas', @atlas_2d_min.create);
prob = coco_set(prob, 'cont', 'h', .075, 'almax', 35);
prob = coco_set(prob, 'cont', 'NPR', 100, 'PtMX', 2000);
coco(prob, 'cuspsurface', [], 2, {'ka' 'la' 'alg.test.FO'}, ...
  {[-0.5 0.5], [-1 1]});
%!tkn8
prob = coco_set(coco_prob(), 'alg', 'norm', true);
prob = alg_isol2eqn(prob, '', alg_args{:});
prob = coco_set(prob, 'cont', 'atlas', @atlas_2d_min.create);
prob = coco_set(prob, 'cont', 'h', .075, 'almax', 35);
prob = coco_set(prob, 'cont', 'NPR', 100, 'PtMX', 2000);
coco(prob, 'run6', [], 2, {'ka' 'la' 'alg.test.FO'}, ...
  {[-0.5 0.5], [-1 1]});
atlas = coco_bd_read('run6', 'atlas');
bd = coco_bd_read('run6');
figure(1)
clf
subplot(1,2,1)
plot_cuspsurf(atlas.charts, 3, 2, 1);
x  = coco_bd_col(bd, '||x||');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
idx = coco_bd_idxs(bd, 'FO');
hold on
plot3(la(idx), ka(idx), x(idx), 'k.', 'MarkerFaceColor', 'k')
hold off
axis tight
view([100 25]);
grid on
drawnow

subplot(1,2,2)
plot_cuspsurf(atlas.charts, 2, 3, 1);
alpha(0.4)
x  = coco_bd_col(bd, '||x||');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
idx = coco_bd_idxs(bd, 'FO');
hold on
plot3(ka(idx), la(idx), 2+x(idx), 'k.', 'MarkerFaceColor', 'k')
hold off
axis tight
view([0 90]);
grid on
drawnow

rmpath('../../../../Atlas_Algorithms/Pass_10');

return

%% Fifth run, restarting from fold point
%!tkn11
prob = coco_prob();
prob = coco_set(prob, 'alg', 'norm', true, 'FO', 'active');
labs = coco_bd_labs(bd2, 'FO');
prob = alg_sol2eqn(prob, '', 'active', labs(1));
prob = coco_xchg_pars(prob, 'la', 'alg.test.FO');
coco(prob, 'run4', [], 1, {'ka' 'la' 'alg.test.FO'}, [-1 1]);
%!tkn12
% plot bifurcation diagram
bd = coco_bd_read('run4');
x  = coco_bd_col(bd, '||x||');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
plot3(ka, la, x, 'go')