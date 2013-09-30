% signature=[9 3 8 7 3 10];
% 
% m=1;
% Ff=.7961;
% k=8;
% om=1;
% a=1;
% b=.8471;
% e=.9;
% 
% atilde=k*a/Ff;
% btilde=k*b/Ff;
% Omega=(1+e)*om*sqrt(m/k);
% xstar=(-4-btilde*Omega^2+sqrt(16-24*Omega^2+8*btilde*Omega^2+atilde^2*Omega^4))/Omega^2;
% q0=Ff*xstar/k;
% 
% x = [q0;0;0];
% p = [ m ; Ff ; k ; om ; a ; b ; e ];
% 
% seglist=simulate(x,p,signature);

signature=[9 3 8 7 10];

m=1;
Ff=.7961;
k=5.5;
% k=5.573034039978373;
% k=3.448187236912674;
om=1;
a=1;
b=.8471;
% b=0.661428093236418;
e=.9;

atilde=k*a/Ff;
btilde=k*b/Ff;
Omega=(1+e)*om*sqrt(m/k);
xstar=(4-btilde*Omega^2-sqrt(16-8*Omega^2-8*btilde*Omega^2+atilde^2*Omega^4))/Omega^2;
q0=Ff*xstar/k;

x = [q0;0;0];
p = [ m ; Ff ; k ; om ; a ; b ; e ];

seglist=simulate(x,p,signature);