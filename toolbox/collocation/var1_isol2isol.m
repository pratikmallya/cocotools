function [opts argnum x0] = var1_isol2isol(opts, prefix, varargin)
%VAR1_ISOL2SOL  Construct variational problem for initial homotopy.
%
%   BD = VAR1_ISOL2SOL(OPTS, ...) is called by COCO if invoked as
%
%   BD = COCO(opts, RUN, 'var1', 'isol', 'sol', ... )
%
%   VAR1_ISOL2SOL constructs a collocation system and an initial solution
%   for a multi-point boundary value problem (MPBVP).
%

%% process input arguments
%  varargin = { coll, x0, p0, ... }
coll   = varargin{1};
x0     = varargin{2};
p0     = varargin{3};
beta0  = varargin{4};
argnum = 5;

%% create variational problem and initial solution
[opts coll M0]  = var1_createCollocationSystem(opts, coll, x0, p0);

coll.var1.p_idx = numel(M0)+1;
fid             = coco_get_id(prefix, 'coll');
opts            = coco_add_func(opts, fid, @var1_F, @var1_DFDX, coll, ...
  'zero', 'x0', [M0 ; beta0]);
xidx = coco_get_func_data(opts, fid, 'xidx');

%% add parameters
opts = coco_add_parameters(opts, '', xidx(coll.var1.p_idx(end)), 'beta');

%% add call back functions
cbdata.xidx = xidx;
cbdata.coll = coll;

fid  = coco_get_id(prefix, 'coll');
opts = coco_add_slot(opts, fid, @var1_save_full,  cbdata, 'save_full');
