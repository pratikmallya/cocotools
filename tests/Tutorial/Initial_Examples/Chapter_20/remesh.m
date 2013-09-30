%!remesh
function [prob stat xtr] = remesh(prob, data, chart, ub, Vb)

f  = ub(data.x_idx);
df = Vb(data.x_idx,:);

g  = 2*(f-f(1))/(f(end)-f(1))-1+data.s*data.t;
u  = 2*(g-g(1))/(g(end)-g(1))-1;
t0 = interp1(u, data.t, data.th);
t0([1 end]) = [-1 1];
ua = [interp1(data.t, f,  t0); ub(data.p_idx)];
Va = [interp1(data.t, df, t0); Vb(data.p_idx,:)];

xtr = data.xtr;
N   = numel(t0);
if numel(data.t)~=numel(t0)
  data.N     = N;
  data.x_idx = 1:N;
  data.p_idx = N+data.pdim;
  xtr(end-data.pdim:end) = N:N+data.pdim;
  data.xtr   = zeros(N+data.pdim,1);
  data.xtr([1 N:N+data.pdim]) = [1 N:N+data.pdim];
end
data.t = t0;
prob   = coco_change_func(prob, data, 'u0', ua, 'vecs', Va);

H  = max(abs(diff(data.t)));
N2 = N;
if H>data.HINC
  N2 = min(100, ceil(N*min((H/data.HINC), 1.1)));
elseif H<data.HDEC
  N2 = max(10, ceil(N*max((H/data.HDEC), 0.75)));
end
if N~=N2
  data.th = linspace(-1, 1, N2)';
  stat = 'repeat';
else
  stat = 'success';
end

end %!end_remesh
%coco_log(prob, 1, 1, '%s: remeshed, N=%d, H=%d, status=''%s''\n', mfilename, N, H, stat);