function opts = save_reduced(opts, chart)
%CONT_SAVE_REDUCED  Save reduced amount of data for labelled solution.
%
%   OPTS = CONT_SAVE_REDUCED(OPTS) saves a reduced amount of data for a
%   labelled solution that is not a restart solution. This data should be a
%   subset of the data saved with CONT_SAVE_FULL. This function calls
%   OPTS.CONT.SAVE_REDUCED to obtain a list of additional class names that
%   should be saved. If this list is empty (default), this function saves
%   nothing.
%
%   See also: cont_save_full, coco_set, coco_opts
%

fname = fullfile(opts.run.dir, sprintf('sol%d', chart.lab));
run   = opts.run; %#ok<NASGU>
[opts fids data] = coco_emit(opts, 'save_reduced', chart);
data  = [ fids data ]; %#ok<NASGU>

version = {1 'reduced'}; %#ok<NASGU>
save(fname, 'version', 'run', 'data');
