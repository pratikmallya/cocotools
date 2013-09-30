function prob = alg_FO2FO(prob, oid, varargin)

tbid = coco_get_id(oid, 'alg');
str  = coco_stream(varargin{:});
run  = str.get;
if ischar(str.peek)
  soid = str.get;
else
  soid = oid;
end
lab = str.get;

[sol data] = alg_read_solution(soid, run, lab);
prob       = coco_set(prob, tbid, 'FO', false);
data       = alg_get_settings(prob, tbid, data);
prob       = alg_construct_eqn(prob, tbid, data, sol);

[data uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
prob        = alg_create_FO(prob, data, uidx, sol);

end

function prob = alg_create_FO(prob, data, uidx, sol)

Jx         = alg_fhan_DFDX(data, sol.x, sol.p);
[v0, ~]    = eigs(Jx, 1, 0);
data.v_idx = data.p_idx(end)+(1:numel(v0));

fid  = coco_get_id(data.tbid, 'fold_cond');
prob = coco_add_func(prob, fid, @alg_FO, @alg_FO_DFDU, ...
  data, 'zero', 'uidx', [uidx(data.x_idx); uidx(data.p_idx)], ...
  'u0', v0);

end

function [data y] = alg_FO(prob, data, u)

Jx = alg_fhan_DFDX(data, u(data.x_idx), u(data.p_idx));
v  = u(data.v_idx);
y  = [Jx*v; v'*v-1];

end

function [data J] = alg_FO_DFDU(prob, data, u)

x  = u(data.x_idx);
p  = u(data.p_idx);
Jx = alg_fhan_DFDX(data, x, p);
v  = u(data.v_idx);

h  = 1.0e-4*(1+norm(x));
J0 = alg_fhan_DFDX(data, x-h*v, p);
J1 = alg_fhan_DFDX(data, x+h*v, p);
Jxx = (0.5/h)*(J1-J0);

J0 = alg_fhan_DFDP(data, x-h*v, p);
J1 = alg_fhan_DFDP(data, x+h*v, p);
Jpx = (0.5/h)*(J1-J0);

J = [Jxx Jpx Jx; zeros(1,numel(data.x_idx)+numel(data.p_idx)) 2*v'];

end