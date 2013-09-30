function data_ptr = update2(opts, data_ptr, cmd, varargin)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function updates the vectors b and c used by
% finitediff_fold4.

data = data_ptr.data;

switch cmd
    case 'update'
        xp = varargin{1};
        [data JJ] = data.dfdx([], data, xp);
        
        [v,d] = eig(full(JJ(1:data.dim+2,1:data.dim+2)));
        [l,k] = min(abs(diag(d)));
        data.c = v(:,k);
        data.c = data.c/norm(data.c,2);
        
        [v,d] = eig(full(JJ(1:data.dim+2,1:data.dim+2)'));
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