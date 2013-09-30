function [data y] = eig_bcs(opts, data, xp) %#ok<INUSL>

x10 = xp(1:3,:);
x20 = xp(4:6,:);
x30 = xp(7:9,:);
s = xp(10,:);
r = xp(11,:);
vec = xp(12:14,:);
eps = xp(15:16,:);

y = [x10 - eps(1,:).*[(1-s+sqrt((1-s)^2+4*r*s))/2/r; 1; 0];...
    x20 - (x30 + eps(2,:)*vec)];

end