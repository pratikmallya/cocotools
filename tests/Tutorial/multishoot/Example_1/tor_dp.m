function J = tor_dp(xx,pp,varargin)
% p = [nu be ga r a3 b3]

nu = pp(1,:);
be = pp(2,:);
ga = pp(3,:);
r  = pp(4,:);
a3 = pp(5,:);
b3 = pp(6,:);

x = xx(1,:);
y = xx(2,:);
z = xx(3,:);

J = zeros(3,6,numel(z));

J(1,1,:) = ( -x )./r;
J(1,2,:) = ( -x + y )./r;
J(1,4,:) = -( -(be+nu).*x + be.*y - a3.*x.^3 + b3.*(y-x).^3 )./r.^2;
J(1,5,:) = ( -x.^3 )./r;
J(1,6,:) = ( (y-x).^3 )./r;

J(2,2,:) = x - y;
J(2,3,:) = -y;
J(2,6,:) = -(y-x).^3;

end
