function opts = coco_add_parameters(varargin)
%COCO_ADD_PARAMETERS   Add external parameters to continuation problem.

fprintf(2, '%s: function will become obsolete, use ''coco_add_pars'' instead.\n', ...
  mfilename);

opts = coco_add_pars(varargin{:});

end

