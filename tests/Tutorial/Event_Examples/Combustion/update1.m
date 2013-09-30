function data_ptr = update1(opts, data_ptr, cmd, varargin)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function updates the vector c used by finitediff_fold2.

data = data_ptr.data;

switch cmd
    case 'update'
        xp = varargin{1};
        data.c = xp(data.sigma_idx);
        
    otherwise
end

data_ptr.data = data;

end