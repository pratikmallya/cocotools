function bd = coco(varargin)
%COCO  Top-level entry point to continuation toolboxes.
% 
%   BD = COCO([OPTS,] RUN, TOOLBOX, IST, ST, TBARGS, PARARGS, CONTARGS)
%   is the main wrapper for the continuation package. This call initiates
%   the continuation of solutions of a type as defined by TOOLBOX. RUN is a
%   unique name assigned to the results produced during the continuation.
%   IST specifies the type of the initial solution and ST the type of
%   solutions to be continued from the starting point of type IST. COCO
%   initialises an options structure used by all continuation toolboses and
%   some variables and then calls the entry function to TOOLBOX. The name
%   of this function is defined as SPRINTF('%s_%s2%s',TOOLBOX,IST,ST). All
%   remaining arguments after ST are passed to this entry function. The
%   optional first argument OPTS is an options structure created with
%   coco_set. This argument allows to adjust the behaviour of the
%   algorithms.
%
%   See also: coco_set
%

% Copyright (C) 2007-2008 Frank Schilder, Harry Dankowicz
% $Id: coco.m 2249 2012-08-29 17:07:39Z fschild $

%% clean up after interrupted or crashed session

cleanup = coco_cleanup();
cleanup.call(@coco_clear_cache);
ptrs = coco_func_data.pointers('copy');
cleanup.call(@coco_func_data.pointers, 'set', ptrs);

%% process input arguments
%  varargin = { [opts], runid, [], ... }
%  varargin = { [opts], runid, @tbxctor, ... }
%  varargin = { [opts], runid, toolbox, fromST, toST, ... }

p = coco_stream(varargin{:});

if isstruct(p.peek)
	opts = p.get;
elseif isempty(p.peek)
  p.skip;
  opts = coco_set();
else
  opts = coco_set();
end

runid   = p.get;
Toolbox = p.get;

if isempty(Toolbox)
  Toolbox = 'empty';
  TbxCtor = @empty_ctor;
  from_st = '';
  to_st   = '';
elseif isa(Toolbox, 'function_handle')
  TbxCtor = Toolbox;
  Toolbox = func2str(Toolbox);
  from_st = '';
  to_st   = '';
else
  from_st = p.get;
  to_st   = p.get;
  cfname  = sprintf('%s_%s2%s', Toolbox, from_st, to_st);
  TbxCtor = str2func(cfname);
end

%% create and clean data directory
copts = get_settings(opts);
if ischar(runid)
  data_dir = fullfile(copts.data_dir, runid);
else
  data_dir = fullfile(copts.data_dir, runid{:});
end

if ~exist(data_dir, 'dir')
	[status,msg,msgid]=mkdir(data_dir); %#ok<NASGU,ASGLU>
  if ~exist(data_dir, 'dir')
    error('%s: could not create directory ''%s''\n%s: %s', ...
      mfilename, data_dir, mfilename, msg);
  end
end

if copts.CleanData
	delete(fullfile(data_dir, '*.mat'));
	delete(fullfile(data_dir, 'coco_*.txt'));
end

%% create run data and message logging information

run.runid     = runid;
run.toolbox   = Toolbox;
run.tbxctor   = TbxCtor;
run.isol_type = from_st;
run.sol_type  = to_st;
run.dir       = data_dir;
run.bdfname   = fullfile(data_dir, 'bd.mat');
run.logname   = fullfile(data_dir, 'coco_log.txt');
run.loghan    = fopen(run.logname, 'w');
cleanup.fclose(run.loghan);
run.scrname   = fullfile(data_dir, 'coco_scr.txt');
run.scrhan    = fopen(run.scrname, 'w');
cleanup.fclose(run.scrhan);
if copts.LogLevel(1)>0
  run.logPrioMN = copts.LogLevel(1);
  if numel(copts.LogLevel)>=2
    run.scrPrioMN = copts.LogLevel(2);
  else
    run.scrPrioMN = 1;
  end
else
  run.logPrioMN = 0;
  run.scrPrioMN = 0;
end
opts.run      = run;

coco_log(opts, 2, copts.LogLevel, ...
  '%s: entering ''coco'', start building problem\n', mfilename);

opts = coco_add_signal(opts, 'save_bd', 'coco');
opts = coco_add_slot(opts, 'run', @save_run, [], 'save_bd');

%% call constructor of toolbox
coco_log(opts, 2, copts.LogLevel, ...
  '%s: calling constructor of top-level toolbox ''%s''\n', mfilename, Toolbox);
opts = run.tbxctor(opts, '', p);

%% call constructor of continuer
coco_log(opts, 2, copts.LogLevel, ...
  '%s: calling constructor of covering toolbox ''%s''\n', mfilename, func2str(copts.ContAlg));
opts = copts.ContAlg(opts, p);
opts = coco_add_slot(opts, 'bd', @save_bd, [], 'save_bd');

%% check that all arguments were used
if numel(p)>0
	error('%s: too many arguments', mfilename);
end

%% call entry function of continuer
%  the call to save is necessary to eliminate side-effects caused by
%  using handle-classes like coco_func_data as part of the opts structure
coco_log(opts, 2, copts.LogLevel, ...
  '%s: construction finished\n\n', mfilename);
fhan = coco_log(opts, 1, copts.LogLevel);
if ~isempty(fhan)
  coco_print_opts(fhan, opts);
  fprintf(fhan, '\n');
  coco_print_funcs(fhan, opts);
  fprintf(fhan, '\n');
  coco_print_slots(fhan, opts);
  fprintf(fhan, '\n');
  coco_print_sigs(fhan, opts);
  fprintf(fhan, '\n');
end
coco_log(opts, 2, copts.LogLevel, ...
  '%s: entering finite state machine\n', mfilename);
coco_log(opts, 1, copts.LogLevel, '%s\n', ...
  '*********************************************************************');
try
  % opts = coco_save_funcs(opts);
  opts = opts.cont.run(opts);
  coco_log(opts, 2, copts.LogLevel, ...
    '\n%s: computation finished successfully\n', mfilename);
catch err
  coco_log(opts, 2, copts.LogLevel, ...
    '\n%s: computation finished with error\n', mfilename);
  coco_log(opts, 1, copts.LogLevel, 'error: %s\n', err.message);
  rethrow(err);
end

%% return bifurcation diagram
if nargout==1
  bd = opts.bd;
end

end

%%
function copts = get_settings(opts)
copts             = coco_get(opts, 'coco');
defaults.ContAlg  = 'covering';
copts             = coco_merge(defaults, copts);
if ischar(copts.ContAlg)
  cfname         = sprintf('%s_create', copts.ContAlg);
  copts.ContAlg  = str2func(cfname);
end
end

%%
function opts = empty_ctor(opts, fid, varargin) %#ok<INUSD>
end

function [data res] = save_run(opts, data)
res = opts.run;
end

function [data res] = save_bd(opts, data)
res = opts.bd;
end
