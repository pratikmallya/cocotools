function opts = fp_curve_create_NS(opts, data, v0, w0, om0real, om0imag)

% get toolbox options
defaults.NSSys = 'complex' ; % use full eigenvalue system
copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% initialise frequently used arrays
data.zeros = zeros(1, data.p_idx(end));
data.NSSys = copts.NSSys;

% add Hopf condition
switch data.NSSys
  case 'complex'
    data.v_idx = data.p_idx(end)+data.x_idx;
    data.w_idx = data.v_idx(end)+data.x_idx;
    data.oreal_idx = data.w_idx(end)+1;
    data.oimag_idx = data.w_idx(end)+2;
    data_ptr   = coco_ptr(data);
    opts = coco_add_func(opts, 'curve_NS', @curve_NS, @curve_NS_DFDU, ...
      data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], ...
      'x0', [v0;w0;om0real;om0imag]);
  case 'squared'
    data.v_idx = data.p_idx(end)+data.x_idx;
    data.oreal_idx = data.v_idx(end)+1;
    data.oimag_idx = data.v_idx(end)+2;
    data.w     = w0';
    data_ptr   = coco_ptr(data);
    opts = coco_add_func(opts, 'curve_NS', @curve_NS_sq, @curve_NS_DFDU_sq, ...
      data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], ...
      'x0', [v0;om0real;om0imag] );
end

% add more output to bifurcation diagram
opts = coco_add_slot(opts, 'curve_NS_bddat', @curve_bddat, ...
  data_ptr, 'bddat');

% add more output to screen
opts = coco_add_slot(opts, 'curve_NS_print', @curve_print, ...
  data_ptr, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_NS_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');

% add slot function to update signal
opts = coco_add_slot(opts, 'curve_NS_update', @curve_update, ...
  data_ptr, 'FSM_update');

end

function [data_ptr y] = curve_NS(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J       = fp_jacobian(data, u);
v       = u(data.v_idx);
w       = u(data.w_idx);
om0real = u(data.oreal_idx);
om0imag = u(data.oimag_idx);
y       = [
  J*v-om0real*v+om0imag*w
  J*w-om0imag*v-om0real*w
  v'*v+w'*w-1
  om0real*om0real+om0imag*om0imag-1
  w'*v
  ];
end

function [data_ptr J] = curve_NS_DFDU(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = fp_jacobian(data, u);
v    = u(data.v_idx);
w    = u(data.w_idx);
om0real   = u(data.oreal_idx);
om0imag   = u(data.oimag_idx);
OMreal   = u(data.oreal_idx)*data.ID;
OMimag   = u(data.oimag_idx)*data.ID;

data2 = data;
data2.fx =@(x,p) fp_jacobian(data, [x;p]);
data2.fp =@(x,p) fp_par_deriv(data, [x;p]);
FXXv = dfvdxx(data2, u, v);
FXPv = dfvdxp(data2, u, v);
FXXw = dfvdxx(data2, u, w);
FXPw = dfvdxp(data2, u, w);
J    = [
  FXXv   FXPv      J-OMreal     OMimag    -v   w
  FXXw   FXPw    -OMimag      J-OMreal  -w   -v
  data.zeros    2*v'   2*w'   0   0
  data.zeros    zeros(1,numel(u(data.x_idx)))   zeros(1,numel(u(data.x_idx)))   2*om0real   2*om0imag
  data.zeros      w'    v'    0    0
  
  ];
 %[data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @curve_NS, u);
end

function [data_ptr y] = curve_NS_sq(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = fp_jacobian(data, u);
v    = u(data.v_idx);
om0real   = u(data.oreal_idx);
om0imag   = u(data.oimag_idx);
y    = [ J*J*v-2*om0real*J*v+om0real*om0real*v+om0imag*om0imag*v ; v'*v-1 ; data.w*v;  om0real*om0real+om0imag*om0imag-1];
end

function [data_ptr J] = curve_NS_DFDU_sq(opts, data_ptr, u) %#ok<INUSL>
data  = data_ptr.data;
J     = fp_jacobian(data, u);
v     = u(data.v_idx);
om0real   = u(data.oreal_idx);
om0imag   = u(data.oimag_idx);
OMreal   = u(data.oreal_idx)*data.ID;
OMimag   = u(data.oimag_idx)*data.ID;

data2 = data;
data2.fx =@(x,p) fp_jacobian(data, [x;p]);
data2.fp =@(x,p) fp_par_deriv(data, [x;p]);

Jv    = J*v;
FXXv  = dfvdxx(data2, u, v);
FXXJv = dfvdxx(data2, u, Jv);
FXPv  = dfvdxp(data2, u, v);
FXPJv = dfvdxp(data2, u, Jv);
J     = [
  FXXJv+J*FXXv-2*om0real*FXXv   FXPJv+J*FXPv-2*om0real*FXPv    J*J-2*om0real*J+OMreal*OMreal+OMimag*OMimag     -2*J*v+2*OMreal*v  +2*OMimag*v
  data.zeros                       2*v'    0 0
  data.zeros                     data.w    0 0
  data.zeros   zeros(1,numel(u(data.x_idx)))  2*om0real 2*om0imag
  ];
% [data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @curve_NS_sq, u);
end

function data_ptr = curve_update(opts, data_ptr, cmd, u, t, varargin) %#ok<INUSD,INUSL>
data = data_ptr.data;
switch cmd
  case 'update'
    % update borders if necessary
    switch data.NSSys
      case 'squared'
        J       = fp_jacobian(data, u);
        v       = u(data.v_idx);
        om0real = u(data.oreal_idx);
        om0imag = u(data.oimag_idx);
        w       = (-J*v+om0real*v)/om0imag;
        data.w  = w';
    end
end
data_ptr.data = data;
end

function [data_ptr res] = curve_bddat(opts, data_ptr, cmd, sol) %#ok<INUSD,INUSL>
switch cmd
  case 'init'
    res = {  };
  case 'data'
    data = data_ptr.data; %#ok<NASGU>
    res = {  };
end
end

function data_ptr = curve_print(opts, data_ptr, cmd, u) %#ok<INUSD,INUSL>
switch cmd
  case 'init'
    % fprintf('%10s', '||x||');
  case 'data'
    data = data_ptr.data; %#ok<NASGU>
    % fprintf('%10.2e', norm(u(data.x_idx)));
end
end
