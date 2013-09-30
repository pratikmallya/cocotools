function [data y xidx] = cone(opts, data, xp)
% CONE   Equation for double cone around z-axis.
%
%    CONE(OPTS,XP) - Equation: z^2 = x^2 + y^2
%    XP = [ z ; x ; y ; alpha ]

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'alcont');
  data.x_idx   = fdata.x_idx;
  data.p_idx   = fdata.p_idx;
  xp           = xp(xidx);
else
  xidx = [];
end

p = xp(data.p_idx,:);

z = p(1,:);
x = p(2,:);
y = p(3,:);

y(1,:) = z.^2 - x.^2 - y.^2;
