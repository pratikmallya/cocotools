function chap16_fig05
oldpath = path;
addpath('../../../../Atlas_Algorithms/Pass_10');
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  path(oldpath);
catch e
  path(oldpath);
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~(coco_exist('run6', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd = coco_bd_read('run6', 'bd');

db.plot_create('chap16_fig05a', mfilename('fullpath'));

% [atlas bd] = coco_bd_read('run6', 'atlas', 'bd');
% [tri X] = plot_cuspsurf(db, atlas.charts, 3, 2, 1);
% 
% x0      = repmat([0 0 0], size(X,1), 1);
% n       = [1 1 1];
% C       = n*(X-x0)';
% cmap    = repmat(linspace(0.55,0.95,100)', 1, 3);
% db.colormap(cmap);
% db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', ...
%   'EdgeColor', 'white', 'FaceAlpha', 0);
% db.trisurf(tri, X(:,1), X(:,2), X(:,3), C, 'FaceColor', 'interp', ...
%   'EdgeColor', 0.5*[1 1 1]);
% db.box('off');
% db.plot_create_template('cusp_surf1', mfilename('fullpath'));
% 
% db.plot_discard();
% db.plot_create('chap16_fig05a', mfilename('fullpath'));
% db.surf([0 0;0 0], [0 0;0 0], [0 0;0 0], 'FaceColor', 'white', ...
%   'EdgeColor', 'white', 'FaceAlpha', 0);
% db.trisurf(tri, X(:,2), X(:,1), X(:,3), 'FaceColor', 0.8*[1 1 1], ...
%   'EdgeColor', 0.7*[1 1 1], 'LineWidth', 0.5, 'FaceAlpha', 0.35);
% db.box('off');
% db.plot_create_template('cusp_surf2', mfilename('fullpath'));

db.plot_use_template('cusp_surf1');
x  = coco_bd_col(bd, '||x||');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
idx = coco_bd_idxs(bd, 'FO');
db.plot(la(idx)+0.05, ka(idx), x(idx), 'none1', 'marker2l')
db.view([100 25]);

db.axis([-1 1 -0.5 0.5 0 1.2]);

db.xaxis(-1:0.5:1, 2, [-0.5 0.6 -0.3], '\lambda');
db.yaxis(-0.6:0.2:0.6,2, [1 -0.4 -0.28], '\kappa');
db.zaxis(0:0.2:1.2,0:0.2:1, [1 -0.65 1.3], '\|X\|');

db.plot_margin([0.04 0.03 0.02 0]);
db.plot_close();

db.plot_align_all_axes({'chap16_fig05a'});



db.plot_create('chap16_fig05b', mfilename('fullpath'));

db.plot_use_template('cusp_surf2');
x  = coco_bd_col(bd, '||x||');
ka = coco_bd_col(bd, 'ka');
la = coco_bd_col(bd, 'la');
idx = coco_bd_idxs(bd, 'FO');
db.plot(ka(idx), la(idx), x(idx)+1.3, 'none1', 'marker2l')
db.view([0 90]);

db.axis([-0.5 0.5 -1 1 0 2]);

db.xaxis(-0.6:0.2:0.6,2, 0.3, '\kappa');
db.yaxis(-1:0.5:1, 2, 0.75, '\lambda');
% db.zaxis(0:0.2:1.2,0:0.2:1, [1 -0.65 1.3], '\|X\|');

db.plot_margin([0.02 0.02 0.01 0]);
db.plot_close();

db.plot_align_all_axes({'chap16_fig05b'});

end

function [tri X] = plot_cuspsurf(db, charts, IX, IY, IZ)
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
X(:,3)=abs(X(:,3));
end
