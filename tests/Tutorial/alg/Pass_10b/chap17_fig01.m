function chap17_fig01
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  path(oldpath);
  coco_clear_cache('reset');
catch e
  path(oldpath);
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~(coco_exist('run', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd = coco_bd_read('run', 'bd');

db.plot_create('chap17_fig01a', mfilename('fullpath'));

% [atlas bd] = coco_bd_read('run', 'atlas', 'bd');
% [tri X] = get_trisurf(atlas.charts, 3,4,1);
% 
% x0      = repmat([0 0 0], size(X,1), 1);
% n       = [-0.5 -0.3 0.01];
% C       = n*(X-x0)';
% cmap    = repmat(linspace(0.55,0.95,100)', 1, 3);
% db.colormap(cmap);
% db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', ...
%   'EdgeColor', 'white', 'FaceAlpha', 0);
% db.trisurf(tri, X(:,1), X(:,2), X(:,3), C, 'FaceColor', 'interp', ...
%   'EdgeColor', 0.5*[1 1 1], 'LineWidth', 0.5);
% db.box('off');
% db.plot_create_template('popul_surf1', mfilename('fullpath'));
%
% db.plot_discard();

db.plot_use_template('popul_surf1');
idx1 = coco_bd_idxs(bd, 'HB');
idx2 = coco_bd_idxs(bd, 'FO');
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
db.plot(p1(idx1)-0.001,p2(idx1)-0.001,x(idx1),'none1', 'marker2l')
db.plot(p1(idx2)-0.002,p2(idx2),x(idx2),'none1', 'marker4l')

db.view([-15 15]);

db.axis([0 0.5 0 0.25 0 10]);

db.xaxis(0:0.1:0.5, 1, [0.37 0 -1.7], 'p_1');
db.yaxis([0 0.1 0.2 0.25],[0 0.1 0.2], [-0.05 0.25 -3], 'p_2');
db.zaxis(0:2:10,1, [-0.05 0.27 8.8], 'x');

db.plot_margin([0.03 0.03 0.01 0]);
db.plot_close();




db.plot_create('chap17_fig01b', mfilename('fullpath'));

x = linspace(0,0.25,100);
y = (1+sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')
y = (1-sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')

db.plot(p1(idx1),p2(idx1),'none1', 'marker2l')
db.plot(p1(idx2),p2(idx2),'none1', 'marker4l')

db.axis([0 0.5 0 0.255]);

db.xaxis(0:0.1:0.5, 1, 0.44, 'p_1');
db.yaxis(0:0.1:0.3,2, 0.235, '\!p_2');

db.plot_margin([0.02 0.03 0 0]);
db.plot_close();

db.plot_align_all_axes({'chap17_fig01a' 'chap17_fig01b'});

end

function [tri X] = get_trisurf(charts, IX, IY, IZ)
tri = [];
X   = [];
N   = numel(charts);
for k=1:N
  chart = charts{k};
  X     = [ X ; chart.x([IX IY IZ])' ];
  ic    = [chart.nb chart.nb(1)];
  ix    = chart.id;
  for l=1:numel(ic)-1
    face = sort([ix ic(l) ic(l+1)]);
    if all(face>0) && ~ismember(face, tri, 'rows')
      tri  = [tri ; face];
    end
  end
end
end
