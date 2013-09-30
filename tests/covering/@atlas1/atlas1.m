classdef atlas1 < AtlasBase

  properties (Access=private)
    base_chart = struct();
    cont       = struct();
  end
  
  methods % constructor
    
    function atlas = atlas1(opts, cont, dim)
      if(dim~=1)
        error('%s: wrong manifold dimension dim=%d, expected dim=1', ...
          mfilename, dim);
      end
      atlas      = atlas@AtlasBase(opts, dim);
      atlas.cont = atlas1.get_settings(cont);
    end
    
  end
  
  methods (Static=true) % static construction method
    [opts cont atlas] = create(opts, cont, dim)
  end
  
  methods (Static=true, Access=private)
    cont = get_settings(cont)
  end
  
  methods % interface methods
    [opts atlas chart accept] = init_chart        (atlas, opts, chart)
    [opts atlas cseg        ] = init_update_chart (atlas, opts, cseg)
    [opts atlas cseg  accept] = init_atlas        (atlas, opts, cseg)
    [opts atlas cseg        ] = predict           (atlas, opts, cseg)
    [opts atlas cseg  accept] = add_chart         (atlas, opts, cseg)
    [opts atlas cseg  accept] = flush             (atlas, opts, cseg, varargin)
  end
  
end
