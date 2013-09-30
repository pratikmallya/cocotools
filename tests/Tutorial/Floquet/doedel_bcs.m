function [data y] = eig_bcs(opts, data, xp) %#ok<INUSL>

x10 = xp(1:2,:);
x20 = xp(3:4,:);
eqs = xp(5:8,:);
vec = xp(9:10,:);
eps = xp(11:12,:);
th  = xp(13,:);

y = [x10 - (eqs(1:2,:) + eps(1,:).*[cos(th); sin(th)]);...
    x20 - (eqs(3:4,:) + eps(2,:)*vec)];

end