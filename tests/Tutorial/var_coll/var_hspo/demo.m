echo on
addpath('../../hspo')
addpath('../../msbvp')
addpath('../../coll/Pass_2')
%!tkn1
p0     = [1; 2; 1.5];
modes  = {'left', 'right'};
events = {'boundary', 'boundary'};
resets = {'switch', 'switch'};
t0 = linspace(0,pi,100)';
x1 = [-sin(t0) 0.5+cos(t0)];
x2 = [ sin(t0) 0.5-cos(t0)];
t0 = {t0, 0.5*t0};
x0 = {x1, x2};
prob = coco_prob();
prob = coco_set(prob, 'msbvp.seg1.coll', 'NTST', 10, 'NCOL', 6);
prob = coco_set(prob, 'msbvp.seg2.coll', 'NTST', 20, 'NCOL', 4);
prob = hspo_isol2segs(prob, '', ...
  {@pwlin, @pwlin_events, @pwlin_resets}, ...
  {@pwlin_DFDX, @pwlin_events_DFDX, @pwlin_resets_DFDX}, ...
  {@pwlin_DFDP, @pwlin_events_DFDP, @pwlin_resets_DFDP}, ...
  modes, events, resets, t0, x0, {'al', 'be', 'ga'}, p0);
data = coco_func_data();
data.M = {repmat(speye(size(x1,2)), [70 1]), ...
  repmat(speye(size(x2,2)), [100 1])};
data.tbid = {'msbvp.seg1.coll', 'msbvp.seg2.coll'};
data.nsegs = 2;
data.nseg = 1;
uidx1 = coco_get_func_data(prob, 'msbvp.seg1.coll', 'uidx');
prob = coco_add_func(prob, 'var_seg', @var_seg, data, 'regular', ...
  {}, 'uidx', uidx1);
uidx2 = coco_get_func_data(prob, 'msbvp.seg2.coll', 'uidx');
prob = coco_add_func(prob, 'var_seg2', @var_seg, data, 'regular', ...
  {}, 'uidx', uidx2);
hspo_data = coco_get_func_data(prob, 'msbvp', 'data');
data.bc_data = hspo_data.bc_data;
prob = coco_add_func(prob, 'hspo_eigs', @hspo_eigs, data, ...
  'regular', {'l1', 'l2'}, 'uidx', [uidx1; uidx2]);
  
% prob = coco_add_slot(prob, 'var', @var_hspo_bddat, data, 'bddat');
prob = coco_set(prob, 'cont', 'h_max', 0.05);
prob = coco_set(prob, 'cont', 'ItMX', 200);
bd   = coco(prob, 'run1', [], 1, {'be', 'l1', 'l2'}, [1 2]);
%!tkn2
rmpath('../../hspo')
rmpath('../../msbvp')
rmpath('../../coll/Pass_2')
echo off