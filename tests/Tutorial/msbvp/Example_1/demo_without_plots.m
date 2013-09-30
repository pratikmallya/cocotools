echo on
addpath('../../coll/Pass_1')
addpath('..')
%!tkn1
p0     = [3.5; 0.35; 0];
T_po   = 5.3;
N      = 50;
tout   = linspace(0, T_po, 2*N+2);
[t x0] = ode45(@(t,x) lang_red(x, p0), tout, [0.3; 0.4]);
%!tkn2
T_ret = 2*pi/p0(1);
tt    = linspace(0, 1, 20*(2*N+1))';
t1    = T_ret*tt;
stt   = sin(tt*2*pi);
ctt   = cos(tt*2*pi);
coll_args = {};
for i=1:2*N+1
  [t xx]  = ode45(@(t,x) lang_red(x, p0), [0 T_ret], x0(i,:));
  xx      = interp1(t, xx, t1);
  x1      = [ctt.*xx(:,1) stt.*xx(:,1) xx(:,2)];
  coll_args = [coll_args {@lang, @lang_DFDX, @lang_DFDP, ...
    t1, x1, [p0; T_ret]}];
end
%!tkn3
Th  = 2*pi*(0:2*N)/(2*N+1);
Th  = kron(1:N, Th');
F   = [ones(2*N+1,1) ...
  2*reshape([cos(Th); sin(Th)], [2*N+1 2*N])]'/(2*N+1);
Th  = (1:N)*2*pi*T_ret/T_po;
SIN = [zeros(size(Th)); sin(Th)];
R   = diag([1, kron(cos(Th), [1, 1])])+ ...
  diag(SIN(:), 1)-diag(SIN(:), -1);
data.F  = kron(F, eye(3));
data.RF = kron(R*F, eye(3));
%!tkn4
prob = msbvp_isol2segs(coco_prob(), '', coll_args{:}, ...
  {'om' 'ro' 'eps' 'T_ret'}, @torus_bc, @torus_bc_DFDX, data);
coco(prob, 'run0', [], 0, {'ro' 'T_ret'});
%!tkn5
prob = msbvp_sol2segs(coco_prob(), '', 'run0', 1);
coco(prob, 'run_eps', [], 1, {'eps' 'ro' 'T_ret'}, [-0.3 0.3]);
%!tkn6
% Make the continuation below an excercise together with the question "Why
% does there exist a family of invariant tori? (RPOs are codin-0 just like
% POs)
% coco(prob, 'run1', [], 1, {'ro' 'om' 'T_ret'}, [0 1]);
rmpath('../../coll/Pass_1')
rmpath('..')
echo off