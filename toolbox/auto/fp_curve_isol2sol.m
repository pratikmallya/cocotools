function [opts argnum] = fp_curve_isol2sol(opts, prefix, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at initial point (x0,p0).

% parse command line
% varargin = {f [fx [fp]] x0 p0 k ...}
argidx = 1;
f = varargin{argidx};
argidx = argidx+1;
if isa(varargin{argidx}, 'function_handle')
  fx = varargin{argidx};
  argidx = argidx+1;
  if isa(varargin{argidx}, 'function_handle')
    fp = varargin{argidx};
    argidx = argidx+1;
  else
    fp = [];
  end
else
  fx = [];
  fp = [];
end

x0 = varargin{argidx};
p0 = varargin{argidx+1};
k  = varargin{argidx+2};

% compute number of processed arguments
argnum = argidx+3;

% call toolbox constructor
opts = fp_curve_create(opts, f, fx, fp, x0, p0, k, [], []);

end
