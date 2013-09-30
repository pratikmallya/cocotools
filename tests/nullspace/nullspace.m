function [ x ] = nullspace( A )
% A rectangular (m,n)-matrix with m<n and full row rank.
[L U P]  = lu(A'); %#ok<ASGLU>
L        = L';
b        = L(:,end);
L(:,end) = [];
x        = L\b;
x        = [x;-1];
x        = (P'*x)/norm(x);
end
