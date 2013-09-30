function [h term dir] = event(data, x,p,s)
% event functions
h    = data.f0(s,:)*(x-data.x0(:,s));
term = true;
dir  = 1;
end
