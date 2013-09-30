function [data res] = bddat(opts, data, command, sol)

switch command
    case 'init'
        res = {'a', 'b'};
    case 'data'
        res = {sol.x(1) sol.x(2)};
end
