classdef cseg1 < CurveSegmentBase
  
  properties (Access = public)
    prcond = struct('x', [], 'TS', [], 's', [], 'h', [])
    correct = true
  end
  
  methods (Access=private)
    
    function cseg = cseg1(prob, chart, init_flag)
      cseg = cseg@CurveSegmentBase(prob, chart, init_flag);
    end
    
  end
  
  methods (Static)
    
    function [prob cseg] = create(prob, chart, prcond, x1)
      cseg              = cseg1(prob, chart, false);
      cseg.prcond       = prcond;
      cseg.ptlist       = { chart };
      cseg.curr_chart.x = x1;
      prob              = coco_emit(prob, 'update', cseg);
    end
    
    function [prob cseg] = create_initial(prob, chart, varargin)
      cseg           = cseg1(prob, chart, true);
      cseg.prcond.x  = chart.x;
      cseg.prcond.TS = cseg.init_TS(prob);
      cseg.prcond.s  = 1;
      cseg.prcond.h  = 0;
      prob           = coco_emit(prob, 'update', cseg);
    end
    
  end
  
  methods
    
    function TS = init_TS(cseg, prob)
      [pidx uidx] = coco_get_func_data(prob, 'efunc', 'pidx', 'uidx');
      if numel(pidx) >= 1
        % go in direction of first active parameter
        idx = pidx(1);
      else
        % go in direction of first component of x
        idx = uidx(1);
      end
      TS      = zeros(size(cseg.src_chart.x));
      TS(idx) = 1;
    end
    
    function [prob chart] = update_TS_and_t(cseg, prob, chart)
      % compute Jacobian of extended system
      [prob chart J]  = prob.efunc.DFDX(prob, chart, chart.x);
      % compute tangent space as solution of DF/DS*TS = [0...0 I]
      b               = zeros(size(chart.x));
      fidx            = coco_get_func_data(prob, 'cseg.prcond', 'fidx');
      b(fidx,:)       = 1;
      [prob chart TS] = prob.lsol.solve(prob, chart, J, b);
      chart.TS        = TS/norm(TS);
      % compute tangent vector aligned with prcond.s
      chart.t         = cseg.prcond.s*chart.TS;
    end
    
    function [prob cseg] = add_chart(cseg, prob, chart)
      [prob chart]         = cseg.update_TS_and_t(prob, chart);
      [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist          = [ cseg.ptlist { chart } ];
    end
    
  end
  
end
