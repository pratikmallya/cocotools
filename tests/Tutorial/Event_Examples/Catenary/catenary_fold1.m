function [data y] = catenary_fold1(opts, data, xp)

[data J] = data.dfdx(opts, data, xp);

y = det(J(1:2,1:2));

end