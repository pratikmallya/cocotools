function J = doedel_DFDX(x, p, mode)

J = zeros(2,2,size(x(1,:),2));
J(1,1,:) = -2*x(1,:);
J(2,1,:) = p(1,:);
J(2,2,:) = p(2,:);

if mode==2
    J=-J;
end

end
