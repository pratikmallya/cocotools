function opts = fp_curve_create_PD(opts, data, v0)

% initialise extended system
data.zeros = zeros(1, data.p_idx(end));
data.v_idx = data.p_idx(end)+data.x_idx;

data_ptr = coco_ptr(data);

% add fold condition
opts = coco_add_func(opts, 'curve_PD', @curve_PD, @curve_PD_DFDU, ...
  data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', v0 );

% add more output to bifurcation diagram
opts = coco_add_slot(opts, 'curve_PD_bddat', @curve_bddat, ...
  data_ptr, 'bddat');

% add more output to screen
opts = coco_add_slot(opts, 'curve_PD_print', @curve_print, ...
  data_ptr, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_PD_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');

% add slot function to update signal
opts = coco_add_slot(opts, 'curve_PD_update', @curve_update, ...
  data_ptr, 'FSM_update');

end

function [data_ptr y] = curve_PD(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = fp_jacobian(data, u);
v    = u(data.v_idx);
y    = [ (J+data.ID)*v ; v'*v-1 ];
end

function [data_ptr J] = curve_PD_DFDU(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
v        = u(data.v_idx);
data2    = data;
data2.fx = @(x,p) fp_jacobian(data, [x;p]);
data2.fp = @(x,p) fp_par_deriv(data, [x;p]);

J2   = fp_jacobian(data, u);
FXXv = dfvdxx(data2, u, v);
FXPv = dfvdxp(data2,u, v);

J    = [ FXXv FXPv J2+data.ID ; data.zeros 2*v' ];

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
