%% compute first branch
%  p = [a b]
f  = @(x,p) [x(2) + 1 - p(1)*x(1)^2 ; p(2)*x(1)];

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'a' 'b'});

p0 = [1;0.3];
x0 = [-(1-p0(2))/(2*p0(1))-sqrt( ((1-p0(2))/(2*p0(1)))^2+1/p0(1) )
  -(1-p0(2))/(2*p0(1))+sqrt( ((1-p0(2))/(2*p0(1)))^2+1/p0(1) )];
y0 = p0(2)*x0;
bd1 = coco(opts,'1' , 'curve','isol','sol',f,[x0(2);y0(2)],p0 , 'a',[0 2]);
plot_bd(bd1)
axis([0 2 -2 2])
grid on
drawnow

%% switch to second branch

% labs = coco_bd_labs(bd1, 'BP');
% 
% bd2 = coco(opts,'2' , 'curve','BP','sol','1',labs(1) , 'a',[0 2]);
% hold on
% plot_bd(bd2)
% hold off

%% compute period-doubled sequence

bd3  = bd1;
opts = coco_set(opts, 'curve', 'LP', 0);
opts = coco_set(opts, 'curve', 'BP', 0);
opts = coco_set(opts, 'curve', 'PD', 2);
% opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'ItMX', 100);

h0 = [0.05 0.01 0.0025 0.0005 0.00004 0.00001 0.000002];
for i=1:7
  labs = coco_bd_labs(bd3, 'PD');
  run  = sprintf('%d', i+1);
  rrun = sprintf('%d', i+0);
  opts = coco_set(opts, 'cont', 'h0',    h0(i));
  opts = coco_set(opts, 'cont', 'h_max', h0(i)*10);
  opts = coco_set(opts, 'cont', 'h_min', h0(i)/10);
  bd3 = coco(opts,run , 'curve','PD','sol',rrun,labs(1) , 'a',[0 2]);
  hold on
  plot_bd(bd3)
  hold off
end
