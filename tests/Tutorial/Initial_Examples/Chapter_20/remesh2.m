%!remesh
function [prob stat xtr] = remesh(prob, data, chart, ub, Vb)

f  = ub(data.x_idx);
df = Vb(data.x_idx,:);

g  = 2*(f-f(1))/(f(end)-f(1))-1+data.s*data.t;
u  = 2*(g-g(1))/(g(end)-g(1))-1;
t0 = interp1(u, data.t, data.th);
ua = [interp1(data.t, f,  t0); ub(data.p_idx)];
Va = [interp1(data.t, df, t0); Vb(data.p_idx,:)];

data.t = t0;
xtr    = data.xtr;
prob   = coco_change_func(prob, data, 'u0', ua, 'vecs', Va);
stat   = 'success';

end %!end_remesh
%coco_log(prob, 1, 1, '%s: remeshed, N=%d, H=%d, status=''%s''\n', mfilename, N, H, stat);