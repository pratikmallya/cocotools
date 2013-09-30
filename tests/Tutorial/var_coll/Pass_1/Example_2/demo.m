echo on
addpath('../')
addpath('../../../hspo')
addpath('../../../msbvp')
addpath('../../../coll/Pass_1')
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
prob = var_coll_add(prob, 'msbvp.seg1');
prob = var_coll_add(prob, 'msbvp.seg2');
prob = hspo_mult_add(prob, '');
coco(prob, 'run1', [], 1, 'be', [1 2]);
%!tkn2
rmpath('../../../coll/Pass_1')
rmpath('../../../msbvp')
rmpath('../../../hspo')
rmpath('../')
echo off