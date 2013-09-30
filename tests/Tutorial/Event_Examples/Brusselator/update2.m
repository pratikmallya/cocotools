function data_ptr = update2(opts, data_ptr, cmd, varargin)

data = data_ptr.data;

switch cmd
    case 'update'
        xp = varargin{1};
        [data JJ] = data.dfdx([], data, xp);
        
        [v,d] = eig(full(JJ(1:2*data.dim+4,1:2*data.dim+4)));
        [l,k] = min(abs(diag(d)));
        data.c = v(:,k);
        data.c = data.c/norm(data.c,2);
        
        [v,d] = eig(full(JJ(1:2*data.dim+4,1:2*data.dim+4)'));
        [l,k] = min(abs(diag(d)));
        if v(1,k)>0
            data.b = v(:,k);
        else
            data.b = -v(:,k);
        end
        data.b = data.b/norm(data.b,2);
        
    otherwise
end

data_ptr.data = data;

end