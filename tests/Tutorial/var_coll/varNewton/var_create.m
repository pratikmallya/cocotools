function varopts = var_create(opts, data, vx0)

tbid     = data.tbid;
data_ptr = coco_ptr(data);

varopts  = coco_add_func([], tbid, @var_F, @var_DFDX, data_ptr, 'zero', ...
    'x0', [vx0 ; 1]);
varopts  = coco_add_slot(varopts, tbid, @coco_save_data, data_ptr, 'save_full');

fid     = coco_get_id(tbid, 'pars');
varopts = coco_add_pars(varopts, fid, data.p_idx, 'beta');
fid     = coco_get_id(tbid, 'update');
varopts  = coco_add_slot(varopts, fid, @var_update, data_ptr, 'corr_step');

end

function [data_ptr y] = var_F(opts, data_ptr, u)

data = data_ptr.data;

x = u(data.x_idx);
p = u(data.p_idx);

y = (p*data.var1+data.var2)*x+data.var3;

end

function [data_ptr J] = var_DFDX(opts, data_ptr, u)

data = data_ptr.data;

x = u(data.x_idx);
p = u(data.p_idx);

J = sparse([p*data.var1+data.var2, data.var1*x]);

end

function [data_ptr stop msg] = var_update(opts, data_ptr, varargin)

data = data_ptr.data;

x    = varargin{3};
xbp0 = x(data.x_idx);
xbp0 = reshape(xbp0, data.var2x0reshape);
B    = data.B1 + xbp0' * data.B2;
V2   = [data.var2upper ; B];
data.var2 = kron(eye(data.dim),V2);

data_ptr.data = data;
stop = false;
msg = [];
end