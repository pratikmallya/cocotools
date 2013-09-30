function chap20_fig01
addpath('..');
try
  compute_run_data()
  db = plotdb(1);
  plot_first(db);
  plot_second(db);
  plot_third(db);
  rmpath('..');
  coco_clear_cache('reset');
catch e
  rmpath('..');
  coco_clear_cache('reset');
  rethrow(e);
end

end

function compute_run_data()
% run demo
if ~(coco_exist('1', 'run') && coco_exist('2', 'run') ...
    && coco_exist('3', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd = coco_bd_read('1');
labs = coco_bd_labs(bd, 'UZ');

for i=1:numel(labs)
  plot_name = sprintf('chap20_fig01%c', char('a'+i-1));
  db.plot_create(plot_name, mfilename('fullpath'));
  db.paper_size([8 2]);

  [soldata sol] = coco_read_solution('tanh','1',labs(i));
  db.plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)), ...
    'line1g6');
  db.plot(soldata.t, sol.x(soldata.x_idx), 'numdatal')
  
  db.plot(soldata.t, 0*soldata.t-1.2, 'none1', 'marker4s');
  
  db.axis('+', [0.02 0.1])
  
  db.xaxis(-1:0.5:1, 5, 0.85, 't');
  db.textbox(-0.9, 0.3, 'f', 'tr', 'func');
  db.yaxis(-1:1:1, 2);
  db.plot_margin([0.02 0.025 0 0]);
  
  db.plot_close();
  
  % fprintf('p = %.3e\n', coco_bd_val(bd, labs(i), 'p'));
end

% align axes
plots = {
  'chap20_fig01a' 'chap20_fig01b'
  'chap20_fig01c' 'chap20_fig01d'
  };

db.plot_align_all_axes(plots);

end

function plot_second(db)

bd = coco_bd_read('2');
labs = coco_bd_labs(bd, 'UZ');

for i=1:numel(labs)
  plot_name = sprintf('chap20_fig02%c', char('a'+i-1));
  db.plot_create(plot_name, mfilename('fullpath'));
  db.paper_size([8 2]);

  [soldata sol] = coco_read_solution('tanh','2',labs(i));
  db.plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)), ...
    'line1g6');
  db.plot(soldata.t, sol.x(soldata.x_idx), 'numdatal')
  
  db.plot(soldata.t, 0*soldata.t-1.2, 'none1', 'marker4s');
  
  db.axis('+', [0.02 0.1])
  
  db.xaxis(-1:0.5:1, 5, 0.85, 't');
  db.textbox(-0.9, 0.3, 'f', 'tr', 'func');
  db.yaxis(-1:1:1, 2);
  db.plot_margin([0.02 0.025 0 0]);
  
  db.plot_close();
  
  % fprintf('p = %.3e\n', coco_bd_val(bd, labs(i), 'p'));
end

% align axes
plots = {
  'chap20_fig02a' 'chap20_fig02b'
  'chap20_fig02c' 'chap20_fig02d'
  };

db.plot_align_all_axes(plots);

end

function plot_third(db)

bd = coco_bd_read('3');
labs = coco_bd_labs(bd, 'UZ');

for i=1:numel(labs)
  plot_name = sprintf('chap20_fig03%c', char('a'+i-1));
  db.plot_create(plot_name, mfilename('fullpath'));
  db.paper_size([8 2]);

  [soldata sol] = coco_read_solution('tanh','3',labs(i));
  db.plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)), ...
    'line1g6');
  db.plot(soldata.t, sol.x(soldata.x_idx), 'numdatal')
  
  db.plot(soldata.t, 0*soldata.t-1.2, 'none1', 'marker4s');
  
  db.axis('+', [0.02 0.1])
  
  db.xaxis(-1:0.5:1, 5, 0.85, 't');
  db.textbox(-0.9, 0.3, 'f', 'tr', 'func');
  db.yaxis(-1:1:1, 2);
  db.plot_margin([0.02 0.025 0 0]);
  
  db.plot_close();
  
  fprintf('p = %2d, N = %d\n', coco_bd_val(bd, labs(i), 'p'), numel(soldata.t));
end

% align axes
plots = {
  'chap20_fig03a' 'chap20_fig03b'
  'chap20_fig03c' 'chap20_fig03d'
  };

db.plot_align_all_axes(plots);

end
