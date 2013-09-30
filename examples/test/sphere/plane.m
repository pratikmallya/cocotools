function [data y xidx] = plane(opts, data, xp)
% PLANE   Equation for plane intersecting a cone.
%
%   PLANE(OPTS,XP) Equation for plane through [0 0 1] with normal vector
%   N=[0 sin(alpha) cos(alpha)]. XP = [ z ; x ; y ; alpha ].

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

z     = x(1,:);
x     = p(1,:);
y     = p(2,:);
alpha = p(3,:);

N  = [ zeros(size(alpha)) ;     sin(alpha) ;    cos(alpha) ];
X  = [                  x ;              y ;             z ];
X0 = [     zeros(size(x)) ; zeros(size(y)) ; ones(size(z)) ];

y(1,:) = sum(N.*(X-X0), 1);
y(2,:) = z;
