function [ hh ] = pocont_plot(run, labs, coords, varargin)

if nargout>1
	hh = [];
end

holdstat = ishold;

if ~holdstat
	clf;
	hold on
end

labs = load_all_labels(run, labs);
for lab = labs
	solfname = fullfile('data', run, sprintf('sol%d.mat', lab));
	load(solfname, 'data');
	x = [data.tbp ; data.xbp];
	x = x(coords+1,:);
	switch numel(coords)
		case 2
			h = plot(x(1,:), x(2,:), varargin{:});
		case 3
			h = plot3(x(1,:), x(2,:), x(3,:), varargin{:});
		otherwise
			error('%s: argument coords must contain two or three integers', ...
				mfilename);
	end
	if nargout>1
		hh = [hh h]; %#ok<AGROW>
	end
end

if ~holdstat
	hold off
end

function labs = load_all_labels(run, labs)

if ischar(labs)
	if strcmp(labs, 'all')
		bdfname = fullfile('data', run, 'bd.mat');
		load(bdfname, 'bd');
		labs = [bd{2:end,6}]; %#ok<USENS>
	else
		error('%s: unrecognised value ''%s'' for argument labs', ...
			mfilename, labs);
	end
end

labs = labs(:)';
