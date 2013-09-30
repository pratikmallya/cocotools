function recipes

% true  : regenerate
% false : do nothing

figs.chap01 = {
  'fig02a' false
  'fig02b' false
  'fig02c' false
  'fig02d' true
  'postprocess' true
  'fig07a' false
  'fig07b' false
  'fig07c' false
  };

figs.chap02 = {
  'fig02a' false
  'fig02b' false
  };

figs.chap15 = {
  'cusp_surface' false
  'fig01'        false
  'fig02'        false
  'fig03'        false
  'postprocess'  false
  };

if ~new_figure()
  generate_figures(figs);
end

end

function flag = new_figure()
flag = false;
end

function add_styles(db)
owner = mfilename('fullpath');
db.add_style('numdata', owner, 'line1', 'marker1');
db.add_style('numdatal', owner, 'line1', 'marker1l');
db.add_style('func', owner, 'math2', 'box1', 'arrow1');
db.add_style('lab', owner, 'text3d', 'box1', 'arrow2');
end

function generate_figures(figs)
owner = mfilename('fullpath');
db    = plotdb(1);
add_styles(db); % define styles
chaps = fieldnames(figs);
for k=1:numel(chaps)
  chap = chaps{k};
  list = figs.(chap);
  for i=1:size(list,1)
    if list{i,2}
      fig = list{i,1};
      figname = sprintf('%s_%s', chap, fig);
      db.plot_create(figname, owner);
      pfunc = str2func(sprintf('plot_%s', figname));
      pfunc(db);
      db.plot_close;
    end
  end
end
end

%#ok<*DEFNU>
function plot_chap01_fig02a(db)
limits = [0.9 4.5 -1 10];
as = 2.473;
at = 1.282;
Yp = @(a) cosh(a+acosh(a))./a;
Ym = @(a) cosh(a-acosh(a))./a;
db.plot([as as], limits(3:4), 'line2g4');
db.plot([at at], limits(3:4), 'line2g4');
a = [linspace(1,1.1,100) linspace(1.1,5,200)];
y = Yp(a);
db.plot(a,y);
a = [linspace(1,1.1,100) linspace(1.1,at,100)];
y = Ym(a);
db.plot(a,y);
a = linspace(at,5,100);
y = Ym(a);
db.plot(a,y, 'line1g4');
a = linspace(at,as,50);
y = Ym(a);
db.plot(a,y, 'line4');

db.axis(limits);
db.plot(1, Yp(1), 'line2', 'marker4s');
% db.plot(1, Yp(1), 'line1g7', 'marker1l');
% db.plot(at, Ym(at), 'line1g4', 'marker1l');
% db.plot(as, Ym(as), 'line1g4', 'marker1l');

db.textarrow(2.15, Yp(2.15), 2, 'Y_{+}', 'tl', 'func');
db.textarrow(3.50, Ym(3.50), 2, 'Y_{-}', 'br', 'func');

db.textarrow(at, -1, 1.5, '\tilde{a}', 'tr', 'func');
db.textarrow(as, -1, 1.5, 'a^*', 'tr', 'func');

db.textarrow(2.0, Yp(2.0), 1, '1', 'br', 'lab');
db.textarrow(1.5, Yp(1.5), 1, '2', 'br' , 'lab');
db.textarrow(1.0, Yp(1.0), 1, '3', 'r', 'lab');

db.textarrow(1.15, Ym(1.15), 1, '4', 'b', 'lab');
db.textarrow(  at, Ym(  at), 1, '5', 'tr', 'lab');
db.textarrow(2.00, Ym(2.00), 1, '6', 'tr', 'lab');
db.textarrow(  as, Ym(  as), 1, '7', 'tr', 'lab');
db.textarrow(4.00, Ym(4.00), 1, '8', 'tl', 'lab');

db.xaxis(linspace(1,5,5), 4, 4.25, 'a');
db.yaxis(linspace(0,10,6), 2);

db.plot_margin([0.0 0.0 0 0]);
%db.plot_margin([0 0.04 0.003 0]);
end

