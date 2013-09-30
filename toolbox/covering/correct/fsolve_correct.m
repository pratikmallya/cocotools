function [opts argnum] = fsolve_correct(opts, func, varargin)

%% get toolbox settings
[opts corr] = fsolve_get_settings(opts);

%% process input arguments
argnum = 1;

%% set up functions
corr.F     = opts.(func).F;
corr.DFDX  = opts.(func).DFDX;
corr.solve = @fsolve_solve;
corr.init  = @fsolve_init;
corr.step  = @fsolve_step;

if ~isa(corr.linsolve, 'function_handle')
  corr.linsolve = str2func(sprintf('linsys_%s', corr.linsolve));
end

%% set options for fsolve
corr.opts = optimset(corr.opts, 'Jacobian', 'on'       );
corr.opts = optimset(corr.opts, 'MaxIter' , corr.ItMX  );
corr.opts = optimset(corr.opts, 'TolX'    , corr.TOL   );
corr.opts = optimset(corr.opts, 'TolFun'  , corr.ResTOL);

%% save corrector in opts.corr
opts.corr = corr;

end

%%
function [opts x] = fsolve_solve(opts, x0)

[opts accept x] = fsolve_init(opts, x0);
if ~accept
	[opts accept x] = fsolve_step(opts); %#ok<ASGLU>
end

end

%%
function [opts accept x0] = fsolve_init(opts, x0)

corr = opts.corr;

corr.x = x0;

if corr.LogLevel <= 0
  corr.opts = optimset(corr.opts, 'Diagnostics', 'off'  );
  corr.opts = optimset(corr.opts, 'Display'    , 'off'  );
elseif corr.LogLevel == 1
  corr.opts = optimset(corr.opts, 'Diagnostics', 'off'  );
  corr.opts = optimset(corr.opts, 'Display'    , 'iter' );
else
  corr.opts = optimset(corr.opts, 'Diagnostics', 'on'   );
  corr.opts = optimset(corr.opts, 'Display'    , 'iter' );
end

[opts corr.f] = corr.F(opts, corr.x);
corr.accept   = (norm(corr.f)<opts.corr.ResTOL);

opts.corr = corr;
accept    = corr.accept;

end

%%
function [opts accept x] = fsolve_step(opts)

corr = opts.corr;

corr.opts                = optimset(corr.opts, 'OutputFcn', @OFunc);
msg                      = ''; % set in call output function below
[x fval exitflag output] = fsolve(@func, corr.x, corr.opts); %#ok<ASGLU>
corr.x                   = x;
corr.accept              = ( exitflag ==  1 );

opts.corr = corr;
accept    = corr.accept;

if accept
  opts = coco_emit(opts, 'corr_end', 'fsolve', 'accept', corr.x);
elseif exitflag == -1
  opts = coco_emit(opts, 'corr_end', 'fsolve', 'stop');
	errmsg.identifier = 'CORR:Stop';
	errmsg.message = sprintf('%s: stop requested by slot function\n%s', ...
    mfilename);
	errmsg.FID = 'FSOLVE';
	errmsg.ID  = 'MX';
	error(errmsg);
else
  opts = coco_emit(opts, 'corr_end', 'fsolve', 'fail');
	errmsg.identifier = 'CORR:NoConvergence';
	errmsg.message = output.message;
	errmsg.FID = 'FSOLVE';
	errmsg.ID  = 'MX';
	error(errmsg);
end

  function varargout = func(x)
    if nargout==1
      [opts f] = corr.F(opts, x);
            J  = [];
    else
      [opts f] = corr.F   (opts, x);
      [opts J] = corr.DFDX(opts, x);
    end
    varargout = {f J};
  end

  function stop = OFunc(x, optimValues, state)
    corr = opts.corr;
    
    stop   = false;
    corr.x = x;
    
    switch state
      case 'init'
        opts = coco_emit(opts, 'corr_begin', 'fsolve', ...
          x, optimValues, state);
      case 'interrupt'
        [opts fids stop msg] = coco_emit(opts, 'corr_step', 'fsolve', ...
          x, state, optimValues, state); %#ok<ASGLU>
        stop = cell2mat(stop);
        if ~isempty(stop) && any(stop)
          stop=true;
        else
          stop=false;
        end
    end
    
    opts.corr = corr;
  end
end
