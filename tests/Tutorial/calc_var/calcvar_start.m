function [opts argnum] = calcvar_start(opts, varargin)

argidx = 1;
prefix = varargin{argidx};
argidx = argidx + 1;

fhan = varargin{argidx};
if ~isa(fhan, 'function_handle')
    error('%s: argument %d must be a function handle', ...
        mfilename, argidx);
end

if isa(varargin{argidx+1}, 'function_handle')
    data.stpnt = varargin{argidx+1};
elseif isstruct(varargin{argidx+1})
    data       = varargin{argidx+1};
else
    error('%s: unknown option ''%s''', mfilename, varargin{argidx});
end

p0 = varargin{argidx + 2};

defaults.NTST = 10;
defaults.NCOL = 4;
fid = coco_get_id(prefix, 'calcvar');
copts = coco_get(opts, fid);
copts = coco_merge(defaults, copts);

if ~isfield(data, 'NTST')
    data.NTST    = copts.NTST;
end
if ~isfield(data, 'NCOL')
    data.NCOL    = copts.NCOL;
end
[data x0]    = calcvar_system(data, p0);
data.fhan    = fhan;
data.prefix  = prefix;

opts = calcvar_create(opts, data, x0, p0);

argnum = argidx + 2;

end