function plot_chap01_fig02b(db)
limits = [0.9 4.5 -1 1];
as = 2.473;
at = 1.282;
bp = @(a) acosh(a)./a;
bm = @(a) -acosh(a)./a;
db.plot([as as], limits(3:4), 'line2g4');
db.plot([at at], limits(3:4), 'line2g4');
a = [linspace(1,1.1,100) linspace(1.1,5,200)];
y = bp(a);
db.plot(a,y);
a = [linspace(1,1.1,100) linspace(1.1,at,100)];
y = bm(a);
db.plot(a,y);
a = linspace(at,5,100);
y = bm(a);
db.plot(a,y, 'line1g4');
a = linspace(at,as,50);
y = bm(a);
db.plot(a,y, 'line4');

db.axis(limits);
db.plot(1, bp(1), 'line2', 'marker4s');
% db.plot(1, bp(1), 'line1g7', 'marker1l');
% db.plot(at, bm(at), 'line1g4', 'marker1l');
% db.plot(as, bm(as), 'line1g4', 'marker1l');

db.textarrow(3, bp(3), 2, 'b_+', 'tr', 'math2');
db.textarrow(3, bm(3), 2, 'b_-', 'br', 'math2');

db.textarrow(at, -1, 1.5, '\tilde{a}', 'tr', 'math2');
db.textarrow(as, -1, 1.5, 'a^*', 'tr', 'math2');

db.textarrow(2.0, bp(2.0), 1, '1', 'br', 'text3d', 'box1', 'arrow2');
db.textarrow(1.5, bp(1.5), 1, '2', 'br', 'text3d', 'box1', 'arrow2');
db.textarrow(1.0, bp(1.0), 1, '3', 'r' , 'text3d', 'box1', 'arrow2');

db.textarrow(1.15, bm(1.15), 2, '4', 'tr', 'text3d', 'box1', 'arrow2');
db.textarrow(  at, bm(  at), 1, '5', 'tr', 'text3d', 'box1', 'arrow2');
db.textarrow(2.00, bm(2.00), 1, '6', 'tl', 'text3d', 'box1', 'arrow2');
db.textarrow(  as, bm(  as), 1, '7', 'tl', 'text3d', 'box1', 'arrow2');
db.textarrow(4.00, bm(4.00), 1, '8', 'tl', 'text3d', 'box1', 'arrow2');

db.xaxis(linspace(1,5,5), 4, 4.25, 'a', 'math');
db.yaxis(linspace(-1,1,5), 2);

db.plot_margin([0.02 0 0 0]);
% db.plot_margin([0.01 0.04 0 0.01]);
end

function plot_chap01_fig02c(db)
limits = [-0.02 1.02 -0.5 7];
as = 2.473; %#ok<NASGU>
at = 1.282;
fp = @(x,a) cosh(a*(x+acosh(a)/a))/a;
fm = @(x,a) cosh(a*(x-acosh(a)/a))/a;

% x = [linspace(0,0,6) linspace(0,1,90) linspace(1,1,20)];
% y = [linspace(1,0,6) linspace(0,0,90) linspace(0,fp(1,1.5),20)];
% db.plot(x, y, 'line1g7', 'marker2');

x = linspace(0,1,100);

y = fp(x,2.0); db.plot(x, y);
y = fp(x,1.5); db.plot(x, y);
y = fp(x,1.0); db.plot(x, y);

y = fm(x,1.15); db.plot(x, y);
y = fm(x,  at); db.plot(x, y);

% y = fm(x,2.00); db.plot(x, y, 'line1g6');
% y = fm(x,2.00); db.plot(x, y, 'line4');
% y = fm(x,  as); db.plot(x, y, 'line1g4');
% y = fm(x,4.00); db.plot(x, y, 'line1g6');

db.axis(limits);

db.textarrow(0.8, fp(0.8,2.0), 1, '1', 'tl', 'text3d', 'box1', 'arrow2');
db.textarrow(0.8, fp(0.8,1.5), 1, '2', 'tl', 'text3d', 'box1', 'arrow2');
db.textarrow(0.8, fp(0.8,1.0), 1, '3', 'tl', 'text3d', 'box1', 'arrow2');

