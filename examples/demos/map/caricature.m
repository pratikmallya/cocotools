f  = @(x,mu) caricature(x,mu);
fx = @(x,mu) caricature_DX(x,mu);
fp = @(x,mu) caricature_DP(x,mu);

opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'be' 'al'});
clf

%% run continuation through PD bubble, k=1
% opts = coco_set(opts, 'cont', 'ItMX', 500);

bd1 = coco(opts, '1', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, [0.25;-0.1], [0.4;0.6], 1, ...
  'al', [0.3 0.6]);

% plot bifurcation diagram
al = coco_bd_col(bd1, 'al');
x  = coco_bd_col(bd1, 'x');
subplot(1,2,1);
plot(al, x(1,:), '.-')
drawnow

%% run continuation through PD bubble, k=2
bd2 = coco(opts, '2', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, [0.25;-0.1], [0.4;0.6], 2, ...
  'al', [0.3 0.6]);

% plot bifurcation diagram
subplot(1,2,1);
hold on
al = coco_bd_col(bd2, 'al');
x  = coco_bd_col(bd2, 'x');
plot(al, x(1,:), 'b.-')
hold off
drawnow

%% switch branches at branch point (PD for k=1)
labs = coco_bd_labs(bd2, 'BP');
bd3 = coco(opts, '3', 'fp_curve', 'BP', 'sol', ...
  '2', labs(1), ...
  'al', [0.3 0.6]);

% plot bifurcation diagram
subplot(1,2,1);
hold on
al = coco_bd_col(bd3, 'al');
x  = coco_bd_col(bd3, 'x');
plot(al, x(1,:), 'r.-')
hold off
drawnow

%% compute PD curve
opts = coco_set(opts, 'cont', 'ItMX', 20);

labs = coco_bd_labs(bd1, 'PD');
bd4 = coco(opts, '4', 'fp_curve', 'PD', 'PD', ...
  '1', labs(1), ...
  {'be' 'al'});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd4, 'be');
al = coco_bd_col(bd4, 'al');
plot(be, al, 'k-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

%% compute NS curve
opts = coco_set(opts, 'cont', 'ItMX', [0 100]);

% run continuation through left-hand NS curve
bd5l = coco(opts, '5l', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, [0.25;-0.1], [0.3;0.6], 1, ...
  'al', [0.3 0.6]);
labs = coco_bd_labs(bd5l, 'NS');
bd6l = coco(opts, '6l', 'fp_curve', 'NS', 'NS', ...
  '5l', labs(1), ...
  {'be' 'al'});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd6l, 'be');
al = coco_bd_col(bd6l, 'al');
plot(be, al, 'b-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

% run continuation through right-hand NS curve
bd5r = coco(opts, '5r', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, [0.25;-0.1], [0.5;0.6], 1, ...
  'al', [0.3 0.6]);
labs = coco_bd_labs(bd5r, 'NS');
bd6r = coco(opts, '6r', 'fp_curve', 'NS', 'NS', ...
  '5r', labs(1), ...
  {'be' 'al'});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd6r, 'be');
al = coco_bd_col(bd6r, 'al');
plot(be, al, 'b-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

%% compute fold curves

% compute initial values inside tongues for k=1,2,3
x0 = [
  1 1 1
  0 0 0
  ];

p0 = [
  1.0 0.4 0.25
  0.1 0.4 0.40
  ];

for i=1:20
  x0 = caricature(x0,p0);
end

% compute 1:1 tongue

% run continuation through tongue
opts = coco_set(opts, 'cont', 'ItMX', [0 100]);
bd7l = coco(opts, '7l', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, x0(:,1), p0(:,1), 1, ...
  'be', [0.8 1.2]);
labs = coco_bd_labs(bd7l, 'SN');
opts = coco_set(opts, 'cont', 'ItMX', [100 100]);
bd8l = coco(opts, '8l', 'fp_curve', 'LP', 'LP', ...
  '7l', labs(1), ...
  {'be' 'al'}, {[0.5 1.5], [0 1]});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd8l, 'be');
al = coco_bd_col(bd8l, 'al');
plot(be, al, 'g-')
plot(be-1, al, 'g-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

% compute 1:2 tongue

% run continuation through tongue
opts = coco_set(opts, 'cont', 'ItMX', [0 100]);
bd9l = coco(opts, '9l', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, x0(:,2), p0(:,2), 2, ...
  'be', [0 1]);
labs = coco_bd_labs(bd9l, 'SN');
opts = coco_set(opts, 'cont', 'ItMX', [100 100]);
bd10l = coco(opts, '10l', 'fp_curve', 'LP', 'LP', ...
  '9l', labs(2), ...
  {'be' 'al'}, {[0 1], [0 1]});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd10l, 'be');
al = coco_bd_col(bd10l, 'al');
plot(be, al, 'g-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

opts = coco_set(opts, 'cont', 'ItMX', [100 100]);
bd10r = coco(opts, '10r', 'fp_curve', 'LP', 'LP', ...
  '9l', labs(1), ...
  {'be' 'al'}, {[0 1], [0 1]});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd10r, 'be');
al = coco_bd_col(bd10r, 'al');
plot(be, al, 'g-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

% compute 1:3 tongue

% run continuation through tongue
opts = coco_set(opts, 'cont', 'ItMX', [0 20]);
bd11l = coco(opts, '11l', 'fp_curve', 'isol', 'sol', ...
  f, fx, fp, x0(:,3), p0(:,3), 3, ...
  'be', [0 1]);
labs = coco_bd_labs(bd11l, 'SN');
opts = coco_set(opts, 'cont', 'ItMX', [100 100]);
bd12l = coco(opts, '12l', 'fp_curve', 'LP', 'LP', ...
  '11l', labs(1), ...
  {'be' 'al'}, {[0 1], [0 1]});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd12l, 'be');
al = coco_bd_col(bd12l, 'al');
plot(be, al, 'g-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow

opts = coco_set(opts, 'cont', 'ItMX', [100 100]);
bd12r = coco(opts, '12r', 'fp_curve', 'LP', 'LP', ...
  '11l', labs(2), ...
  {'be' 'al'}, {[0 1], [0 1]});

% plot bifurcation diagram
subplot(1,2,2);
hold on
be = coco_bd_col(bd12r, 'be');
al = coco_bd_col(bd12r, 'al');
plot(be, al, 'g-')
axis([0 1 0 0.6]);
grid on
hold off
drawnow
