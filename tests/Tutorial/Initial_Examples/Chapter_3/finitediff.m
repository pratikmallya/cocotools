function [data y] = finitediff(prob, data, u)

dep = u(data.dep_idx);
par = u(data.par_idx);

ff = dep(data.f_idx);
gg = dep(data.g_idx);

f = [par(1)-(par(2)+1)*ff+ff.^2.*gg; par(2)*ff-ff.^2.*gg];

y = data.A*dep+data.B*f;

end