function z = char_it_F(A,B,C, ga, z)
z = (1-ga)*z + ga*C./(A.*conj(z)+B);

% x  = real(z);
% y  = imag(z);
% al = real(B);
% be = imag(B);
% 
% u = C.*(A.*x + al);
% v = C.*(A.*y - be);
% w = A.*A.*(x.*x+y.*y) + 2*A.*(al.*x-be.*y) + (al.*al+be.*be);
% 
% z = u./w + 1i*v./w;
end
