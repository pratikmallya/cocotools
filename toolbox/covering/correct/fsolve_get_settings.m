function [opts corr] = fsolve_get_settings(opts)

corr = coco_get(opts, 'corr');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for Newton's method

defaults.ItMX     = 10      ; % max. number of iterations
defaults.TOL      = 1.0e-8  ; % convergence criterion ||d||<=TOL
defaults.ResTOL   = 1.0e-12 ; % convergence criterion ||f(x)||<=ResTOL
defaults.LogLevel = 1       ; % level of diagnostic output
defaults.opts     = optimset; % options passed to fsolve
defaults.linsolve = 'splu' ; % linear solver

corr = coco_set(defaults, corr);

end
