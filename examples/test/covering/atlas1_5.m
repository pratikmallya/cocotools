classdef atlas1_5 < AtlasBase
  %ATLAS1_5  Is bi-directional and restricts to computational domain.
  %   Can run with:
  %   cseg4 - event handling with linear interpolation.
  %   CurveSegment - default core functionality.

  properties (Access=private)
    boundary = {};
    cont     = struct();
  end
  
  methods (Access=private)
    function atlas = atlas1_5(prob, cont, dim)
      assert(dim==1, '%s: wrong manifold dimension', mfilename);
      atlas      = atlas@AtlasBase(prob);
      atlas.cont = atlas.get_settings(cont);
    end
  end
  
  methods (Static)
    function [prob cont atlas] = create(prob, cont, dim)
      atlas = atlas1_5(prob, cont, dim);
      prob  = atlas.cont.add_prcond(prob, dim);
    end
  end
  
  methods (Static, Access=private)
    function cont = get_settings(cont)
      defaults.h     = 0.1 ; % continuation step size
      defaults.PtMX  = 50  ; % number of continuation steps
      defaults.theta = 0.5 ; % step size of theta method
      defaults.almax = 10  ; % desired bound on angle
      defaults.Rmarg = 0.95; % boundary of margin of width=R*(1-Rmarg)
      defaults.cseg  = 'CurveSegment'; % curve segment class
      cont           = coco_merge(defaults, cont);
      cont.almax     = cont.almax*pi/180;
      cont.CurveSegment   = str2func( cont.cseg );
      cont.add_prcond     = str2func([cont.cseg '.add_prcond']);
      cont.create_initial = str2func([cont.cseg '.create_initial']);
      cont.create         = str2func([cont.cseg '.create']);
    end
  end
  
  methods (Access=public)
    
    function [prob atlas cseg correct] = init_prcond(atlas, prob, chart)
      chart.R       = 0;
      chart.pt      = -1;
      chart.pt_type = 'IP';
      chart.ep_flag = 1;
      [prob cseg]   = atlas.cont.create_initial(prob, chart);
      correct       = cseg.correct;
    end
    
    function [prob atlas cseg flush] = init_atlas(atlas, prob, cseg)
      chart           = cseg.curr_chart;
      chart.R         = atlas.cont.h;
      chart.s         = [-1 1];
      atlas.cont.PtMX = abs(atlas.cont.PtMX);
      chart.pt        = 0;
      chart.pt_type   = 'EP';
      chart.ep_flag   = 1;
      [prob cseg]     = cseg.add_chart(prob, chart);
      flush           = true;
      prob = AtlasBase.bddat_set(prob, 'ins_mode', 'prepend');
    end
    
    function [prob atlas cseg accept] = flush(atlas, prob, cseg)
      if cseg.Status==cseg.CurveSegmentOK
        [atlas cseg] = atlas.merge(cseg);
      end
      [prob atlas cseg accept] = atlas.flush@AtlasBase(prob, cseg);
      if accept == cseg.CurveSegmentOK
        accept = isempty(atlas.boundary);
        accept = accept || (atlas.boundary{1,1}.pt>=atlas.cont.PtMX);
      elseif accept == cseg.BoundaryPoint
        atlas.boundary = atlas.boundary(2:end,:);
        accept = isempty(atlas.boundary);
        prob   = AtlasBase.bddat_set(prob, 'ins_mode', 'append');
        atlas.PrintHeadLine = true;
      end
    end
    
    function [prob atlas cseg correct] = predict(atlas, prob, cseg)
      [chart x1 s h] = atlas.boundary{1,:};
      prcond         = struct('x', chart.x, 'TS', chart.TS, 's', s, 'h', h);
      th             = atlas.cont.theta;
      if th>=0.5 && th<=1
        x1          = chart.x+(th*h)*(chart.TS*s);
        [prob cseg] = atlas.cont.create(prob, chart, prcond, x1);
        [prob ch2]  = cseg.update_TS(prob, cseg.curr_chart);
        h           = abs(ch2.TS'*(x1-chart.x))/th;
        x1          = chart.x + h*(ch2.TS*s);
        prcond      = struct('x', chart.x, 'TS', ch2.TS, 's', s, 'h', h);
      end
      [prob cseg] = atlas.cont.create(prob, chart, prcond, x1);
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
      
      if ~atlas.isneighbour(cseg.ptlist{1}, cseg.ptlist{end})
        cseg.ptlist{end}.pt_type = 'DROP';
        cseg.ptlist{end}.ep_flag = 2;
        cseg.Status              = cseg.CurveSegmentCorrupted;
      end
    end
    
  end
  
  methods (Access=private)
    
    function flag = isneighbour(atlas, chart1, chart2)
      al  = atlas.cont.almax;
      sa  = sin(al);
      R   = atlas.cont.h;
      x1  = chart1.x;
      x2  = chart2.x;
      dx  = x2-x1;
      x1s = chart2.TS*(chart2.TS'*dx);
      x2s = chart1.TS*(chart1.TS'*dx);
      dst = [ norm(x1s) norm(x2s) ...
        norm(dx-x1s) norm(dx-x2s) ...
        subspace( chart1.TS , chart2.TS ) ];
      dstmx = [ R R sa*norm(x1s) sa*norm(x2s) al ];
      flag  = all(dst<dstmx);
    end
    
    function [atlas cseg] = merge(atlas, cseg)
      chart = cseg.ptlist{end};
      R     = atlas.cont.h;
      h     = atlas.cont.Rmarg*chart.R;
      nb    = cell(2,4);
      for k=1:2
        sk      = chart.s(k);
        xk      = chart.x+h*(chart.TS*sk);
        nb(k,:) = { chart , xk , sk , h };
      end
      for i=size(atlas.boundary,1):-1:1
        chart2 = atlas.boundary{i,1};
        if atlas.isneighbour(chart, chart2)
          x2 = atlas.boundary{i,2};
          if norm(chart.TS'*(x2-chart.x))<R
            atlas.boundary(i,:) = [];
          end
          for k=size(nb,1):-1:1
            x1 = nb{k,2};
            if norm(chart2.TS'*(x1-chart2.x))<R
              nb(k,:) = [];
            end
          end
        end
      end
      atlas.boundary = [ nb ; atlas.boundary ];
      if isempty(atlas.boundary)
        chart.pt_type    = 'EP';
        chart.ep_flag    = 1;
        cseg.ptlist{end} = chart;
      end
    end
    
  end
  
end