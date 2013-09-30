% - first part is identical to demo in Examples_2
% - second part shows continuation of homoclinic curve
%   NOTE: please increase scale and fac. The numbers below are for tests
%   with reasonable computation time on my notebook, for the book we should
%   demonstrate something like scale = 100; fac = 2; note that larger
%   meshes are unreasonably expensive  with non-adaptive codes
% - please add '%tkn#' markers as necessary
%

echo on
addpath('../../coll/Pass_1')
addpath('../')
%!tkn1
t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0;6];
%!tkn2
prob = coco_prob();
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'run1', [], 1, {'p1' 'po.period'}, [-1 1]);
%!tkn3


% we restart at last computed solution with T=1.9553e+01
% find mesh point closest to equilibrium
%!tkn4
sol1 = po_read_solution('', 'run1', 6);
f = marsden(sol1.x', repmat(sol1.p, [1 size(sol1.x, 1)]));
[mn idx] = min(sqrt(sum(f.*f, 1)));
%!tkn5
% perform surgery on periodic orbit to crank up period,
% po.period -> scale*po.period
% scale = 100;
%!tkn6
scale = 25;
T  = sol1.t(end);
t0 = [sol1.t(1:idx,1) ; T*(scale-1)+sol1.t(idx+1:end,1)];
x0 = sol1.x;
p0 = sol1.p;
%!tkn7
% restart with much finer mesh, rule of thumb for uniform mesh of same quality:
%    NTST(new) = scale*NTST(old)
% to improve quality use
%    NTST(new) = fac*scale*NTST(old)
% with fac>1
% Exercise: Why is this 'remeshing' correct?
% Exercise: Repeat this computation with moving mesh using
%    NTST(new) = fac*NTST(old)
% instead. Why can we ommit the factor scale here?
fac = 1.0;
% fac = 2.0;
%!tkn8
prob = coco_set(coco_prob(), 'coll', 'NTST', ceil(scale*10));
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
%!tkn9
prob = coco_xchg_pars(prob, 'p2', 'po.period');
coco(prob, 'run2', [], 1, {'p1' 'p2'}, [-1 1]);
%!tkn10
% exchange parameters to fix period and free p2
% compute family of homoclinic orbits, if not all columns fit, make 'check
% that period is constant an exercise)
% coco(prob, 'run2', [], 1, {'p1' 'p2' 'po.period'}, [-1 1]);

rmpath('../../coll/Pass_1')
rmpath('../')