db.textarrow(0.835, fm(0.835,1.15), 1, '4', 'b', 'text3d', 'box1', 'arrow2');
db.textarrow(0.685, fm(0.685,  at), 1, '5', 'b', 'text3d', 'box1', 'arrow2');

% db.textarrow(0.66, fm(0.66,2.00), 1.9, '6', 'b', 'text2', 'box1', 'arrow2');
% db.textarrow(0.54, fm(0.54,  as), 1.8, '7', 'b', 'text2', 'box1', 'arrow2');
% db.textarrow(0.46, fm(0.46,4.00), 1.5, '8', 'b', 'text2', 'box1', 'arrow2');

% db.textarrow(0.02, 0, 1, '9', 'tr', 'text2', 'box1', 'arrow2');

db.textbox(0.35, 6, 'f(a,b)', 'r', 'math2');
db.xaxis(linspace(0,1,6), 2, 0.9, 'x', 'math');
db.yaxis(linspace(0,7,8), 1);

% db.plot_margin([0.01 0.025 0 0]);
% db.plot_margin([0.02 0.03 0 0]);
end

function plot_chap01_fig02d(db)
limits = [-0.02 1.02 -0.04 1.04];
as = 2.473;
at = 1.282;
fp = @(x,a) cosh(a*(x+acosh(a)/a))/a; %#ok<NASGU>
fm = @(x,a) cosh(a*(x-acosh(a)/a))/a;

x = [linspace(0,0,30) linspace(0,1,45) linspace(1,1,20)];
y = [linspace(1,0,30) linspace(0,0,45) linspace(0,fm(1,at),20)];
%db.plot(x, y, 'line1g7', 'marker2');
db.plot(x, y, 'line1g7');

x = linspace(0,1,100);

% y = fp(x,2.0); db.plot(x, y);
% y = fp(x,1.5); db.plot(x, y);
% y = fp(x,1.0); db.plot(x, y, 'line1g7');

% y = fm(x,1.15); db.plot(x, y);
y = fm(x,  at); db.plot(x, y);
y = fm(x,2.00); db.plot(x, y);
% y = fm(x,2.00); db.plot(x, y, 'line4');
y = fm(x,  as); db.plot(x, y);
y = fm(x,4.00); db.plot(x, y);

db.plot(0, 1, 'line1g7', 'marker1');
db.plot(1, fm(1,at), 'line1g7', 'marker1');

db.axis(limits);

% db.textarrow(0.8, fp(0.8,2.0), 1, '1', 'tl', 'text2', 'box1', 'arrow2');
% db.textarrow(0.8, fp(0.8,1.5), 1, '2', 'tl', 'text2', 'box1', 'arrow2');
% db.textarrow(0.8, fp(0.8,1.0), 1, '3', 'tl', 'text2', 'box1', 'arrow2');

% db.textarrow(0.96, fm(0.96,1.15), 1, '4', 'tl', 'text2', 'box1', 'arrow2');
db.textarrow(0.74, fm(0.74,  at), 1, '5', 'b', 'text3d', 'box1', 'arrow2');
db.textarrow(0.66, fm(0.66,2.00), 1, '6', 't', 'text3d', 'box1', 'arrow2');
db.textarrow(0.54, fm(0.54,  as), 1, '7', 'b', 'text3d', 'box1', 'arrow2');
db.textarrow(0.46, fm(0.46,4.00), 1, '8', 'b', 'text3d', 'box1', 'arrow2');

db.textarrow(0.35, 0, 1, '9', 't', 'text3d', 'box1', 'arrow2');

db.textbox(0.4, 0.9, 'f(a,b)', 'r', 'math2');
db.xaxis(linspace(0,1,6), 2, 0.9, 'x', 'math');
db.yaxis(linspace(0,1,6), 2);

db.plot_margin([0.02 0 0 0]);
%db.plot_margin([0.01 0.025 0 0]);
%db.plot_margin([0.024 0.03 0 0.025]);
end

function plot_chap01_postprocess(db)
db.plot_discard();

% align axes
db.plot_align_all_axes({'chap01_fig02a' 'chap01_fig02b'});
db.plot_align_all_axes({'chap01_fig02c' 'chap01_fig02d'});

end

