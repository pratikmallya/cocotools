function [y]=seir(xx,pp)
% p = [be0 de mu al ga]

be0 = pp(1,:);
de  = pp(2,:);
mu  = pp(3,:);
al  = pp(4,:);
ga  = pp(5,:);

S  = exp(xx(1,:));
E  = exp(xx(2,:));
I  = exp(xx(3,:));
st = xx(4,:);
ct = xx(5,:);

T1 = be0.*(1+de.*ct).*S.*I;

y(1,:) = mu-mu.*S-T1;
y(2,:) = T1-(mu+al).*E;
y(3,:) = al.*E-(mu+ga).*I;

% Harmonic oscillator
ss     = st.*st+ct.*ct;
y(4,:) =  st + ct - st.*ss;
y(5,:) = -st + ct - ct.*ss;
