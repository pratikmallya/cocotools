function  J = duffing_DX(x,p)
% x = [x, xdot, t]
% p = [lambda alpha epsilon A omega]

J = [
    0                    1      0
    -p(2)-3*p(3)*x(1).^2  -p(1)  -p(4)*p(5)*sin(p(5).*x(3))
    0                    0      0
    ];
