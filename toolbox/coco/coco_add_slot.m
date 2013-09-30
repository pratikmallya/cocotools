function opts = coco_add_slot(varargin)
%coco_add_slot   Add function to a callback list.
%
%   OPTS = coco_add_slot([OPTS], FID, @FUNC, DATA, SIGNAL, [@COPY])
%

%% parse input arguments
%  varargin = { [OPTS], FID, @FUNC, DATA, SIGNAL, [@COPY] }

argidx = 1;

if isempty(varargin{argidx}) || isstruct(varargin{argidx})
	opts   = varargin{argidx};
	argidx = argidx + 1;
else
	opts = [];
end

fid     = varargin{argidx  };
coco_opts_tree.check_path(fid);
fhan    = varargin{argidx+1};
data    = varargin{argidx+2};
list    = varargin{argidx+3};
signame = lower(list);
if strcmp('funcs', signame)
  error('%s: illegal slot name ''%s''', mfilename, list);
end
if nargin>argidx+3
  copy = varargin{argidx+4};
else
  copy = [];
end

%% create slot structure or check for duplicate identifyer
if ~isfield(opts, 'slots')
  opts.slots.funcs = struct([]);
  if ~isfield(opts, 'signals')
    opts.signals = struct();
  end
end

if isfield(opts.slots, signame)
  fidx = opts.slots.(signame);
  fids = { opts.slots.funcs(fidx).identifyer };
  if any( strcmp(fid, fids) )
    error('%s: slot identifyer ''%s'' already in use at signal ''%s''', ...
      mfilename, fid, list);
  end
else
  opts.slots.(signame) = [];
end

%% add function to list

func.identifyer      = fid;
func.F               = fhan;
func.data            = data;
func.copy            = copy;
opts.slots.funcs     = [ opts.slots.funcs func ];
idx                  = numel(opts.slots.funcs);
opts.slots.(signame) = [ opts.slots.(signame) idx ];
