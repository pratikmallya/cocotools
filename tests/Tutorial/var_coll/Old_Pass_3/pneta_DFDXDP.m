function J = pneta_DFDXDP(x, ~, ~)

x2 = x(2,:);

J          = zeros(2,2,numel(x2),1);
J(2,2,:,1) = 0.5-3*x2.^2;

end