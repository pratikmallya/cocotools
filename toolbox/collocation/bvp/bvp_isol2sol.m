function [opts argnum] = bvp_isol2sol(opts, varargin)
%MPBVP_ISOL2SOL  Construct boundary value problem and start continuation.
%
%   BD = MPBVP_ISOL2SOL(OPTS, ...) is called by COCO if invoked as
%
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, [@]STPNT, P0, ... )
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, T0, X0, P0,   ... )
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, SEGLIST, P0,  ... )
%
%   MPBVP_ISOL2SOL constructs a collocation system and an initial solution
%   for a multi-point boundary value problem (MPBVP).
%
%   Note: This function is mainly provided for convenience of toolbox
%   developers. It allows to check that a specific BVP is set-up correctly.
%

%% process input arguments
%  varargin = { prefix, func, [options,] [@]stpnt, p0, ... }
%           | { prefix, func, [options,] t0, x0,   p0, ... }
%           | { prefix, func, [options,] seglist,  p0, ... }
%
% options = {'dfdx' dfdxhan} | {'dfdp' dfdphan}
%         | {'bc' bchan} | {'bc_dfdx' bc_dfdxhan} | {'bc_dfdp' bc_dfdphan}

argidx = 1;
prefix = varargin{argidx};

if ~isa(varargin{argidx+1}, 'function_handle')
  error('%s: argument %d must be a function handle', mfilename, argidx+1);
end

collargs = { varargin{argidx+1} };
odefname = func2str(varargin{argidx+1});

bcnd.fhan       = [];
bcnd.vectorised = 1;
bcnd.dfdxhan    = [];
bcnd.dfdphan    = [];
bcnd.update     = [];

% look for default function names
fname = sprintf('%s_bc_F', odefname);
if any(exist(fname, 'file') == [2 3])
  bcnd.fhan = str2func(fname);
end
fname = sprintf('%s_bc_DFDX', odefname);
if any(exist(fname, 'file') == [2 3])
  bcnd.dfdxhan = str2func(fname);
end
fname = sprintf('%s_bc_update', odefname);
if any(exist(fname, 'file') == [2 3])
  bcnd.update = str2func(fname);
end

% process options
bvp_argnum = 0; % func and prefix will be counted by collocation constructor
while ischar(varargin{argidx+2})
  switch lower(varargin{argidx+2})
    
    case 'dfdx'
      collargs = [collargs 'dfdx' varargin{argidx+3}]; %#ok<AGROW>
    case 'dfdp'
      collargs = [collargs 'dfdp' varargin{argidx+3}]; %#ok<AGROW>
      
    case 'bc'
      bcnd.fhan    = varargin{argidx+3};
      bvp_argnum   = bvp_argnum + 2;
    case 'bc_dfdx'
      bcnd.dfdxhan = varargin{argidx+3};
      bvp_argnum   = bvp_argnum + 2;
    case 'bc_update'
      bcnd.update  = varargin{argidx+3};
      bvp_argnum   = bvp_argnum + 2;
      
    otherwise
      error('%s: unknown option ''%s''', mfilename, varargin{argidx+2});
  end
  argidx = argidx + 2;
end

%% construct collocation system
[opts coll_argnum] = coll_isol2sol(opts, prefix, collargs{:}, varargin{argidx+2:end});
argnum = bvp_argnum + coll_argnum;

%% construct two-point boundary value problem
opts = bvp_add_BC(opts, prefix, bcnd);
