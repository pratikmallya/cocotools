function [soldata chart run chart1] = coco_read_solution(fid, runid, lab, varargin)
persistent cache

if nargin==0
  % clear cache and exit
  cache = [];
  return
end

sfname = sprintf('sol%d.mat', lab);
sfname = coco_fname(runid, sfname);

lst = dir(sfname);
if isempty(cache) || ~strcmp(sfname,cache.sfname) || cache.datenum<lst.datenum
  cache.sfname  = sfname;
  cache.datenum = lst.datenum;
  cache.vars    = who('-file', sfname);
  cache.cont    = load(sfname);
end

vars = cache.vars;
if any(strcmp('version', vars))
  version = cache.cont.version;
  switch version{1}
    case 1
      [soldata chart run chart1] = read_sol_v1(cache, fid, ...
        version{2}, varargin);
    otherwise
      error('%s: unknown format of solution file', mfilename);
  end
else
  [soldata chart run chart1] = read_sol_v0(cache, fid);
end

end

function [soldata chart run chart1] = read_sol_v1(cache, fid, ...
  format, varargin)

extract_xp = true;

argidx = 1;
while argidx<nargin-3 && ischar(varargin{1})
  switch lower(varargin{argidx})
    case 'no-extract-xp'
      extract_xp = false;
      argidx = argidx+1;
    otherwise
      break;
  end
end
if argidx<nargin-3
  error('%s: unknown option(s) passed as argument(s)', mfilename);
end

switch format
  case 'full'
    % save(fname, 'version', 'run', 'data', ['chart', 'chart1', 'fdata'])
    run    = cache.cont.run;
    data   = cache.cont.data;
    chart  = cache.cont.chart;
    chart1 = cache.cont.chart1;
    fdata  = cache.cont.fdata;
    if isempty(fid)
      soldata = data;
    else
      if isempty(data)
        soldata = data;
      else
        soldata = coco_slot_data(fid, data);
      end
      if extract_xp
        xidx = coco_slot_data(fid, fdata);
        if ~isempty(xidx)
          chart.x  = chart.x(xidx);
          if isfield(chart, 't')
            chart.t = chart.t(xidx);
          end
          if isfield(chart, 'TS')
            chart.TS = chart.TS(xidx,:);
          end
          
          if isfield(chart1, 'x')
            chart1.x = chart1.x(xidx);
          end
          if isfield(chart1, 't')
            chart1.t = chart1.t(xidx);
          end
          if isfield(chart1, 'TS')
            chart1.TS = chart1.TS(xidx,:);
          end
        end
      end
    end
    
  case 'reduced'
    % save(sfname, 'run', 'data');
    run  = cache.cont.run;
    data = cache.cont.data;
    if isempty(fid) || isempty(data)
      soldata = data;
    else
      soldata = coco_slot_data(fid, data);
    end
    chart  = struct();
    chart1 = struct();
end
end

function [soldata chart run chart1] = read_sol_v0(cache, fid)
% save(fname, 'data', 'sol', 'run', ['pt0'])
vars = cache.vars;
if any(strcmp('pt0', vars))
  % load(sfname, 'data', 'sol', 'run', 'pt0');
  run    = cache.cont.run;
  data   = cache.cont.data;
  chart  = cache.cont.sol;
  chart1 = cache.cont.pt0;
else
  % load(sfname, 'data', 'sol', 'run');
  run    = cache.cont.run;
  data   = cache.cont.data;
  chart  = cache.cont.sol;
  chart1 = struct();
end
if isempty(fid) || isempty(data)
  soldata = data;
else
  soldata = coco_slot_data(fid, data);
end
end
