% - initial solution now two half circles
% - changed continuation intervals to get more solutions
% - made discretisation of right segment finer

echo on
addpath('../')
addpath('../../msbvp')
addpath('../../coll/Pass_2')
%!tkn1
p0     = [1; 2; 1.5];
modes  = {'left' 'right'};
events = {'boundary' 'boundary'};
resets = {'switch' 'switch'};
t0 = linspace(0, pi, 100)';
x1 = [-sin(t0) 0.5+cos(t0)];
x2 = [ sin(t0) 0.5-cos(t0)];
t0 = {t0 0.5*t0};
x0 = {x1 x2};
prob = coco_prob();
prob = coco_set(prob, 'msbvp.seg1.coll', 'NTST', 10, 'NCOL', 6);
prob = coco_set(prob, 'msbvp.seg2.coll', 'NTST', 20, 'NCOL', 4);
prob = hspo_isol2segs(prob, '', ...
  {@pwlin, @pwlin_events, @pwlin_resets}, ...
  {@pwlin_DFDX, @pwlin_events_DFDX, @pwlin_resets_DFDX}, ...
  {@pwlin_DFDP, @pwlin_events_DFDP, @pwlin_resets_DFDP}, ...
  modes, events, resets, t0, x0, {'al' 'be' 'ga'}, p0);
coco(prob, 'run1', [], 1, 'be', [0 5]);
%!tkn2
%!tkn3
clf
grid on
%!tkn4
bd1 = coco_bd_read('run1');
labs = coco_bd_labs(bd1, 'all');
hold on
for lab=labs
  [sol data] = msbvp_read_solution('', 'run1', lab);
  for i=1:data.nsegs
    plot(sol{i}.x(:,1), sol{i}.x(:,2), 'k.-')
    axis([-1.5 4 -4 6])
    drawnow
  end
end
hold off
%!tkn5
%% test restart
%!tkn6
prob = msbvp_sol2segs(coco_prob(), '', 'run1', 9);
coco(prob, 'run2', [], 1, 'al', [0 4]);
%!tkn7
bd2 = coco_bd_read('run2');
labs = coco_bd_labs(bd2, 'all');
hold on
grid on
for lab=labs
  [sol data] = msbvp_read_solution('', 'run2', lab);
  for i=1:data.nsegs
    plot(sol{i}.x(:,1), sol{i}.x(:,2), 'r-')
    axis([-1.5 4 -4 6])
    drawnow
  end
end
hold off

rmpath('../')
rmpath('../../coll/Pass_2')
echo off