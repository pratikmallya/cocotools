function [data_ptr y] = catenary_fold2(opts, data_ptr, xp)

data = data_ptr.data;

[data JJ] = data.dfdx(opts, data, xp);
M = [JJ(1:2,1:2) data.b ; data.c' 0];

if condest(M)<1e17
    
    V = M \ [0; 0; 1];
    % v = V(1:2);
    h1 = V(3);
    
    % W = M' \ [0; 0; 1];
    % w = W(1:2);
    % h2 = W(3);
    
    y = h1;
    
else
    print('error')
    y=1;
end

data_ptr.data = data;

end