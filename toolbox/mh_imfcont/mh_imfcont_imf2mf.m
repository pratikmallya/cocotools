function [opts argnum] = mh_imfcont_imf2mf(opts, prefix, fhan, varargin)

%% process input arguments
%  varargin = { [options,] [collargs,] ... }
%  options  = {'dfdx' dfdxhan} | {'dfdp' dfdphan}
%  collargs = additional arguments to collocation toolbox

func.fhan       = fhan;
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
imf_argnum = 1; % prefix will be counted by collocation constructor
argidx = 1;
while ischar(varargin{argidx})
  switch lower(varargin{argidx})
    
    case 'dfdx'
      func.dfdxhan = varargin{argidx+1};
      imf_argnum   = imf_argnum + 2;
    case 'dfdp'
      func.dfdphan = varargin{argidx+1};
      imf_argnum   = imf_argnum + 2;
      
    otherwise
      error('%s: unknown option ''%s''', mfilename, varargin{argidx});
  end
  argidx = argidx + 2;
end

%% construct extended ODE
collargs = imf_create_xode(func);

%% get options
mh_imf = imf_get_settings(opts, prefix);

%% construct collocation system
coll_func          = sprintf('%s_isol2sol', mh_imf.collocation);
coll_func          = str2func(coll_func);
[opts coll_argnum] = coll_func(opts, prefix, collargs{:}, varargin{argidx:end});
argnum             = imf_argnum + coll_argnum - numel(collargs);

%% create BVP
opts = imf_create(opts, prefix, func);
