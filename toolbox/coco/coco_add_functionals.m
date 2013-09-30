function [opts data] = coco_add_functionals(opts, fid, A, b, x_idx, varargin)
%COCO_ADD_FUNCTIONALS   Add linear functionals A*x=b to continuation problem.

%% parse input arguments
%  varargin = { type pnames }

if nargin>5
  type      = varargin{1};
  par_names = varargin{2};
else
  type      = 'zero';
  par_names = [];
end

if ischar(par_names)
  par_names = { par_names };
elseif isnumeric(par_names)
  par_names = coco_get_def_par_names('PAR', par_names);
end

% bug: correction of semantics (2) required:
% 1) A matrix, x vector -> A*x=b
% 2) A matrix, x matrix -> A(i,:)*x(:,i)=b(i), i=1,...,n
[m n]       = size(A);
data.A      = A;
data.b      = b;
data.xshape = [m n];
data.xidx   = reshape(1:numel(x_idx), m, n);
data.fidx   = repmat( (1:m)', 1, n);

if nargout>1
  data = coco_func_data(data);
end

switch type
  case 'zero'
    opts = coco_add_func(opts, fid, ...
      @func_LFUNC, @func_DLFUNCDX, data, ...
      'zero', 'xidx', x_idx);
  otherwise
    opts = coco_add_func(opts, fid, ...
      @func_LFUNC, @func_DLFUNCDX, data, ...
      type, par_names, 'xidx', x_idx);
end
