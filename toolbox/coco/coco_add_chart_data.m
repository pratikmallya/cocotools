function opts = coco_add_chart_data(opts, fid, varargin)
% COCO_ADD_CHART_DATA(prob, fid, varargin)
%
% varargin = init [[@cp_func] data]

% varargin = {} | { init|@han } | { init @han|idata }
% bug: change to

cp_han = @default_cp_func;
data   = [];

s     = coco_stream(varargin{:});
init1 = s.get;

if ~isempty(s)
  if isa(s.peek, 'function_handle')
    cp_han = s.get;
    data   = s.get;
  else
    data   = s.get;
    cp_han = @reset_cp_func;
  end
end

if ~isfield(opts, 'efunc')
  opts.efunc = efunc_new([]);
end
if ~isfield(opts.efunc, 'identifyers')
  opts.efunc = efunc_new(opts.efunc);
end

cfunc = struct('identifier', fid, 'F', cp_han, 'data', data);
if ~isfield(opts, 'cfunc')
  opts.cfunc.identifiers = { fid };
  opts.cfunc.funcs       =  cfunc ;
else
  if any(strcmpi(fid, { opts.cfunc(:).identifiers } ))
    error('%s: copy function with name ''%s'' already defined', ...
      mfilename, fid);
  end
  opts.cfunc.identifiers = [ opts.cfunc.identifiers { fid } ];
  opts.cfunc.funcs       = [ opts.cfunc.funcs        cfunc  ];
end

chart              = opts.efunc.chart;
chart.private.data = [ chart.private.data ; { fid init1 } ];
opts.efunc.chart   = chart;

end

% these functions must be constructed in this way to avoid having opts in
% the stack frame when constructing the function handles, which would lead
% to opts being saved whenever the returned function handle is saved
function [data cdata] = default_cp_func(opts, data, chart, cdata) %#ok<INUSL>
end

function [data cdata] = reset_cp_func(opts, data, chart, cdata) %#ok<INUSD,INUSL>
cdata = data; % reset chart data to init2
end