function [X Y Z] = rotsurf(x, y, N)
[Z Y ~] = cylinder(y,N);
X = repmat(x', [1 N+1]);
end

function plot_chap01_fig07a(db)
limits = [0.9 4.5 2 2+28];
as = 2.473;
at = 1.282;

Jp = @(a) 0.5*pi*(2*a-sinh(2*acosh(a)) + sinh(2*a+2*acosh(a)))./a.^2;
Jm = @(a) 0.5*pi*(2*a+sinh(2*acosh(a)) + sinh(2*a-2*acosh(a)))./a.^2;

db.paper_size([5.3 7]);
db.axis(limits);

db.plot([as as], limits(3:4), 'line2g4');
db.plot([at at], limits(3:4), 'line2g4');

a = [linspace(1,1.1,100) linspace(1.1,5,200)];
J = Jp(a);
db.plot(a,J);

a = [linspace(1,1.1,100) linspace(1.1,at,100)];
J = Jm(a);
db.plot(a,J);

a = linspace(at,5,100);
J = Jm(a);
db.plot(a,J, 'line1g4');

a = linspace(at,as,50);
J = Jm(a);
db.plot(a,J, 'line4');

db.plot(1, Jp(1), 'line2', 'marker4s');

db.textarrow(1.08, Jp(1.08), 2, 'J_{+}', 'r', 'func');
db.textarrow(4, Jm(4), 2, 'J_{-}', 'tl', 'func');

db.textarrow(at, limits(3), 1.5, '\tilde{a}', 'tr', 'func');
db.textarrow(as, limits(3), 1.5, 'a^*', 'tr', 'func');

db.textarrow(  at, Jm(at), 1, '5', 'tr', 'lab');

db.xaxis(linspace(1,5,5), 2, 4.25, 'a');
db.yaxis(0:5:50, 2);

db.plot_margin([0 0.01 0.005 0]);
end

function plot_chap01_fig07b(db)
fm = @(x,a) cosh(a*(x-acosh(a)/a))/a;
at = 1.282;

db.paper_size([5.3 7]);

cmap = repmat(linspace(0.55,0.95,100)', 1, 3);
db.colormap(cmap);

x = linspace(0,1,101);
y = fm(x,at);
[X Y Z] = rotsurf(x, y, 100);
xidx = 1:10:101;
yidx = 1:5:101;
db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', 'FaceAlpha', 0);
db.surf(X,Y,Z, 'LineStyle', 'none', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'FaceColor', 'interp', 'FaceAlpha', 1);
db.surf(X(xidx,:),Y(xidx,:),Z(xidx,:), ...
  'LineStyle', '-', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'MeshStyle', 'row', 'FaceColor', 'none');
db.surf(X(:,yidx),Y(:,yidx),Z(:,yidx), ...
  'LineStyle', '-', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'MeshStyle', 'column', 'FaceColor', 'none');
db.plot(x, 0*x, y+0.001, 'line1');
db.textarrow(0.41, 0.76, 2, 'f(\tilde{a},\tilde{b})', 'tr', 'func');

db.xaxis(0:0.5:1,1, [0.13 -1 -1.35], 'x');
db.yaxis(-1:0.5:1,1);
db.zaxis(-1:0.5:1,1);

db.view([25, 30]);
db.axis('tight');
db.axis('equal');
db.box('off');
db.plot_margin([0 0.01 0 0]);

end

function plot_chap01_fig07c(db)
fm = @(x,a) cosh(a*(x-acosh(a)/a))/a;
at = 1.282;

db.paper_size([5.3 7]);

cmap = repmat(linspace(0.55,0.95,100)', 1, 3);
db.colormap(cmap);

x = [linspace(0,0,9) 0 1 linspace(1,1,6)];
y = [linspace(1,0,9) 0 0 linspace(0,fm(1,at),6)];
[X Y Z] = rotsurf(x, y, 20);
db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', 'FaceAlpha', 0);
db.surf(X,Y,Z, 'LineStyle', '-', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'FaceColor', 'interp', 'FaceAlpha', 1);
db.plot(x, 0*x, y+0.001, 'line1');
db.textarrow(0.365, 0.78, 2, 'f_{\mathrm{boundary}}', 'tr', 'func');

db.xaxis(0:0.5:1,1, [0.13 -1 -1.35], 'x');
db.yaxis(-1:0.5:1,1);
db.zaxis(-1:0.5:1,1);

db.view([25, 30]);
db.axis('tight');
db.axis('equal');
db.box('off');
db.plot_margin([0 0.01 0 0]);

end




function plot_chap02_fig02a(db)
cmap = repmat(linspace(0.55,0.95,100)', 1, 3);
db.colormap(cmap);

t = linspace(0,1,201);
xidx = 1:10:201;
yidx = 1:10:201;
[X Y] = meshgrid(t);
Z = X.^2 - (3/2)*X.*Y + 2*Y.^2;

db.axis('tight');
db.box('off');
db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', 'FaceAlpha', 0);

db.surf(X,Y,Z, 'LineStyle', 'none', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'FaceColor', 'interp', 'FaceAlpha', 1);

db.surf(X(xidx,:),Y(xidx,:),Z(xidx,:), ...
  'LineStyle', '-', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'MeshStyle', 'row', 'FaceColor', 'none');
db.surf(X(:,yidx),Y(:,yidx),Z(:,yidx), ...
  'LineStyle', '-', 'LineWidth', 0.5, 'EdgeColor', 0.5*[1 1 1], ...
  'MeshStyle', 'column', 'FaceColor', 'none');

db.surf([0.75 0.75;0.75 0.75], [0 1;0 1], ...
  [0 0;2 2], 'FaceColor', 0.95*[1 1 1], 'FaceAlpha', 0.8, ...
  'EdgeColor', 0.6*[1 1 1], 'LineWidth', 1.0);


t = linspace(0,1,201);
o = ones(size(t));
db.plot(3*o/4, t, 2*t.^2-9*t/8+9/16+0.005);

t0 = 0.65;
z0 = 2*t0.^2-9*t0/8+9/16;
x1 = sqrt(z0*32/23);
x0 = sqrt(z0);

db.surf([0 0;1 1], [0 1;0 1], ...
  [z0 z0;z0 z0], 'FaceColor', 0.95*[1 1 1], 'FaceAlpha', 0.8, ...
  'EdgeColor', 0.6*[1 1 1], 'LineWidth', 1.0);

x  = linspace(0,x1,1000);
y  = (3/8)*x + sqrt(z0/2-(23/64)*x.^2);
db.plot(x, y, x.^2 - (3/2)*x.*y + 2*y.^2+0.005);
x  = linspace(x0,x1,1000);
y  = (3/8)*x - sqrt(z0/2-(23/64)*x.^2);
db.plot(x, y, x.^2 - (3/2)*x.*y + 2*y.^2+0.005);

db.xaxis(0:0.5:1,2, [0.85 0 -0.5], 'p_2');
db.yaxis(0:0.5:1,2, [0 0.9 -0.5], 'p_1');
db.zaxis(0:1:2,2, [0 1.15 1.5], 'T');

db.view([-45 25]);

db.textarrow(0.5, 0.6, 1.5, 'p_2=\mathrm{const.}', 'tr', 'func');
db.textarrow(0.4, 0.445, 1.5, 'T=\mathrm{const.}', 'br', 'func');

db.plot_margin([0.03 0 0 0]);

end

function plot_chap02_fig02b(db)
db.axis([0 1 0 1]);

t = linspace(0,1,201);
o = ones(size(t));
db.plot(t, 3*o/4);
db.textarrow(0.5, 3/4, 2, 'p_2=\mathrm{const.}', 'br', 'func');

t0 = 0.65;
z0 = 2*t0.^2-9*t0/8+9/16;
x1 = sqrt(z0*32/23);
x0 = sqrt(z0);

x  = linspace(0,x1,1000);
y  = (3/8)*x + sqrt(z0/2-(23/64)*x.^2);
db.plot(1-y, x);
db.textarrow(1-y(250), x(250), 2, 'T=\mathrm{const.}', 'r', 'func');

x  = linspace(x0,x1,1000);
y  = (3/8)*x - sqrt(z0/2-(23/64)*x.^2);
db.plot(1-y, x);

db.xaxis(0:0.2:1,2, 0.925, 'p_1');
db.yaxis(0:0.2:1,2, 0.92, 'p_2');

db.plot_margin([0.015 0.02 0 0]);

end




function [data y] = cusp(prob, data, u) %#ok<INUSL>
y = u(2)-u(1)*(u(3)-u(1)^2);
end

function plot_chap15_cusp_surface(db)

N    = 51;
ka   = 0.5;
u0   = [-nthroot(ka,3); ka ; 0];
la   = linspace(-1, 1, N);
prob = coco_prob();
prob = coco_add_func(prob, 'cusp', @cusp, [], 'zero', 'u0', u0);
prob = coco_add_pars(prob, 'pars', [1 2 3], {'x' 'ka' 'la'});
prob = coco_add_event(prob, 'UZ', 'la', la);
bd   = coco(prob, 'cusp_x', [], {'x' 'la'}, {[],[min(la) max(la)]});

x     = coco_bd_col(bd, 'x');
idx   = coco_bd_idxs(bd, 'UZ');
x     = x(idx);
X     = [];
N2    = round(0.8*N);
for i=1:N
  X   = [ X ; linspace(x(i), -x(i), N2) ]; %#ok<AGROW>
end
L     = repmat(-la', 1, N2);
K     = X.*(L-X.^2);

db.paper_size([16 6]);
cmap  = repmat(linspace(0.55,0.95,100)', 1, 3);
db.colormap(cmap);
db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', ...
  'EdgeColor', 'white', 'FaceAlpha', 0);
db.surf(L,K,X,K, 'FaceColor', 'interp', 'EdgeColor', 0.5*[1 1 1], 'LineWidth', 1.0);
db.axis([min(la) max(la) -ka ka min(x) -min(x)]);
db.camproj('perspective');
db.view([-170 10]);
db.box('off');
db.xaxis(min(la):0.5:max(la),2, [0.45 0.5 min(x)-0.4],'\lambda');
db.yaxis(-ka:0.5:ka,2, [-1.2 0.3 min(x)-0.25], '\kappa');
db.zaxis([min(x) -1:0.5:1 -min(x)],-1:0.5:1, [1.15 0.5 0.7], 'x');
db.plot_margin([0.01 0.05 0 0]);
db.plot_create_template('cusp_surface', mfilename('fullpath'));
db.plot_discard();

end

function plot_chap15_fig01(db)

db.plot_use_template('cusp_surface');
x = linspace(-sqrt(1/3), sqrt(1/3), 100);
k = 2*x.^3;
l = 3*x.^2;
db.plot(l,k+0.001,x,'line1');

end

function plot_chap15_fig02(db)

db.plot_use_template('cusp_surface');
x = linspace(-1, 1, 100);
l = 0.5*ones(1,100);
k = x.*(l-x.^2);
db.plot(l,k+0.001,x,'line1');
db.surf([0.501 0.501;0.501 0.501], [0.5 -0.5;0.5 -0.5], ...
  [-1.19 -1.19;1.19 1.19], 'FaceColor', 0.95*[1 1 1], 'FaceAlpha', 0.85, ...
  'EdgeColor', 0.6*[1 1 1], 'LineWidth', 1.0);

end

function plot_chap15_fig03(db)

db.plot_use_template('cusp_surface');
x = linspace(-1, 1, 100);
l = x.^2;
k = 0*x;
db.plot(l,k+0.005,x,'line1');
l = linspace(-1, 1, 100);
x = 0*l;
k = 0*l;
db.plot(l,k+0.005,x,'line1');
db.surf([1 -1;1 -1], [-0.0001 -0.0001;-0.0001 -0.0001], ...
  [-1.19 -1.19;1.19 1.19], 'FaceColor', 0.95*[1 1 1], 'FaceAlpha', 0.85, ...
  'EdgeColor', 0.6*[1 1 1], 'LineWidth', 1.0);

end

function plot_chap15_postprocess(db)
db.plot_discard();

db.plot_align_all_axes({'chap15_fig01'});
db.plot_align_all_axes({'chap15_fig02'});
db.plot_align_all_axes({'chap15_fig03'});

end
