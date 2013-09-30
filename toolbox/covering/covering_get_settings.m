function [opts cont] = covering_get_settings(opts)

error('%s: function obsolete', mfilename);

cont = coco_get(opts, 'cont');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for covering algorithm

defaults.MaxRes    = 0.1  ; % max. residuum for prediction step
defaults.al_max    = 7.0  ; % max. angle between two consecutive tangents
defaults.h0        = 0.1  ; % initial continuation step size
defaults.h_max     = 0.5  ; % max. continuation step size
defaults.h_min     = 0.01 ; % min. continuation step size
defaults.h_fac_min = 0.5  ; % min. step size adaption factor
defaults.h_fac_max = 2.0  ; % max. step size adaption factor
defaults.ga        = 0.95 ; % adaption security factor
defaults.ItMX      = 100  ; % max. number of continuation steps
defaults.LogLevel  = [1 0]; % diagnostic output level
defaults.NPR       = 10   ; % diagnostic output every NPR steps
defaults.NSV       = []   ; % save solution every NSV steps, default = NPR
defaults.MEVFac    = 5    ; % tolerance factor for accepting multiple events
defaults.fsm_debug = 'off'; % set breakpoints at each state

defaults.efunc    = 'efunc'; % function defining manifold
defaults.corr     = 'nwtn' ; % corrector toolbox
defaults.covering = []     ; % user-defined covering toolbox

defaults.cseg_classes = { [] 'cover_kd' ; 0 'cover_0d' ; 1 'cover_1d_ct' };

cont = coco_set(defaults, cont);

cont.arc_alpha = cont.al_max * pi / 180;

end
