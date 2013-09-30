function chap18_fig02
addpath('..');
try
  N  = [2 3 4 5 7 9];
  db = plotdb(1);
  plot_first(db, N);
  rmpath('..');
catch e
  rmpath('..');
  rethrow(e);
end

end

function plot_first(db, N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second sequence of plots of difference to solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yticks = {
  [-1 -0.5 0]
  1.0e-1*[-3 0 3]
  1.0e-1*[-2 -1 0 1]
  1.0e-1*[-1 0 1]
  1.0e-2*[-3 0 3]
  1.0e-2*[-1 0 1]
  };

for i=1:6
  plot_name = sprintf('chap18_fig02%c', char('a'+i-1));
  db.plot_create(plot_name, mfilename('fullpath'));
  db.paper_size([8 2]);
  
  tk = linspace(-1,1,N(i));
  x  = linspace(-1,1,1000);
  f  = @(x) prod(x-tk);
  y  = arrayfun(f, x);
  db.plot(x,y, 'line1');
  db.plot(tk,0*tk, 'line2g4', 'marker4');
  db.axis('+', [0.02 0.08]);
  
  db.xaxis(-1:0.5:1, 2, 0.85, '\sigma');
  db.yaxis(yticks{i});
  db.plot_margin([0.02 0.025 0 0]);
  
  db.plot_close();
end

% align axes
plots = {
  'chap18_fig02a' 'chap18_fig02b'
  'chap18_fig02c' 'chap18_fig02d'
  'chap18_fig02e' 'chap18_fig02f'
  };

db.plot_align_all_axes(plots);

end
