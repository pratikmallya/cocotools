function [opts argnum] = alcont_isol2sol(opts, varargin)
%ALCONT_ISOL2SOL  Start continuation from known solution.
%
%   BD = ALCONT_ISOL2SOL(OPTS, X0, P0, PNUM, PINT) starts a continuation
%   of solutions of algebraic equations F(X,P)=0. Continuation starts at
%   the solution X0 for parameter values P0. The solution is continued with
%   respect to parameter P(PNUM) in the interval PINT(1)<=P(PNUM)<=PINT(1).
%   F is the function passed to COCO as argument NAME. The return value BD
%   is a cell array containing the bifurcation diagram as constructed by
%   COCO.
%
%   Note: The initial guess X0 does not need to be accurate. An initial
%   Netwon iteration is performed to improve X0 before starting the
%   continuation.
%
%   See also: coco, alcont_sol2sol
%

%% process input arguments
%  varargin = { prefix, fhan, [dfdxhan, [dfdphan,]] x0, p0 }

argidx = 1;
prefix = varargin{argidx};

fhan = varargin{argidx+1};
if ~(isa(fhan, 'function_handle') || isempty(fhan))
  error('%s: argument %d must be a function handle (or empty)', ...
    mfilename, argidx+1);
end
if isa(varargin{argidx+2}, 'function_handle')
  dfdxhan   = varargin{argidx+2};
  argidx    = argidx + 1;
else
  if isa(fhan, 'function_handle')
    dfdxname  = sprintf('%s_DFDX', func2str(fhan));
    if exist(dfdxname, 'file')==2 || exist(dfdxname, 'file')==3
      dfdxhan = str2func(dfdxname);
    else
      dfdxhan = [];
    end
  else
    dfdxhan = [];
  end
end
if isa(varargin{argidx+2}, 'function_handle')
  dfdphan   = varargin{argidx+2};
  argidx    = argidx + 1;
else
  if isa(fhan, 'function_handle')
    dfdpname  = sprintf('%s_DFDP', func2str(fhan));
    if exist(dfdpname, 'file')==2 || exist(dfdpname, 'file')==3
      dfdphan = str2func(dfdpname);
    else
      dfdphan = [];
    end
  else
    dfdphan = [];
  end
end

x0       = varargin{argidx+2};
p0       = varargin{argidx+3};
argnum   = argidx + 3;

%% create instance of toolbox alcont

data.F          = fhan;
data.DFDX       = dfdxhan;
data.DFDP       = dfdphan;
data.x_idx      = (1:numel(x0))';
data.p_idx      = numel(x0)+(1:numel(p0))';
data.vectorised = 1;

opts = alcont_create(opts, prefix, data, x0, p0);
