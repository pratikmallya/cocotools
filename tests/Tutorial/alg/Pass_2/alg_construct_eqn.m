%!alg_add_func
function prob = alg_construct_eqn(fhan, dfdxhan, dfdphan, x0, ...
  pnames, p0)

xdim         = numel(x0);
pdim         = numel(p0);
data.fhan    = fhan;
data.dfdxhan = dfdxhan;
data.dfdphan = dfdphan;
data.x_idx   = (1:xdim)';
data.p_idx   = xdim+(1:pdim)';

prob = coco_prob();
prob = coco_add_func(prob, 'alg', @alg_F, @alg_DFDU, data, 'zero', ...
  'u0', [x0(:); p0(:)]);
prob = coco_add_pars(prob, 'pars', data.p_idx, pnames);

end
%!end_alg_add_func
%!alg_F
function [data y] = alg_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = data.fhan(x, p);

end
%!end_alg_F
%!alg_DFDU
function [data J] = alg_DFDU(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

if isempty(data.dfdxhan), 
  J1 = coco_ezDFDX('f(x,p)', data.fhan, x, p);
else
  J1 = data.dfdxhan(x, p);
end
if isempty(data.dfdphan)
  J2 = coco_ezDFDP('f(x,p)', data.fhan, x, p);
else
  J2 = data.dfdphan(x, p);
end
J = sparse([J1 J2]);

end
%!end_alg_DFDU