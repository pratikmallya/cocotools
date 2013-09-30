function [varargout] = coco_num_D2FDX2v(varargin)
%COCO_NUM_D2FDX2V  Numerical differentiation wrt. state, vectorised.
%
%   J        = COCO_NUM_D2FDX2V(F,X,P)
%   [OPTS J] = COCO_NUM_D2FDX2V(OPTS,F,X,P) The routines COCO_NUM_D2FDX2,
%   COCO_NUM_D2FDX2V, COCO_NUM_DFDP, and COCO_NUM_DFDPV use mid-point
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
%   See also: gcont_num_DFDP, gcont_num_DFDPV, gcont_num_D2FDX2
%

if isstruct(varargin{1})
  if nargin == 5 && nargout == 4
    [varargout{1:nargout}] = coco_num_D2FDX2v__B(varargin{:});
  elseif nargin == 4 && nargout == 4
    [varargout{1:nargout}] = coco_num_D2FDX2v__C(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
else
  if nargin == 4 && 0<=nargout && nargout<=3
    [varargout{1:nargout}] = coco_num_D2FDX2v__A(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [J JA JJA] = coco_num_D2FDX2v__A(F, x, p, A)

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
function [opts J] = coco_num_D2FDX2v__B(opts, F, x, p)

[m n] = size(x);
h     = reshape(1.0e-8*( 1.0 + abs(x) ), 1, m*n);

idx1 = kron( 1:n , ones(1,m) );
x0   = x(:,idx1);
p    = p(:,idx1);

idx1 = repmat(1:m, [1 n]);
idx2 = 1:m*n;
idx  = sub2ind([m m*n], idx1, idx2);

x    = x0;

x(idx)    = x0(idx)+h;
[opts fr] = F(opts, x,p);
x(idx)    = x0(idx)-h;
[opts fl] = F(opts, x,p);

l  = size(fr, 1);
hi = repmat(0.5./h, l, 1);
J  = hi.*(fr-fl);
end
