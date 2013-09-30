function [varargout] = fdm_ezDFDX(key, varargin)
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
  %case 'f(x)v'
  %case 'f(x)'
  case 'f(x,p)v'
    [varargout{1:nargout}] = coco_num_DFDXv__A(varargin{:});
  case 'f(x,p)'
    [varargout{1:nargout}] = coco_num_DFDX__A(varargin{:});
  case 'f(o,x)v'
    [varargout{1:nargout}] = coco_num_DFDXv__B(varargin{:});
  case 'f(o,x)'
    [varargout{1:nargout}] = coco_num_DFDX__B(varargin{:});
  case 'f(o,d,x)v'
    [varargout{1:nargout}] = coco_num_DFDXv__C(varargin{:});
  case 'f(o,d,x)'
    [varargout{1:nargout}] = coco_num_DFDX__C(varargin{:});
  case 'f(o,x,p)v'
    [varargout{1:nargout}] = coco_num_DFDXv__D(varargin{:});
  case 'f(o,x,p)'
    [varargout{1:nargout}] = coco_num_DFDX__D(varargin{:});
  case 'f(o,d,x,p)v'
    [varargout{1:nargout}] = coco_num_DFDXv__E(varargin{:});
  case 'f(o,d,x,p)'
    [varargout{1:nargout}] = coco_num_DFDX__E(varargin{:});
  otherwise
    error('%s: key ''%s'' unrecognised', mfilename, key);
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDXv__A(F, x, p)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);
p    = p(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx) = x0(idx)+h;
fr     = F(x,p);
x(idx) = x0(idx)-h;
fl     = F(x,p);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDX__A(F, x, p)

[m n] = size(x);

fr = F(x(:,1),p(:,1));
l  = size(fr,1);

J  = zeros(l,m,n);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-8*( 1.0 + abs(x0) );
	hi = 0.5./h;
	for i=1:m
		xx       = x0;
		xx(i)    = x0(i)+h(i);
		fr       = F(xx,p(:,j));
		xx(i)    = x0(i)-h(i);
		fl       = F(xx,p(:,j));
		J(:,i,j) = hi(i)*(fr-fl);
	end
end
J = reshape(J, [l m*n]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDXv__B(opts, F, x)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx)    = x0(idx)+h;
[opts fr] = F(opts, x);
x(idx)    = x0(idx)-h;
[opts fl] = F(opts, x);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDX__B(opts, F, x)

[m n] = size(x);

[opts fr] = F(opts, x(:,1));
l  = size(fr,1);

J  = zeros(l,m,n);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-8*( 1.0 + abs(x0) );
	hi = 0.5./h;
	for i=1:m
		xx        = x0;
		xx(i)     = x0(i)+h(i);
		[opts fr] = F(opts, xx);
		xx(i)     = x0(i)-h(i);
		[opts fl] = F(opts, xx);
		J(:,i,j)  = hi(i)*(fr-fl);
	end
end
J = reshape(J, [l m*n]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDXv__C(opts, data, F, x)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx)    = x0(idx)+h;
[data fr] = F(opts, data, x);
x(idx)    = x0(idx)-h;
[data fl] = F(opts, data, x);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDX__C(opts, data, F, x)

[m n] = size(x);

[data fr] = F(opts, data, x(:,1));
l  = size(fr,1);

J  = zeros(l,m,n);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-8*( 1.0 + abs(x0) );
	hi = 0.5./h;
	for i=1:m
		xx        = x0;
		xx(i)     = x0(i)+h(i);
		[data fr] = F(opts, data, xx);
		xx(i)     = x0(i)-h(i);
		[data fl] = F(opts, data, xx);
		J(:,i,j)  = hi(i)*(fr-fl);
	end
end
J = reshape(J, [l m*n]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDXv__D(opts, F, x, p)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx)    = x0(idx)+h;
[opts fr] = F(opts, x, p);
x(idx)    = x0(idx)-h;
[opts fl] = F(opts, x, p);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J] = coco_num_DFDX__D(opts, F, x, p)

[m n] = size(x);

[opts fr] = F(opts, x(:,1));
l  = size(fr,1);

J  = zeros(l,m,n);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-8*( 1.0 + abs(x0) );
	hi = 0.5./h;
	for i=1:m
		xx        = x0;
		xx(i)     = x0(i)+h(i);
		[opts fr] = F(opts, xx, p);
		xx(i)     = x0(i)-h(i);
		[opts fl] = F(opts, xx, p);
		J(:,i,j)  = hi(i)*(fr-fl);
	end
end
J = reshape(J, [l m*n]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDXv__E(opts, data, F, x, p)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx)    = x0(idx)+h;
[data fr] = F(opts, data, x, p);
x(idx)    = x0(idx)-h;
[data fl] = F(opts, data, x, p);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [data J] = coco_num_DFDX__E(opts, data, F, x, p)

[m n] = size(x);

[data fr] = F(opts, data, x(:,1));
l  = size(fr,1);

J  = zeros(l,m,n);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-8*( 1.0 + abs(x0) );
	hi = 0.5./h;
	for i=1:m
		xx        = x0;
		xx(i)     = x0(i)+h(i);
		[data fr] = F(opts, data, xx, p);
		xx(i)     = x0(i)-h(i);
		[data fl] = F(opts, data, xx, p);
		J(:,i,j)  = hi(i)*(fr-fl);
	end
end
J = reshape(J, [l m*n]);
end
