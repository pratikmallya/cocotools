function chap01_fig03
addpath('..');
try
  NCOLS = (1:6);
  compute_run_data(NCOLS);
  db = plotdb(1);
  plot_first(db);
  % plot_second(db, NCOLS);
  rmpath('..');
catch e
  rmpath('..');
  rethrow(e);
end

end

function compute_run_data(NCOLS)

fp = @(x,a) [cosh(a*(x+acosh(a)/a))/a sinh(a*(x+acosh(a)/a))];
t0 = linspace(0,1,100)';
x0 = fp(t0,1.5);
Y0 = x0(end,1);

if ~coco_exist('run1', 'run')
  prob = coco_prob();
  prob = coco_set(prob, 'coll', 'NTST', 1, 'NCOL', 2, 'TOL', 1);
  prob = coll_isol2sol(prob, '', @catenary, t0, x0, Y0);
  data = coco_get_func_data(prob, 'coll', 'data');
  prob = coco_add_func(prob, 'bcs', @catenary_bc, @catenary_bc_DFDX, [], 'zero', ...
    'xidx', [data.x0idx(1) ; data.x1idx(1) ; data.p_idx(1)]);
  prob = coco_add_pars(prob, '', [data.p_idx, data.Tidx], {'Y0', 'T'});
  coco(prob, 'run1', [], 0, {'Y0' 'coll.err' 'T'});
end

for i=1:numel(NCOLS)
  run = sprintf('run2_%d', NCOLS(i));
  if ~coco_exist(run, 'run')
    prob = coco_prob();
    prob = coco_set(prob, 'coll', 'NTST', 1, 'NCOL', NCOLS(i), 'TOL', 10);
    prob = coll_isol2sol(prob, '', @catenary, t0, x0, Y0);
    data = coco_get_func_data(prob, 'coll', 'data');
    prob = coco_add_func(prob, 'bcs', @catenary_bc, @catenary_bc_DFDX, [], 'zero', ...
      'xidx', [data.x0idx(1) ; data.x1idx(1) ; data.p_idx(1)]);
    prob = coco_add_pars(prob, '', [data.p_idx, data.Tidx], {'Y0', 'T'});
    coco(prob, run, [], 0, {'Y0' 'coll.err' 'T'});
  end
end

end

function plot_first(db)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot of exact and approximate solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

db.plot_create('chap01_fig03', mfilename('fullpath'));
db.paper_size([16 6]);

fp = @(x,a) [cosh(a*(x+acosh(a)/a))/a sinh(a*(x+acosh(a)/a))];
t0 = linspace(0,1,100)';
x0 = fp(t0,1.5);

db.plot(t0, x0(:,1), 'line1g5');

[t,x,data] = coll_read_sol('', 'run1', 1); %#ok<ASGLU>
tk   = (data.tk+1)/2;
th   = (data.th+1)/2;
y    = lag_interp(x(1,:), tk, t0);
cpts = lag_interp(x(1,:), tk, th);

db.plot(t0, y, 'line1')
db.plot(th, cpts, 'none1', 'marker4l')

db.axis([-0.02 1.02 0 4]);

y = fp(0.25,1.5);
db.textarrow(0.25, y(1), 1.5, 'f(a,b)', 'tl', 'func');
db.textarrow(0.25, lag_interp(x(1,:), tk, 0.25), 1.5, 'p_1', 'br', 'func');

db.xaxis(linspace(0,1,6), 4, 0.95, 'x');
db.yaxis(linspace(0,4,5), 1);
%db.plot_margin([0 0.04 0 0.0]);

db.plot_close();
db.plot_set_bbox('chap01_fig03');

end

function plot_second(db, NCOLS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second sequence of plots of difference to solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot_labs = char('a'+NCOLS-NCOLS(1));

fp = @(x,a) [cosh(a*(x+acosh(a)/a))/a sinh(a*(x+acosh(a)/a))];
t0 = linspace(0,1,100)';
x0 = fp(t0,1.5);

yticks = {
  1.0e-1*[-4   -1]
  1.0e-2*[-1    4]
  1.0e-3*[-4 0  4]
  1.0e-4*[-3 0  3]
  1.0e-5*[-2 0  2]
  1.0e-6*[-1 0  1]
  };

for i=1:numel(NCOLS)
  
  plot_name = sprintf('chap01_fig03%c', plot_labs(i));
  db.plot_create(plot_name, mfilename('fullpath'));
  db.paper_size([8 2]);
  
  run = sprintf('run2_%d', NCOLS(i));
  [t,x,data] = coll_read_sol('', run, 1); %#ok<ASGLU>
  tk   = (data.tk+1)/2;
  th   = (data.th+1)/2;
  y    = lag_interp(x(1,:), tk, t0);
  cpts = lag_interp(x(1,:), tk, th);
  
  % db.plot(t0, 0*x0(:,1), 'line3g5')
  db.plot(t0, 0*t0, 'line2g4')
  db.plot(t0, x0(:,1)-y, 'line1')
  x1 = fp(th,1.5);
  db.plot(th, x1(:,1)-cpts, 'none1', 'marker4')
  db.axis('+', [0.02 0.08]);
  
  % db.title([0 -0.02], sprintf('\\boldmath$f(a,b)-f_{%d}$', NCOLS(i)), 'math2');
  % db.xlabel([0 -0.02], '\boldmath$x$', 'math1');
  db.xaxis(linspace(0,1,6), 2, 0.9, 'x');
  db.yaxis(yticks{i});
  db.plot_margin([0.02 0.025 0 0]);
  
  db.plot_close();
  
end

% align axes
plots = {
  'chap01_fig03a' 'chap01_fig03d'
  'chap01_fig03b' 'chap01_fig03e'
  'chap01_fig03c' 'chap01_fig03f'
  };

db.plot_align_all_axes(plots);

end
