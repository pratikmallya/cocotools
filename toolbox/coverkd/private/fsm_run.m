function opts = fsm_run(opts, varargin)
%COCO_CONT  Entry point to continuation method.
%
%   OPTS = COCO_CONT(OPTS)
%   OPTS = COCO_CONT(OPTS,INITFLAG) The function COCO_CONT repeatedly calls
%   the function COCO_CONT_STEP which in turn executes the action of the
%   finite-state machine associated with the current state.  The COCO_CONT
%   function accepts (at least) two arguments, where the second argument
%   (when included) specifies whether this is a new run of the function or
%   an already initiated continuation. In the former case, the state of the
%   finite-state machine is set to 'init', whereas it is left unchanged in
%   the latter case.
%
%   To do: Add error handling for the case when compute_events detects
%   events that cannot be handled by handle_event or that should definitely
%   be addressed within a developer's toolbox. This will include adding an
%   'event' property to the 'cont' class.
%
%   See also: coco_cont_step
%

if nargin <= 1 || varargin{1}==1
	opts.cont.state = 'init';
end

opts.cont.accept = 0;

while(~opts.cont.accept)
	opts = fsm_step(opts);
end
