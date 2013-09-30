function opts = curve_create_LP(opts, prefix, data, v0)

% initialise extended system
data.zeros = zeros(1, data.p_idx(end));
data.v_idx = data.p_idx(end)+data.x_idx;

% add fold condition
fid  = coco_get_id(prefix, 'curve_LP');
opts = coco_add_func(opts, fid, @curve_LP, @curve_LP_DFDU, ...
  data, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', v0 );

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_LP_save', @coco_save_data, ...
  data, 'save_full');

end

function [data y] = curve_LP(opts, data, u) %#ok<INUSL>
J    = jacobian(data, u);
v    = u(data.v_idx);
y    = [ J*v ; v'*v-1 ];
end

function [data J] = curve_LP_DFDU(opts, data, u) %#ok<INUSL>
v    = u(data.v_idx);
J    = jacobian(data, u);
FXXv = dfvdxx(data, u, v);
FXPv = dfvdxp(data, u, v);
J    = [ FXXv FXPv J ; data.zeros 2*v' ];
end

function J = jacobian(data, u)
if isempty(data.fx)
  J = fdm_ezDFDX('f(x,p)', data.f, u(data.x_idx), u(data.p_idx));
else
  J = data.fx(u(data.x_idx), u(data.p_idx));
end
end

