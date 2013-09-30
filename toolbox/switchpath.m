function switchpath(v) %#ok<INUSD>

fprintf(2, '%s: warning: this function is obsolete, path not changed\n', mfilename);

return

if nargin<1 %#ok<UNRCH>
  if exist('covering_create', 'file')
    v = 'old';
  else
    v = 'new';
  end
end

cocodir = mfilename('fullpath');
cocodir = fileparts(cocodir);

switch v
  case 'old'
    if exist('covering_create', 'file')
      cpo = cocopath(cocodir, { 'cover1d' 'cover_kd' });
      cpn = cocopath(cocodir, { 'covering' });
      rmpath (cpo{:});
      addpath(cpn{:});
    end
    if nargin<1
      fprintf('coco now uses cover1d\n');
    end
    
  case 'new'
    if ~exist('covering_create', 'file')
      cpo = cocopath(cocodir, { 'covering' });
      cpn = cocopath(cocodir, { 'cover1d' 'cover_kd' });
      rmpath (cpo{:});
      addpath(cpn{:});
    end
    if nargin<1
      fprintf('coco now uses covering\n');
    end
    
  otherwise
    error('%s: unknown version string ''%s''\n', ...
      mfilename, v);
end
