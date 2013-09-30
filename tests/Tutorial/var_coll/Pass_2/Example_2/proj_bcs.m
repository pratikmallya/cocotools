function [data y] = proj_bcs(prob, data, u)

x1 = u(1:3);
x2 = u(4:6);

y = [data.nrm*(x1-data.pt0); data.nrm*(x2-data.pt0)];
  
end