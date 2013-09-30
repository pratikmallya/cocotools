%% plot double-cone
clf

dcone = @(z,al) reshape([z.*cos(al) z.*sin(al) z], [size(z) 3]);
z  = linspace(0.3,1.5,50);
al = linspace(0,2*pi,100);
[Z AL] = meshgrid(z,al);
XX = dcone(Z,AL);
surf(XX(:,:,1), XX(:,:,2), XX(:,:,3), 'FaceColor', 0.5*[1 1 1], ... %'g', ...
	'FaceAlpha', 0.6, 'LineStyle', 'none')
hold on
plot3(XX(:,end,1), XX(:,end,2), XX(:,end,3), 'Color', 0.4*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XX(:,1,1), XX(:,1,2), XX(:,1,3), 'Color', 0.4*[1 1 1], ...
	'LineWidth', 0.5);
hold off

aplane = @(y,al) (1-tan(al)*y);
x = linspace(-1.5, 1.5, 100);
y = linspace(-1.5, 1.5, 100);
[X Y] = meshgrid(x, y);
Z = aplane(Y, pi/16);
hold on
surf(X, Y, Z, 'FaceColor', 0.5*[1 1 1], ... %'b', ...
	'FaceAlpha', 0.8, 'LineStyle', 'none')
plot3(X(:,end), Y(:,end), Z(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(:,1), Y(:,1), Z(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(end,:), Y(end,:), Z(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X(1,:), Y(1,:), Z(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
hold off

lighting phong; % flat gouraud phong
light('Position',[   1 0.5  1.6], 'Color',   1*[1 1 1],'Style','local');
light('Position',[   2 0.5 -0.5], 'Color', 0.6*[1 1 1],'Style','local');
light('Position',[ 1.5 0.5   -1], 'Color', 0.4*[1 1 1],'Style','infinite');
light('Position',[   0   0   -1], 'Color', 0.2*[1 1 1],'Style','infinite');

view([135 10]);
drawnow;

%% perform continuation

% par = [ x ; y ; alpha ]

opts = [];

opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
  'internal', 'H', 'vectorised', 'on');

opts = coco_add_event(opts, 'UZ', 'H',  0);
opts = coco_set(opts, 'all', 'CleanData', 1);

bd1 = coco(opts, 'x', 'alcont', 'isol', 'sol', @cone, ...
	[1.3], [0;1.3;pi/16], 'PAR(2)', [0.4, 1.4]); %#ok<NBRAK>

z = coco_bd_col(bd1, 'X');
p = coco_bd_col(bd1, 'PARS');
x = p(1,:);
y = p(2,:);
hold on
plot3(x, y, z, 'k-', 'Linewidth', 2.5);
hold off
grid on
drawnow

idx = find(strcmp('UZ', coco_bd_col(bd1, 'TYPE') ));
lab = coco_bd_labs(bd1, 'UZ');
hold on
%plot3(x(idx), y(idx), z(idx), 'yo', 'LineWidth', 10, 'MarkerSize', 10);
hold off
drawnow

fprintf('\n');

opts = coco_set(opts, 'cont', 'ItMX', [40 40]);

bd2 = coco(opts, 'sec', 'alcont', 'sol', 'sol', ...
	'x', lab, {'PAR(1)' 'PAR(2)'}, [-2 2]);

z = coco_bd_col(bd2, 'X');
p = coco_bd_col(bd2, 'PARS');
x = p(1,:);
y = p(2,:);
hold on
plot3(x, y, z, 'k-', 'LineWidth', 3);
hold off
drawnow

% print('-djpeg', 'cone1');
