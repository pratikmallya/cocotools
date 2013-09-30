% %!var_add_func
function prob = var_add_func(tbid, data, sol)

prob  = coco_prob();
prob  = coco_add_func(prob, tbid, @var_F, @var_DFDU, data, 'zero', ...
  'u0', sol.u);
prob  = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

fid  = coco_get_id(tbid, 'pars');
prob = coco_add_pars(prob, fid, data.p_idx, 'beta');
fid  = coco_get_id(tbid, 'update');
prob = coco_add_slot(prob, fid, @var_update, data, 'update');

end %!end_var_add_func
%!var_F
function [data y] = var_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

fode  = (p*data.fx-data.Wp)*x;
fcont = data.Q*x;
fbc   = data.B*x - data.I3;

y = [fode; fcont; fbc];

end %!end_var_F
%!var_DFDU
function [data J] = var_DFDU(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

J = [
  (p*data.fx-data.Wp)  data.fx*x
  data.Q               data.z1
  data.B               data.z2
  ];

end %!end_var_DFDU
%!var_update
function data = var_update(prob, data, cseg, varargin)

x      = cseg.src_chart.x;
M0     = reshape(x(data.x_idx), data.M_shape);
B      = data.B1+M0'*data.B2;
data.B = kron(speye(data.dim),B);

end %!end_var_update