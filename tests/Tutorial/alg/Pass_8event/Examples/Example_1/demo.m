addpath('../../')
clf
hold on

%% First run with default fold event function
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka', 'la'}, [0; 1]};
prob = coco_prob();
prob = coco_set(prob, 'alg', 'norm', true, 'FOTF', 'fold1c');
prob = alg_isol2eqn(prob, '', alg_args{:});
bd1   = coco(prob, 'run1', [], 1, {'ka' 'la' 'alg.FO'}, [-1 1]);

% plot bifurcation diagram
x  = coco_bd_col(bd1, '||x||');
ka = coco_bd_col(bd1, 'ka');
la = coco_bd_col(bd1, 'la');

plot3(ka, la, x, 'r.-')
grid on
drawnow

%% Second run with bordered matrix event function
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka', 'la'}, [0; 1]};
prob = coco_prob();
prob = coco_set(prob, 'alg', 'FOTF', 'fold2_reg', 'norm', true);
prob = alg_isol2eqn(prob, '', alg_args{:});
bd2 = coco(prob, 'run2', [], 1, {'ka' 'la' 'alg.FO'}, [-1,1]);

% plot bifurcation diagram
x  = coco_bd_col(bd2, '||x||');
ka = coco_bd_col(bd2, 'ka');
la = coco_bd_col(bd2, 'la');

plot3(ka, la, x, 'g.-')
grid on
drawnow

%% Third run with bordered matrix event function
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka', 'la'}, [0; 1]};
prob = coco_prob();
prob = coco_set(prob, 'alg', 'FOTF', 'fold2_act', 'norm', true);
prob = alg_isol2eqn(prob, '', alg_args{:});
bd3 = coco(prob, 'run3', [], 1, {'ka' 'la' 'alg.FO'}, [-1,1]);

% plot bifurcation diagram
x  = coco_bd_col(bd3, '||x||');
ka = coco_bd_col(bd3, 'ka');
la = coco_bd_col(bd3, 'la');

plot3(ka, la, x, 'b.-')
grid on
drawnow

%% Fourth run, restarting from fold point
prob = coco_prob();
prob = coco_set(prob, 'alg', 'FOTF', 'fold2_act', 'norm', true);
labs = coco_bd_labs(bd3, 'FO');
prob = alg_sol2eqn(prob, '', 'run3', labs(1));
prob = coco_xchg_pars(prob, 'la', 'alg.FO');
bd4  = coco(prob, 'run4', [], 1, {'ka' 'la'}, [-1 1]);

% plot bifurcation diagram
x  = coco_bd_col(bd4, '||x||');
ka = coco_bd_col(bd4, 'ka');
la = coco_bd_col(bd4, 'la');

plot3(ka, la, x, 'k')
grid on
drawnow

%% Fifth run, restarting from fold point
prob = coco_prob();
prob = coco_set(prob, 'alg', 'FO', false, 'norm', true);
labs = coco_bd_labs(bd1, 'FO');
prob = alg_FO2FO(prob, '', 'run1', labs(1));
bd5  = coco(prob, 'run5', [], 1, {'ka' 'la'}, {[-2 2] [-2 2]});

% plot bifurcation diagram
x  = coco_bd_col(bd5, '||x||');
ka = coco_bd_col(bd5, 'ka');
la = coco_bd_col(bd5, 'la');

plot3(ka, la, x, 'go')
grid on
drawnow

%% Sixth run, two-dimensional atlas algorithm
addpath('../../../../Atlas_Algorithms/Pass_10');
alg_args = {@cusp, @cusp_DFDX, @cusp_DFDP, 0, {'ka', 'la'}, [0; 1]};
prob = coco_prob();
prob = coco_set(prob, 'alg', 'FO', false, 'norm', true);
prob = coco_set(prob, 'cont', 'atlas', @atlas_2d_min.create);
prob = coco_set(prob, 'cont', 'h', .1, 'almax', 35);
prob = coco_set(prob, 'cont', 'NPR', 100, 'PtMX', 2000);
prob = alg_isol2eqn(prob, '', alg_args{:});
bd6  = coco(prob, 'run6', [], 2, {'ka' 'la'}, {[-2,2], [-2, 2]});
atlas = coco_bd_read('run6', 'atlas');
plot_trisurf(atlas.charts, 1, 2, 3);
axis equal
view(60,30)
rmpath('../../../../Atlas_Algorithms/Pass_10');