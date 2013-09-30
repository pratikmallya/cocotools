echo on
%!tkn1
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas_0d.create);
%% basic test
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [2;0.5] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 0, {'x' 'y'});
%!tkn2
%% MX with parameters
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [2;1.5] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 0, {'x' 'y'});
%!tkn3
%% MX, no parameters
pprob = coco_add_func(prob, 'func', @empty, [], 'zero', 'x0', 1 );
coco(pprob, '1', [], 0);
%!tkn4
%% singular problem
pprob = coco_add_func(prob, 'func', @singular, [], 'zero', 'x0', 1 );
coco(pprob, '1', [], 0);
%!tkn5
echo off
