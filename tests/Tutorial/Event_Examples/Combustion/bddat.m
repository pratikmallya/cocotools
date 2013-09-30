function [data res] = bddat(opts, data, command, sol)

switch command
    case 'init'
        res = {'midpoint' 'lambda' 'mu'};
    case 'data'
        res = {sol.x(data.dim/2+1) sol.x(data.p_idx(1))...
            sol.x(data.p_idx(2))};
end
