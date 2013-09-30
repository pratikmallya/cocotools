function [varargout] = coco_num_D2FDX2(varargin)
%COCO_NUM_D2FDX2  Numerical differentiation wrt. state, non-vectorised.
%
%   J        = COCO_NUM_D2FDX2(F,X,P)
%   [OPTS J] = COCO_NUM_D2FDX2(OPTS,F,X,P) The routines COCO_NUM_D2FDX2,
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
%   See also: gcont_num_DFDP, gcont_num_DFDPv, gcont_num_D2FDX2v
%

if isstruct(varargin{1})
  if nargin == 5 && nargout == 4
    [varargout{1:nargout}] = coco_num_D2FDX2__B(varargin{:});
  elseif nargin == 4 && nargout == 4
    [varargout{1:nargout}] = coco_num_D2FDX2__C(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
else
  if nargin == 4 && 0<=nargout && nargout<=3
    [varargout{1:nargout}] = coco_num_D2FDX2__A(varargin{:});
  else
    error('%s: called with wrong agruments', mfilename);
  end
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [J JA JJA] = coco_num_D2FDX2__A(F, x, p, A)

[m n] = size(x);

fr = F(x(:,1),p(:,1));
l  = size(fr,1);

J   = zeros(l,m,n);
JA  = zeros(l,n,m);
JJA = zeros(l,n,m,m);
a   = reshape(max(abs(A)), [n m])';
E   = eye(m,m);

for j=1:n
	x0 = x(:,j);
  pp = p(:,j);
	h  = 1.0e-4*( 1.0 + abs(x0) );
  k  = 5.0e-7*( 1.0 + abs(x0) )./(1.0e-2+a(:,j));
	
	for i=1:m
    aa = A(:,j,i);
    
    for o=1:m
      ee = E(:,o);
      
      xx = x0-h(o)*ee-k(i)*aa;
      F1 = F(xx,pp);
      
      xx = x0+h(o)*ee-k(i)*aa;
      F2 = F(xx,pp);
      
      xx = x0-h(o)*ee+k(i)*aa;
      F3 = F(xx,pp);
      
      xx = x0+h(o)*ee+k(i)*aa;
      F4 = F(xx,pp);
      
      JJA(:,j,i,o) = (F4-F3-F2+F1)/(4*h(o)*k(i));
    
      if o==i
        J (:,o,j) = (F2-F1+F4-F3)/(4*h(i));
        JA(:,j,i) = (F3-F1+F4-F2)/(4*k(i));
      end
    end
	end
end
% J   = reshape(J  , [l m*n  ]);
% JA  = reshape(JA , [l n*m  ]);
% JJA = reshape(JJA, [l m*n*m]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J JA JJA] = coco_num_D2FDX2__B(opts, F, x, p, A)

[m n] = size(x);

fr = F(opts, x(:,1),p(:,1));
l  = size(fr,1);

J   = zeros(l,m,n);
JA  = zeros(l,n,m);
JJA = zeros(l,n,m,m);
a   = reshape(max(abs(A)), [n m])';
E   = eye(m,m);

for j=1:n
	x0 = x(:,j);
  pp = p(:,j);
	h  = 1.0e-4*( 1.0 + abs(x0) );
  k  = 5.0e-7*( 1.0 + abs(x0) )./(1.0e-2+a(:,j));
	
	for i=1:m
    aa = A(:,j,i);
    
    for o=1:m
      ee = E(:,o);
      
      xx = x0-h(o)*ee-k(i)*aa;
      F1 = F(opts, xx,pp);
      
      xx = x0+h(o)*ee-k(i)*aa;
      F2 = F(opts, xx,pp);
      
      xx = x0-h(o)*ee+k(i)*aa;
      F3 = F(opts, xx,pp);
      
      xx = x0+h(o)*ee+k(i)*aa;
      F4 = F(opts, xx,pp);
      
      JJA(:,j,i,o) = (F4-F3-F2+F1)/(4*h(o)*k(i));
    
      if o==i
        J (:,o,j) = (F2-F1+F4-F3)/(4*h(i));
        JA(:,j,i) = (F3-F1+F4-F2)/(4*k(i));
      end
    end
	end
end
% J   = reshape(J  , [l m*n  ]);
% JA  = reshape(JA , [l n*m  ]);
% JJA = reshape(JJA, [l m*n*m]);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [opts J JA JJA] = coco_num_D2FDX2__C(opts, F, x, A)

[m n] = size(x);

fr = F(opts, x(:,1));
l  = size(fr,1);

J   = zeros(l,m,n);
JA  = zeros(l,n,m);
JJA = zeros(l,n,m,m);
a   = reshape(max(abs(A)), [n m])';
E   = eye(m,m);

for j=1:n
	x0 = x(:,j);
	h  = 1.0e-4*( 1.0 + abs(x0) );
  k  = 5.0e-7*( 1.0 + abs(x0) )./(1.0e-2+a(:,j));
	
	for i=1:m
    aa = A(:,j,i);
    
    for o=1:m
      ee = E(:,o);
      
      xx = x0-h(o)*ee-k(i)*aa;
      F1 = F(opts, xx);
      
      xx = x0+h(o)*ee-k(i)*aa;
      F2 = F(opts, xx);
      
      xx = x0-h(o)*ee+k(i)*aa;
      F3 = F(opts, xx);
      
      xx = x0+h(o)*ee+k(i)*aa;
      F4 = F(opts, xx);
      
      JJA(:,j,i,o) = (F4-F3-F2+F1)/(4*h(o)*k(i));
    
      if o==i
        J (:,o,j) = (F2-F1+F4-F3)/(4*h(i));
        JA(:,j,i) = (F3-F1+F4-F2)/(4*k(i));
      end
    end
	end
end
% J   = reshape(J  , [l m*n  ]);
% JA  = reshape(JA , [l n*m  ]);
% JJA = reshape(JJA, [l m*n*m]);
end
