function [opts cont atlas] = create(opts, cont, dim)
atlas = atlas1(opts, cont, dim);
cont = atlas.cont;

if atlas.cont.FP
  opts = coco_add_func_after(opts, 'mfunc', @add_test_FP);
end

if atlas.cont.BP
  opts = coco_set(opts, 'lsol', 'det', true);
  opts = coco_add_func(opts, 'atlas.test_BP', @test_BP, ...
    atlas.cont, 'singular', 'atlas_BP', ...
    'xidx', 'all', 'PassChart', 'fdim', 1);
  opts = coco_add_event(opts, 'BP', 'SP', 'atlas_BP', 0);
end
end

function opts = add_test_FP(opts)
if numel(opts.efunc.p_idx)>=1
  opts = coco_add_func(opts, 'atlas.test_FP', @test_FP, ...
    [], 'singular', 'atlas_FP', ...
    'xidx', 'all', 'PassTangent', 'fdim', 1);
  opts = coco_add_event(opts, 'FP', 'SP', 'atlas_FP', 0);
end
end

function [data f] = test_FP(opts, data, x, t) %#ok<INUSL>
f = t(opts.efunc.p_idx(1));
end

function [data chart f] = test_BP(opts, data, chart, x) %#ok<INUSD>
cdata = coco_get_chart_data(chart, 'lsol');
if isfield(cdata, 'det')
  f = cdata.det;
else
  [opts chart] = opts.cseg.tangent_space(opts, chart); %#ok<ASGLU>
  cdata = coco_get_chart_data(chart, 'lsol');
  f = cdata.det;
end
end
