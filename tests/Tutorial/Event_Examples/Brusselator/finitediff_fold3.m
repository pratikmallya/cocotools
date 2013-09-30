function [data y] = finitediff_fold3(opts, data, xp)

sigma = xp(data.sigma_idx);
eigvl = xp(data.eigvl_idx);
[data JJ] = data.dfdx(opts, data, xp);

y = [(JJ(1:2*data.dim+4,1:2*data.dim+4)-eigvl*eye(2*data.dim+4))*sigma; ...
    sigma'*sigma-1];

end