function opts = save_full(opts, sol, pt0)
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
  pt0 = [];
end

fname       = fullfile(opts.run.dir, sprintf('sol%d', sol.lab));
run         = opts.run; %#ok<NASGU>
[opts data] = coco_emit(opts, 'save_full', sol, pt0); %#ok<NASGU>

save(fname, 'data', 'sol', 'run', 'pt0');
