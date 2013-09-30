function y = char_eqn(A,B,C, z)
y = A.*conj(z).*z + B.*z - C;
end
