N  = 20;
X  = 1:N+1;
Y  = N+1+X;
B  = [ 1 ; zeros(N-1,1) ; 1 ];
BX = repmat(B, 1, N+1);
BP = repmat(B, 1, 4);
C  = [ 0 ; ones(N-1,1) ; 0 ];
CX = repmat(C, 1, N+1);
CP = repmat(C, 1, 4);
D  = diag([0 -2*ones(1,N-1) 0]) + ...
  diag([ ones(1,N-1) 0 ],-1) + ...
  diag([ 0 ones(1,N-1) ],1);
D  = N^2*D;
ID = eye(N+1,N+1);
O  = ones(N+1,1);
ZE = zeros(N+1,1);

f  = @(u,mu) [
  C.*(mu(3)*D*u(X) + mu(1) + u(X).^2.*u(Y) - (mu(2)+1)*u(X)) + B.*(mu(1)-u(X))
  C.*((mu(3)*mu(4))*D*u(Y) + mu(2)*u(X) - u(X).^2.*u(Y)) + B.*(mu(2)/mu(1)-u(Y))
  ];
fx = @(u,mu) [
  CX.*(mu(3)*D + 2*diag(u(X).*u(Y)) - (mu(2)+1)*ID) - BX.*(ID) ...
    CX.*(diag(u(X).^2))
  CX.*(mu(2)*ID - 2*diag(u(X).*u(Y))) ...
    CX.*((mu(3)*mu(4))*D - diag(u(X).^2)) - BX.*(ID)
  ];
fp = @(u,mu) [
                  C+B              C.*(-u(X))        C.*(D*u(X))                 ZE
  -B.*(mu(2)/mu(1)^2)  C.*(u(X))+B.*(1/mu(1))  C.*(mu(4)*D*u(Y))  C.*(mu(3)*D*u(Y))
  ];

mu = [ 1 ; 3 ; 0.075 ; 1 ];
u0 = [ mu(1)*ones(N+1,1); (mu(2)/mu(1))*ones(N+1,1) ];

% ode15s(@(t,x) f(x,mu), [0 200], u0+0.01*rand(size(u0))); return

%%

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'A' 'B' 'D' 'R'});
opts = coco_set(opts, 'curve', 'FPTF', 'tangent');
% opts = coco_set(opts, 'curve', 'FPTF', 'determinant');
% opts = coco_set(opts, 'curve', 'FPTF', 'extended');
% opts = coco_set(opts, 'curve', 'FPTF', 'extended active');
opts = coco_set(opts, 'cont', 'ItMX', 100);

% run continuation, name branch '1'
bd1 = coco(opts, '1', 'ep_curve', 'isol', 'sol', ...
  f, fx, fp, u0, mu, ...
  {'B' 'test_HB' 'test_SN'}, [1 8]);

% plot bifurcation diagram
% u  = coco_bd_col(bd1, {'B' 'test_HB'});
u  = coco_bd_col(bd1, {'B' '||x||'});
subplot(1,2,1);
plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow

%% compute secondary branches

labs = coco_bd_labs(bd1, 'BP');

% run continuation, name branch '2'
bd2 = coco(opts, '2', 'ep_curve', 'BP', 'sol', ...
  '1', labs(1), ...
  {'B' 'test_HB' 'test_SN'}, [1 8]);

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'B' '||x||'});
subplot(1,2,1);
hold on
plot(u(1,:), u(2,:), 'r.-')
hold off
grid on
drawnow

% run continuation, name branch '3'
bd3 = coco(opts, '3', 'ep_curve', 'BP', 'sol', ...
  '1', labs(end), ...
  {'B' 'test_HB' 'test_SN'}, [1 8]);

% plot bifurcation diagram
u  = coco_bd_col(bd3, {'B' '||x||'});
subplot(1,2,1);
hold on
plot(u(1,:), u(2,:), 'r.-')
hold off
grid on
drawnow

%% compute Hopf curve

labs = coco_bd_labs(bd1, 'HB');
% opts = coco_set(opts, 'curve', 'HBSys', 'complex');
opts = coco_set(opts, 'curve', 'HBSys', 'squared');
% opts = coco_set(opts, 'curve', 'HBSys', 'extended');

% run continuation, name branch '4'
bd2 = coco(opts, '4', 'ep_curve', 'HB', 'HB', ...
  '1', labs(1), ...
  {'D' 'B' 'test_HB' 'test_SN'}, {[0 0.2] [0 6]});

% plot bifurcation diagram
u  = coco_bd_col(bd2, {'D' 'B' '||x||'});
% u  = coco_bd_col(bd2, {'D' 'B' 'test_HB'});
subplot(1,2,2);
plot3(u(1,:), u(2,:), u(3,:), '.-')
view(2)
grid on
drawnow
