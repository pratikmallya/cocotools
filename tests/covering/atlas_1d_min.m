classdef atlas_1d_min < AtlasBase

  properties (Access=private)
    base_chart = struct([]);
    cont       = struct([]);
  end
  
  methods % constructor
    
    function atlas = atlas_1d_min(opts, cont, dim)
      if(dim~=1)
        error('%s: wrong manifold dimension dim=%d, expected dim=1', ...
          mfilename, dim);
      end
      atlas      = atlas@AtlasBase(opts, dim);
      atlas.cont = atlas_1d_min.get_settings(cont);
    end
    
  end
  
  methods (Static=true) % static construction method
    
    function [opts cont atlas] = create(opts, cont, dim)
      atlas = atlas_1d_min(opts, cont, dim);
      cont  = atlas.cont;
      
      if atlas.cont.FP
        opts = coco_add_func_after(opts, 'mfunc', @atlas_1d_min.add_test_FP);
      end
      
      if atlas.cont.BP
        opts = coco_set(opts, 'lsol', 'det', true);
        opts = coco_add_func(opts, 'atlas.test_BP', @atlas_1d_min.test_BP, ...
          atlas.cont, 'singular', 'atlas_BP', ...
          'xidx', 'all', 'PassChart', 'fdim', 1);
        opts = coco_add_event(opts, 'BP', 'SP', 'atlas_BP', 0);
      end
    end
    
    function opts = add_test_FP(opts)
      if numel(opts.efunc.p_idx)>=1
        opts = coco_add_func(opts, 'atlas.test_FP', @atlas_1d_min.test_FP, ...
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
    
  end
  
  methods (Static=true, Access = private)
    
    function cont = get_settings(cont)
      defaults.h      = 0.1    ; % continuation step size
      defaults.ItMX   = 100    ; % number of continuation steps
      defaults.FP     = true   ; % detect fold points
      defaults.BP     = true   ; % detect branch points
      defaults.interp = 'cubic'; % use curve segment with qubic interpolation
      % defaults.interp = 'linear'; % use curve segment with linear interpolation
      cont            = coco_merge(defaults, cont);
    end
    
  end
  
  methods % interface methods
    
    function [opts atlas chart accept] = init_chart(atlas, opts, chart)
      % construct initial continuation direction
      if all(chart.t == 0)
        if numel(opts.efunc.p_idx)>=1
          % go in direction of first active parameter
          fp_idx = opts.efunc.p_idx(1);
        else
          % go in direction of last component of x
          fp_idx = opts.efunc.x_idx(end);
        end
        chart.t(fp_idx) = 1;
      end
      
      % Initialize initial chart
      chart.t  = chart.t/norm(chart.t);
      chart.TS = chart.t;
      chart.R  = atlas.cont.h;
      chart.pt = -1;
      if atlas.cont.ItMX >=0
        chart.s =  1;
      else
        chart.s = -1;
      end
      chart.pt_type = 'IP';
      chart.ep_flag = 1;

      % request correction of initial point
      accept = false;
    end
    
    function [opts atlas cseg] = init_update_chart(atlas, opts, cseg)
      % update tangent space TS
      [opts cseg.curr_chart] = cseg.tangent_space(opts, cseg.curr_chart);
      
      % initialise tangent t
      cseg.curr_chart.t = cseg.curr_chart.TS * cseg.curr_chart.s;
      
      % update point count
      cseg.curr_chart.pt = cseg.curr_chart.pt + 1;
    end
    
    function [opts atlas cseg accept] = init_atlas(atlas, opts, cseg)
      % Insert chart in point list and flush.
      chart         = cseg.curr_chart;
      chart.pt_type = 'EP';
      chart.ep_flag = 1;
      cseg.ptlist   = { chart };
      
      % Flush curve segment.
      accept = true;
    end
    
    function [opts atlas cseg accept] = add_chart(atlas, opts, cseg)
      
      % update tangent space TS
      [opts chart] = cseg.tangent_space(opts, cseg.curr_chart);

      % compute tangent t
      [opts chart] = cseg.tangent(opts, chart);
      chart.pt     = chart.pt + 1;
      
      % check if final chart
      if chart.pt >= abs(atlas.cont.ItMX)
        chart.pt_type = 'EP';
        chart.ep_flag = 1;
      end
      
      % add chart to point list
      cseg.ptlist = [ cseg.ptlist chart ];
      
      % accept curve segment
      accept = true;
    end
    
    function [opts atlas cseg] = predict(atlas, opts, cseg) %#ok<INUSD>
      
      % use pseudo arc-length projection condition
      chart      = atlas.base_chart;
      pr_cond.x  = chart.x;
      pr_cond.TS = chart.TS;
      pr_cond.s  = chart.s;
      pr_cond.h  = chart.R;
      
      % construct new curve segment
      % first point new segment = last point old segment
      cseg        = CurveSegment(opts, chart, pr_cond, atlas.cont.interp);
      cseg.ptlist = { chart };
      
      % update curr_chart with predicted point
      cseg.curr_chart.x = chart.x + chart.R*chart.t;
      
    end
    
    function [opts atlas cseg accept] = flush(atlas, opts, cseg)
      % Flush chart to disk and screen output.
      
      % flush point list
      [opts atlas cseg accept] = atlas.flush@AtlasBase(opts, cseg);
      
      if cseg.Status == cseg.CurveSegmentOK
        
        % flush last point into base_chart
        atlas.base_chart = cseg.ptlist{end};
        
        % Stop FSM if accept or It>=ItMX.
        chart  = cseg.ptlist{end};
        accept = accept || (chart.pt>=atlas.cont.ItMX);
        
      end
      
    end
    
  end
  
end