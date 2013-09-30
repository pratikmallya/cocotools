%!interp_construct_curve
function prob = interp_construct_curve(prob, data, sol)

data = coco_func_data(data);
prob = coco_add_func(prob, 'interp', @interp_F, data, 'zero', ...
  'u0', sol, 'remesh', @remesh);
prob = coco_add_slot(prob, 'interp', @bddat, data, 'bddat');

end %!end_interp_construct_curve
%!interp_F
function [data y] = interp_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = x-data.fhan(data.t', repmat(p, [1 data.N]))';

end %!end_interp_F
%!remesh
function [prob status xtr] = remesh(prob, data, ...
  chart, old_x, old_t, old_TS)

u  = old_x(data.x_idx);
v  = old_t(data.x_idx);
TS = old_TS(data.x_idx,:);

uu  = 2*(u-u(1))/(u(end)-u(1))-1+data.sg*data.t;
uu  = 2*(uu-uu(1))/(uu(end)-uu(1))-1;
t0  = interp1(uu, data.t, data.th, 'cubic');
u0  = [interp1(data.t, u, t0, 'cubic'); old_x(data.p_idx)];
v0  = [interp1(data.t, v, t0, 'cubic'); old_t(data.p_idx)];
TS0 = [interp1(data.t, TS,t0, 'cubic'); old_TS(data.p_idx,:)];
xtr = data.xtr;
N   = numel(t0);
if numel(data.t)~=numel(t0)
  data.N     = N;
  data.x_idx = 1:N;
  data.p_idx = N+(1:data.pdim);
  xtr(end-data.pdim:end) = N:N+data.pdim;
  data.xtr   = zeros(N+data.pdim,1);
  data.xtr([1 N data.p_idx]) = [1 N data.p_idx];
end
data.t = t0;
prob   = coco_change_func(prob, data, 'u0', u0, 't0', v0, 'TS', TS0);

H  = max(abs(diff(data.t)));
N2 = N;
if H>0.3
  N2 = min(100, ceil(N*min((H/0.2), 1.1)));
elseif H<0.2
  N2 = max(10, ceil(N*max((H/0.2), 0.75)));
end
if N~=N2
  data.th = linspace(-1, 1, N2)';
  status = 'repeat';
else
  status = 'success';
end

end %!end_remesh
%!interp_bddat
function [data res] = bddat(prob, data, command, sol)

switch command
  case 'init'
    res = {'u', 't'};
  case 'data'
    res = {sol.x(data.x_idx), data.t};
end

end %!end_tanh_bddat

%coco_log(prob, 1, 1, '%s: remeshed, N=%d, status=''%s''\n', mfilename, N, status);