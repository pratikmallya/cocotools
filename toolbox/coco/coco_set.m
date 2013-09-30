function prob = coco_set(varargin)
%COCO_SET([prob], [path, [p, val]... ]]) set property P of PATH to VAL.

s = coco_stream(varargin{:});
if isempty(s)
  prob = prob_new([]);
  return;
end

if isstruct(s.peek)
  prob = s.get;
  if ~isfield(prob, 'opts')
    prob = prob_new(prob);
  end
elseif ischar(s.peek)
  prob = prob_new([]);
elseif isempty(s.peek)
  prob = prob_new(s.get);
end

if isempty(s)
  return;
end

assert(ischar(s.peek), '%s: path must be a string', mfilename);
path = s.get;
if strcmpi(path, 'all')
  path = '';
end
all = isempty(path);

while ~isempty(s);
  prop = s.get;
  val  = s.get;
  if all
    check_all_prop(prop, val);
  end
  prob.opts = prob.opts.prop_set(path, prop, val);
end

end

function prob = prob_new(prob)
if isempty(prob)
  prob = struct();
end
if ~isfield(prob, 'opts')
  prob.opts = coco_opts_tree();
  prob.opts = prob.opts.prop_set('', '', global_opts());
  if any(exist('coco_global_opts', 'file') == [2 3 6])
    prob = coco_global_opts(prob);
  end
  fname = fullfile(pwd, 'coco_project_opts');
  if any(exist(fname, 'file') == [2 3 6])
    prob = coco_project_opts(prob);
  end
end
end

function opts = global_opts()
opts.TOL       = 1.0e-6; % overall tolerance for algorithms
opts.CleanData = false ; % clean destination directory prior to computation
opts.LogLevel  = 1     ; % general log level
opts.data_dir  = fullfile(pwd, 'data'); % default location for saving data
end

function check_all_prop(prop, val)
if ~ischar(prop)
  error ('%s: attempt to set illegal property at ''all''', mfilename);
end

switch lower(prop)
  
  case 'tol'
    assert(isnumeric(val) && numel(val)==1 && val>0, ...
      '%s: all.TOL must be a positive scalar', mfilename);
    
  case 'cleandata'
    assert(numel(val)==1 && (islogical(val) || isnumeric(val)), ...
      '%s: all.CleanData must be true, false, or a scalar', mfilename);
    
  case 'loglevel'
    assert(isnumeric(val) && numel(val)==1 && mod(val,1)==0 && val>=0, ...
      '%s: all.LogLevel must be an integer >= 0', mfilename);
    
  case 'data_dir'
    assert(ischar(val), ...
      '%s: all.data_dir must be a directory name', mfilename);
    
  otherwise
    error('%s: property ''%s'' cannot be set at ''all''', ...
      mfilename, prop);
end

end
