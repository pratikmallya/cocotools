echo on
addpath('../')
addpath('../../coll')
addpath('../../hspo')
%!tkn1
p0      = [1; 1; 1];
f       = @(t, x) pwlin(x, p0, struct('seg', 1));
[t1,x1] = ode45(f, [0 pi], [0; 1.1]);
f       = @(t, x) pwlin(x, p0, struct('seg', 2));
[t2,x2] = ode45(f, [0 pi], [0; -1.1]);
opts = coco_set('hspo.seg1.coll', 'NTST', 5, 'NCOL', 6);
opts = hspo_isol2sol(opts, '', @pwlin, {t1, t2}, {x1, x2}, ...
  {'a', 'b', 'c'}, p0, @pwlin_bc, {struct('seg', 1), struct('seg', 2)});
coco(opts, 'run', [], 1, 'b', [0.1 2]);
stab(2, 'run', 2)
%!tkn2
rmpath('../')
rmpath('../../coll')
rmpath('../../hspo')
echo off