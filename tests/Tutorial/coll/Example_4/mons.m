function [data y] = mons(opts, data, xp)

x11 = xp(1:3);
x21 = xp(4:6);

y = [3-x11(3) ; ...
    3-x21(3) ; ...
    x21(1) - x11(1) + x21(2) - x11(2)];

end