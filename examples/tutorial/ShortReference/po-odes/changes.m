% Changes since curve04:
%-----------------------
%
% changed zero problem to f^q(x,p)-x
% detection of codim-one bifurcations of maps
% branch-switching at PD points
%
% Changes since curve03:
%-----------------------
%
% created parser for branch-switching at branch point
%
% new toolbox file(s):
%   curve_BP2sol.m : parser for branch-switching at BP point
%
% modified demo file(s):
%   demo_ode1.m : added run for branch-switching at BP
%
%
% Changes since curve02.m:
%-------------------------
%
% created separate toolbox and example files
%
% toolbox files:
%   curve_create.m   : constructor
%   curve_isol2sol.m : parser for start from initial point
%   curve_sol2sol.m  : parser for re-start from saved point
%
% demo files:
%   demo_circ.m : computation of circle
%   demo_ode1.m : bifurcation diagram of ODE (1)
%   demo_csec.m : computation of cone section
