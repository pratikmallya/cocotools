fprintf('\n**************** starting %s ****************\n',mfilename);
t1 = tic;
opts = [];

%% compute first branch
%  p = [A om]
f  = @(t,x,p) [ x(2) ; p(1)*cos(p(2)*t) - 0.2*x(2) - x(1) - x(1)^3 ];
fx = @(t,x,p) [ 0 1 ; -1-3*x(1)^2 -0.2 ];
fp = @(t,x,p) [ 0 0 ; cos(p(2)*t) -p(1)*sin(p(2)*t)*t ];
T  = @(p)     2*pi/p(2);
Tp = @(p)     [0 -2*pi/p(2)^2];

% opts = coco_set(opts, 'corr', 'TOL'   , 1.0e-6);
% opts = coco_set(opts, 'corr', 'ResTOL', 1.0e-10);

opts = coco_set(opts, 'cont', 'ItMX', [300 10]);
opts = coco_set(opts, 'cont', 'h0', 0.05);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'PD', 1);
opts = coco_set(opts, 'curve', 'NS', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'A' 'om'});

p0 = [1;1];
x0 = [0;0];
[t x] = ode45(f, [0 20*T(p0)], x0, [], p0); %#ok<ASGLU>
x0 = x(end,:)';
plot(x(:,1), x(:,2))
[t x] = ode45(f, [0 T(p0)], x0, [], p0);
hold on
plot(x(:,1), x(:,2), 'r-', 'LineWidth', 2)
hold off
grid on
drawnow

if coco_run_exist('1')
  bd1 = coco_bd_read('1');
else
  bd1 = coco(opts,'1' , 'curve','isol','sol', ...
    f,fx,fp,T,Tp, x0,p0, {'A' 'stab'},[0.9 70]);
end
plot_bd(bd1, 1,2)
%axis([0 4 0 2])
grid on
drawnow

%% switch to second branch

labs = coco_bd_labs(bd1, 'BP');

opts = coco_set(opts, 'cont', 'ItMX', [150 10]);

if coco_run_exist('2')
  bd2 = coco_bd_read('2');
else
  bd2 = coco(opts,'2' , 'curve','BP','sol','1',labs(1) , ...
    {'A' 'stab'},[0.9 70]);
end
hold on
plot_bd(bd2, 1,2)
hold off

%% switch to third branch

labs = coco_bd_labs(bd1, 'BP');

opts = coco_set(opts, 'cont', 'ItMX', [300 300]);

if coco_run_exist('3')
  bd3 = coco_bd_read('3');
else
  bd3 = coco(opts,'3' , 'curve','BP','sol','1',labs(3) , ...
    {'A' 'stab'},[0.9 70]);
end
hold on
plot_bd(bd3, 1,2)
hold off

%% compute period-doubled sequence

% opts = coco_set(opts, 'curve', 'LP', 0);
% opts = coco_set(opts, 'curve', 'BP', 0);
% opts = coco_set(opts, 'cont', 'NPR', 1);
% opts = coco_set(opts, 'cont', 'ItMX', 10);
opts = coco_set(opts, 'cont', 'ItMX', 100);

h0   = [0.1 0.1 0.01];
lidx = [2 4 1];
ex   = [true true true];
for i=1:3
  labs = coco_bd_labs(bd3, 'PD');
  run  = sprintf('%d', i+3);
  rrun = sprintf('%d', i+2);
  opts = coco_set(opts, 'cont', 'h0',    h0(i));
  opts = coco_set(opts, 'cont', 'h_max', h0(i)*20);
  opts = coco_set(opts, 'cont', 'h_min', h0(i)/10);
  if ex(i) && coco_run_exist(run)
    bd3 = coco_bd_read(run);
  else
    bd3 = coco(opts,run , 'curve','PD','sol',rrun,labs(lidx(i)) , ...
      {'A' 'sym' 'stab'},[0.9 70]);
  end
  hold on
  plot_bd(bd3, 1,2)
  hold off
end

%%
toc(t1);
