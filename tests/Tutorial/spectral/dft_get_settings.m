function data = dft_get_settings(prob, tbid, data)

defaults.NMAX = 8;
defaults.NMIN = 3;
defaults.NMOD = 3;
if ~isfield(data, 'dft')
  data.dft = [];
end
data.dft = coco_merge(defaults, coco_merge(data.dft, ...
  coco_get(prob, tbid)));

if ~coco_exist('TOL', 'class_prop', prob, tbid, '-no-inherit-all')
  data.dft.TOL = coco_get(prob, 'corr', 'TOL')^(2/3);
end
defaults.TOLINC = data.dft.TOL/5;
defaults.TOLDEC = data.dft.TOL/20;
data.dft = coco_merge(defaults, data.dft);

NMOD = data.dft.NMOD;
assert(numel(NMOD)==1 && isnumeric(NMOD) && mod(NMOD,1)==0, ...
  '%s: input for option ''NMOD'' is not an integer', tbid);
NMAX = data.dft.NMAX;
assert(numel(NMAX)==1 && isnumeric(NMAX) && mod(NMAX,1)==0, ...
  '%s: input for option ''NMAX'' is not an integer', tbid);
NMIN = data.dft.NMIN;
assert(numel(NMIN)==1 && isnumeric(NMIN) && mod(NMIN,1)==0, ...
  '%s: input for option ''NMIN'' is not an integer', tbid);
assert(NMIN<=NMOD && NMOD<=NMAX, ...
  '%s: input violates ''NMIN<=NMOD<=NMAX''', tbid);
end
