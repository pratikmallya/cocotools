function [data y xidx] = fold(opts, data, xp)
% FOLD   Test function for folds of cusp normal form.
%    X = x
%    P = [ mu la ]

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'alcont');
  data.x_idx   = fdata.x_idx;
  data.p_idx   = fdata.p_idx;
  xp           = xp(xidx);
else
  xidx = [];
end

x = xp(data.x_idx,:);
p = xp(data.p_idx,:);

mu = p(1,:);
al = p(2,:);

% y(1,:) = x .* (mu - (x-al).*(x-al));

y(1,:) = (mu - (x-al).*(x-al)) - 2 * (x .* (x-al));
