fprintf('********************\n\n');

a = 0; % 0.025

f    = @(x,p) p(1,:).^2-25*x(1,:)^2+24*x(1,:).^4-15 + a*rand(size(x));
dfdx = @(x,p) 96*x(1)^3-50*x(1) + 2*a*rand(1,1);
dfdp = @(x,p) 2*p(1) + 2*a*rand(1,1);

opts = [];

% opts = coco_add_event(opts, 'UZ', 'H',  0);

opts = coco_set(opts, 'cont', 'ItMX', [200 0]);
% opts = coco_set(opts, 'cont', 'NPR', 1, 'NSV', 10);
opts = coco_set(opts, 'cont', 'h_max', 0.5);
% opts = coco_set(opts, 'cont', 'h_min', 0.05);
opts = coco_set(opts, 'cont', 'atlas', '1d_lsq');
opts = coco_set(opts, 'corr', 'TOL', 1.0e-3);
opts = coco_set(opts, 'cont', 'LogLevel', 3);

bd1 = coco(opts, '1', 'alcont', 'isol', 'sol', f, dfdx, dfdp, ...
	[1], [1], 'PAR(1)', [-6, 6]); %#ok<NBRAK>

y = coco_bd_col(bd1, 'X');
x = coco_bd_col(bd1, 'PAR(1)');

clf
plot(x, y, 'b.-', 1,1,'r*');
grid on
drawnow
axis equal
