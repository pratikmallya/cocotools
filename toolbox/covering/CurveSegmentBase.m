classdef CurveSegmentBase
  
  properties % public properties
    
    % chart list of current curve segment, all charts in ptlist will be
    % included in the bifurcation diagram (point list)
    % ptlist{  1} must be base chart of curve segment
    % ptlist{end} must be end chart of curve segment
    ptlist = {}
    
    % flag indicating whether this is a first segment of a branch
    % this flag will trigger printing of a headline in flush
    isInitialSegment = false
    
    % copy of chart used for initialising new charts, this property is
    % changed by the FSM:
    % during construction of ptlist : src_chart = ctor arg
    % during event location         : src_chart = ptlist{end}
    src_chart = []
    
    % workig copy of current chart, may be modified by FSM and all
    % embedded functions of efunc
    curr_chart = []
    
    % flag indicating state of curce segment, see constants below
    Status = CurveSegmentBase.CurveSegmentOK
    
  end
  
  properties (Constant = true)
    % states a curve segment can be in
    CurveSegmentOK        = 0;
    CurveSegmentCorrupted = 1;
    CorrectionFailed      = 2;
    BoundaryPoint         = 3;
    TerminalEventDetected = 4;
    % list of properties to be removed when initialising a new chart
    rmProps = {'p' 'e'}
  end
  
  methods % constructor
    
    function cseg = CurveSegmentBase(opts, chart, init_flag)
      if isfield(chart, 'rmProps')
        chart.rmProps = union(cseg.rmProps, setdiff(chart.rmProps, {'rmProps'}));
      else
        chart.rmProps = cseg.rmProps;
      end
      cseg.isInitialSegment = init_flag;
      cseg.src_chart        = chart;
      cseg.curr_chart       = cseg.init_chart_from(opts, chart);
    end
    
    function chart = init_chart_from(cseg, opts, chart) %#ok<MANU>
      assert(~isempty(chart), '%s: empty source chart', mfilename);
      
      chart.pt_type    = '';
      chart.ep_flag    = 0;
      chart.ignore_at  = false;
      chart.ignore_evs = [];
      chart.t          = nan(size(chart.x));
      
      chart = rmfield(chart, intersect(fieldnames(chart), chart.rmProps));
      
      new_cdata = cell(size(chart.private.data));
      for i=1:size(new_cdata,1)
        fid     = opts.cfunc.identifiers{i};
        cp_func = opts.cfunc.funcs(i).F;
        data    = opts.cfunc.funcs(i).data;
        cdata   = chart.private.data{i,2};
        new_cdata{i,1} = fid;
        [data new_cdata{i,2}] = cp_func(opts, data, chart, cdata);
        opts.cfunc.funcs(i).data = data;
      end
      chart.private.data = new_cdata;
    end
    
    function chart = new_chart(cseg, opts, chart)
      if nargin>=3
        chart = cseg.init_chart_from(opts, chart);
      else
        chart = cseg.init_chart_from(opts, cseg.src_chart);
      end
    end
    
  end
  
  methods (Static)
    
    function [opts data] = add_prcond(opts, dim)
      opts = coco_add_signal(opts, 'update',    mfilename);
      opts = coco_add_signal(opts, 'set_mode',  mfilename);
      opts = coco_add_signal(opts, 'update_h',  mfilename);
      opts = coco_add_signal(opts, 'fix_mfunc', mfilename);
      
      data = struct('dim', dim, 'mode', 0, ...
        'x', [], 'TS', [], 's', [], 'h', []);

      data = coco_func_data(data);
      opts = coco_add_func(opts, 'cseg.prcond', ...
        @CurveSegmentBase.prcond_F, @CurveSegmentBase.prcond_DFDX, ...
        data, 'zero', 'xidx', 'all');
      
      opts = coco_add_slot(opts, 'cseg.update', ...
        @CurveSegmentBase.update, data, 'update');
      opts = coco_add_slot(opts, 'cseg.set_mode', ...
        @CurveSegmentBase.set_mode, data, 'set_mode');
      opts = coco_add_slot(opts, 'cseg.update_h', ...
        @CurveSegmentBase.update_h, data, 'update_h');
      opts = coco_add_slot(opts, 'cseg.fix_mfunc', ...
        @CurveSegmentBase.fix_mfunc, data, 'fix_mfunc');
      
      opts = coco_add_slot(opts, 'cseg.remesh', ...
        @CurveSegmentBase.remesh, data, 'remesh');
    end
    
    function [data f] = prcond_F(opts, data, u)  %#ok<INUSD>
      
      switch data.mode
        
        case 0 % initialise f for coco_add_func
          f = zeros(data.dim,1);
          
        case 1 % projection condition
          f = data.TS*(u-data.u0) - data.s*data.h;
          
        case 2 % fix embedded test function along curve segment
          f = u(data.fixpar_idx) - data.fixpar_val;
          TSjj = data.TS(data.jj,:);
          for j=data.j
            f = [f; (data.TS(j,:)-data.ss(j)*TSjj)*(u-data.u0)]; %#ok<AGROW>
          end
          
      end
      
    end
    
    function [data J] = prcond_DFDX(opts, data, u) %#ok<INUSD>
      
      switch data.mode
        
        case 0
          J = sparse(data.dim, numel(u));
          
        case 1
          J = data.TS;
          
        case 2
          J    = sparse(1, data.fixpar_idx, 1, 1, numel(u));
          TSjj = data.TS(data.jj,:);
          for j=data.j
            J = [ J ; data.TS(j,:)-data.ss(j)*TSjj ]; %#ok<AGROW>
          end
          
      end
      
    end
    
    function data = update(opts, data, cseg, varargin) %#ok<INUSD>
      data.u0 = cseg.prcond.x;
      data.TS = cseg.prcond.TS';
      data.s  = cseg.prcond.s;
      data.h  = cseg.prcond.h;
      
      [data.ss data.jj] = max(abs(data.s));
      data.ss           = data.s/data.s(data.jj);
      data.j            = setdiff(1:data.dim, data.jj);
      
      data.mode = 1;
    end
    
    function data = set_mode(opts, data, mode, varargin) %#ok<INUSD>
      switch lower(mode)
        case {'init' 'check_res'}
          data.mode = 0;
        case 'prcond'
          data.mode = 1;
        case 'fix_mfunc'
          data.mode = 2;
      end
    end
    
    function data = update_h(opts, data, h, varargin) %#ok<INUSD>
      data.h    = h;
      data.mode = 1;
    end
    
    function data = fix_mfunc(opts, data, mf_idx, mf_val, varargin) %#ok<INUSD>
      data.fixpar_idx = mf_idx;
      data.fixpar_val = mf_val;
      data.mode       = 2;
    end
    
    function data = remesh(opts, data, varargin) %#ok<INUSD>
      % set projection condition back to init mode so that change_func
      % succeeds when called in coco_remesh
      data.mode = 0;
    end
    
  end
  
end
