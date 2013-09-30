function [z1 z2] = solve_char_eqn(A,B,C)
% solve equation A*conj(z)*z + B*z = C,
% where A,C are real and B is complex

d  = A;
al = real(B);
be = imag(B);

idx = (abs(al)<1.0e-8 & abs(be)<1.0e-8);
E  = d.*(1 + be.^2 ./ al.^2);
E(idx) = 1;

F  = al + be.^2 ./ al;
F(idx) = al(idx);

x1 = -F./(2*E) + sqrt( F.^2 ./ (4*E.^2) + (C./E) );
y1 = - be./al .* x1;
y1(idx) = -x1(idx);

x2 = -F./(2*E) - sqrt( F.^2 ./ (4*E.^2) + (C./E) );
y2 = - be./al .* x2;
y2(idx) = -x2(idx);

% z1 = x1 + 1i*y1;
% z2 = x2 + 1i*y2;

xx1 = zeros(size(al));
yy1 = zeros(size(al));
xx2 = zeros(size(al));
yy2 = zeros(size(al));

idx       = al>0;
xx1(idx)  = x1(idx);
xx1(~idx) = x2(~idx);
xx2(idx)  = x2(idx);
xx2(~idx) = x1(~idx);
yy1(idx)  = y1(idx);
yy1(~idx) = y2(~idx);
yy2(idx)  = y2(idx);
yy2(~idx) = y1(~idx);

z1 = xx1 + 1i*yy1;
z2 = xx2 + 1i*yy2;
