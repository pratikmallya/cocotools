function J = pneta_DFDP(x, ~, ~)

x2 = x(2,:);

J        = zeros(2,1,numel(x2));
J(2,1,:) = 0.5.*x2-x2.^3;

end