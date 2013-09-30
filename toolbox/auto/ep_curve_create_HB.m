function opts = ep_curve_create_HB(opts, data, v0, w0, om0, v1, w1)

% get toolbox options
defaults.HBSys    = 'complex' ; % use full Hopf system
copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% initialise frequently used arrays
data.zeros = zeros(1, data.p_idx(end));
data.ID    = eye(data.x_idx(end));
data.HBSys = copts.HBSys;

% add Hopf condition
switch data.HBSys
  case 'complex'
    data.v_idx = data.p_idx(end)+data.x_idx;
    data.w_idx = data.v_idx(end)+data.x_idx;
    data.o_idx = data.w_idx(end)+1;
    data_ptr   = coco_ptr(data);
    opts = coco_add_func(opts, 'curve_HB', @curve_HB, @curve_HB_DFDU, ...
      data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', [v0;w0;om0] );
  case 'squared'
    data.v_idx = data.p_idx(end)+data.x_idx;
    data.o_idx = data.v_idx(end)+1;
    data.w     = w0';
    data_ptr   = coco_ptr(data);
    opts = coco_add_func(opts, 'curve_HB', @curve_HB_sq, @curve_HB_DFDU_sq, ...
      data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', [v0;om0^2] );
  case 'extended'
    data.o_idx = data.p_idx(end)+1;
    data.b1    = v1;
    data.b2    = w1;
    data.c1    = v0';
    data.c2    = w0';
    data.rhs   = [ zeros(size(v0)) ; 1 ; 0 ];
    data.rhs2  = [ zeros(size(v0,1),2) ; 1 0 ; 0 1 ];
    data_ptr   = coco_ptr(data);
    opts = coco_add_func(opts, 'curve_HB', @curve_HB_ext, @curve_HB_DFDU_ext, ...
      data_ptr, 'zero', 'xidx', [data.x_idx data.p_idx], 'x0', om0^2 );
end

% add more output to bifurcation diagram
opts = coco_add_slot(opts, 'curve_HB_bddat', @curve_bddat, ...
  data_ptr, 'bddat');

% add more output to screen
opts = coco_add_slot(opts, 'curve_HB_print', @curve_print, ...
  data_ptr, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_HB_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');

% add slot function to update signal
opts = coco_add_slot(opts, 'curve_HB_update', @curve_update, ...
  data_ptr, 'FSM_update');

end

function [data_ptr y] = curve_HB(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
v    = u(data.v_idx);
w    = u(data.w_idx);
om   = u(data.o_idx);
y    = [ J*v+om*w ; J*w-om*v ; v'*v+w'*w-1 ; v'*w ];
end

function [data_ptr J] = curve_HB_DFDU(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
v    = u(data.v_idx);
w    = u(data.w_idx);
OM   = u(data.o_idx)*data.ID;
FXXv = dfvdxx(data, u, v);
FXPv = dfvdxp(data, u, v);
FXXw = dfvdxx(data, u, w);
FXPw = dfvdxp(data, u, w);
J    = [
  FXXv   FXPv      J     OM    w
  FXXw   FXPw    -OM      J   -v
  data.zeros    2*v'   2*w'    0
  data.zeros      w'     v'    0
  ];
% [data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @curve_HB, u);
end

function [data_ptr y] = curve_HB_sq(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
v    = u(data.v_idx);
k    = u(data.o_idx);
y    = [ J*J*v+k*v ; v'*v-1 ; data.w*v ];
end

function [data_ptr J] = curve_HB_DFDU_sq(opts, data_ptr, u) %#ok<INUSL>
data  = data_ptr.data;
J     = jacobian(data, u);
v     = u(data.v_idx);
K     = u(data.o_idx)*data.ID;
Jv    = J*v;
FXXv  = dfvdxx(data, u, v);
FXXJv = dfvdxx(data, u, Jv);
FXPv  = dfvdxp(data, u, v);
FXPJv = dfvdxp(data, u, Jv);
J     = [
  FXXJv+J*FXXv   FXPJv+J*FXPv    J*J+K     v
  data.zeros                       2*v'    0
  data.zeros                     data.w    0
  ];
% [data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @curve_HB_sq, u);
end

function [data_ptr y] = curve_HB_ext(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
K    = u(data.o_idx)*data.ID;
M    = [ J*J+K data.b1 data.b2 ; data.c1 0 0; data.c2 0 0 ];
v    = M\data.rhs;
y    = v(end-1:end);
end

function [data_ptr J] = curve_HB_DFDU_ext(opts, data_ptr, u) %#ok<INUSL>
data  = data_ptr.data;
J     = jacobian(data, u);
K     = u(data.o_idx)*data.ID;
M     = [ J*J+K data.b1 data.b2 ; data.c1 0 0; data.c2 0 0 ];
v     = M\data.rhs;
v     = v(data.x_idx);
w     = data.rhs2'/M;
w1    = w(1,data.x_idx);
w2    = w(2,data.x_idx);
Jv    = J*v;
FXXv  = dfvdxx(data, u, v);
FXXJv = dfvdxx(data, u, Jv);
FXPv  = dfvdxp(data, u, v);
FXPJv = dfvdxp(data, u, Jv);
J2Xv  = FXXJv+J*FXXv;
J2Pv  = FXPJv+J*FXPv;
J     = [
  -w1*J2Xv -w1*J2Pv -w1*v
  -w2*J2Xv -w2*J2Pv -w2*v
  ];
% [data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @curve_HB_ext, u);
end

function J = jacobian(data, u)
if isempty(data.fx)
  J = fdm_ezDFDX('f(x,p)', data.f, u(data.x_idx), u(data.p_idx));
else
  J = data.fx(u(data.x_idx), u(data.p_idx));
end
end

function data_ptr = curve_update(opts, data_ptr, cmd, u, t, varargin) %#ok<INUSD,INUSL>
data = data_ptr.data;
switch cmd
  case 'update'
    % update borders if necessary
    switch data.HBSys
      case 'squared'
        J = jacobian(data, u);
        v = u(data.v_idx);
        k = u(data.o_idx);
        w = (-1/sqrt(abs(k)))*(J*v);
        data.w = w';
      case 'extended'
        J    = jacobian(data, u);
        k    = u(data.o_idx);
        M    = [ J*J+k*data.ID data.b1 data.b2 ; data.c1 0 0; data.c2 0 0 ];
        w    = data.rhs2'/M;
        data.b1 = w(1,1:end-2)';
        data.b2 = w(2,1:end-2)';
        M    = [ J*J+k*data.ID data.b1 data.b2 ; data.c1 0 0; data.c2 0 0 ];
        v    = M\data.rhs2;
        data.c1 = v(1:end-2,1)';
        data.c2 = v(1:end-2,2)';
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
