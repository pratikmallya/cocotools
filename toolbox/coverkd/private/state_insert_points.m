function opts = state_insert_points(opts)
%STATE_INSERT_POINT  Insert point into bifurcation diagram.
%
%   OPTS = STATE_INSERT_POINT(OPTS) pops the 'ptlist' to 'sol', saves (if
%   necessary), prints, modifies 'cont.next_lab', and subsequently assigns
%   'sol' to the 'cont' class. The state is subsequently returned to
%   HANDLE_EVENTS. 

%% get current point list

ptlist = opts.cont.ptlist;

%% save point list

for i = 2:numel(ptlist)
	if ptlist{i}.ep_flag==2
		[opts sol] = save_data (opts, ptlist{i}, ptlist{1});
		opts       = print_data(opts, sol);
	else
		[opts sol] = save_data (opts, ptlist{i});
		opts       = print_data(opts, sol);
	end
end

%% next state is update

opts.cont.state = 'update';
