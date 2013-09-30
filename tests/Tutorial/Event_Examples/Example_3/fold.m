function [data y] = fold(opts, data, xp)

if isempty(data)
  data = coco_get_func_data(opts, 'alg_fun');
end

x = xp(data.x_idx);
p = xp(data.p_idx);

lambda = p(2);

y = 3*x^2 - lambda;
