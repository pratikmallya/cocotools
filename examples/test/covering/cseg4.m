classdef cseg4 < CurveSegmentBase & EventLocator
  
  properties (Access = public)
    prcond  = struct('x', [], 'TS', [], 's', [], 'h', [])
    correct = true
  end
  
  methods (Access=private)
    
    function cseg = cseg4(prob, chart, init_flag)
      chart.rmProps = 'TS';
      cseg = cseg@CurveSegmentBase(prob, chart, init_flag);
    end
    
  end
  
  methods (Static)
    
    function [prob cseg] = create(prob, chart, prcond, x1)
      cseg              = cseg4(prob, chart, false);
      cseg.prcond       = prcond;
      cseg.ptlist       = { chart };
      cseg.curr_chart.x = x1;
      prob              = coco_emit(prob, 'update', cseg);
    end
    
    function [prob cseg] = create_initial(prob, chart, varargin)
      cseg           = cseg4(prob, chart, true);
      [prob cseg TS] = cseg.init_TS(prob);
      cseg.prcond.x  = chart.x;
      cseg.prcond.TS = TS;
      cseg.prcond.s  = 1;
      cseg.prcond.h  = 0;
      prob           = coco_emit(prob, 'update', cseg);
    end
    
  end
  
  methods
    
    function [prob cseg TS] = init_TS(cseg, prob)
      cseg.correct = all(cseg.src_chart.t==0);
      if cseg.correct
        % compute Jacobian of extended system exclusive prcond
        fidx  = coco_get_func_data(prob, 'cseg.prcond', 'fidx');
        chart = cseg.curr_chart;
        [prob chart J]  = prob.efunc.DFDX(prob, chart, chart.x);
        cseg.curr_chart = chart;
        J(fidx,:)       = [];
        
        % compute null space of linearisation of continuation problem
        [L U P] = lu(J'); %#ok<ASGLU>
        [m n]   = size(J);
        Y       = L(1:m, 1:m)' \ L(m+1:end, 1:m)';
        TS      = P'*[Y; -speye(n-m)];
        TS      = orth(full(TS));
      else
        TS = cseg.src_chart.t/norm(cseg.src_chart.t);
        cseg.curr_chart.TS = TS;
      end
    end
    
    function [prob chart] = update_TS(cseg, prob, chart)
      % compute Jacobian of extended system
      [prob chart J]  = prob.efunc.DFDX(prob, chart, chart.x);
      % compute tangent space as solution of DF/DS*TS = [0...0 I]
      b               = zeros(size(chart.x));
      fidx            = coco_get_func_data(prob, 'cseg.prcond', 'fidx');
      b(fidx,:)       = 1;
      [prob chart TS] = prob.lsol.solve(prob, chart, J, b);
      chart.TS        = TS/norm(TS);
    end
    
    function [prob cseg] = add_chart(cseg, prob, chart)
      if cseg.correct
        [prob chart]       = cseg.update_TS(prob, chart);
      end
      % compute tangent vector aligned with prcond.s
      chart.t              = cseg.prcond.s*chart.TS;
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist          = [ cseg.ptlist { chart } ];
    end
    
    function [prob cseg chart h] = chart_at(cseg, prob, la, evidx, varargin)
      chart   = cseg.new_chart(prob, varargin{:});
      x0      = cseg.ptlist{  1}.x;
      x1      = cseg.ptlist{end}.x;
      t0      = cseg.ptlist{  1}.t;
      t1      = cseg.ptlist{end}.t;
      chart.x = (1-la)*x0 + la*x1;
      chart.t = (1-la)*t0 + la*t1;
      chart.t = chart.t/norm(chart.t);
      
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t, evidx);
      
      x0 = cseg.prcond.x;
      TS = cseg.prcond.TS;
      s  = cseg.prcond.s;
      h  = ((TS*s)'*(chart.x-x0));
    end

    function [prob cseg] = eval_p(cseg, prob, evidx)
      chart                = cseg.curr_chart;
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t, evidx);
      cseg.curr_chart      = chart;
    end

    function [prob cseg idx] = insert_chart(cseg, prob, chart)
      x0  = cseg.prcond.x;
      TS  = cseg.prcond.TS;
      s   = cseg.prcond.s;
      t   = TS*s;
      h0  = t'*(chart.x-x0);
      h1  = cellfun(@(c) t'*(c.x-x0), cseg.ptlist(2:end));
      idx = find(h0<=h1, 1, 'last')+1;
      
      chart.TS             = TS;
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist          = [ cseg.ptlist(1:idx-1) chart cseg.ptlist(idx:end) ];
    end
    
  end
  
end
