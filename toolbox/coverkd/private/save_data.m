function [opts sol] = save_data(opts, pt1, pt0)
%SAVE_DATA   Save point data.
%
%   OPTS = COCO_SAVE_DATA(OPTS) is called whenever a new solution has been
%   computed. COCO_SAVE_DATA checks if a label was or should be assigned to
%   the current solution and calls the appropriate save function if so. It
%   inserts the current solution point into the bifurcation diagram.
%
%   See also: save_full, save_reduced, bddat_insert_point
%

%% we might modify opts, so check that opts gets assigned

if nargout<1
	error('%s: too few output arguments', mfilename);
end

%% save solution point

sol      = pt1;
sol.lab  = [];
next_lab = opts.cont.next_lab;
NSV      = opts.cont.NSV;
if isempty(NSV)
	NSV    = opts.cont.NPR;
end

if isfield(sol, 'pt_type') && ~isempty(sol.pt_type)
	
	% special solution point, full save
	sol.lab   = next_lab;
	next_lab  = next_lab + 1;
	save_func = @save_full;

elseif mod(opts.cont.It, NSV) == 0
	
	% regular output point for restart, full save
	sol.pt_type = 'RO';
	sol.lab     = next_lab;
	next_lab    = next_lab + 1;
	save_func   = @save_full;
	
elseif mod(opts.cont.It, opts.cont.NPR) == 0
	
	% regular output point for plotting, reduced save
	sol.pt_type = 'ROS';
	sol.lab     = next_lab;
	next_lab    = next_lab + 1;
	save_func   = @save_reduced;
	
end

opts.cont.next_lab = next_lab;

%% insert point into opts.bd and save bifurcation diagram

[opts opts.bd] = opts.bddat.insert(opts, opts.bd, sol);

if ~isempty(sol.lab)
	if nargin>2
		opts = save_func(opts, sol, pt0);
	else
		opts = save_func(opts, sol);
	end
	save(opts.run.bdfname, '-struct', 'opts', 'bd', 'run');
end
