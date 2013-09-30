function [data y] = pneta_bc(opts, data, u)

y = [u(1:2,:)-u(3:4,:); u(1)];

end
