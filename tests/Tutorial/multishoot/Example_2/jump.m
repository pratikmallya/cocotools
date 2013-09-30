function g = jump(x, p, s)
% jump functions

g = x;
switch s
    case 1
        g(2) = -p(7)*x(2);
    case 2
        g(3) = x(3)-2*pi;
end
end