classdef atlas_0d_min < AtlasBase
  
  methods % constructor
    
    function atlas = atlas_0d_min(opts, dim)
      if(dim~=0)
        error('%s: wrong manifold dimension dim=%d, expected dim=0', ...
          mfilename, dim);
      end
      atlas = atlas@AtlasBase(opts, dim);
    end
    
  end
  
  methods (Static=true) % static construction method
    
    function [opts cont atlas] = create(opts, cont, dim)
      atlas = atlas_0d_min(opts, dim);
    end
    
  end
  
  methods % interface methods
    
    function [opts atlas chart accept] = init_chart(atlas, opts, chart)
      % Initialize boundary chart
      chart.R  = 0;
      chart.TS = nan(numel(chart.x),0);
      chart.t  = nan(numel(chart.x),1);
      chart.pt = -1;
      chart.s  = [];
      chart.pt_type = 'IP';
      chart.ep_flag = 1;
      
      % demand correction of initial point
      accept = false;
    end
    
    function [opts atlas cseg] = init_update_chart(atlas, opts, cseg)
      cseg.curr_chart.TS = nan(numel(cseg.curr_chart.x),0);
      cseg.curr_chart.t  = nan(numel(cseg.curr_chart.x),1);
      cseg.curr_chart.pt = cseg.curr_chart.pt + 1;
    end
    
    function [opts atlas cseg accept] = init_atlas(atlas, opts, cseg)
      % Insert chart in point list and flush.
      chart         = cseg.curr_chart;
      chart.pt_type = 'EP';
      chart.ep_flag = 1;
      cseg.ptlist   = { chart };
      
      % flush initial chart
      accept = true;
    end
    
    function [opts atlas cseg accept] = flush(atlas, opts, cseg)
      % Flush curve segment.
      [opts atlas cseg accept] = atlas.flush@AtlasBase(opts, cseg); %#ok<NASGU>
      
      % Always stop FSM.
      accept = true;
    end
    
    function [opts atlas cseg accept] = add_chart(atlas, opts, cseg) %#ok<STOUT>
      error('%s: this function should never be called', mfilename);
    end
    
    function [opts atlas cseg] = predict(atlas, opts, cseg)
      error('%s: this function should never be called', mfilename);
    end
    
  end
  
end
