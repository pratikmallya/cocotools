fprintf('\n**************** starting %s ****************\n',mfilename);
t1 = tic;
opts = [];

%% compute first branch
%  p = [A om]
la = 0.5;
f  = @(t,x,p) [ x(2) ; -la*x(2) - sin(x(1))*( 1+p(1)*cos(p(2)*t) ) ];
fx = @(t,x,p) [ 0 1 ; -cos(x(1))*( 1+p(1)*cos(p(2)*t) ) -la ];
fp = @(t,x,p) [ 0 0 ; -sin(x(1))*cos(p(2)*t) sin(x(1))*p(1)*sin(p(2)*t)*t ];
T  = @(p)     2*pi/p(2);
Tp = @(p)     [0 -2*pi/p(2)^2];

% opts = coco_set(opts, 'corr', 'TOL'   , 1.0e-6);
% opts = coco_set(opts, 'corr', 'ResTOL', 1.0e-10);

opts = coco_set(opts, 'cont', 'ItMX', [0 100]);
opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'h0', 0.01);
opts = coco_set(opts, 'cont', 'h_max', 0.01);
opts = coco_set(opts, 'cont', 'h_min', 0.00001);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'PD', 1);
opts = coco_set(opts, 'curve', 'NS', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'A' 'om'});

% interesting frequencies for A=150
% 3.7181    6.2608   18.0149  106.0595
p0 = [1;0.35];
% p0 = [1000;100];
x0 = [pi;0];
cont_pars = {'om' 'test_PD' 'test_BP' 'test_NS' 'stab'};
rerun = true;

if ~rerun && coco_run_exist('1')
  bd1 = coco_bd_read('1');
else
  bd1 = coco(opts,'1' , 'curve','isol','sol', ...
    f,fx,fp,T,Tp, x0,p0, cont_pars,[0.025 10]);
end
plot_bd(bd1, 2,2)
%axis([0 4 0 2])
grid on
drawnow
return

%% switch to period-doubled branch

labs = coco_bd_labs(bd1, 'PD');

opts = coco_set(opts, 'cont', 'ItMX', [10 10]);

if ~isempty(labs)
  if ~rerun && coco_run_exist('2')
    bd2 = coco_bd_read('2');
  else
    bd2 = coco(opts,'2' , 'curve','PD','sol','1',labs(1) , ...
      cont_pars,[0.9 70]);
  end
  hold on
  plot_bd(bd2, 2,2)
  hold off
end

%% switch to third branch

labs = coco_bd_labs(bd1, 'BP');

opts = coco_set(opts, 'cont', 'ItMX', [300 300]);

if ~rerun && coco_run_exist('3')
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
