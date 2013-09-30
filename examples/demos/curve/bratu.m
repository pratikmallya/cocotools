N  = 20;
D  = diag(-2*ones(N-1,1)) + diag(ones(N-2,1),-1) + diag(ones(N-2,1),1);
D  = N^2*D;
ID = eye(N-1,N-1);

f  = @(u,mu) D*u + mu(2)*u  + mu(1)*exp(u);
fx = @(u,mu) D   + mu(2)*ID + mu(1)*diag(exp(u));
fp = @(u,mu) [ exp(u) u ];

u0 = zeros(N-1,1);
mu = [0;0];

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'mu' 'la'});

%% run continuation, name branch '1'

opts = coco_set(opts, 'cont', 'ItMX', 200);

bd1 = coco(opts, {'bratu' '1'}, 'curve', 'sol', 'sol', ...
  f, fx, fp, u0, mu, 'mu', [0 4]);

% plot bifurcation diagram
u  = coco_bd_col(bd1, {'mu' '||x||'});
subplot(1,2,1);
plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow

%% compute fold curve

labs = coco_bd_labs(bd1, 'FP');
opts = coco_add_event(opts, 'UZ', 'mu', 0);

% run continuation, name branch '2'
bd2 = coco(opts, {'bratu' '2'}, 'curve', 'LP', 'LP', ...
  {'bratu' '1'}, labs(1), {'mu' 'la'}, {[-4 4] [-2 20]});

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'la' 'mu' '||x||'});
subplot(1,2,2);
plot3(u(1,:), u(2,:), u(3,:), '.-')
view(2)
grid on
drawnow
