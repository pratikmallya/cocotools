function x = gaussnodes(n)
%Compute location of N Gauss nodes in [-1,1].
%
%   X = GAUSSNODES(N) computes the locations of N Gauss nodes in the
%   interval [-1,1]. Collocation on N Gauss nodes will give a method of
%   order 2*N.
%

% companion method: compute eigenvalues of companion matrix of Legendre
% polynomial of order n; this method is deprecated
%
% p = legcoeffs(n);
% A = compan(p);

% Jacobi matrix method: compute eigenvalues of the Jacobi matrix associated
% with the three-point recursion formula for Legendre polynomials,
% this method is superior to the companion method and works for large n

A = JacobiMatrix(n);

x = eig(A);

y = norm(imag(x));
z = norm(x+x(end:-1:1))>sqrt(eps);
if(max(y,z)>10*eps)
	error('gauss nodes inaccurate, use smaller n');
end

x = sort(real(x));
x = 0.5*(x-x(end:-1:1));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function J = JacobiMatrix(n)
% compute Jacobi matrix for Legendre polynomial of order n
% based on recursion
%   p0   = 1
%   p1   = x
%   pn+1 = x*pn - n^2/(4*n^2-1)*pn-1

nn = 1:n-1;
ga = -nn.*sqrt(1./(4.*nn.^2-1));
J  = zeros(n,n);
J(sub2ind([n n], [nn], [nn+1])) = ga;
J(sub2ind([n n], [nn+1], [nn])) = ga;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = legcoeffs(n)

p  = [1];
if n==0; return; end
p1 = p;

p  = [1 0];
if n==1; return; end
p2 = p;

for i=2:n
	p3 = (2*i-1)/i*[p2 0]- (i-1)/i*[0 0 p1];
	p1 = p2;
	p2 = p3;
end

p = p3;
return

p1 = legcoeffs(n-1);
p2 = legcoeffs(n-2);

p1 = [p1 0];
p2 = [0 0 p2];

p = (2*n-1)/n*p1 - (n-1)/n*p2;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C     ---------- -----
%       SUBROUTINE CPNTS(NCOL,ZM)
% C
%       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
% C
% C Generates the collocation points with respect to [0,1].
% C
%       DIMENSION ZM(*)
% C
%        GOTO (2,3,4,5,6,7)NCOL-1
% C
%  2     C=.5d0/DSQRT(3.0d0)
%        ZM(1)=.5d0-C
%        ZM(2)=.5d0+C
%       RETURN
% C
%  3     C=.5d0*DSQRT(0.6d0)
%        ZM(1)=.5d0-C
%        ZM(2)=.5d0
%        ZM(3)=.5d0+C
%       RETURN
% C
%  4     R=6.0d0/7.0d0
%        C=.5d0*DSQRT(R**2-12.0d0/35.0d0)
%        C1=.5d0*DSQRT(3.0d0/7.0d0+C)
%        C2=.5d0*DSQRT(3.0d0/7.0d0-C)
%        ZM(1)=.5d0-C1
%        ZM(2)=.5d0-C2
%        ZM(3)=.5d0+C2
%        ZM(4)=.5d0+C1
%       RETURN
% C
%  5     C1=.5d0*0.90617984593866399280d0
%        C2=.5d0*0.53846931010568309104d0
%        ZM(1)=.5d0-C1
%        ZM(2)=.5d0-C2
%        ZM(3)=.5d0
%        ZM(4)=.5d0+C2
%        ZM(5)=.5d0+C1
%       RETURN
% C
%  6     C1=.5d0*0.93246951420315202781d0
%        C2=.5d0*0.66120938646626451366d0
%        C3=.5d0*0.23861918608319690863d0
%        ZM(1)=.5d0-C1
%        ZM(2)=.5d0-C2
%        ZM(3)=.5d0-C3
%        ZM(4)=.5d0+C3
%        ZM(5)=.5d0+C2
%        ZM(6)=.5d0+C1
%       RETURN
% C
% %%%%%%%%%%%%%% warning: typo below: C1=.5d0*0.94910791234275852452d0
%  7     C1=.5d0*0.949107991234275852452d0
%        C2=.5d0*0.74153118559939443986d0
%        C3=.5d0*0.40584515137739716690d0
%        ZM(1)=.5d0-C1
%        ZM(2)=.5d0-C2
%        ZM(3)=.5d0-C3
%        ZM(4)=.5d0
%        ZM(5)=.5d0+C3
%        ZM(6)=.5d0+C2
%        ZM(7)=.5d0+C1
%       RETURN
%       END
