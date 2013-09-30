function flag = coco_exist(name, type, varargin)

switch type
  
  case 'opts_path'
    % varargin = { prob [inherit-mode] }
    opts = varargin{1}.opts;
    if nargin<4
      flag = opts.path_exist(name, '-inherit');
    else
      flag = opts.path_exist(name, varargin{2});
    end

  case 'class_prop'
    % varargin = { prob path [inherit-mode] }
    opts = varargin{1}.opts;
    path = varargin{2};
    if nargin<5
      flag = opts.prop_exist(path, name, '-inherit');
    else
      flag = opts.prop_exist(path, name, varargin{3});
    end

  case 'run'
    % varargin = { }
    [fname flag] = coco_fname(name, 'bd.mat'); %#ok<ASGLU>
    
  case 'slot'
    % varargin = { prob }
    prob = varargin{1};
    flag = ( isfield(prob, 'slots') && isfield(prob.slots, lower(name)) );
    
  case 'signal'
    % varargin = { prob }
    prob = varargin{1};
    flag = ( isfield(prob, 'signals') && isfield(prob.signals, lower(name)) );
    
  case 'func'
    % varargin = { opts }
    prob = varargin{1};
    flag = ( isfield(prob, 'efunc') && ...
      isfield(prob.efunc, 'identifyers') && ...
      any(strcmpi(name, prob.efunc.identifyers)) );
    
  otherwise
    if ischar(type)
      error('%s: unknown object type ''%s''', mfilename, type);
    else
      error('%s: unknown object type', mfilename);
    end
end

end
