function gp = jump_dp(x, ~, s)
% jump functions

gp = zeros(3,7);
switch s
    case 1
        gp(2,7) = -x(2);
end
end