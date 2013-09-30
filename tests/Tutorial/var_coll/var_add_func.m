%!var_add_func
function varopts = var_add_func(tbid, data, sol)

data_ptr = coco_ptr(data);

varopts  = coco_add_func(tbid, @var_F, @var_DFDU, data_ptr, ...
  'zero', 'u0', sol.u);
varopts  = coco_add_slot(varopts, tbid, @coco_save_data, ...
  data_ptr, 'save_full');

fid      = coco_get_id(tbid, 'pars');
varopts  = coco_add_pars(varopts, fid, data.p_idx, 'beta');
fid      = coco_get_id(tbid, 'update');
varopts  = coco_add_slot(varopts, fid, @var_update, ...
  data_ptr, 'update');

end
%!end_var_add_func %!var_F
function [data_ptr y] = var_F(opts, data_ptr, u)

data = data_ptr.data;

x = u(data.x_idx);
p = u(data.p_idx);

y = (p*data.var1+data.var2)*x+data.var3;

end
%!end_var_F %!var_DFDU
function [data_ptr J] = var_DFDU(opts, data_ptr, u)

data = data_ptr.data;

x = u(data.x_idx);
p = u(data.p_idx);

J = sparse([p*data.var1+data.var2, data.var1*x]);

end
%!end_var_DFDU %!var_update
function data_ptr = var_update(opts, data_ptr, cseg, varargin)

data = data_ptr.data;

x    = cseg.src_chart.x;
xbp0 = x(data.x_idx);
xbp0 = reshape(xbp0, data.var2x0reshape);
B    = data.B1 + xbp0' * data.B2;
V2   = [data.var2upper ; B];
data.var2 = kron(eye(data.dim),V2);

data_ptr.data = data;

end
%!end_var_update