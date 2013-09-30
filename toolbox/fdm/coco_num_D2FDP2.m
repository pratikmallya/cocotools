function [varargout] = coco_num_D2FDP2(varargin)
%COCO_NUM_D2FDP2  Numerical differentiation wrt. parameter, non-vectorised.
%
%   J        = COCO_NUM_D2FDP2(F,X,P,PARS)
%   [OPTS J] = COCO_NUM_D2FDP2(OPTS,F,X,P,PARS) The routines COCO_NUM_DFDX,
%   COCO_NUM_DFDXV, COCO_NUM_D2FDP2, and COCO_NUM_D2FDP2V use mid-point
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
%   See also: gcont_num_D2FDP2v, gcont_num_DFDX, gcont_num_DFDXv
%

if isstruct(varargin{1})
  if nargin==6 && nargout==3
    [varargout{1:nargout}] = coco_num_D2FDP2__B(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
else
  if nargin==5 && 0<=nargout && nargout<=2
    [varargout{1:nargout}] = coco_num_D2FDP2__A(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [J JJA] = coco_num_D2FDP2__A(F, x, p, pars, A)

m     = length(pars);
[q n] = size(x);

fr    = F(x(:,1),p(:,1));
l     = size(fr,1);

J     = zeros(l,n,m);
JJA   = zeros(l,n,q,m);
a     = reshape(max(abs(A)), [n q])';
E     = eye(m,m);

for i=1:m
  pidx = pars(i);
  ee   = E(:,i);
  for j=1:n
    x0 = x(:,j);
    p0 = p(:,j);
    h  = 5.0e-7*( 1.0 + abs(x0) )./(1.0e-2+a(:,j));
    k  = 1.0e-4*( 1.0 + abs(p0(pidx)) );
    
    for o=1:q
      aa = A(:,j,o);
      p1 = p0+k*ee;
      p2 = p0-k*ee;
      
      xx = x0+h(o)*aa;
      F1 = F(xx,p1);
      F3 = F(xx,p2);

      xx = x0-h(o)*aa;
      F2 = F(xx,p1);
      F4 = F(xx,p2);

      J  (:,j,i)   = J  (:,j,i) + ( (F1-F3) + (F2-F4) )/(4*q*k);
      JJA(:,j,o,i) = ( (F1-F3)/(2*k) - (F2-F4)/(2*k) )/(2*h(o));
    end
  end
end
% J   = reshape(J  , [l n*m]);
% JJA = reshape(JJA, [l n*q*m]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J JJA] = coco_num_D2FDP2__B(opts, F, x, p, pars, A)

m     = length(pars);
[q n] = size(x);

fr    = F(opts, x(:,1),p(:,1));
l     = size(fr,1);

J     = zeros(l,n,m);
JJA   = zeros(l,n,q,m);
a     = reshape(max(abs(A)), [n q])';
E     = eye(m,m);

for i=1:m
  pidx = pars(i);
  ee   = E(:,i);
  for j=1:n
    x0 = x(:,j);
    p0 = p(:,j);
    h  = 5.0e-7*( 1.0 + abs(x0) )./(1.0e-2+a(:,j));
    k  = 1.0e-4*( 1.0 + abs(p0(pidx)) );
    
    for o=1:q
      aa = A(:,j,o);
      p1 = p0+k*ee;
      p2 = p0-k*ee;
      
      xx = x0+h(o)*aa;
      F1 = F(opts, xx,p1);
      F3 = F(opts, xx,p2);

      xx = x0-h(o)*aa;
      F2 = F(opts, xx,p1);
      F4 = F(opts, xx,p2);

      J  (:,j,i)   = J  (:,j,i) + ( (F1-F3) + (F2-F4) )/(4*q*k);
      JJA(:,j,o,i) = ( (F1-F3)/(2*k) - (F2-F4)/(2*k) )/(2*h(o));
    end
  end
end
% J   = reshape(J  , [l n*m]);
% JJA = reshape(JJA, [l n*q*m]);
end
