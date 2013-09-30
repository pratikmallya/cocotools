addpath('../')
fprintf('**************************\n\n');

ep = 0.01;

p0 = [10 ; 13.92656 ; 8/3; ep ; 20*ep ; pi/2];

segs(1).mode  = 1;
segs(1).t0    = [0 ; ep];
segs(1).x0    = [-ep*0.583773 -ep 0 ; -2*ep*0.583773 -2*ep 0];
segs(1).NTST  = 7;
segs(1).NCOL  = 3;

segs(2).mode  = 2;
segs(2).t0    = [0 ; 20*ep];
segs(2).x0    = [0 0 20*ep; 0 0 2*20*ep];
segs(2).NTST  = 5;
segs(2).NCOL  = 3;

%% step 1

opts = coll_isol2sol([], 'col1', @lorenz, segs(1), p0);
opts = coll_isol2sol(opts, 'col2', @lorenz, segs(2), p0);

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'addzero', @addzero, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx1(data1.p_idx)  xidx2(data2.p_idx)]);

opts = coco_add_pars(opts, '', ...
    [xidx1(data1.p_idx) xidx1(data1.Tidx) xidx2(data2.Tidx)], 1:8);

opts = coco_add_func(opts, 'mons', @mons, [], 'active', ...
    {'sigma1', 'sigma2', 'delta'}, 'xidx', ...
    [xidx1(data1.x1idx) xidx2(data2.x1idx)]);

opts = coco_set(opts, 'cont', 'ItMX', [-500 500]);
bd1 = coco(opts, 'run1', [], {'PAR(7)' 'sigma1' 'sigma2' 'PAR(6)'}, [ep/2, 0.8]);

labs = coco_bd_labs(bd1, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
    [~,x]  = coll_read_sol('col1', 'run1', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'g.-')
    [t,x]  = coll_read_sol('col2', 'run1', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'k.-')
    drawnow
end
hold off

%% step 2

opts = coll_sol2sol([], 'col1', 'run1', 24);
opts = coll_sol2sol(opts, 'col2', 'run1', 24);

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'addzero', @addzero, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx1(data1.p_idx)  xidx2(data2.p_idx)]);

opts = coco_add_pars(opts, '', ...
    [xidx1(data1.p_idx) xidx1(data1.Tidx) xidx2(data2.Tidx)], 1:8);

opts = coco_add_func(opts, 'mons', @mons, [], 'active', ...
    {'sigma1', 'sigma2', 'delta'}, 'xidx', ...
    [xidx1(data1.x1idx) xidx2(data2.x1idx)]);

opts = coco_set(opts, 'cont', 'ItMX', [-500 500]);
opts = coco_xchg_pars(opts, 'PAR(7)', 'sigma1');
bd2 = coco(opts, 'run2', [], {'sigma1' 'PAR(7)' 'sigma2'}, [-17.9, 0]);

labs = coco_bd_labs(bd2, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
    [~,x]  = coll_read_sol('col1', 'run2', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'g.-')
    [t,x]  = coll_read_sol('col2', 'run2', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'k.-')
    drawnow
end
hold off

%% step3

opts = coll_sol2sol([], 'col1', 'run2', 33);
opts = coll_sol2sol(opts, 'col2', 'run2', 33);

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'addzero', @addzero, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx1(data1.p_idx)  xidx2(data2.p_idx)]);

opts = coco_add_pars(opts, '', ...
    [xidx1(data1.p_idx) xidx1(data1.Tidx) xidx2(data2.Tidx)], 1:8);

opts = coco_add_func(opts, 'mons', @mons, [], 'active', ...
    {'sigma1', 'sigma2', 'delta'}, 'xidx', ...
    [xidx1(data1.x1idx) xidx2(data2.x1idx)]);

opts = coco_set(opts, 'cont', 'ItMX', [-500 500]);
opts = coco_xchg_pars(opts, 'PAR(8)', 'sigma2');
bd3 = coco(opts, 'run3', [], {'sigma2' 'PAR(8)' 'delta'}, [0 2.7]);

labs = coco_bd_labs(bd3, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
    [~,x]  = coll_read_sol('col1', 'run3', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'g.-')
    [t,x]  = coll_read_sol('col2', 'run3', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'k.-')
    drawnow
end
hold off


%% step 4

opts = coll_sol2sol([], 'col1', 'run3', 3);
opts = coll_sol2sol(opts, 'col2', 'run3', 3);

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'addzero', @addzero, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx1(data1.p_idx)  xidx2(data2.p_idx)]);

opts = coco_add_pars(opts, '', ...
    [xidx1(data1.p_idx) xidx1(data1.Tidx) xidx2(data2.Tidx)], 1:8);

opts = coco_add_func(opts, 'mons', @mons, [], 'active', ...
    {'sigma1', 'sigma2', 'delta'}, 'xidx', ...
    [xidx1(data1.x1idx) xidx2(data2.x1idx)]);

opts = coco_set(opts, 'cont', 'ItMX', [-1000 1000]);
opts = coco_xchg_pars(opts, 'PAR(7)', 'sigma1');
opts = coco_xchg_pars(opts, 'PAR(5)', 'sigma2');
opts = coco_xchg_pars(opts, 'PAR(2)', 'delta');
bd4 = coco(opts, 'run4', [], {'delta' 'PAR(6)' 'PAR(7)' 'PAR(1)'}, [-0.5 0]);

labs = coco_bd_labs(bd4, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
    [~,x]  = coll_read_sol('col1', 'run4', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'g.-')
    [t,x]  = coll_read_sol('col2', 'run4', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'k.-')
    drawnow
end
hold off

%% step 5

opts = coll_sol2sol([], 'col1', 'run4', 4);
opts = coll_sol2sol(opts, 'col2', 'run4', 4);

[data1 xidx1] = coco_get_func_data(opts, 'col1.coll_fun', 'data', 'xidx');
[data2 xidx2] = coco_get_func_data(opts, 'col2.coll_fun', 'data', 'xidx');

opts = coco_add_func(opts, 'addzero', @addzero, [], 'zero', 'xidx', ...
    [xidx1(data1.x0idx)  xidx2(data2.x0idx) ...
    xidx1(data1.p_idx)  xidx2(data2.p_idx)]);

opts = coco_add_pars(opts, '', ...
    [xidx1(data1.p_idx) xidx1(data1.Tidx) xidx2(data2.Tidx)], 1:8);

opts = coco_add_func(opts, 'mons', @mons, [], 'active', ...
    {'sigma1', 'sigma2', 'delta'}, 'xidx', ...
    [xidx1(data1.x1idx) xidx2(data2.x1idx)]);

opts = coco_set(opts, 'cont', 'ItMX', [-1000 1000]);
opts = coco_xchg_pars(opts, 'PAR(7)', 'sigma1');
opts = coco_xchg_pars(opts, 'PAR(5)', 'sigma2');
opts = coco_xchg_pars(opts, 'PAR(2)', 'delta');
opts = coco_add_event(opts, 'UZ', 'PAR(3)', [8/3, 14/3, 20/3, 26/3, 32/3]);
bd5 = coco(opts, 'run5', [], {'PAR(3)' 'PAR(6)' 'PAR(7)' 'PAR(2)'}, [2 10]);

labs = coco_bd_labs(bd5, 'UZ');
figure(1)
clf
hold on
grid on
for lab=labs
    [~,x]  = coll_read_sol('col1', 'run5', lab);
    plot(x(1,:), x(3,:), 'g.-')
    [t,x]  = coll_read_sol('col2', 'run5', lab);
    plot(x(1,:), x(3,:), 'k.-')
    drawnow
end
hold off