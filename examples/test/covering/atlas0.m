classdef atlas0 < AtlasBase
  %ATLAS0  Baisc 0d atlas code.
  
  methods (Access=private) % constructor
    
    function atlas = atlas0(prob, dim)
      assert(dim==0, '%s: wrong manifold dimension', mfilename);
      atlas = atlas@AtlasBase(prob);
    end
    
  end
  
  methods (Static=true) % static construction method
    
    function [prob cont atlas] = create(prob, cont, dim)
      atlas = atlas0(prob, dim);
    end
    
  end
  
  methods % interface methods
    
    function [prob atlas cseg correct] = init_prcond(atlas, prob, chart)
      chart.R       = 0;
      chart.pt      = -1;
      chart.pt_type = 'IP';
      chart.ep_flag = 1;
      cseg          = CurveSegmentBase(prob, chart, true);
      correct       = true;
    end
    
    function [prob atlas cseg flush] = init_atlas(atlas, prob, cseg)
      chart         = cseg.curr_chart;
      chart.pt      = 0;
      chart.pt_type = 'EP';
      chart.ep_flag = 1;
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist   = { chart };
      flush         = true;
    end
    
    function [prob atlas cseg accept] = flush(atlas, prob, cseg)
      [prob atlas cseg] = atlas.flush@AtlasBase(prob, cseg);
      accept            = true;
    end
    
    function [prob atlas cseg flush] = add_chart(atlas, prob, cseg)
      error('%s: this function should never be called', mfilename);
    end
    
    function [prob atlas cseg correct] = predict(atlas, prob, cseg)
      error('%s: this function should never be called', mfilename);
    end
    
  end
  
end