function  J = duffing_DP(x,p)
% x = [x, xdot, t]
% p = [lambda alpha epsilon A omega]

J = [
    0      0      0         0               0
    -x(2)  -x(1)  -x(1).^3  cos(p(5)*x(3))  -p(4)*x(3).*sin(p(5)*x(3))
    0      0      0         0               0
    ];
