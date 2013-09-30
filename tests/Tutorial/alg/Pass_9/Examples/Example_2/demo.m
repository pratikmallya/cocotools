addpath('../../');
addpath('../../../../Atlas_Algorithms/Pass_11')
w_state = warning('off', 'backtrace');
echo on
%!tkn1
N =40;
D = diag(-2*ones(N-1,1))+diag(ones(N-2,1),-1)+diag(ones(N-2,1),1);
D = N^2*D;
ID = eye(N-1,N-1);
f  = @(u,mu) D*u+mu(2)*u+mu(1)*exp(u);
fx = @(u,mu) D+mu(2)*ID+mu(1)*diag(exp(u));
fp = @(u,mu) [exp(u) u];
u0 = zeros(N-1,1);
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas_1d_min.create);
prob = coco_set(prob, 'cont', 'PtMX', 200, 'NPR', 50);
prob = coco_set(prob, 'cont', 'BP', true);
prob = coco_set(prob, 'alg', 'FO', 'regular');
coco(prob, 'bratu1', @alg_isol2eqn, f, fx, fp, u0, ...
    {'mu', 'la'}, [0; 0], 1, 'mu', [-4 4]);
%!tkn2
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas_1d_min.create);
prob = coco_set(prob, 'cont', 'PtMX', -500, 'NPR', 50);
prob = coco_set(prob, 'cont', 'BP', true);
prob = coco_set(prob, 'alg', 'FO', 'active');
prob = coco_xchg_pars(prob, 'alg.FO', 'la');
coco(prob, 'bratu2', @alg_sol2eqn, 'bratu1', 3, 1, {'la' 'mu'}, [-10 10]);
%!tkn3
echo off
warning(w_state.state, w_state.identifier);
rmpath('../../../../Atlas_Algorithms/Pass_11')
rmpath('../../');