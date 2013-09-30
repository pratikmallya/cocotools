function opts = state_correct(opts)
% STATE_CORRECT  Execute correction steps.
%
%   OPTS = STATE_CORRECT(OPTS) executes one step of the corrector (here the
%   COCO_NWTN_STEP function) to the extended left-hand side that includes
%   the pseudo arc-length condition. If the number of newton iterations
%   exceeds 'nwtn.ItMx' the state of the finite-state machine is set to
%   REFINE_STEP. Otherwise, if convergence is not achieved, the state
%   remains at CORRECT. Finally, if convergence is achieved, 'sol.u' is set
%   to the converged state vector, 'sol.p' is set to the current parameter
%   vector, including the converged value for the continuation parameter.
%   Subsequently, the state of the finite-state machine is set to
%   CHECK_SOLUTION.
%
%   To do: Why is the 'func' property of nwtn and LogLevel of nwtn set here
%   and not in state_predict? Fix the .pdf file showing the state machine
%   diagram.
%
%   See also:
%

%% perform one newton iteration
try
	opts = opts.cont.corrector(opts);
catch
	err = lasterror;
	switch err.identifier
		% no convergence
		case 'NWTN:NoConvergence'
			if isempty(opts.cont.err_state)
				error(err);
			else
				opts.cont.state      = opts.cont.err_state;
				opts.cont.err_state  = [];
				opts.cont.next_state = [];
				return
			end
		
		% stop computation with error
		otherwise
			error(err);
	end
end

if opts.nwtn.accept
	opts.cont.state      = opts.cont.next_state;
	opts.cont.err_state  = [];
	opts.cont.next_state = [];
end
