function [data y] = range(opts, data, xp)

if isempty(data)
  data = coco_get_func_data(opts, 'alg_fun');
end

x = xp(data.x_idx);

y = -x;
