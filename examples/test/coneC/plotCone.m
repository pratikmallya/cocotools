function plotCone

%% plot double-cone

dcone = @(z,al) reshape([z.*cos(al) z.*sin(al) z], [size(z) 3]);
z  = linspace(0.3,1.5,25);
al = linspace(0,2*pi,50);
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
Z = aplane(Y, 0);
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

view([150 30]);
%view([160 0]);
drawnow;
