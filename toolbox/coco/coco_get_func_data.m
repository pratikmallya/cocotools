function varargout = coco_get_func_data(opts, fid, varargin)

efunc     = opts.efunc;
varargout = {};
idx       = find(strcmpi(fid, ['efunc' efunc.identifyers]), 1)-1;
if isempty(idx)
  error('%s: could not find function with identifyer ''%s''', mfilename, fid);
else
  if idx
    func = efunc.funcs(idx);
    for oarg = 1:nargin-2
      switch lower(varargin{oarg})
        case 'cdata' % chart data
          varargout = [ varargout { func.data.cdata } ]; %#ok<AGROW>
        case 'data'  % toolbox data
          if isa(func.data, 'coco_func_data')
            varargout = [ varargout { func.data.protect() } ]; %#ok<AGROW>
          else
            varargout = [ varargout { func.data } ]; %#ok<AGROW>
          end
        case {'xidx' 'uidx'} % position of x0 and t0 in full solution vector
          varargout = [ varargout { func.x_idx(:) } ]; %#ok<AGROW>
        case 'fidx'  % position of F(x) in zero function
          varargout = [ varargout { func.f_idx(:) } ]; %#ok<AGROW>
        case 'midx'  % position of F(x) in monitor function
          varargout = [ varargout { func.m_idx(:) } ]; %#ok<AGROW>
        case {'x0' 'u0'}  % initial solution point of toolbox
          varargout = [ varargout { efunc.x0(func.x_idx) } ]; %#ok<AGROW>
        case 't0'    % initial tangent of toolbox
          varargout = [ varargout { efunc.tx(func.x_idx) } ]; %#ok<AGROW>
        otherwise
          error('%s: unknown function data field ''%s''', ...
            mfilename, varargin{oarg});
      end
    end
  else
    for oarg = 1:nargin-2
      switch lower(varargin{oarg})
        case {'x0' 'u0'} % full solution vector constructed so far
          varargout = [ varargout { efunc.x0 } ]; %#ok<AGROW>
        case {'xidx' 'uidx'} % indices of full solution vector constructed so far
          varargout = [ varargout { 1:numel(efunc.x0) } ]; %#ok<AGROW>
        case 't0' % full initial tangent vector constructed so far
          varargout = [ varargout { efunc.tx } ]; %#ok<AGROW>
        case 'pidx' % continuation parameters
          assert(isfield(efunc, 'p_idx'), ...
            '%s: cannot extract %s, equations not closed', ...
            varargin{oarg}, mfilename);
          varargout = [ varargout { efunc.p_idx(:) } ]; %#ok<AGROW>
        otherwise
          error('%s: unknown function data field ''%s''', ...
            mfilename, varargin{oarg});
      end
    end
  end
end
