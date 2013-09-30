function z = iterat_char_eqn(A,B,C, ga, z, N)
for i=1:N
  z = char_it_F(A,B,C, ga, z);
end
end
