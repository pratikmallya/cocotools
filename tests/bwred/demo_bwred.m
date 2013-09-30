% spparms('umfpack', 0);
% spparms('umfpack', 1);

% setup example matrix:

J = ones(3,4);
J = blkdiag(J,J);
J = [J; 2*ones(1,8)];
J = [J 3*ones(7,1)];
J = blkdiag(J,J);
J = [J; zeros(4,18); 4*ones(1,18)];
J = [J 5*ones(19,1)];
J = sparse(J);
[rows cols vals] = find(J);
subplot(2,2,1);
spy(J)

rblocks = [1 3; 4 6;  8 10; 11 13; 15 18];
cblocks = [1 4; 5 8; 10 13; 14 17];
rlist   = [7 14 19];
clist   = [9 18 19];

N         = length(rlist);
new_nrows = N*size(rblocks,1)-1;

for i = 1:size(rblocks,1)-1;
	
end


idx = zeros(size(rows));

for r=rlist
	idx = idx | rows==r;
end
for c=clist
	idx = idx | cols==c;
end


% load('jac_po', 'J', 'b', 'x');

% tic; J\b; toc
% tic; [L,U,P,Q,R] = lu(J); toc
% tic; [L,U,P,Q]   = lu(J); toc
