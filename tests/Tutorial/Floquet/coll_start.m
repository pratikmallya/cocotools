function [opts argnum] = coll_start(opts, varargin)

argidx = 1;
prefix = varargin{argidx};
argidx = argidx + 1;

fhan = varargin{argidx};
if ~isa(fhan, 'function_handle')
    error('%s: argument %d must be a function handle', ...
        mfilename, argidx);
end

dfdxhan  = [];
dfdphan  = [];
dfdxname = sprintf('%s_DFDX', func2str(fhan));
if any(exist(dfdxname, 'file') == [2 3])
    dfdxhan = str2func(dfdxname);
end
dfdpname = sprintf('%s_DFDP', func2str(fhan));
if any(exist(dfdpname, 'file') == [2 3])
    dfdphan = str2func(dfdpname);
end

while ischar(varargin{argidx+1})
    switch lower(varargin{argidx+1})
        case 'dfdx'
            dfdxhan = varargin{argidx+2};
        case 'dfdp'
            dfdphan = varargin{argidx+2};
        otherwise
            error('%s: unknown option ''%s''', mfilename, varargin{argidx+1});
    end
    argidx = argidx + 2;
end

if isa(varargin{argidx + 1}, 'function_handle')
    data.stpnt = varargin{argidx + 1};
elseif isstruct(varargin{argidx + 1})
    data       = varargin{argidx + 1};
else
    error('%s: unknown option ''%s''', mfilename, varargin{argidx});
end

p0 = varargin{argidx + 2};

data          = coco_set(coll_settings(opts, prefix),data);
[data x0 dx0] = coll_system(data, p0);
data.fhan     = fhan;
data.dfdxhan  = dfdxhan;
data.dfdphan  = dfdphan;
data.prefix   = prefix;

opts = coll_create(opts, data, x0, p0, dx0);

argnum = argidx + 2;

end

function data = coll_settings(opts, prefix)

fid  = coco_get_id(prefix, 'coll');
if ~isempty(opts) && isfield(opts,fid)
    data = coco_get(opts, fid);
    
    defaults.NTST   = 10;
    defaults.NCOL   = 4;
    
    data = coco_set(defaults,data);
else
    data.NTST = 10;
    data.NCOL = 4;
end

end