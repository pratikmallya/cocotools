N  = 40;
P  = 3*N+1;
Q  = 2*N+1;
X  = reshape(1:P*Q, P, Q);

Mask            = true(P, Q);
Mask(1:end,1)   = false;
Mask(1:end,end) = false;
Mask(1,1:end)   = false;
Mask(end,1:end) = false;
Mask(1:2*N+1,1:N+1) = false;

rows = X(Mask);
cols = rows;
o    = ones(numel(rows), 1);
C    = sparse(rows, cols, o, P*Q, P*Q);
D    = sparse(rows, cols, -4*o, P*Q, P*Q);
cols = X(circshift(Mask, [0 1]));
D    = D + sparse(rows, cols, o, P*Q, P*Q);
cols = X(circshift(Mask, [0 -1]));
D    = D + sparse(rows, cols, o, P*Q, P*Q);
cols = X(circshift(Mask, [1 0]));
D    = D + sparse(rows, cols, o, P*Q, P*Q);
cols = X(circshift(Mask, [-1 0]));
D    = D + sparse(rows, cols, o, P*Q, P*Q);
D    = N^2*D;

rows = X(~Mask);
cols = rows;
o    = ones(numel(rows), 1);
B    = sparse(rows, cols, o, P*Q, P*Q);

Id   = speye(P*Q, P*Q);

f  = @(u,mu) D*u + mu(1)*(C*u + mu(2)*(C*exp(u))) - B*u;
fx = @(u,mu) D + mu(1)*(C + mu(2)*(C*spdiags(exp(u),0,Id))) - B;
fp = @(u,mu) [C*u+mu(2)*(C*exp(u)) mu(1)*(C*exp(u))];

mu = [ 0.1 ; 0 ];
u0 = zeros(P*Q,1);

% ode15s(@(t,x) f(x,mu), [0 200], u0+0.1*rand(size(u0))); return

%%

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'la' 'mu'});
opts = coco_set(opts, 'cont', 'ItMX', 100);

% run continuation, name branch '1'
bd1 = coco(opts, {'pdeeig' '1'}, 'curve', 'sol', 'sol', ...
  f, fx, fp, u0, mu, 'la', [-5 50]);

%% add norm as test function
data.x_idx = 1:P*Q;
opts = coco_add_func(opts, '||X||', @norm_X, data, ...
  'regular', '||X||', 'xidx', 'all');

% add ||x|| = 1 as boundary event to compute unit eigenfunction
opts = coco_add_event(opts, 'UZ', 'BP', '||X||', 1);

%% compute eigenfunctions

labs = coco_bd_labs(bd1, 'BP');
opts = coco_set(opts, 'cont', 'ItMX', [0 10]);

for lab = labs
  % run continuation, name branch '2'
  bd2 = coco(opts, {'pdeeig' sprintf('2lab%02d', lab)}, 'curve', 'BP', 'sol', ...
    {'pdeeig' '1'}, lab, 'la');
  
  % plot bifurcation diagram
  ulab = coco_bd_labs(bd2, 'UZ');
  U    = coco_bd_val(bd2, 2, 'x');
  U    = reshape(U,P,Q);
  [X Y] = meshgrid(linspace(0,2,Q), linspace(0,3,P));
  clf
  mesh(X,Y,U)
  view([-125 60])
  drawnow
end
