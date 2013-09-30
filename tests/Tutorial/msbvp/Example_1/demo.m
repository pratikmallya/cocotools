% echo on
addpath('../../coll/Pass_1')
addpath('..')
%!tkn1
% compute approximation of periodic orbit of reduced system in y=0 plane
% period of po of reduced system T_po_red
p0 = [3.5;0.35;0];
N  = 101;
T_po_ret = 5.3;
[t x0] = ode45(@(t,x) lang_red(x,p0), linspace(0,T_po_ret,N+1), [0.3;0.4]);
plot(x0(:,1), x0(:,2), 'ko')

% return time T_ret = 2*pi/om
% rotation number = T_ret/T_po_red
T_ret = 2*pi/p0(1);
r     = T_ret/T_po_ret;
p0    = [p0;T_ret;0]; % add unfolding parameter and Tail

% compute set of initial segments as x0 times group orbit:
% x0 -> [cos(t)*x0(:,1) sin(t)*x0(:,1) x0(:,2)]
tt  = linspace(0,1,20*N)';
t1  = T_ret*tt;
stt = sin(tt*2*pi);
ctt = cos(tt*2*pi);
coll_in = {};
clf
set(gca, 'DrawMode', 'fast');
hold on
for i=1:N
  [t xx]  = ode45(@(t,x) lang_red(x,p0), [0 T_ret], x0(i,:));
  xx      = interp1(t, xx, t1);
  x1      = [ctt.*xx(:,1) stt.*xx(:,1) xx(:,2)];
  coll_in = [coll_in {@lang @lang_DFDX @lang_DFDP t1 x1 p0}];
  % coll_in = [coll_in {@lang t1 x1 p0}];
  plot3(x1(:,1), x1(:,2), x1(:,3));
  plot3(x1(1,1), x1(1,2), x1(1,3), 'ko');
  grid on
  view([-15 20]);
  drawnow
end
hold off

% construct data for boundary conditions
% - real Fourier transforms
Q  = (N-1)/2;
Th = 2*pi*(0:N-1)/N;
Th = kron(1:Q, Th');
Fi = [ones(N,1) reshape([sin(Th);cos(Th)], [N 2*Q])];
F  = [ones(N,1) 2*reshape([sin(Th);cos(Th)], [N 2*Q])]'/N;

% - rotation matrix
Th  = (1:Q)*2*pi*r;
R   = diag([1 kron(cos(Th), [1 1])]);
SIN = [ zeros(size(Th)) ; sin(Th) ];
R   = R + diag(SIN(:),-1) - diag(SIN(:),+1);
RF  = R * F;

% - quality measure norm of tail
Qt = floor((Q-1)/2);
Ct = reshape(1:3*N, 3, N);
Ct = Ct(:,(N-2*Qt)+(1:Qt));

% - pass data through anonymous function, Fi, R for debugging
data.F  = kron(F , eye(3));
data.Fi = kron(Fi, eye(3));
data.R  = R;
data.RF = kron(RF, eye(3));
data.Ct = Ct(:);

% construct MS BVP
prob = coco_prob();
prob = msbvp_isol2segs(prob, '', coll_in{:}, ...
  {'om' 'ro' 'eps' 'T_ret' 'Tail'}, ...
  @torus_bc, @torus_bc_DFDX, data);

% compute initial torus
coco(prob, 'run0', [], 0, {'ro' 'T_ret' 'Tail'});
prob = msbvp_sol2segs(coco_prob(), '', 'run0', 1);

% run continuation of relative periodic orbits
% prob = coco_set(prob, 'corr', 'ItMX', 30);
% prob = coco_set(prob, 'coll', 'NTST', 20);
% prob = coco_set(prob, 'cont', 'NPR', 1);
% prob = coco_set(prob, 'cont', 'ItMX', 0);
% construct MS BVP
coco(prob, 'run1', [], 1, {'ro' 'om' 'T_ret' 'Tail'}, [0 1]);

% optional plot of family of tori
plot_tori('run1');

% run continuation of proper quasiperiodic torus in eps
% prob = coco_set(prob, 'corr', 'ItMX', 30);
% prob = coco_set(prob, 'coll', 'NTST', 20);
coco(prob, 'run2', [], 1, {'eps' 'ro' 'T_ret' 'Tail'}, [-0.3 0.3]);

% optional plot of family of tori
plot_tori('run2');