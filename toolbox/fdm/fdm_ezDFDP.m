function [varargout] = fdm_ezDFDP(key, varargin)
%COCO_NUM_DFDX  Numerical differentiation wrt. state.
%
%   J        = FDM_EZDFDX(KEY, ...)
%   The routines COCO_NUM_DFDX,
%   COCO_NUM_DFDXV, COCO_NUM_DFDP, and COCO_NUM_DFDPV use mid-point
%   finite-difference scheme for numerically approximating the Jacobian of
%   the right-hand side with respect to the state vector at a number of
%   distinct points and with respect to the parameter vector at a number of
%   distinct points. Each function includes the possibility of
%   differentiation of an algorithm rather than a straightforward function.
%
%   NOTE: These functions are inefficient for functions F with sparse
%   Jacobian J, for example, algorithms. Use the vectorised versions
%   whenever possible for differentiating functions provided by the user.
%   In this case the variable opts.pdat.vectorised is set to 'true', which
%   is the default.
%
%   See also: gcont_num_DFDP, gcont_num_DFDPv, gcont_num_DFDXv
%

switch key
  case 'f(x,p)v'
    [varargout{1:nargout}] = coco_num_DFDPv__A(varargin{:});
  case 'f(x,p)'
    [varargout{1:nargout}] = coco_num_DFDP__A(varargin{:});
  case 'f(o,x,p)v'
    [varargout{1:nargout}] = coco_num_DFDPv__D(varargin{:});
  case 'f(o,x,p)'
    [varargout{1:nargout}] = coco_num_DFDP__D(varargin{:});
  case 'f(o,d,x,p)v'
    [varargout{1:nargout}] = coco_num_DFDPv__E(varargin{:});
  case 'f(o,d,x,p)'
    [varargout{1:nargout}] = coco_num_DFDP__E(varargin{:});
  otherwise
    error('%s: key ''%s'' unrecognised', mfilename, key);
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDPv__A(F, x, p, pars)

if nargin<4
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

idx1 = kron( ones(1,m) , 1:n );
x    = x(:,idx1);
p0   = p(:,idx1);

idx1 = kron(pars, ones(1,n));
idx2 = 1:n*m;
idx  = sub2ind([size(p0,1) n*m], idx1, idx2);

h    = 1.0e-8*( 1.0 + abs(p0(idx)) );

p    = p0;

p(idx) = p0(idx)+h;
fr     = F(x,p);
p(idx) = p0(idx)-h;
fl     = F(x,p);

l  = size(fr,1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDP__A(F, x, p, pars)

if nargin<4
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

fr = F(x(:,1),p(:,1));
l  = size(fr,1);

J  = zeros(l,n,m);

for j=1:n
	p0 = p(:,j);
	h  = 1.0e-8*( 1.0 + abs(p0(pars)) );
	hi = 0.5./h;
	for i=1:m
		p1        = p0;
		pidx      = pars(i);

		p1(pidx)  = p0(pidx)+h(i);
		fr        = F(x(:,j),p1);
		p1(pidx)  = p0(pidx)-h(i);
		fl        = F(x(:,j),p1);

		J(:,j,i) = hi(i).*(fr-fl);
	end
end
J = reshape(J, [l n*m]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDPv__D(opts, F, x, p, pars)

if nargin<5
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

idx1 = kron( ones(1,m) , 1:n );
x    = x(:,idx1);
p0   = p(:,idx1);

idx1 = kron(pars, ones(1,n));
idx2 = 1:n*m;
idx  = sub2ind([size(p0,1) n*m], idx1, idx2);

h    = 1.0e-8*( 1.0 + abs(p0(idx)) );

p    = p0;

p(idx)    = p0(idx)+h;
[opts fr] = F(opts,x,p);
p(idx)    = p0(idx)-h;
[opts fl] = F(opts,x,p);

l  = size(fr,1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDP__D(opts, F, x, p, pars)

if nargin<5
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

[opts fr] = F(opts, x(:,1),p(:,1));
l         = size(fr,1);

J = zeros(l,n,m);

for j=1:n
	p0 = p(:,j);
	h  = 1.0e-8*( 1.0 + abs(p0(pars)) );
	hi = 0.5./h;
	for i=1:m
		p1        = p0;
		pidx      = pars(i);

		p1(pidx)  = p0(pidx)+h(i);
		[opts fr] = F(opts, x(:,j),p1);
		p1(pidx)  = p0(pidx)-h(i);
		[opts fl] = F(opts, x(:,j),p1);

		J(:,j,i) = hi(i).*(fr-fl);
	end
end
J = reshape(J, [l n*m]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDPv__E(opts, data, F, x, p, pars)

if nargin<6
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

idx1 = kron( ones(1,m) , 1:n );
x    = x(:,idx1);
p0   = p(:,idx1);

idx1 = kron(pars, ones(1,n));
idx2 = 1:n*m;
idx  = sub2ind([size(p0,1) n*m], idx1, idx2);

h    = 1.0e-8*( 1.0 + abs(p0(idx)) );

p    = p0;

p(idx)    = p0(idx)+h;
[data fr] = F(opts,data,x,p);
p(idx)    = p0(idx)-h;
[data fl] = F(opts,data,x,p);

l  = size(fr,1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDP__E(opts, data, F, x, p, pars)

if nargin<6
  pars = 1:numel(p);
end

m = length(pars);
n = size(x,2);

[data fr] = F(opts, data, x(:,1),p(:,1));
l         = size(fr,1);

J = zeros(l,n,m);

for j=1:n
	p0 = p(:,j);
	h  = 1.0e-8*( 1.0 + abs(p0(pars)) );
	hi = 0.5./h;
	for i=1:m
		p1        = p0;
		pidx      = pars(i);

		p1(pidx)  = p0(pidx)+h(i);
		[data fr] = F(opts,data, x(:,j),p1);
		p1(pidx)  = p0(pidx)-h(i);
		[data fl] = F(opts,data, x(:,j),p1);

		J(:,j,i) = hi(i).*(fr-fl);
	end
end
J = reshape(J, [l n*m]);
end
