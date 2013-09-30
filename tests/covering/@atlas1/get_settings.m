function cont = get_settings(cont)
defaults.h      = 0.1    ; % continuation step size
defaults.ItMX   = 100    ; % number of continuation steps
defaults.FP     = true   ; % detect fold points
defaults.BP     = true   ; % detect branch points
defaults.interp = 'cubic'; % use curve segment with qubic interpolation
% defaults.interp = 'linear'; % use curve segment with linear interpolation
cont            = coco_set(defaults, cont);
end
