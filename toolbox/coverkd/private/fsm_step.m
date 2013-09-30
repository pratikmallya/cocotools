function [opts] = fsm_step(opts)
%COCO_CONT_STEP  Dispatch call to current state in finite-state machine.

%% get field names

fsm   = opts.cont.continuer;
state = opts.cont.state;
bcb   = sprintf('fsm_bcb_%s', state);
ecb   = sprintf('fsm_ecb_%s', state);

%% execute state and call back functions

opts  = coco_emit(opts, bcb);  % begin call back
opts  = opts.(fsm).(state) (opts); % execute state
opts  = coco_emit(opts, ecb);  % end call back
