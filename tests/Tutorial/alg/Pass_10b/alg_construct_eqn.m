%!alg_construct_eqn
function prob = alg_construct_eqn(prob, tbid, data, sol)

prob = coco_add_func(prob, tbid, @alg_F, @alg_DFDU, data, 'zero', ...
  'u0', sol.u);
uidx = coco_get_func_data(prob, tbid, 'uidx');
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, uidx(data.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');
if data.alg.norm
  data.tbid = tbid;
  prob = coco_add_slot(prob, tbid, @alg_bddat, data, 'bddat');
end

switch data.alg.FO
  case {'regular', 'active'}
    fid_FO = coco_get_id(tbid, 'test', 'FO');
    data.tbid = tbid;
    data = coco_func_data(data);
    prob = coco_add_func(prob, fid_FO, @alg_fold, ...
      @alg_fold_DFDU, data, data.alg.FO, fid_FO, ...
      'uidx', uidx, 'fdim', 1);
    prob = coco_add_slot(prob, tbid, @alg_update, data, 'update');
    prob = coco_add_event(prob, 'FO', fid_FO, 0);
end

if data.alg.HB
  fid_HB = coco_get_id(tbid, 'test', 'HB');
  prob = coco_add_func(prob, fid_HB, @alg_hopf, data, ...
    'regular', fid_HB, 'uidx', uidx);
  prob = coco_add_event(prob, 'HB', fid_HB, 0);
end

end %!end_alg_construct_eqn
%!alg_F
function [data y] = alg_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = data.fhan(x, p);

end %!end_alg_F
%!alg_DFDU
function [data J] = alg_DFDU(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);

J1 = alg_fhan_DFDX(data, x, p);
J2 = alg_fhan_DFDP(data, x, p);
J  = sparse([J1 J2]);

end %!end_alg_DFDU
%!alg_fold
function [data y] = alg_fold(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
v  = [Jx data.b; data.c' 0]\data.rhs;
y  = v(end);

end %!end_alg_fold
%!alg_fold_DFDU
function [data J] = alg_fold_DFDU(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
M  = [Jx data.b; data.c' 0];
v  = M\data.rhs;
w  = data.rhs'/M;

h  = 1.0e-4*(1+norm(x));
J0 = alg_fhan_DFDX(data, x-h*v(data.x_idx), p);
J1 = alg_fhan_DFDX(data, x+h*v(data.x_idx), p);
hx = -w(data.x_idx)*(0.5/h)*(J1-J0);

J0 = alg_fhan_DFDP(data, x-h*v(data.x_idx), p);
J1 = alg_fhan_DFDP(data, x+h*v(data.x_idx), p);
hp = -w(data.x_idx)*(0.5/h)*(J1-J0);

J  = [hx hp];

end %!end_alg_fold_DFDU
%!alg_update
function data = alg_update(prob, data, cseg, varargin)

chart  = cseg.src_chart;
uidx   = coco_get_func_data(prob, data.tbid, 'uidx');
u      = chart.x(uidx);
x      = u(data.x_idx);
p      = u(data.p_idx);
Jx     = alg_fhan_DFDX(data, x, p);
w      = data.rhs'/[Jx data.b; data.c' 0];
data.b = w(data.x_idx)';
data.b = data.b/norm(data.b);
v      = [Jx data.b; data.c' 0]\data.rhs;
data.c = v(data.x_idx);
data.c = data.c/norm(data.c);

end %!end_alg_update
%!alg_hopf
function [data y] = alg_hopf(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
la = eig(Jx);
la = la(data.la_idx1)+la(data.la_idx2);
sc = abs(la);
y  = real(prod((2*la)./(max(1,sc)+sc)));

end %!end_alg_hopf
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
