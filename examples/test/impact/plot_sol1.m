load isol/isol5

b=0.8471;
a=1;
Ff=.7961;
k=5.573034039978373;

clf
hold on
plot3(seglist(1).x0(:,1),seglist(1).x0(:,3),seglist(1).x0(:,2),'k','LineWidth',2.5)
plot3(seglist(2).x0(:,1),mod(seglist(2).x0(:,3),2*pi),seglist(2).x0(:,2),'k','LineWidth',2.5)
plot3(seglist(3).x0(:,1),mod(seglist(3).x0(:,3),2*pi),seglist(3).x0(:,2),'k','LineWidth',2.5)
plot3(seglist(4).x0(:,1),mod(seglist(4).x0(:,3),2*pi),seglist(4).x0(:,2),'k','LineWidth',2.5)
plot3(seglist(5).x0(:,1),seglist(5).x0(:,3),seglist(5).x0(:,2),'k','LineWidth',2.5)
plot3(seglist(1).x0(end,1),mod(seglist(1).x0(end,3),2*pi),seglist(1).x0(end,2),'ok','MarkerSize',6,'MarkerFaceColor','k')
plot3(seglist(2).x0(end,1),mod(seglist(2).x0(end,3),2*pi),seglist(2).x0(end,2),'ok','MarkerSize',6,'MarkerFaceColor','k')
plot3(seglist(3).x0(end,1),mod(seglist(3).x0(end,3),2*pi),seglist(3).x0(end,2),'ok','MarkerSize',6,'MarkerFaceColor','k')
plot3(seglist(4).x0(end,1),mod(seglist(4).x0(end,3),2*pi),seglist(4).x0(end,2),'ok','MarkerSize',6,'MarkerFaceColor','k')
plot3(seglist(5).x0(end,1),seglist(5).x0(end,3),seglist(5).x0(end,2),'ok','MarkerSize',6,'MarkerFaceColor','k')
dimpact = @(x2,x3) reshape([-b+a*sin(x3) x2 x3], [size(x2) 3]);

x2  = linspace(-1,1.5,251);
x3 = linspace(0,2*pi,300);

ind=find(-b+a*sin(x3)>-2*Ff/k);
ind2=find(abs(x2)<=eps);

[X2 X3] = meshgrid(x2,x3(ind));
XX = dimpact(X2,X3);
surf(XX(:,:,1), XX(:,:,3), XX(:,:,2), 'FaceColor', .5*[1 1 1], ...
	'FaceAlpha', 0.8, 'LineStyle', 'none')
plot3(XX(:,end,1), XX(:,end,3), XX(:,end,2), 'Color', 0.4*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XX(:,1,1), XX(:,1,3), XX(:,1,2), 'Color', 0.4*[1 1 1], ...
	'LineWidth', 0.5);
plot3(XX(:,ind2,1), XX(:,ind2,3), XX(:,ind2,2), 'Color', 0.55*[1 1 1], ...
	'LineWidth', 0.5);

aplane = @(y) 0.*y;

x1 = linspace(-2*Ff/k, -1*Ff/k, 200);
x3 = linspace(0,2*pi,200);

[X1 X3] = meshgrid(x1, x3);
Z = aplane(X1);
surf(X1, X3, Z, 'FaceColor', .5*[1 1 1], ...
	'FaceAlpha', 0.7, 'LineStyle', 'none')
plot3(X1(:,end), X3(:,end), Z(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(:,1), X3(:,1), Z(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(end,:), X3(end,:), Z(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(1,:), X3(1,:), Z(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

aplane = @(y) 0.*y;

x1 = linspace(1*Ff/k, 3.4*Ff/k, 200);
x3 = linspace(0,2*pi, 200);

[X1 X3] = meshgrid(x1, x3);
Z = aplane(X1);
surf(X1, X3, Z, 'FaceColor', .5*[1 1 1], ...
	'FaceAlpha', 0.7, 'LineStyle', 'none')
plot3(X1(:,end), X3(:,end), Z(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(:,1), X3(:,1), Z(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(end,:), X3(end,:), Z(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(1,:), X3(1,:), Z(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

aplane = @(y) 0.*y;

x1 = linspace(-1*Ff/k, 1*Ff/k, 200);
x3 = linspace(0,2*pi,200);

[X1 X3] = meshgrid(x1, x3);
Z = aplane(X1);
surf(X1, X3, Z, 'FaceColor', 0.35*[1 1 1], ...
	'FaceAlpha', 0.7, 'LineStyle', 'none')
plot3(X1(:,end), X3(:,end), Z(:,end), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(:,1), X3(:,1), Z(:,1), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(end,:), X3(end,:), Z(end,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);
plot3(X1(1,:), X3(1,:), Z(1,:), 'Color', 0.2*[1 1 1], ...
	'LineWidth', 0.5);

view(80,20)
axis([-1.5*Ff/k 4*Ff/k 0 2*pi -1 2])
grid on

lighting phong; % flat gouraud phong
material shiny

light('Position',[0 1 1], 'Color', 1*[1 1 1],'Style','infinite');
light('Position',[1 0 1], 'Color', 1*[1 1 1],'Style','infinite');
light('Position',[1 0 0], 'Color', 1*[1 1 1],'Style','infinite');
light('Position',[0 0 1], 'Color', 1*[1 1 1],'Style','infinite');
light('Position',[0.5 -1 0.5], 'Color', 1*[1 1 1],'Style','infinite');
