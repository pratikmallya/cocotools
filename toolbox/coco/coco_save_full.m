function opts = coco_save_full(opts, chart, chart1)
%CONT_SAVE_FULL  Save restart data for labelled solution.
%
%   OPTS = CONT_SAVE_FULL(OPTS) saves restart data for a labelled solution.
%   This data usually contains the solution, tangent vector and a toolbox
%   identifyer. This function calls OPTS.CONT.SAVE_FULL to obtain a list of
%   additional class names that should be saved.
%
%   See also: cont_save_reduced, coco_set, coco_opts
%

if nargin<=2
  chart1 = struct();
end

fname   = fullfile(opts.run.dir, sprintf('sol%d', chart.lab));
run     = opts.run; %#ok<NASGU>
[opts fids data] = coco_emit(opts, 'save_full', chart, chart1);
data    = [ fids data ]; %#ok<NASGU>
fdata   = [ opts.efunc.identifyers' { opts.efunc.funcs(:).x_idx }' ]; %#ok<NASGU>
version = {1 'full'}; %#ok<NASGU>
save(fname, 'version', 'run', 'data', 'chart', 'chart1', 'fdata');
