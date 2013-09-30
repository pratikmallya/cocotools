function data_ptr = update(opts, data_ptr, cmd, varargin)

data = data_ptr.data;

switch cmd
    case 'update'
        xp = varargin{1};
        [data JJ] = data.dfdx(opts, data, xp);
        Jx = JJ(1:2, 1:2);
        temp = Jx\data.b;
        data.b = Jx'\data.c;
        data.b = data.b/norm(data.b,2);
        data.c = temp/norm(temp,2);
        
    otherwise
end

data_ptr.data = data;

end