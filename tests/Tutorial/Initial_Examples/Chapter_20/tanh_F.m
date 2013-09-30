function [data y] = tanh_F(prob, data, u)

x = u(data.x_idx);
p = u(data.p_idx);

y = x-tanh(p*data.t)/tanh(p);

end