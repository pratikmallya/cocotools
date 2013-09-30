function chap07_fig01
addpath('..');
try
  db = plotdb(1);
  plot_data(db);
  rmpath('..');
catch e
  rmpath('..');
  rethrow(e);
end
end

function plot_data(db)
db.plot_create('chap07_fig01', mfilename('fullpath'));
% db.paper_size([16 4]);

N  = 4;
tk = linspace(-1,1,N);
% tk = -cos(linspace(0,pi,N));
th = coll_nodes(N-1);
t0 = linspace(-1,1,N*50);

for i=1:N-1
  db.plot([th th], [-2 2], 'line2g4')
end

ymax  = 0;
ymin  = 0;
lines = {'line1g6', 'line1', 'line1', 'line1g6'};
nlin  = numel(lines);
for i=N:-1:1
  y = lag_base(i, tk, t0);
  ymax = max(ymax, max(y));
  ymin = min(ymin, min(y));
  db.plot(t0, y, lines{mod(i,nlin)+1})
end

db.plot(tk, ones(size(tk)), 'none2', 'marker4s')
db.plot(tk, zeros(size(tk)), 'none2', 'marker4')
db.axis([-1 1 ymin-0.05 ymax+0.05]);

db.plot_margin([0.02 0 0 0]);

x = -0.6;
y = lag_base(1, tk, x);
db.textarrow(x, y, 3, '{\cal L}_1', 'tr', 'func');
y = lag_base(2, tk, x);
db.textarrow(x, y, 3, '{\cal L}_2', 'br', 'func');

x = 0.6;
y = lag_base(3, tk, x);
db.textarrow(x, y, 3, '{\cal L}_3', 'bl', 'func');
y = lag_base(4, tk, x);
db.textarrow(x, y, 3, '{\cal L}_4', 'tl', 'func');

db.xaxis(linspace(-1,1,5),5, 0.8, '\sigma');
db.yaxis(linspace(-0.4,1,8),2);

db.plot_close();

db.plot_set_bbox('chap07_fig01');

end

function [x, w] = coll_nodes(n)

nn = 1:n-1;
ga = -nn.*sqrt(1./(4.*nn.^2-1));
J  = zeros(n,n);
J(sub2ind([n n], nn, nn+1)) = ga;
J(sub2ind([n n], nn+1, nn)) = ga;

[w,x] = eig(J);

x = diag(x);
w = 2*w(1,:).^2;

end
