function opts = ep_curve_create_LP(opts, data, t0)

% initialise extended system
data.zeros = zeros(1, data.p_idx(end));
data.v_idx = data.p_idx(end)+data.x_idx;
v0 = t0(data.x_idx);

data_ptr = coco_ptr(data);

% add fold condition
opts = coco_add_func(opts, 'curve_LP', @curve_LP, @curve_LP_DFDU, ...
  data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', v0 );

% add more output to bifurcation diagram
opts = coco_add_slot(opts, 'curve_LP_bddat', @curve_bddat, ...
  data_ptr, 'bddat');

% add more output to screen
opts = coco_add_slot(opts, 'curve_LP_print', @curve_print, ...
  data_ptr, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_LP_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');

% add slot function to update signal
opts = coco_add_slot(opts, 'curve_LP_update', @curve_update, ...
  data_ptr, 'FSM_update');

end

function [data_ptr y] = curve_LP(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
v    = u(data.v_idx);
y    = [ J*v ; v'*v-1 ];
end

function [data_ptr J] = curve_LP_DFDU(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
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

function data_ptr = curve_update(opts, data_ptr, cmd, u, t, varargin)
data = data_ptr.data;
switch cmd
  case 'update'
    % update borders if necessary
end
data_ptr.data = data;
end

function [data_ptr res] = curve_bddat(opts, data_ptr, cmd, sol) %#ok<INUSL>
switch cmd
  case 'init'
    res = {  };
  case 'data'
    data = data_ptr.data;
    res = {  };
end
end

function data_ptr = curve_print(opts, data_ptr, cmd, u) %#ok<INUSL>
switch cmd
  case 'init'
    % fprintf('%10s', '||x||');
  case 'data'
    data = data_ptr.data;
    % fprintf('%10.2e', norm(u(data.x_idx)));
end
end
