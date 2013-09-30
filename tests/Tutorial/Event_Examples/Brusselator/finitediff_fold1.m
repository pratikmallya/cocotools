function [data y] = finitediff_fold1(opts, data, xp)

[data JJ] = data.dfdx(opts, data, xp);

y = tanh(det(JJ(1:2*data.dim+4,1:2*data.dim+4)));

end