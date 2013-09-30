function [data_ptr res] = bddat(opts, data_ptr, command, sol)

data = data_ptr.data;

switch command
    case 'init'
        res = {'norm(U)' 'A0'};
    case 'data'
        res = {norm(sol.x(1:2*data.dim+4),2) sol.x(data.p_idx(3))};
end

data_ptr.data = data;

end
