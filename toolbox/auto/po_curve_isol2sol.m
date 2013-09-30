function [opts argnum] = po_curve_isol2sol(opts, prefix, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at initial point (x0,p0,T0).

% parse command line
% varargin = {f [fx [fp]] x0 p0 auto ...}

f  = varargin{1};
fx = varargin{2};
fp = varargin{3};

g  = varargin{4};
gx = varargin{5};
gp = varargin{6};

h  = varargin{7};
hx = varargin{8};
hp = varargin{9};

x0 = varargin{10};
p0 = varargin{11};
T0 = varargin{12};

% compute number of processed arguments
argnum = 13; 

% call toolbox constructor
opts = po_curve_create(opts, f, fx, fp, g, gx, gp, h, hx, hp, ...
  x0, p0, T0, [], [], []);

end
