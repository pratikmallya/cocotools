function opts = var_create(opts, prefix, data, x0)

data_ptr = coco_ptr(data);

fid      = coco_get_id(prefix, 'var_fun');
opts     = coco_add_func([], fid, @var_F, @var_DFDX, ...
    data_ptr, 'zero', 'x0', [x0 ; 0]);

fid      = coco_get_id(prefix, 'var_save');
opts     = coco_add_slot(opts, fid, @coco_save_data, ...
    data_ptr, 'save_full');

fid      = coco_get_id(prefix, 'var_update');
opts     = coco_add_slot(opts, fid, @var_update, ...
    data_ptr, 'covering_update');

opts     = coco_add_parameters(opts, '', data.varb_idx, 'beta');
end

function [data_ptr y] = var_F(opts, data_ptr, xp)

data = data_ptr.data;

u = xp(data.varu_idx);
b = xp(data.varb_idx);

y = (b * data.var1 + data.var2) * u + data.var3;

end

function [data_ptr J] = var_DFDX(opts, data_ptr, xp)

data = data_ptr.data;

u = xp(data.varu_idx);
b = xp(data.varb_idx);

J = sparse([b * data.var1 + data.var2 data.var1 * u]);

end

function data_ptr = var_update(opts, data_ptr, cmd, varargin)

data = data_ptr.data;

switch cmd
    case 'update'
        xp   = varargin{1};
        xbp0 = xp(data.varu_idx);
        xbp0 = reshape(xbp0, data.var2x0reshape);
        B    = data.B1 + xbp0' * data.B2;
        V2   = [data.var2upper ; B];
        data.var2 = kron(eye(data.dim),V2);
    otherwise
end

data_ptr.data = data;

end