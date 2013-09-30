function [data y xidx] = range(opts, data, xp)
% RANGE   Test function for df/dla in range of df/dx.
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

% y(1,:) = mu - x.*(la-x.*x);

y(1,:) = -x;
