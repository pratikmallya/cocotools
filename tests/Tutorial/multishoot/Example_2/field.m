function f = field(x, p, s)
% Vector fields

switch s
    case {1,2,3,'all'}
        f = [x(2); 1/p(1)*(p(2)*cos(x(3))-p(3)*x(2)-p(4)*x(1)); p(5)];
end
end