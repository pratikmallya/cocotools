function tk = lagrange_bpoints(n, varargin)
%Compute base points for Lagrange interpolation in [-1,1].
%
%   TK = LAGRANGE_BPOINTS(N)
%   TK = LAGRANGE_BPOINTS(N,METHOD) computes the location of N
%   interpolation points for Lagrange interpolation. Two methods are
%   supported:
%
%   'linspace'     : equidistributed points and
%   'tschebycheff' : Tschebycheff-points.
%
%   The method 'linspace' is default at the moment and preferable for
%   plotting. The method 'tchebycheff' leads to a better conditiond
%   collocation method and might become default in the future.
%

if nargin < 2
	method = 'linspace';
else
	method = varargin{1};
end

switch method
	case 'linspace'
		tk = linspace(-1, 1, n);
		
	case 'tschebycheff'
		tk = cos(linspace(pi, 0, n));
		
	otherwise
		error('lagrange_bpoints: unknown distribution method %s', method);
end
