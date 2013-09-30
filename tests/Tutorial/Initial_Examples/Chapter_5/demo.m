echo on
%!tkn1
A = (1:12)'
%!tkn2
A = reshape(A, [2 3 2])
%!tkn3
size(A)
%!tkn4
A = A(:,:)
size(A)
A = A(:)
size(A)
%!tkn5
A = reshape(A, [2 3 2 1 1])
size(A)
%!tkn6
A = A(:,:);
B = A(:,:,[1 1])
%!tkn6b
B = B(:,:)
%!tkn7
repmat(A, [3 1])
%!tkn8
A = [1 2 3; 4 5 6];
kron(ones(2,3), A)
%!tkn9
repmat(A, [2, 3])
%!tkn10
k = 3;
[m n] = size(A);
A = repmat(A, [1 k]);
r = reshape(1:k*m, [m k]);
r = repmat(r, [n 1]);
c = repmat(1:k*n, [m 1]);
sparse(r, c, A)
%!tkn11
full(ans)
%!tkn12
echo off