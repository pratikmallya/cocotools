%!alg_construct_eqn
function prob = alg_construct_eqn(prob, tbid, data, sol)

prob = coco_add_func(prob, tbid, @alg_F, @alg_DFDU, data, 'zero', ...
  'u0', sol.u);
uidx = coco_get_func_data(prob, tbid, 'uidx');
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, uidx(data.p_idx), data.pnames);
end
if data.alg.norm
  prob = coco_add_slot(prob, tbid, @alg_bddat, data, 'bddat');
end

if data.alg.FO
  fid_FO = coco_get_id(tbid, 'FO');
  switch lower(data.alg.FOTF)
    case {'fold1a' 'fold1b' 'fold1c'}
      fold_TF = str2func(sprintf('alg_%s', lower(data.alg.FOTF)));
      prob = coco_add_func(prob, fid_FO, fold_TF, ...
        data, 'regular', fid_FO, 'uidx', uidx);
    case {'fold2_reg','fold2_act'}
      data.rhs = [zeros(numel(data.x_idx),1); 1];
      data.eye = eye(numel(data.p_idx));
      data = coco_func_data(data);
      data = alg_init(prob, data, sol.x, sol.p);
      if strcmp(data.alg.FOTF, 'fold2_reg')
        prob = coco_add_func(prob, fid_FO, @alg_fold2, ...
          data, 'regular', fid_FO, 'uidx', uidx, 'fdim', 1);
      else
        prob = coco_add_func(prob, fid_FO, @alg_fold2, ...
          @alg_fold2_DFDU, data, 'active', fid_FO, ...
          'uidx', uidx, 'fdim', 1);
      end
      % this should really be unnecessary
      % prob = coco_add_slot(prob, tbid, @alg_init, data, ...
      %   'FSM_state_init_admissible_begin');
      prob = coco_add_slot(prob, tbid, @alg_update, data, 'update');
    otherwise
      error('%s: unrecognised test function type ''%s''', ...
        mfilename, data.alg.FOTF);
  end
  prob = coco_add_event(prob, 'FO', 'SP', fid_FO, 0);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_alg_construct_eqn
%!alg_F
function [data y] = alg_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = data.fhan(x, p);

end %!end_alg_F
%!alg_DFDU
function [data J] = alg_DFDU(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

J1 = alg_fhan_DFDX(data, x, p);
J2 = alg_fhan_DFDP(data, x, p);
J = sparse([J1 J2]);

end %!end_alg_DFDU
%!alg_fold1a
function [data y] = alg_fold1a(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
y  = det(Jx);

end %!end_alg_fold1a
%!alg_fold1b
function [data y] = alg_fold1b(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
la = eig(Jx);
sc = abs(la);
y  = prod((2*la)./(max(1,sc)+sc));

end %!end_alg_fold1b
%!alg_fold1c
function [data y] = alg_fold1c(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
la = eig(Jx);
sg = prod(sign(real(la)));
sc = min([abs(la) ; 1]);
y  = sg*sc;

end %!end_alg_fold1c
%!alg_fold2
function [data y] = alg_fold2(prob, data, u)

if isfield(data, 'b')
  x  = u(data.x_idx);
  p  = u(data.p_idx);
  Jx = alg_fhan_DFDX(data, x, p);
  v  = [Jx data.b; data.c' 0] \ data.rhs;
  y  = v(end);
else
  y = nan;
end

end %!end_alg_fold2
%!alg_fold2_DFDU
function [data J] = alg_fold2_DFDU(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
M  = [Jx data.b; data.c' 0];
v  = M \ data.rhs;
w  = data.rhs' / M;

h  = 1.0e-4*(1+norm(x));
J0 = alg_fhan_DFDX(data, x-h*v(data.x_idx), p);
J1 = alg_fhan_DFDX(data, x+h*v(data.x_idx), p);
hx = -w(data.x_idx)*(0.5/h)*(J1-J0);

Jpv = zeros(numel(J0),numel(p));
for i=1:numel(p)
  h        = 1.0e-6*(1+abs(p(i)));
  J0       = alg_fhan_DFDX(data, x, p-h*data.eye(:,i));
  J1       = alg_fhan_DFDX(data, x, p+h*data.eye(:,i));
  Jpv(:,i) = (0.5/h)*(J1-J0)*v(data.x_idx);
end
hp   = -w(data.x_idx)*Jpv;
J    = [hx hp];

end %!end_alg_fold2_DFDU
%!alg_init
function data = alg_init(prob, data, x0, p0)

if nargin==2
  chart = prob.cont.chart0;
  uidx   = coco_get_func_data(prob, data.tbid, 'uidx');
  u     = chart.x(uidx);
  x0    = u(data.x_idx);
  p0    = u(data.p_idx);
end
Jx        = alg_fhan_DFDX(data, x0, p0);
[data.b, ~, data.c] = svds(Jx,1,0);

end
%!end_alg_init %!alg_update
function data = alg_update(prob, data, cseg, varargin)

chart  = cseg.src_chart;
uidx   = coco_get_func_data(prob, data.tbid, 'uidx');
u      = chart.x(uidx);
x      = u(data.x_idx);
p      = u(data.p_idx);
Jx     = alg_fhan_DFDX(data, x, p);
w      = data.rhs' / [Jx data.b; data.c 0];
data.b = w(data.x_idx)';
data.b = data.b/norm(data.b);
v      = [Jx data.b; data.c 0] \ data.rhs;
data.c = v(data.x_idx)';
data.c = data.c/norm(data.c);
data.M = [Jx data.b; data.c 0];

end %!end_alg_update
%!alg_bddat
function [data res] = alg_bddat(prob, data, command, varargin)

res = {};
switch command
  case 'init'
    res   = '||x||';
  case 'data'
    chart = varargin{1};
    uidx  = coco_get_func_data(prob, data.tbid, 'uidx');
    u     = chart.x(uidx);
    res   = norm(u(data.x_idx),2);
end

end %!end_alg_bddat