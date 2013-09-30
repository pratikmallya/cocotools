function opts = print_data(opts, sol)
%PRINT_DATA  Save data and print point information to screen.
%
%   OPTS = PRINT_DATA(OPTS) is called whenever a new solution has been
%   computed. If a solution label has been assigned to the current solution
%   point it prints a line with information about the current solution
%   point on screen. This function calls OPTS.CONT.PRINT_DATA to print
%   additional data.
%
%   See also: 
%

%% check if solution info should be printed

if isempty(sol.pt_type) || opts.cont.LogLevel(1) < 1
	return
end
	
%% print solution info on screen

%  compute computation times in hours, minutes and seconds
ctm  = etime(clock, opts.cont.tm);
ctmh = floor(ctm/3600);
ctm  = ctm - 3600*ctmh;
ctmm = floor(ctm/60);
ctm  = ctm - 60*ctmm;
ctms = floor(ctm);

if opts.cont.LogLevel(1) >= 2

	% print extended information
	fprintf('%5d %11.2e  %-5s %6s %*.4e %12.4e  %02d:%02d:%02d', ...
		opts.cont.It, opts.xfunc.h, spt_name(sol.pt_type), ...
		lab_name(sol.pt_type, sol.lab), ...
		opts.cont.pp_width, sol.p(opts.cont.op_idx(1)), ...
		norm(sol.x(opts.cont.xidx)), ctmh, ctmm, ctms);

elseif opts.cont.LogLevel(1) >= 1

	% print normal information
	fprintf('%5d  %-5s %6s %*.4e %12.4e  %02d:%02d:%02d', ...
		opts.cont.It, spt_name(sol.pt_type), ...
		lab_name(sol.pt_type, sol.lab), ...
		opts.cont.pp_width, sol.p(opts.cont.op_idx(1)), ...
		norm(sol.x(opts.cont.xidx)), ctmh, ctmm, ctms);

end

fprintf(opts.cont.op_fmt, sol.p(opts.cont.op_idx(2:end)));

%  print user defined information
opts = coco_emit(opts, 'cont_print', 'data', sol.x);
fprintf('\n');

%% local functions

function [y] = spt_name(x)

switch(x)
	case {'RO', 'ROS'}, y = ' ';
	otherwise,          y =  x ;
end

function [y] = lab_name(ty,lab)

switch(ty)
	case 'ROS', y = sprintf('*%d', lab);
	otherwise,  y = sprintf('%d', lab);
end
