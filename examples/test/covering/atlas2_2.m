classdef atlas2_2 < AtlasBase
  %ATLAS2_2  Merge with full atlas.
  
  properties (Access=private)
    boundary = []
    charts   = {}
    next_pt  = 0;
    cont     = struct();
  end
  
  methods (Access=private)
    function atlas = atlas2_2(prob, cont, dim)
      assert(dim==2, '%s: wrong manifold dimension', mfilename);
      atlas      = atlas@AtlasBase(prob);
      atlas.cont = atlas.get_settings(cont);
    end
  end
  
  methods (Static)
    function [prob cont atlas] = create(prob, cont, dim)
      atlas = atlas2_2(prob, cont, dim);
      prob  = CurveSegment.add_prcond(prob, dim);
    end
  end
  
  methods (Static, Access=private)
    function cont = get_settings(cont)
      defaults.h     = 0.1 ; % continuation step size
      defaults.PtMX  = 50  ; % number of continuation steps
      defaults.theta = 0.5 ; % step size of theta method
      defaults.almax = 10  ; % desired bound on angle
      defaults.Rmarg = 0.95; % boundary of margin of width=R*(1-Rmarg)
      defaults.Ndirs = 6   ; % number of initial directions
      cont           = coco_merge(defaults, cont);
      cont.PtMX      = abs(cont.PtMX);
      cont.almax     = cont.almax*pi/180;
      cont.Ndirs     = max(3, ceil(cont.Ndirs));
      al             = ((1:cont.Ndirs)-1)*(2*pi/cont.Ndirs);
      cont.s0        = [cos(al);sin(al)]; % initial directions
      cont.bv0       = 1:cont.Ndirs;      % list of boundary vertices
      cont.nb0       = [];                % list of neighbours
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
      [atlas chart] = atlas.set_fields(cseg.curr_chart);
      chart.pt_type = 'EP';
      chart.ep_flag = 1;
      [prob cseg]   = cseg.add_chart(prob, chart);
      flush         = true;
    end
    
    function [prob atlas cseg accept] = flush(atlas, prob, cseg)
      if cseg.Status==cseg.CurveSegmentOK
        [atlas cseg] = atlas.merge(cseg);
      end
      [prob atlas cseg accept] = atlas.flush@AtlasBase(prob, cseg);
      if accept == cseg.CurveSegmentOK
        accept = isempty(atlas.boundary);
        accept = accept || (atlas.next_pt>atlas.cont.PtMX);
      end
    end
    
    function [prob atlas cseg correct] = predict(atlas, prob, cseg)
      chart  = atlas.charts{atlas.boundary(1)};
      x0     = chart.x;
      TS     = chart.TS;
      s      = chart.s(:,chart.bv(1));
      h      = atlas.cont.Rmarg*chart.R;
      prcond = struct('x', x0, 'TS', TS, 's', s, 'h', h);
      th     = atlas.cont.theta;
      if th>=0.5 && th<=1
        x1          = x0 + (th*h)*(TS*s);
        [prob cseg] = CurveSegment.create(prob, chart, prcond, x1);
        [prob ch2]  = cseg.update_TS(prob, cseg.curr_chart);
        s           = ch2.TS'*(x1-x0);
        h           = norm(s);
        s           = s/h;
        x1          = x0 + (h/th)*(ch2.TS*s);
        prcond      = struct('x', x0, 'TS', ch2.TS, 's', s, 'h', h/th);
      else
        x1          = x0 + h*(TS*s);
      end
      [prob cseg] = CurveSegment.create(prob, chart, prcond, x1);
      correct     = true;
    end
    
    function [prob atlas cseg flush] = add_chart(atlas, prob, cseg)
      [atlas chart] = atlas.set_fields(cseg.curr_chart);
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
    
    function [atlas chart] = set_fields(atlas, chart)
      chart.pt      = atlas.next_pt;
      atlas.next_pt = atlas.next_pt + 1;
      chart.id      = chart.pt + 1;
      chart.R       = atlas.cont.h;
      chart.s       = atlas.cont.s0;
      chart.bv      = atlas.cont.bv0;
      chart.nb      = atlas.cont.nb0;
    end
    
    function flag = isneighbour(atlas, chart1, chart2)
      al  = atlas.cont.almax;
      sa  = sin(al);
      R   = atlas.cont.h;
      x1  = chart1.x;
      x2  = chart2.x;
      dx  = x2-x1;
      x1s = chart1.TS*(chart1.TS'*dx);
      x2s = chart2.TS*(chart2.TS'*dx);
      dst = [ norm(x1s) norm(x2s) norm(dx-x1s) norm(dx-x2s) ...
        subspace( chart1.TS , chart2.TS ) ];
      dstmx = [ R R sa*norm(x1s) sa*norm(x2s) al];
      flag  = all(dst<dstmx);
    end
    
    function [atlas cseg] = merge(atlas, cseg)
      chart        = cseg.ptlist{end};
      nbfunc       = @(x) atlas.isneighbour(chart, x);
      close_charts = find(cellfun(nbfunc, atlas.charts));
      checked      = chart.id;
      while ~isempty(close_charts)
        [atlas chart checked] = atlas.merge_recursive(chart, close_charts(1), checked);
        close_charts = setdiff(close_charts, checked);
      end
      atlas.charts   = [ atlas.charts { chart }   ];
      atlas.boundary = [ chart.id  atlas.boundary ];
      bd_charts      = atlas.charts(atlas.boundary);
      idx            = cellfun(@(x) ~isempty(x.bv), bd_charts);
      atlas.boundary = atlas.boundary(idx);
      if isempty(atlas.boundary)
        chart.pt_type    = 'EP';
        chart.ep_flag    = 1;
        cseg.ptlist{end} = chart;
      end
    end
    
    function [atlas chart1 checked] = merge_recursive(atlas, chart1, k, checked)
      checked(end+1) = k;
      chartk = atlas.charts{k};
      if atlas.isneighbour(chart1, chartk)
        R   = atlas.cont.h;
        h   = atlas.cont.Rmarg*chart1.R;
        v   = @(i,c) c.x + h*(c.TS*c.s(:,i));
        v1  = arrayfun(@(i) v(i,chart1), chart1.bv, 'UniformOutput', false);
        idx = cellfun(@(x) (norm(chartk.TS'*(x-chartk.x))<R), v1);
        chart1.bv(idx) = [];
        chart1.nb      = [ chart1.nb k ];
        vk  = arrayfun(@(i) v(i,chartk), chartk.bv, 'UniformOutput', false);
        idx = cellfun(@(x) (norm(chart1.TS'*(x-chart1.x))<R), vk);
        chartk.bv(idx)  = [];
        chartk.nb       = [ chartk.nb chart1.id ];
        atlas.charts{k} = chartk;
        check = setdiff(chartk.nb, checked);
        while ~isempty(check)
          [atlas chart1 checked] = atlas.merge_recursive(chart1, check(1), checked);
          check = setdiff(chartk.nb, checked);
        end
      end
    end
    
  end
  
  methods (Static)
    
  end
  
end