function [data y] = proj_bcs(opts, data, xp) %#ok<INUSL>

x1 = xp(1:3,:);
x2 = xp(4:6,:);

normal = [42.299 -154.725 284.103];
normal = normal/norm(normal);

y = [normal*(x1-[17.2077; 21.4376; 31.7953]);
    normal*(x2-[17.2077; 21.4376; 31.7953])];

end