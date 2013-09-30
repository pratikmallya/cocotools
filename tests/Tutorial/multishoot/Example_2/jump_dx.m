function gx = jump_dx(~, p, s)
% jump functions

gx = eye(3,3);
switch s
    case 1
        gx(2,2) = -p(7);
end
end