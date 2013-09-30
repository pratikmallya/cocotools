%% compute first branch

f  = @(x,p) p*x*(1-x);

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'mu'});

bd1 = coco(opts,'1' , 'curve','isol','sol',f,0,0 , 'mu',[-2 4]);
plot_bd(bd1)
axis([0 4 0 1])
grid on
drawnow

%% switch to second branch

labs = coco_bd_labs(bd1, 'BP');

bd2 = coco(opts,'2' , 'curve','BP','sol','1',labs(1) , 'mu',[-2 4]);
hold on
plot_bd(bd2)
hold off

%% compute period-doubled sequence

bd3  = bd2;
opts = coco_set(opts, 'curve', 'LP', 0);
opts = coco_set(opts, 'curve', 'BP', 0);
opts = coco_set(opts, 'curve', 'PD', 2);
% opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'ItMX', 300);

h0 = [0.05 0.01 0.00064 0.00016 0.00004 0.00001 0.000002];
for i=1:7
  labs = coco_bd_labs(bd3, 'PD');
  run  = sprintf('%d', i+2);
  rrun = sprintf('%d', i+1);
  opts = coco_set(opts, 'cont', 'h0',    h0(i));
  opts = coco_set(opts, 'cont', 'h_max', h0(i)*10);
  opts = coco_set(opts, 'cont', 'h_min', h0(i)/10);
  bd3 = coco(opts,run , 'curve','PD','sol',rrun,labs(1) , 'mu',[-2 4]);
  hold on
  plot_bd(bd3)
  hold off
end
