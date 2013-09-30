function [data y] = po_eigs(prob, data, u)

M   = data.M{1};
dim = size(M,2);
M0  = full(M(1:dim,:));
M1  = full(M(end-dim+1:end,:));
y   = [eig(M1,M0); condest(data.J)];

end