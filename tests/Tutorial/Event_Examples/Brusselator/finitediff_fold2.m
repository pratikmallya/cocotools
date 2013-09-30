function [data_ptr y] = finitediff_fold2(opts, data_ptr, xp)

data = data_ptr.data;

[data JJ] = data.dfdx(opts, data, xp);
M = [JJ(1:2*data.dim+4,1:2*data.dim+4) data.b ; data.c' 0];
if condest(M)<1e17
    
    V = M \ [zeros(2*data.dim+4,1); 1];
    % v = V(1:2*data.dim+4);
    h1 = V(2*data.dim+5);
    
    % W = M' \ [zeros(2*data.dim+4,1); 1];
    % w = W(1:2*data.dim+4);
    % h2 = W(2*data.dim+5);
    
    y = h1;
    
else
    print('error')
    y=1;
end

data_ptr.data = data;

end