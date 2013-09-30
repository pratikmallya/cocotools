function [varargout] = coco_num_DFDP(varargin)
%COCO_NUM_DFDP  Numerical differentiation wrt. parameter, non-vectorised.
%
%   J        = COCO_NUM_DFDP(F,X,P,PARS)
%   [OPTS J] = COCO_NUM_DFDP(OPTS,F,X,P,PARS) The routines COCO_NUM_DFDX,
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
%   See also: gcont_num_DFDPv, gcont_num_DFDX, gcont_num_DFDXv
%

if nargin == 4 && nargout == 1
	[varargout{1:nargout}] = coco_num_DFDP__A(varargin{:});
elseif nargin == 5 && nargout == 2 && isstruct(varargin{1})
	[varargout{1:nargout}] = coco_num_DFDP__B(varargin{:});
else
	error('%s: called with wrong agruments', mfilename);
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function J = coco_num_DFDP__A(F, x, p, pars)

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
function [opts J] = coco_num_DFDP__B(opts, F, x, p, pars)

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
