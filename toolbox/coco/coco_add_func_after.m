function opts = coco_add_func_after(varargin)
%COCO_ADD_FUNC   Add function to system of equations.
%
%   [OPTS XIDX MIDX FIDX] = COCO_ADD_FUNC([OPTS], DEPLIST, @CTOR, ... )
%

%% parse input arguments
%  varargin = { [OPTS], DEPLIST, @CTOR, ... }

argidx = 1;

if isempty(varargin{argidx}) || isstruct(varargin{argidx})
	opts   = varargin{argidx};
	argidx = argidx + 1;
else
	opts = [];
end

if ~isfield(opts, 'efunc')
  opts.efunc = efunc_new([]);
end
if ~isfield(opts.efunc, 'identifyers')
  opts.efunc = efunc_new(opts.efunc);
end

if iscell(varargin{argidx})
  deplist = varargin{argidx};
elseif ischar(varargin{argidx})
  deplist = { varargin{argidx} };
else
  deplist = varargin{argidx};
end
argidx = argidx + 1;

ctor = varargin{argidx};
if ~isa(ctor, 'function_handle')
  error('%s: argument %d must be a function handle', mfilename, argidx);
end
argidx = argidx + 1;

args = { varargin{argidx:end} };

% add function to pending list
opts.efunc.pending = [opts.efunc.pending ; { deplist ctor args } ];

% try to add pending functions
if opts.efunc.add_pending
  opts = coco_add_pending(opts);
end

end
