function J = fp_par_deriv(data, u, varargin)

x = u(data.x_idx);
p = u(data.p_idx);
if isempty(data.fp)
  if nargin>=3
    acp_idx = varargin{1};
    J = fdm_ezDFDP('f(x,p)', data.f, x, p, acp_idx);
    for j=2:data.k
      x = data.f(x,p);
      J = fdm_ezDFDX('f(x,p)', data.f, x, p)*J + ...
        fdm_ezDFDP('f(x,p)', data.f, x, p, acp_idx);
    end
  else
    J = fdm_ezDFDP('f(x,p)', data.f, x, p);
    for j=2:data.k
      x = data.f(x,p);
      J = fdm_ezDFDX('f(x,p)', data.f, x, p)*J + ...
        fdm_ezDFDP('f(x,p)', data.f, x, p);
    end
  end
else
  J = data.fp(x, p);
  for j=2:data.k
    x = data.f(x,p);
    J = data.fx(x,p)*J+data.fp(x,p);
  end
  if nargin>=3
    J = J(:,varargin{1});
  end
end

end
