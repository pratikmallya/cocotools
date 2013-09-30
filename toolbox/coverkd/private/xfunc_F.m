function [data f] = xfunc_F(opts, data, u) %#ok<INUSL>
%XFUNC_F  Evaluate extended system at UP=[U;P].
%
%   [OPTS F] = XFUNC_F(OPTS, UP) evaluates the extended system associated
%   with the tangent predictor.
%
%   See also:
%

switch data.mode
	
	case 0
		f = data.t*(u-data.u0) - data.s*data.h;
	
	case 1
    f    = zeros(data.k,1);
		f(1) = u(data.fixpar_idx) - data.fixpar_val;
    for j=2:data.k
      f(j) = (data.s(1)*data.t(j,:)-data.s(j)*data.t(1,:))*(u-data.u0);
    end
		
  case 2
    f = zeros(data.k,1);
  
	case 3
		f = u(data.fixpar_idx) - data.fixpar_val;
		
end
