%!alg_add_func
function prob = alg_construct_eqn(prob, tbid, data, sol)

prob = coco_add_func(prob, tbid, @alg_F, @alg_DFDU, data, 'zero', ...
  'u0', sol.u);
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  uidx = coco_get_func_data(prob, tbid, 'uidx');
  prob = coco_add_pars(prob, fid, uidx(data.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_alg_add_func
%!alg_F
function [data y] = alg_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = data.fhan(x, p);

end %!end_alg_F
%!alg_DFDU
function [data J] = alg_DFDU(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

if isempty(data.dfdxhan)
  J1 = coco_ezDFDX('f(x,p)',data.fhan, x, p);
else
  J1 = data.dfdxhan(x, p);
end

if isempty(data.dfdphan)
  J2 = coco_ezDFDP('f(x,p)',data.fhan, x, p);
else
  J2 = data.dfdphan(x, p);
end
J = sparse([J1 J2]);

end %!end_alg_DFDU