%% perform sweep (vectorised)

ItTrans = 200;
NPoints = 200;
NPars   = 200;
aint    = [0 4]; %[2.3 2.8];
xint    = [-2 2]; %[-1.6 -0.5];
%  p = [a b]
f  = @(x,p) [ x(2,:) ; -p(2,:).*x(1,:)+p(1,:).*x(2,:)-x(2,:).^3 ];

a  = linspace(aint(1),aint(2),NPars);
a  = [a a];
x0 = [-0.1*ones(2,NPars) 0.1*ones(2,NPars)];
clear xx pp
xx(:,:,1) = x0;
pp(:,:,1) = [ a ; 0.2*ones(1,2*NPars) ];

for i=2:NPoints
  xx(:,:,i) = f(xx(:,:,i-1),pp(:,:,i-1));
  pp(:,:,i) = pp(:,:,i-1);
end

xx = reshape(xx, 2, 2*NPars*NPoints);
pp = reshape(pp, 2, 2*NPars*NPoints);
for i=1:ItTrans
  xx = f(xx,pp);
  plot(pp(1,:), xx(1,:), 'r.','MarkerSize', 1);
  axis([aint xint]);
  grid on
  drawnow
end

%% compute first branch
%  p = [a b]
f  = @(x,p) [ x(2) ; -p(2)*x(1)+p(1)*x(2)-x(2)^3 ];

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'a' 'b'});

bd1 = coco(opts,'1' , 'curve','isol','sol',f,[0;0],[1;0.2], 'a',[0 4]);
hold on
plot_bd(bd1)
hold off
drawnow

%% switch to second branch

labs = coco_bd_labs(bd1, 'BP');

bd2 = coco(opts,'2' , 'curve','BP','sol','1',labs(1) , 'a',[0 4]);
hold on
plot_bd(bd2)
hold off

%% compute period-doubled sequence

bd3  = bd2;
opts = coco_set(opts, 'curve', 'LP', 0);
opts = coco_set(opts, 'curve', 'BP', 0);
opts = coco_set(opts, 'curve', 'PD', 2);
% opts = coco_set(opts, 'cont', 'NPR', 1);
opts = coco_set(opts, 'cont', 'ItMX', 100);

h0 = [0.1 0.01 0.0005 0.00001 0.00004 0.00001 0.000002];
for i=1:7
  labs = coco_bd_labs(bd3, 'PD');
  run  = sprintf('%d', i+2);
  rrun = sprintf('%d', i+1);
  opts = coco_set(opts, 'cont', 'h0',    h0(i));
  opts = coco_set(opts, 'cont', 'h_max', h0(i)*10);
  opts = coco_set(opts, 'cont', 'h_min', h0(i)/10);
  bd3 = coco(opts,run , 'curve','PD','sol',rrun,labs(1) , 'a',[0 4]);
  hold on
  plot_bd(bd3)
  hold off
end
