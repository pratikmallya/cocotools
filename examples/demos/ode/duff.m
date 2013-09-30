function [y]=duffing(x,p)
% x = [x, xdot, t]
% p = [lambda alpha epsilon A omega]

y = [
    x(2)
    p(4)*cos(p(5)*x(3)) - p(1)*x(2) - p(2)*x(1) - p(3)*x(1).^3
    1
    ];
