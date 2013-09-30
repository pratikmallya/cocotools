function fx = field_dx(x, p, s)
% Vector fields

fx = zeros(3,3);
switch s
    case {1,2,3}
        fx(1,2) = 1;
        fx(2,1) = -p(4)/p(1);
        fx(2,2) = -p(3)/p(1);
        fx(2,3) = -p(2)/p(1)*sin(x(3));
end
end