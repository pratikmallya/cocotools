classdef atlas2_4 < AtlasBase
  %ATLAS2_4  Stops at boundary of computational domain.
  
  properties (Access=private)
    boundary = []
    charts   = {}
    next_pt  = 0;
    cont     = struct();
  end
  
  methods (Access=private)
    function atlas = atlas2_4(prob, cont, dim)
      assert(dim==2, '%s: wrong manifold dimension', mfilename);
      atlas      = atlas@AtlasBase(prob);
      atlas.cont = atlas.get_settings(cont);
    end
  end
  
  methods (Static)
    function [prob cont atlas] = create(prob, cont, dim)
      atlas = atlas2_4(prob, cont, dim);
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
      r1             = cont.h * sqrt(1+(pi/cont.Ndirs)^2);
      cont.s0        = [cos(al);sin(al)];     % initial directions
      cont.v0        = r1*ones(cont.Ndirs,1); % initial vertices
      cont.bv0       = 1:cont.Ndirs;          % list of boundary vertices
      cont.nb0       = zeros(1,cont.Ndirs);   % list of neighbours
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
      [atlas chart]  = atlas.set_fields(cseg.curr_chart);
      chart.pt_type  = 'EP';
      chart.ep_flag  = 1;
      [prob cseg]    = cseg.add_chart(prob, chart);
      [atlas cseg]   = atlas.merge(cseg);
      flush          = (atlas.next_pt>atlas.cont.PtMX);
    end
    
    function [prob atlas cseg accept] = flush(atlas, prob, cseg)
      if cseg.Status==cseg.CurveSegmentOK
        [atlas cseg] = atlas.merge(cseg);
      end
      [prob atlas cseg accept] = atlas.flush@AtlasBase(prob, cseg);
      if accept == cseg.CurveSegmentOK || accept == cseg.BoundaryPoint
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
      [prob cseg]    = CurveSegment.create(prob, chart, prcond, x1);
      [prob chart]   = update_t(cseg, prob, cseg.ptlist{1});
      [prob chart]   = cseg.update_p(prob, chart);
      cseg.ptlist{1} = chart;
      correct        = true;
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
      chart.v       = atlas.cont.v0;
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
    
    function flag = isclose(atlas, chart1, chart2)
      al   = atlas.cont.almax;
      R    = atlas.cont.h;
      sa   = sin(al);
      x1   = chart1.x;
      x2   = chart2.x;
      dx   = x2-x1;
      phi1 = chart1.TS'*dx;
      phi2 = chart2.TS'*dx;
      x1s  = chart1.TS*(phi1);
      x2s  = chart2.TS*(phi2);
      dst  = [ norm(x1s) norm(x2s) norm(dx-x1s) norm(dx-x2s) ...
        subspace( chart1.TS , chart2.TS ) ];
      dstmx = [ 2*R 2*R sa*(norm(x1s)+max(0,norm(x1s)-R)) ...
        sa*(norm(x2s)+max(0,norm(x2s)-R)) 2*al];
      if all(dst<dstmx);
        test1 = chart1.v.*(chart1.s'*phi1) - norm(phi1)^2/2;
        test2 = chart2.v.*(chart2.s'*phi2) + norm(phi2)^2/2;
        flag  = any(test1>0) && any(test2<0);
      else
        flag = false;
      end
    end
    
    function [atlas cseg] = merge(atlas, cseg)
      chart        = cseg.ptlist{end};
      nbfunc       = @(x) atlas.isclose(chart, x);
      bd_charts    = atlas.charts(atlas.boundary);
      idx          = cellfun(nbfunc, bd_charts);
      close_charts = atlas.boundary(idx);
      checked      = [0 chart.id];
      while ~isempty(close_charts)
        [atlas chart checked] = atlas.merge_recursive(chart, close_charts(1), checked);
        close_charts = setdiff(close_charts, checked);
      end
      atlas.charts   = [ atlas.charts   { chart } ];
      atlas.boundary = [ atlas.boundary  chart.id ];
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
      if atlas.isclose(chart1, chartk)
        dx     = chartk.x - chart1.x;
        phi1   = chart1.TS'*dx;
        phik   = chartk.TS'*(-dx);
        test1  = chart1.v.*(chart1.s'*phi1) - norm(phi1)^2/2;
        testk  = chartk.v.*(chartk.s'*phik) - norm(phik)^2/2;
        flag1  = (test1>0);
        flagk  = (testk>0);
        chart1 = atlas.subtract_half_space(chart1, test1, phi1, flag1, k);
        chartk = atlas.subtract_half_space(chartk, testk, phik, flagk, chart1.id);
        atlas.charts{k} = chartk;
        check = setdiff(chartk.nb, checked);
        while ~isempty(check)
          [atlas chart1 checked] = atlas.merge_recursive(chart1, check(1), checked);
          check = setdiff(chartk.nb, checked);
        end
      end
    end
    
    function chart = subtract_half_space(atlas, chart, test, phi, flag, NB)
      k        = [find(flag & ~circshift(flag, -1), 1) 0];
      flag     = circshift(flag, -k(1));
      test     = circshift(test, -k(1));
      chart.s  = circshift(chart.s, [0 -k(1)]);
      chart.v  = circshift(chart.v, -k(1));
      chart.nb = circshift(chart.nb, [0 -k(1)]);
      j        = find(~flag & circshift(flag,  -1), 1);
      vx1      = chart.v(j)*chart.s(:,j);
      vx2      = chart.v(j+1)*chart.s(:,j+1);
      nvx1     = vx1 - test(j)/((vx2-vx1)'*phi) * (vx2 - vx1);
      vx1      = chart.v(end)*chart.s(:,end);
      vx2      = chart.v(1)*chart.s(:,1);
      nvx2     = vx1 - test(end)/((vx2 - vx1)'*phi) * (vx2 - vx1);
      chart.s  = [ chart.s(:,1:j) nvx1/norm(nvx1) nvx2/norm(nvx2)];
      chart.v  = [ chart.v(1:j) ; norm(nvx1) ; norm(nvx2)];
      chart.nb = [ chart.nb(1:j+1) NB];
      ep_flag  = (chart.ep_flag && (chart.pt>0));
      chart.bv = find(~ep_flag & (chart.v > atlas.cont.Rmarg*chart.R));
    end
    
  end
  
  methods (Static)
    
  end
  
end