function [data J] = xfunc_DFDX(opts, data, u) %#ok<INUSL>
%XFUNC_DFDX  Evaluate Jacobian of extended system at UP=[U;P].
%
%   [OPTS J] = XFUNC_DFDX(OPTS, U, P) evaluates the Jacobian of the
%   extended system associated with the tangent predictor.
%
%   See also:
%

switch data.mode
	
	case 0
		J = data.t;
	
	case 1
		J = sparse(1, data.fixpar_idx, 1, 1, numel(u));
    for j=2:data.k
      J = [ J ; data.s(1)*data.t(j,:)-data.s(j)*data.t(1,:) ]; %#ok<AGROW>
    end
		
	case 3
		J = sparse(1:data.k, data.fixpar_idx, 1, data.k, numel(u));
		
end
