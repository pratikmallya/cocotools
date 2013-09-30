function [varargout] = coco_num_DFDPv(varargin)
%COCO_NUM_DFDPV  Numerical differentiation wrt. parameter, vectorised.
%
%   J        = COCO_NUM_DFDPV(F,X,P,PARS)
%   [OPTS J] = COCO_NUM_DFDPV(OPTS,F,X,P,PARS) The routines COCO_NUM_DFDX,
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
%   See also: gcont_num_DFDP, gcont_num_DFDX, gcont_num_DFDXv
%

if nargin == 4 && nargout == 1
	[varargout{1:nargout}] = coco_num_DFDPv__A(varargin{:});
elseif nargin == 5 && nargout == 2 && isstruct(varargin{1})
	[varargout{1:nargout}] = coco_num_DFDPv__B(varargin{:});
else
	error('%s: called with wrong agruments', mfilename);
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDPv__A(F, x, p, pars)

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
function [opts J] = coco_num_DFDPv__B(opts, F, x, p, pars)

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
