function [K K1 K2] = char_it_DFDZ(A,B,C, ga, z)
% z = C./(A.*conj(z)+B);

x  = real(z);
y  = imag(z);
al = real(B);
be = imag(B);

u = C.*(A.*x + al);
v = C.*(A.*y - be);
w = A.*A.*(x.*x+y.*y) + 2*A.*(al.*x-be.*y) + (al.*al+be.*be);

ux = C.*A;
uy = 0;
vx = 0;
vy = C.*A;

wx = 2*A.*A.*x + 2*A.*al;
wy = 2*A.*A.*y - 2*A.*be;

J(:,:,1,1) = (1-ga) + ga*(ux.*w-u.*wx)./w.^2;
J(:,:,1,2) =          ga*(uy.*w-u.*wy)./w.^2;
J(:,:,2,1) =          ga*(vx.*w-v.*wx)./w.^2;
J(:,:,2,2) = (1-ga) + ga*(vy.*w-v.*wy)./w.^2;

p = J(:,:,1,1)+J(:,:,2,2);
q = J(:,:,1,1).*J(:,:,2,2)-J(:,:,2,1).*J(:,:,1,2);

K1 = p/2 + sqrt(p.^2/4-q);
K2 = p/2 - sqrt(p.^2/4-q);

K = max(abs(K1),abs(K2));

end
