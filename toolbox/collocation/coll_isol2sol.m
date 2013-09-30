function [opts argnum] = coll_isol2sol(opts, varargin)
%coll_ISOL2SOL  Construct boundary value problem and start continuation.
%
%   BD = coll_ISOL2SOL(OPTS, ...) is called by COCO if invoked as
%
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, [@]STPNT, P0, ... )
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, T0, X0, P0,   ... )
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'isol', 'sol', ...
%          BC, SEGLIST, P0,  ... )
%
%   coll_ISOL2SOL constructs a collocation system and an initial solution
%   for a multi-point boundary value problem (MPBVP).
%
%   Note: This function is mainly provided for convenience of toolbox
%   developers. It allows to check that a specific BVP is set-up correctly.
%

%% process input arguments
%  varargin = { prefix, func, [options,] [@]stpnt,            p0, ... }
%           | { prefix, func, [options,] t0, x0,   ['s0' s0,] p0, ... }
%           | { prefix, func, [options,] seglist,             p0, ... }
%
% options = {'dfdx' dfdxhan} | {'dfdp' dfdphan}

argidx = 1;
prefix = varargin{argidx};

if ~isa(varargin{argidx+1}, 'function_handle')
  error('%s: argument %d must be a function handle', mfilename, argidx+1);
end

func.fhan       = varargin{argidx+1};
func.fname      = func2str(func.fhan);
func.vectorised = 1;
func.dfdxhan    = [];
func.dfdphan    = [];

% look for default function names
fname = sprintf('%s_DFDX', func.fname);
if any(exist(fname, 'file') == [2 3])
  func.dfdxhan = str2func(fname);
end
fname = sprintf('%s_DFDP', func.fname);
if any(exist(fname, 'file') == [2 3])
  func.dfdphan = str2func(fname);
end

% process options
while ischar(varargin{argidx+2})
  switch lower(varargin{argidx+2})
    
    case 'dfdx'
      func.dfdxhan = varargin{argidx+3};
    case 'dfdp'
      func.dfdphan = varargin{argidx+3};
      
    otherwise
      error('%s: unknown option ''%s''', mfilename, varargin{argidx+2});
  end
  argidx = argidx + 2;
end

%% get collocation settings
coll = coll_get_settings(opts, prefix);

%% construct initial solution { seglist p0 }
[opts coll argnum seglist] = ...
  coll_createInitialSegList(opts, coll, varargin{argidx+2:end});
argidx = argidx + argnum + 2;
p0     = varargin{argidx};
argnum = argidx;

%% construct collocation equations
opts = coll_create(opts, prefix, coll, func, seglist, p0);
