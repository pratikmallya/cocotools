function J = tor_dx(xx,pp,varargin)
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

J = zeros(3,3,numel(z));

J(1,1,:) = ( -(be+nu) - 3*a3.*x.^2 - 3*b3.*(y-x).^2 )./r;
J(1,2,:) = ( be + 3*b3.*(y-x).^2 )./r;

J(2,1,:) = be + 3*b3.*(y-x).^2;
J(2,2,:) = -(be+ga) - 3*b3.*(y-x).^2;
J(2,3,:) = -1;

J(3,2,:) = 1;

end
