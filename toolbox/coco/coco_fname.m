function [fname flag] = coco_fname(runid, fname)

flag = true;

if ischar(runid)
  run_dir = runid;
else
  run_dir = fullfile(runid{:});
end

if ~exist(run_dir, 'dir')
  run_dir = fullfile('data', run_dir);
end

if ~exist(run_dir, 'dir')
  flag = false;
  if nargout<2
    if ischar(runid)
      runid_str = sprintf('''%s''', runid);
    else
      if numel(runid)>1
        runid_str = sprintf(',''%s''', runid{2:end});
      else
        runid_str = '';
      end
      runid_str = sprintf('{''%s''%s}', runid{1}, runid_str);
    end
    error('%s: run %s not found', mfilename, runid_str);
  end
  return
end

fname = fullfile(run_dir, fname);
if ~exist(fname, 'file')
  flag = false;
  if nargout<2
    error('%s: %s: file not found', mfilename, fname);
  end
end

end
