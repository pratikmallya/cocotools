f = @(al) [cos(al);0.1*sin(al)]+0.00*randn(2,numel(al));
R = @(al) [cos(al) sin(al); -sin(al) cos(al)];

N      = 10;
h      = 0.7;
al0    = -0.5;
x      = sort(linspace(al0,al0+h,N)+0.001*rand(1,N));
y      = f(x);
data.y = y;

tt = y(:,2:end)-y(:,1:end-1);
tt = sum(tt,2);
tt = tt/norm(tt);
t  = tt;

[data C t Res3 Res2 Res ZZ1 ZZ2 ZZ3] = fit_curve([], data, t, 1.0e-5);

% NL  = norm(C(4,:))/(norm(C(3,:))+norm(C(2,:)));
NL  = norm(C(3,:));
AE2 = 2*Res2/h;
AQ3 = 2*(Res3/h)/AE2;

fprintf('NL = % .2e, AE2 = % .2e, AQ3 = % .2e\n', NL, AE2, AQ3);

plot(ZZ1(1,:), ZZ1(2,:), 'k.-', y(1,:), y(2,:), 'r.', ...
  ZZ3(1,:), ZZ3(2,:), 'g-', ZZ2(1,:), ZZ2(2,:), 'b-', ...
  'LineWidth', 2.0);
axis equal
grid on
