classdef atlas1_3b < AtlasBase
  %ATLAS1_3b  Implements step size control.
  
  properties (Access=private)
    base_chart = struct();
    cont       = struct();
  end
  
  methods (Access=private)
    function atlas = atlas1_3b(prob, cont, dim)
      assert(dim==1, '%s: wrong manifold dimension', mfilename);
      atlas      = atlas@AtlasBase(prob);
      atlas.cont = atlas.get_settings(cont);
    end
  end
  
  methods (Static)
    function [prob cont atlas] = create(prob, cont, dim)
      atlas = atlas1_3b(prob, cont, dim);
      prob  = CurveSegment.add_prcond(prob, dim);
    end
  end
  
  methods (Static, Access=private)
    function cont = get_settings(cont)
      defaults.h     = 0.1 ; % continuation step size
      defaults.PtMX  = 50  ; % number of continuation steps
      defaults.theta = 0.5 ; % step size of theta method
      defaults.hmax  = 0.1 ; % maximum step size
      defaults.hmin  = 0.01; % minimum step size
      defaults.hfinc = 1.1 ; % step size magnification factor
      defaults.hfred = 0.5 ; % step size reduction factor
      defaults.almax = 10  ; % desired bound on angle
      cont           = coco_merge(defaults, cont);
      cont.almax     = cont.almax*pi/180;
    end
  end
  
  methods (Access=public)
    
    function [prob atlas cseg correct] = init_prcond(atlas, prob, chart)
      chart.R       = 0;
      chart.pt      = -1;
      chart.pt_type = 'IP';
      chart.ep_flag = 1;
      [prob cseg]   = CurveSegment.create_initial(prob, chart);
      correct       = cseg.correct;
    end
    
    function [prob atlas cseg flush] = init_atlas(atlas, prob, cseg)
      chart           = cseg.curr_chart;
      chart.R         = atlas.cont.h;
      chart.s         = sign(atlas.cont.PtMX);
      atlas.cont.PtMX = abs(atlas.cont.PtMX);
      chart.pt        = 0;
      chart.pt_type   = 'EP';
      chart.ep_flag   = 1;
      [prob cseg]     = cseg.add_chart(prob, chart);
      flush           = true;
    end
    
    function [prob atlas cseg accept] = flush(atlas, prob, cseg)
      [prob atlas cseg accept] = atlas.flush@AtlasBase(prob, cseg);
      if accept == cseg.CurveSegmentOK
        atlas.base_chart = cseg.ptlist{end};
        accept = (atlas.base_chart.pt>=atlas.cont.PtMX);
      end
    end
    
    function [prob atlas cseg correct] = predict(atlas, prob, cseg)
      chart  = atlas.base_chart;
      prcond = struct('x', chart.x, 'TS', chart.TS, 's', chart.s, 'h', chart.R);
      th     = atlas.cont.theta;
      if th>=0.5 && th<=1
        x1          = chart.x+(th*chart.R)*(chart.TS*chart.s);
        [prob cseg] = CurveSegment.create(prob, chart, prcond, x1);
        [prob ch2]  = cseg.update_TS(prob, cseg.curr_chart);
        h           = abs(ch2.TS'*(x1-chart.x))/th;
        x1          = chart.x + h*(ch2.TS*chart.s);
        prcond      = struct('x', chart.x, 'TS', ch2.TS, 's', chart.s, 'h', h);
      else
        x1          = chart.x+chart.R*(chart.TS*chart.s);
      end
      [prob cseg] = CurveSegment.create(prob, chart, prcond, x1);
      correct     = true;
    end
    
    function [prob atlas cseg flush] = add_chart(atlas, prob, cseg)
      chart    = cseg.curr_chart;
      chart.pt = chart.pt + 1;
      if chart.pt >= atlas.cont.PtMX
        chart.pt_type = 'EP';
        chart.ep_flag = 1;
      end
      [prob cseg] = cseg.add_chart(prob, chart);
      flush       = true;

      al = subspace(cseg.ptlist{1}.TS, cseg.ptlist{end}.TS);
      R  = atlas.base_chart.R;
      if al>atlas.cont.almax
        if R > atlas.cont.hmin
          atlas.base_chart.R = max(atlas.cont.hfred*R, atlas.cont.hmin);
          flush = false;
        else
          coco_warn(prob, 1, atlas.cont.LogLevel, ...
            '%s: minimum step size reached, angle = %.2e[DEG]\n', ...
            mfilename, 180*al/pi);
        end
      elseif al<=atlas.cont.almax/2
        cseg.ptlist{end}.R = min(atlas.cont.hfinc*R, atlas.cont.hmax);
      end
    end
    
    function [prob atlas cseg predict] = refine_step(atlas, prob, cseg)
      predict = false;
      R       = atlas.base_chart.R;
      if R > atlas.cont.hmin
        atlas.base_chart.R = max(atlas.cont.hfred*R, atlas.cont.hmin);
        predict = true;
      end
    end
    
  end
  
end