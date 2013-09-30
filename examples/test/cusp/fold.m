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

la = p(2,:);

% y(1,:) = mu - x.*(la-x.*x);

y(1,:) = -(la-x.*x)+2*(x.*x);
