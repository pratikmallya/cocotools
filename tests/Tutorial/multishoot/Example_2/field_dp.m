function fp = field_dp(x, p, s)
% Vector fields

fp = zeros(3,7);
switch s
    case {1,2,3,[1,2,3]}
        fp(2,1) = -1/p(1)^2*(p(2)*cos(x(3))-p(3)*x(2)-p(4)*x(1));
        fp(2,2) = cos(x(3))/p(1);
        fp(2,3) = -x(2)/p(1);
        fp(2,4) = -x(1)/p(1);
        fp(3,5) = 1;
end
end