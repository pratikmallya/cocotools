function [opts argnum] = ep_curve_isol2sol(opts, prefix, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at initial point (x0,p0).

% parse command line
% varargin = {f [fx [fp]] x0 p0 ...}
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

% compute number of processed arguments
argnum = argidx+2;

% call toolbox constructor
opts = ep_curve_create(opts, f, fx, fp, x0, p0, [], []);

end
