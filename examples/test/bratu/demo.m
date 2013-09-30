fprintf('**************************\n\n');

clf

p1 = 0;

opts = [];
opts = coco_set(opts, 'coll', 'NTST', 10, 'NCOL', 4);
opts = coco_set(opts, 'cont', 'LogLevel', 1, 'ItMX', 250);
opts = coco_set(opts, 'cont', 'NSV', 50);

bd = coco(opts, '1', 'bvp', 'isol', 'sol', @bratu, ...
	@stpnt, p1, 'PAR(1)', [-0.1 4]);

par  = coco_bd_col(bd, 'PAR(1)');
nrmx = coco_bd_col(bd, '||U||');
subplot(2,1,1);
plot(par, nrmx, 'b.-');
grid on;
drawnow

labs = coco_bd_labs(bd, 'all');
subplot(2,1,2);
cla;
grid on;
hold on;
for lab=labs
  [segs t x] = coll_read_sol('', '1', lab);
	plot(t, x(2,:), 'b.-');
	plot(t, x(1,:), 'g.-');
end
hold off;
drawnow

%% test restart of bvp

bd2 = coco(opts, '2', 'bvp', 'sol', 'sol', '1', 6, 'PAR(1)', [1 4]);

par  = coco_bd_col(bd2, 'PAR(1)');
nrmx = coco_bd_col(bd2, '||U||');
subplot(2,1,1);
hold on
plot(par, nrmx, 'r.-');
hold off
grid on;
drawnow

labs = coco_bd_labs(bd2, 'all');
subplot(2,1,2);
grid on;
hold on;
for lab=labs
  [segs t x] = coll_read_sol('', '2', lab);
	plot(t, x(2,:), 'b.-');
	plot(t, x(1,:), 'g.-');
end
hold off;
