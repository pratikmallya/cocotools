N  = 20;
D  = diag(-2*ones(N-1,1)) + diag(ones(N-2,1),-1) + diag(ones(N-2,1),1);
D  = N^2*D;
ID = eye(N-1,N-1);

f  = @(u,mu) D*u + mu(2)*u  + mu(1)*exp(u);
fx = @(u,mu) D   + mu(2)*ID + mu(1)*diag(exp(u));
fp = @(u,mu) [ exp(u) u ];

u0 = zeros(N-1,1);
mu = [0;0];

%% run continuation, name branch '1'

bd1 = coco({'bratu' '1'}, 'alg', 'isol', 'eqn', ...
  f, fx, fp, u0, {'mu' 'la'}, mu, 'mu', [0 4]);

% plot bifurcation diagram
u  = coco_bd_col(bd1, {'mu' '||U||'});
plot(u(1,:), u(2:end,:), 'b.-')
grid on
drawnow

%% compute fold curve

labs = coco_bd_labs(bd1, 'FO');

opts = coco_prob();
opts = coco_add_event(opts, 'UZ', 'mu', 0);

% run continuation, name branch '2'
bd2 = coco(opts, {'bratu' '2'}, 'alg', 'FO', 'FO', ...
  {'bratu' '1'}, labs(1), {'mu' 'la'}, {[-4 4] [-2 20]});

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'la' 'mu' '||U||'});
plot3(u(1,:), u(2,:), u(3:end,:), '.-')
view(2)
grid on
drawnow
