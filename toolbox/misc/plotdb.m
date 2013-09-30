classdef plotdb < handle
  
  properties (Constant, GetAccess=private)
    roots    = { 'Tutorial' }
    mode_ro  = 'read only';
    mode_rw  = 'read/write';
    warnlist = {'MATLAB:tex' 'MATLAB:latex' 'MATLAB:gui:latexsup:BadTeXString'};
  end
  
  properties (Access=private) % data base properties
    dbfile  = ''
    figpath = ''
    
    fh       = []
    fcl      = true;
    ah       = []
    has_lock = false;
    
    rc    = struct()
    db    = struct()
    tmplt = struct()
    trash = struct('nextid', 1)
    style = struct()
    
    isplotting = false
    isreadonly = true;
    curr_plot  = struct()
    
    ws = [];
  end
  
  methods (Access=public) % data base and plot constructors
    
    function pdb = plotdb(fhan)
      if nargin>=1
        pdb.fcl = false;
      else
        fhan = figure();
      end
      pdb.init(fhan);
      
      for i=1:numel(pdb.warnlist)
        s      =  warning('off', pdb.warnlist{i});
        pdb.ws = [ pdb.ws s(:) ];
      end
    end
    
    function add_style(pdb, name, owner, varargin)
      assert(~pdb.isplotting, ...
        '%s: cannot create new plot, close current plot first', mfilename);
      
      id = pdb.plot_id(name, owner, 'style');
      pdb.style.(name).id = id;
      pdb.style.(name).st = varargin;
      pdb.save_db();
    end
    
    function reset(pdb)
      pdb.plot_exit();
      pdb.init(pdb.fh);
    end
    
    function replot(pdb, plots)
      if nargin>=2
        flag = ~pdb.isplotting || strcmp(name, pdb.curr_plot.name);
        assert(flag, '%s: close current plot first', mfilename)
        if ~iscell(plots)
          plots = { plots };
        end
      else
        plots = fieldnames(pdb.db);
      end
      
      data = pdb.plot_window_init();
      try
        if pdb.isplotting
          pdb.redraw();
          pdb.plot_save();
        else
          pdb.init_rc();
          for i=1:numel(plots)
            cp = pdb.db.(plots{i});
            try
              pdb.plot_init(cp.name, cp.id);
              pdb.paper_set_size(cp.PaperSize);
              pdb.plot_draw(cp.name);
              pdb.plot_save();
            catch e
              pdb.plot_exit();
              rethrow(e);
            end
          end
          pdb.plot_exit();
        end
        pdb.plot_window_restore(data);
      catch e
        pdb.plot_window_restore(data);
        rethrow(e);
      end
    end
    
    function redraw(pdb)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      pdb.init_rc();
      cp = pdb.curr_plot;
      try
        pdb.plot_init(cp.name, cp.id);
        pdb.paper_set_size(cp.PaperSize);
        pdb.plot_exec(cp.cmds);
      catch e
        pdb.curr_plot = cp;
        rethrow(e);
      end
    end
    
    function plot_create(pdb, name, owner)
      assert(~pdb.isplotting, ...
        '%s: cannot create new plot, close current plot first', mfilename);
      
      id = pdb.plot_id(name, owner);
      pdb.plot_init(name, id, 'reset');
    end
    
    function plot_open(pdb, name, owner)
      assert(~pdb.isplotting, ...
        '%s: cannot create new plot, close current plot first', mfilename);
      
      id = pdb.plot_id(name, owner);
      pdb.plot_init(name, id);
      pdb.plot_draw(name);
    end
    
    function plot_print(pdb)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      name          = pdb.curr_plot.name;
      pdb.db.(name) = pdb.curr_plot;
      
      try
        data = pdb.plot_window_init();
        pdb.redraw();
        pdb.plot_save();
        pdb.plot_window_restore(data);
      catch e
        pdb.plot_window_restore(data);
        rethrow(e);
      end
    end
    
    function plot_close(pdb)
      if pdb.isplotting
        pdb.plot_print();
        pdb.plot_exit();
      end
    end
    
    function plot_discard(pdb)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      pdb.plot_exit();
    end
    
    function cmds = plot_get(pdb)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      cmds = pdb.curr_plot.cmds;
    end
    
    function plot_set(pdb, cmds)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      cp = pdb.curr_plot;
      try
        pdb.plot_init(cp.name, cp.id);
        pdb.plot_exec(cmds);
      catch e
        pdb.curr_plot = cp;
        rethrow(e);
      end
    end
    
    function plot_create_template(pdb, name, owner)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      id               = pdb.plot_id(name, owner, 'tmplt');
      template         = struct('name', name, 'id', id, 'cmds', {pdb.curr_plot.cmds});
      pdb.tmplt.(name) = template;
      
      pdb.save_db();
    end
    
    function plot_use_template(pdb, name)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      assert(isfield(pdb.tmplt, name), '%s: template ''%s'' not found', ...
        mfilename, name);
      
      cmds = pdb.tmplt.(name).cmds;
      cp   = pdb.curr_plot;
      try
        pdb.plot_exec(cmds);
      catch e
        pdb.curr_plot = cp;
        rethrow(e);
      end
    end
    
    function print_test_page(pdb)
      pdb.plot_create('test_page', mfilename);
      
      pdb.axis([0 1 0 1]);
      pdb.grid('off');
      pdb.paper_size([16 6]);
      
      x2 = 0.35;
      pdb.plot([0.05 x2], [0.95 0.95], 'line1');
      pdb.plot([0.05 x2], [0.90 0.90], 'line1g1');
      pdb.plot([0.05 x2], [0.85 0.85], 'line1g2');
      pdb.plot([0.05 x2], [0.80 0.80], 'line1g3');
      pdb.plot([0.05 x2], [0.75 0.75], 'line1g4');
      pdb.plot([0.05 x2], [0.70 0.70], 'line1g5');
      pdb.plot([0.05 x2], [0.65 0.65], 'line1g6');
      pdb.plot([0.05 x2], [0.60 0.60], 'line1g7');
      pdb.plot([0.05 x2], [0.55 0.55], 'line1g8');
      pdb.plot([0.05 x2], [0.50 0.50], 'line1g9');
      
      pdb.plot([0.05 x2], [0.40 0.40], 'line2');
      pdb.plot([0.05 x2], [0.35 0.35], 'line3');
      pdb.plot([0.05 x2], [0.30 0.30], 'line4');
      pdb.plot([0.05 x2], [0.25 0.25], 'line5');
      pdb.plot([0.05 x2], [0.20 0.20], 'line6');
      pdb.plot([0.05 x2], [0.15 0.15], 'line7');
      pdb.plot([0.05 x2], [0.10 0.10], 'line8');
      pdb.plot([0.05 x2], [0.05 0.05], 'line9');
      
      pdb.textbox(x2, 0.95, 'line1', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.90, 'line1g1', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.85, 'line1g2', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.80, 'line1g3', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.75, 'line1g4', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.70, 'line1g5', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.65, 'line1g6', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.60, 'line1g7', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.55, 'line1g8', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.50, 'line1g9', 'r', 'text5', 'box1');
      
      pdb.textbox(x2, 0.40, 'line2', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.35, 'line3', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.30, 'line4', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.25, 'line5', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.20, 'line6', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.15, 'line7', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.10, 'line8', 'r', 'text5', 'box1');
      pdb.textbox(x2, 0.05, 'line9', 'r', 'text5', 'box1');
      
      pdb.textbox(0.5, 0.95, 'text1', 'l', 'text5', 'box1');
      pdb.textbox(0.5, 0.95, 'Abc 123',   'r', 'text1', 'box1');
      pdb.textbox(0.5, 0.87, 'text2', 'l', 'text5', 'box1');
      pdb.textbox(0.5, 0.87, 'Abc 123',   'r', 'text2', 'box1');
      
      pdb.textbox(0.7, 0.95, 'text1d', 'l', 'text5', 'box1');
      pdb.textbox(0.7, 0.95, 'Abc 123',   'r', 'text1d', 'box1');
      pdb.textbox(0.7, 0.87, 'text2d', 'l', 'text5', 'box1');
      pdb.textbox(0.7, 0.87, 'Abc 123',   'r', 'text2d', 'box1');
      
      pdb.textbox(0.9, 0.95, 'text1b', 'l', 'text5', 'box1');
      pdb.textbox(0.9, 0.95, 'Abc 123',   'r', 'text1b', 'box1');
      pdb.textbox(0.9, 0.87, 'text2b', 'l', 'text5', 'box1');
      pdb.textbox(0.9, 0.87, 'Abc 123',   'r', 'text2b', 'box1');
      
      pdb.textbox(0.55, 0.79, 'math1', 'l', 'text5', 'box1');
      pdb.textbox(0.55, 0.79, 'ABC 123', 'r', 'math1', 'box1');
      pdb.textbox(0.55, 0.71, 'math2', 'l', 'text5', 'box1');
      pdb.textbox(0.55, 0.71, 'ABC 123', 'r', 'math2', 'box1');
      
      pdb.textbox(0.85, 0.79, 'math1b', 'l', 'text5', 'box1');
      pdb.textbox(0.85, 0.79, 'ABC 123', 'r', 'math1b', 'box1');
      pdb.textbox(0.85, 0.71, 'math2b', 'l', 'text5', 'box1');
      pdb.textbox(0.85, 0.71, 'ABC 123', 'r', 'math2b', 'box1');
      
      pdb.textbox(0.65, 0.55, 'arrow1', 't', 'text5', 'box1');
      pdb.textarrow(0.65,0.4, 't', 't', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'tr', 'tr', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'r', 'r', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'br', 'br', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'b', 'b', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'bl', 'bl', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'l', 'l', 'text2', 'box1', 'arrow1');
      pdb.textarrow(0.65,0.4, 'tl', 'tl', 'text2', 'box1', 'arrow1');
      
      pdb.textbox(0.8, 0.55, 'arrow2', 't', 'text5', 'box1');
      pdb.textarrow(0.8,0.4, 't', 't', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'tr', 'tr', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'r', 'r', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'br', 'br', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'b', 'b', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'bl', 'bl', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'l', 'l', 'text2', 'box1', 'arrow2');
      pdb.textarrow(0.8,0.4, 'tl', 'tl', 'text2', 'box1', 'arrow2');
      
      pdb.textbox(0.95, 0.55, 'box1', 't', 'text5', 'box1');
      pdb.plot([0.935 0.965 0.965 0.935 0.935], [0.44 0.44 0.36 0.36 0.44], 'line3g8');
      pdb.textbox(0.95,0.44, 't', 't', 'text2', 'box1');
      pdb.textbox(0.965,0.44, 'tr', 'tr', 'text2', 'box1');
      pdb.textbox(0.965,0.4, 'r', 'r', 'text2', 'box1');
      pdb.textbox(0.965,0.36, 'br', 'br', 'text2', 'box1');
      pdb.textbox(0.95,0.36, 'b', 'b', 'text2', 'box1');
      pdb.textbox(0.935,0.36, 'bl', 'bl', 'text2', 'box1');
      pdb.textbox(0.935,0.4, 'l', 'l', 'text2', 'box1');
      pdb.textbox(0.935,0.44, 'tl', 'tl', 'text2', 'box1');
      
      pdb.textbox(0.8, 0.17, 'marker 1-6', 't', 'text5');
      pdb.textbox(0.65, 0.15, 's', 'l', 'text5');
      pdb.textbox(0.65, 0.10, ' ', 'l', 'text5');
      pdb.textbox(0.65, 0.05, 'l', 'l', 'text5');
      
      pdb.plot([0.65 0.95], [0.15 0.15], 'line2g5');
      x = linspace(0.65, 0.95, 8);
      x = x(2:end-1);
      for i=1:6
        marker = sprintf('marker%ds', i);
        pdb.plot(x(i),0.15, 'line2g5', marker);
      end
      
      pdb.plot([0.65 0.95], [0.10 0.10], 'line2g5');
      x = linspace(0.65, 0.95, 8);
      x = x(2:end-1);
      for i=1:6
        marker = sprintf('marker%d', i);
        pdb.plot(x(i),0.10, 'line2g5', marker);
      end
      
      pdb.plot([0.65 0.95], [0.05 0.05], 'line2g5');
      x = linspace(0.65, 0.95, 8);
      x = x(2:end-1);
      for i=1:6
        marker = sprintf('marker%dl', i);
        pdb.plot(x(i),0.05, 'line2g5', marker);
      end
      
      pdb.plot_close();
    end
    
  end
  
  methods (Access=public) % plot functions
    
    function plot(pdb, varargin)
      % varargin = x y [z] [style] [linestyle [markerstyle]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      flag = isfield(pdb.curr_plot, 'dim');
      
      z        = [];
      linstyle = 'line1';
      mrkstyle = 'default';
      dim      = 2;
      
      s = coco_stream(varargin{:});
      x   = s.get;
      y   = s.get;
      if ~isempty(s) && isnumeric(s.peek)
        z   = s.get;
        dim = dim+1;
      end
      if ~isempty(s) && ischar(s.peek)
        st = s.peek;
        if isfield(pdb.style, st)
          st = s.get;
          [linstyle mrkstyle] = str_deal('', pdb.style.(st).st, ...
            {linstyle mrkstyle});
        end
      end
      if ~isempty(s) && ischar(s.peek)
        linstyle = s.get;
      end
      if ~isempty(s) && ischar(s.peek)
        mrkstyle = s.get;
      end
      
      assert(isempty(s), '%s: too many input arguments', mfilename);
      
      assert( ~flag || pdb.curr_plot.dim==dim, ...
        '%s: plot dimensions do not agree', mfilename);
      
      linstyle = pdb.rc.(linstyle);
      mrkstyle = pdb.rc.(mrkstyle);
      
      if flag
        hold(pdb.ah, 'on');
      end
      
      if dim==2
        plot(pdb.ah, x, y, linstyle{:}, mrkstyle{:});
      else
        plot3(pdb.ah, x, y, z, linstyle{:}, mrkstyle{:});
      end
      
      hold(pdb.ah, 'off');
      
      pdb.curr_plot.dim  = dim;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'plot' varargin } ];
      
      pdb.plot_update();
    end
    
    function surf(pdb, x, y, z, varargin)
      % varargin = [style]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      flag = isfield(pdb.curr_plot, 'dim');
      
      assert( ~flag || pdb.curr_plot.dim==3, ...
        '%s: plot dimensions do not agree', mfilename);
      
      if flag
        hold(pdb.ah, 'on');
      end
      surf(pdb.ah, x,y,z, varargin{:});
      hold(pdb.ah, 'off');
      
      pdb.curr_plot.dim  = 3;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'surf' [{x y z} varargin] } ];
      
      pdb.plot_update();
    end
    
    function trisurf(pdb, tri, x, y, z, varargin)
      % varargin = [style]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      flag = isfield(pdb.curr_plot, 'dim');
      
      assert( ~flag || pdb.curr_plot.dim==3, ...
        '%s: plot dimensions do not agree', mfilename);
      
      if flag
        hold(pdb.ah, 'on');
      end
      set(pdb.fh,'CurrentAxes',pdb.ah);
      trisurf(tri, x,y,z, varargin{:});
      hold(pdb.ah, 'off');
      
      pdb.curr_plot.dim  = 3;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'trisurf' [{tri x y z} varargin] } ];
      
      pdb.plot_update();
    end
    
    function quiver(pdb, varargin)
      % varargin = x y dx dy [scale] [style] [linestyle [arrowstyle [markerstyle]]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      flag = isfield(pdb.curr_plot, 'dim');
      assert(~flag || pdb.curr_plot.dim==2, ...
        '%s: dimension of plot must be 2', mfilename);
      
      linstyle = 'qvr_line1';
      arrstyle = 'qvr_arrow1';
      mrkstyle = 'qvr_marker1';
      
      scale = 1.5;
      
      s = coco_stream(varargin{:});
      x  = s.get;
      y  = s.get;
      dx = s.get;
      dy = s.get;
      if ~isempty(s) && isnumeric(s.peek)
        scale = s.get;
      end
      if ~isempty(s) && ischar(s.peek)
        st = s.peek;
        if isfield(pdb.style, st)
          st = s.get;
          [linstyle arrstyle mrkstyle] = str_deal('qvr', pdb.style.(st).st, ...
            {linstyle arrstyle mrkstyle});
        end
      end
      if ~isempty(s) && ischar(s.peek)
        linstyle = sprintf('qvr_%s', s.get);
      end
      if ~isempty(s) && ischar(s.peek)
        arrstyle = sprintf('qvr_%s', s.get);
      end
      if ~isempty(s) && ischar(s.peek)
        mrkstyle = sprintf('qvr_%s', s.get);
      end
      
      assert(isempty(s), '%s: too many input arguments', mfilename);
      
      linstyle = pdb.rc.(linstyle);
      arrstyle = pdb.rc.(arrstyle);
      mrkstyle = pdb.rc.(mrkstyle);
      
      if flag
        hold(pdb.ah, 'on');
      end
      
      quiver(pdb.ah, x,y, dx,dy, scale, linstyle{:}, arrstyle{:}, mrkstyle{:});
      
      hold(pdb.ah, 'off');
      
      pdb.curr_plot.dim  = 2;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'quiver' varargin } ];
      
      pdb.plot_update();
    end
    
  end
  
  methods (Access=public) % annotation functions
    
    function text(pdb, varargin)
      % varargin = x y [z] text spec [style [options]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      assert(isfield(pdb.curr_plot, 'dim'), '%s: plot something first', mfilename);
      
      txtstyle  = 'text1';
      opts      = {};
      
      s = coco_parser(varargin{:});
      x = s.get;
      y = s.get;
      if pdb.curr_plot.dim==3
        z = s.get;
      end
      string = s.get;
      spec = s.get;
      if ~isempty(s) && ischar(s.peek)
        txtstyle = s.get;
        if isfield(pdb.style, txtstyle)
          txtstyle = pdb.style.(txtstyle).st;
        end
      end
      while ~isempty(s)
        opts = [opts {s.get}]; %#ok<AGROW>
      end
      
      switch lower(spec)
        case 't'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'};
        case 'tr'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'};
        case 'r'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle'};
        case 'br'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'top'};
        case 'b'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top'};
        case 'bl'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'top'};
        case 'l'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'};
        case 'tl'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom'};
        case 'c'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
        otherwise
          error('%s: unrecognised alignment specification ''%s''', ...
            mfilename, spec);
      end
      
      if ~isempty(regexp(txtstyle, '^math', 'once'))
        if txtstyle(end) == 'b'
          string = ['\boldmath$' string '$'];
        else
          string = ['$' string '$'];
        end
      end
      
      txtstyle = pdb.rc.(txtstyle);
      set(pdb.fh,'CurrentAxes',pdb.ah);
      if pdb.curr_plot.dim==3
        text(x, y, z, string, txtstyle{:}, alignment{:}, opts{:});
      else
        text(x, y, string, txtstyle{:}, alignment{:}, opts{:});
      end
      
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'text' varargin } ];
      
      pdb.plot_update();
    end
    
    function title(pdb, varargin)
      % varargin = [pos] text [style] [txtstyle]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      pos      = [];
      txtstyle = 'text1';
      
      s = coco_parser(varargin{:});
      if isnumeric(s.peek)
        pos = s.get;
      end
      text = s.get;
      if ~isempty(s) && ischar(s.peek)
        st = s.peek;
        if isfield(pdb.style, st)
          st = s.get;
          txtstyle = str_deal('', pdb.style.(st).st, {txtstyle});
        end
      end
      if ~isempty(s) && ischar(s.peek)
        txtstyle = s.get;
      end
      
      if ~isempty(regexp(txtstyle, '^math', 'once'))
        if txtstyle(end) == 'b'
          text = ['\boldmath$' text '$'];
        else
          text = ['$' text '$'];
        end
      end
      
      txtstyle = pdb.rc.(txtstyle);
      
      h = title(pdb.ah, text, txtstyle{:}, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');
      
      if ~isempty(pos)
        lpos = get(h, 'Position');
        pos  = [pos(:)' zeros(numel(lpos)-numel(pos))];
        lim  = get(pdb.ah, 'XLim');
        pos(1) = pos(1)*(lim(2)-lim(1));
        lim  = get(pdb.ah, 'YLim');
        pos(2) = pos(2)*(lim(2)-lim(1));
        lim  = get(pdb.ah, 'ZLim');
        pos(3) = pos(3)*(lim(2)-lim(1));
        set(h, 'Position', lpos+pos);
      end
      
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'title' varargin } ];
      
      pdb.plot_update();
    end
    
    function textarrow(pdb, varargin)
      % varargin = x y [length] text spec [style] [txtstyle [boxstyle [arrstyle]]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      assert(isfield(pdb.curr_plot, 'dim'), '%s: plot something first', mfilename);
      
      length = 1;
      
      txtstyle = 'arr_text1';
      boxstyle = 'arr_box1';
      arrstyle = 'arr_arrow1';
      
      s    = coco_parser(varargin{:});
      x    = s.get;
      y    = s.get;
      if isnumeric(s.peek)
        length = s.get;
      end
      text = s.get;
      spec = s.get;
      if ~isempty(s) && ischar(s.peek)
        st = s.peek;
        if isfield(pdb.style, st)
          st = s.get;
          [txtstyle boxstyle arrstyle] = str_deal('arr', pdb.style.(st).st, ...
            {txtstyle boxstyle arrstyle});
        end
      end
      if ~isempty(s) && ischar(s.peek)
        txtstyle = sprintf('arr_%s', s.get);
      end
      if ~isempty(s) && ischar(s.peek)
        boxstyle = sprintf('arr_%s', s.get);
      end
      if ~isempty(s) && ischar(s.peek)
        arrstyle = sprintf('arr_%s', s.get);
      end
      
      if pdb.curr_plot.dim == 2
        bbox = get(pdb.ah, 'Position');
        xlim = get(pdb.ah, 'XLim');
        ylim = get(pdb.ah, 'YLim');
        x1   = bbox(1)+bbox(3)*(x-xlim(1))/(xlim(2)-xlim(1));
        y1   = bbox(2)+bbox(4)*(y-ylim(1))/(ylim(2)-ylim(1));
      else
        x1 = x;
        y1 = y;
      end
      
      idx = strcmpi(spec, {'t' 'tr' 'r' 'br' 'b' 'bl' 'l' 'tl'});
      if any(idx)
        ps = pdb.curr_plot.PaperSize;
        r  = ps(2)/ps(1);
        s2 = 0.5*sqrt(2);
        dx = [0 s2 1  s2  0 -s2 -1 -s2];
        dy = [1 s2 0 -s2 -1 -s2  0  s2];
        dx = length*0.04*dx(idx)*r;
        dy = length*0.04*dy(idx);
        x2 = x1+dx;
        y2 = y1+dy;
      elseif isnumeric(spec)
        ps = pdb.curr_plot.PaperSize;
        r  = ps(2)/ps(1);
        dx = sin(spec(1));
        dy = cos(spec(1));
        dx = length*0.04*dx*r;
        dy = length*0.04*dy;
        x2 = x1+dx;
        y2 = y1+dy;
        if numel(spec)==1
          idx = round(4*mod(spec,2*pi)/pi);
        else
          idx = spec(2);
        end
      else
        error('%s: unrecognised direction specification ''%s''', ...
          mfilename, spec);
      end
      alignment = {
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle'
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top'
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top'
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'top'
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom'
        };
      alignment = alignment(idx,:);
      
      if ~isempty(regexp(txtstyle, '^arr_math', 'once'))
        if txtstyle(end) == 'b'
          text = ['\boldmath$' text '$'];
        else
          text = ['$' text '$'];
        end
      end
      
      txtstyle = pdb.rc.(txtstyle);
      boxstyle = pdb.rc.(boxstyle);
      arrstyle = pdb.rc.(arrstyle);
      annotation(pdb.fh, 'textarrow', [x2 x1], [y2 y1], 'String', text, ...
        arrstyle{:}, boxstyle{:}, txtstyle{:}, alignment{:});
      
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'textarrow' varargin } ];
      
      pdb.plot_update();
    end
    
    function textbox(pdb, varargin)
      % varargin = x y [w [h]] text spec [style] [txtstyle [boxstyle]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      assert(isfield(pdb.curr_plot, 'dim'), '%s: plot something first', mfilename);
      
      width  = 0;
      height = 0;
      txtstyle = 'box_text1';
      boxstyle = 'box_box1';
      
      s    = coco_parser(varargin{:});
      x    = s.get;
      y    = s.get;
      if isnumeric(s.peek)
        width = s.get;
      end
      if isnumeric(s.peek)
        height = s.get;
      end
      text = s.get;
      spec = s.get;
      if ~isempty(s) && ischar(s.peek)
        st = s.peek;
        if isfield(pdb.style, st)
          st = s.get;
          [txtstyle boxstyle] = str_deal('box', pdb.style.(st).st, ...
            {txtstyle boxstyle});
        end
      end
      if ~isempty(s) && ischar(s.peek)
        txtstyle = sprintf('box_%s', s.get);
      end
      if ~isempty(s) && ischar(s.peek)
        boxstyle = sprintf('box_%s', s.get);
      end
      
      if pdb.curr_plot.dim == 2
        bbox   = get(pdb.ah, 'Position');
        xlim   = get(pdb.ah, 'XLim');
        ylim   = get(pdb.ah, 'YLim');
        x      = bbox(1)+bbox(3)*(x-xlim(1))/(xlim(2)-xlim(1));
        y      = bbox(2)+bbox(4)*(y-ylim(1))/(ylim(2)-ylim(1));
        width  = bbox(3)*width /(xlim(2)-xlim(1));
        height = bbox(4)*height/(ylim(2)-ylim(1));
      end
      
      switch lower(spec)
        case 't'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'};
        case 'tr'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'};
        case 'r'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle'};
        case 'br'
          alignment = {'HorizontalAlignment', 'left', 'VerticalAlignment', 'top'};
        case 'b'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top'};
        case 'bl'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'top'};
        case 'l'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'};
        case 'tl'
          alignment = {'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom'};
        case 'c'
          alignment = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
        otherwise
          error('%s: unrecognised direction specification ''%s''', ...
            mfilename, spec);
      end
      
      if ~isempty(regexp(txtstyle, '^box_math', 'once'))
        if txtstyle(end) == 'b'
          text = ['\boldmath$' text '$'];
        else
          text = ['$' text '$'];
        end
      end
      
      txtstyle = pdb.rc.(txtstyle);
      boxstyle = pdb.rc.(boxstyle);
      annotation(pdb.fh, 'textbox', [x y width height], 'String', text, ...
        txtstyle{:}, alignment{:}, boxstyle{:});
      
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'textbox' varargin } ];
      
      pdb.plot_update();
    end
    
    function xaxis(pdb, varargin)
      pdb.xyz_axis('X', varargin{:});
    end
    
    function yaxis(pdb, varargin)
      pdb.xyz_axis('Y', varargin{:});
    end
    
    function zaxis(pdb, varargin)
      pdb.xyz_axis('Z', varargin{:});
    end
    
    function xyz_axis(pdb, varargin)
      % varargin = AXIS vals [(tickfac|tickvals) [pos text [txtstyle] [angle]]]
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      fac      = 1;
      angle    = 0;
      labstyle = 'lab_math';
      nolabel  = true;
      
      s = coco_parser(varargin{:});
      AXIS = s.get;
      vals = s.get;
      assert(isempty(vals) || numel(vals)>=2, '%s: too few tick values', mfilename);
      if ~isempty(s) && isnumeric(s.peek)
        fac = s.get;
        if ~isempty(s) && isnumeric(s.peek)
          apos    = s.get;
          text    = s.get;
          nolabel = false;
          if ~isempty(s) && ischar(s.peek)
            labstyle = sprintf('lab_%s', s.get);
          end
          if ~isempty(s) && isnumeric(s.peek)
            angle = s.get;
          end
        end
      end
      
      if isempty(vals)
        set(pdb.ah, [AXIS 'Tick'], vals);
      elseif isscalar(fac)
        if fac == 1
          set(pdb.ah, [AXIS 'Tick'], vals);
        else
          val1     = vals(1);
          tickvals = val1;
          if abs(val1)>10*eps
            ticklabs = { sprintf('%g', val1) };
          else
            ticklabs = { '0' };
          end
          for val2 = vals(2:end)
            v = linspace(val1,val2,fac+1);
            for vv = v(2:end-1);
              tickvals = [tickvals vv]; %#ok<AGROW>
              ticklabs = [ticklabs {''}]; %#ok<AGROW>
            end
            tickvals = [tickvals val2]; %#ok<AGROW>
            if abs(val2)>10*eps
              ticklabs = [ticklabs { sprintf('%g', val2) }]; %#ok<AGROW>
            else
              ticklabs = [ticklabs { '0' }]; %#ok<AGROW>
            end
            val1 = val2;
          end
          set(pdb.ah, [AXIS 'Tick'], tickvals, [AXIS 'TickLabel'], ticklabs);
        end
      else
        nticks = numel(vals);
        [ticklabs{1:nticks}] = deal('');
        for tickval = fac
          [v idx] = min(abs(vals-tickval)); %#ok<ASGLU>
          if abs(tickval)>10*eps
            ticklabs{idx} = sprintf('%g', tickval);
          else
            ticklabs{idx} = '0';
          end          
        end
        set(pdb.ah, [AXIS 'Tick'], vals, [AXIS 'TickLabel'], ticklabs);
      end
      
      if ~nolabel
        if ~isempty(regexp(labstyle, '^lab_math', 'once'))
          if labstyle(end) == 'b'
            text = ['\boldmath$' text '$'];
          else
            text = ['$' text '$'];
          end
        end
        
        labstyle = pdb.rc.(labstyle);
        
        switch AXIS
          case 'X'
            h    = xlabel(pdb.ah, text, labstyle{:}, 'Rotation', angle);
            aidx = 1;
          case 'Y'
            h    = ylabel(pdb.ah, text, labstyle{:}, 'Rotation', angle);
            aidx = 2;
          case 'Z'
            h    = zlabel(pdb.ah, text, labstyle{:}, 'Rotation', angle);
            aidx = 3;
        end
        
        pos       = get(h, 'Position');
        if numel(apos)==numel(pos)
          pos(:) = apos(:);
        else
          pos(aidx) = apos;
        end
        set(h, 'Position', pos);
      end
      
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'xyz_axis' varargin }];
      
      pdb.plot_update();
    end
    
  end
  
  methods (Access=public) % figure and axis property methods
    
    function box(pdb, flag)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      box_style = sprintf('box_%s', flag);
      pdb.curr_plot.box = pdb.rc.(box_style);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'box' { flag } } ];
    end
    
    function grid(pdb, flag)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      grid_style = sprintf('grid_%s', flag);
      pdb.curr_plot.grid = pdb.rc.(grid_style);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'grid' { flag } } ];
    end
    
    function axis(pdb, varargin)
      % varargin = ('+' border)|limits [style] 
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      axis_style = 'axis';
      s = coco_stream(varargin{:});
      if ischar(s.peek) && strcmp('+', s.peek)
        assert(isfield(pdb.curr_plot, 'dim'), ...
          '%s: plot dimension unknown, plot something first', mfilename);
        s.skip;
        dim = pdb.curr_plot.dim;
        border = s.get;
        assert(any(numel(border)==[1 dim]), ...
          '%s: border must have 1 or %d elements', mfilename, dim);
        if numel(border)==1
          limits = border*ones(1,dim);
        else
          limits = border;
        end
        mode = '+';
      else
        limits = s.get;
        mode   = 'normal';
      end
      if ~isempty(s) && ischar(s.peek)
        axis_style = s.get;
      end
      
      axis_style = pdb.rc.(axis_style);
      
      pdb.curr_plot.axis = [ mode limits axis_style ];
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'axis' varargin } ];
    end
    
    function view(pdb, x)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      view(pdb.ah, x);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'view' { x } } ];
    end
    
    function camproj(pdb, proj)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      camproj(pdb.ah, proj);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'camproj' { camproj } } ];
    end
    
    function campos(pdb, pos)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      campos(pdb.ah, pos);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'campos' { pos } } ];
    end
    
    function camva(pdb, va)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      camva(pdb.ah, va);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'camva' { va } } ];
    end
    
    function camtarget(pdb, tar)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      camtarget(pdb.ah, tar);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'camtarget' { tar } } ];
    end
    
    function colormap(pdb, map)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      colormap(pdb.ah, map);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'colormap' { map } } ];
    end
    
    function paper_size(pdb, psize)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      assert(isnumeric(psize) && numel(psize)==2, ...
        '%s: paper size must be a vector with two elements [w h]', mfilename);
      
      pdb.curr_plot.PaperSize = psize;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'paper_size' {psize} } ];
    end
    
    function plot_margin(pdb, margin)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      assert(isnumeric(margin) && numel(margin)==4, ...
        '%s: margin must be a vector with four elements [l b r t]', mfilename);
      
      pdb.curr_plot.margin = margin;
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'plot_margin' {margin} } ];
    end
    
    function lighting(pdb, type, color)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      if nargin<3
        color = [1 1 1];
      end
      lighting(pdb.ah, type);
      set(pdb.ah, 'AmbientLightColor', color)
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'lighting' { type color } } ];
    end
    
    function light(pdb, pos, color)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      set(pdb.fh, 'CurrentAxes', pdb.ah)
      light('Position', pos, 'Color', color);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'light' { pos color } } ];
    end
    
    function material(pdb, type)
      assert(pdb.isplotting, '%s: create/open plot first', mfilename)
      
      material(type);
      pdb.plot_update();
      pdb.curr_plot.cmds = [ pdb.curr_plot.cmds ; { 'material' { type } } ];
    end
    
  end
  
  methods (Access=public) % database edit functions
    
    function plot_list(pdb, field)
      if nargin<2
        field = 'db';
      end
      
      if strcmp(field, 'trash')
        pdb.plot_list_trash();
      else
        plots = fieldnames(pdb.(field));
        for i=1:numel(plots)
          cp = pdb.(field).(plots{i});
          fprintf('%-20s [%s]\n', cp.name, cp.id);
        end
      end
    end
    
    function plot_view(pdb, name, field)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      assert(isfield(pdb.db, name), '%s: plot ''%s'' not found', ...
        mfilename, name);
      
      if nargin<3
        field = 'db';
      end
      
      if strcmp(field, 'trash')
        pdb.plot_view_trash(name);
      else
        cp = pdb.(field).(name);
        try
          pdb.plot_init(cp.name, cp.id);
          pdb.paper_set_size(cp.PaperSize);
          pdb.plot_draw(cp);
          pdb.plot_exit();
        catch e
          pdb.plot_exit();
          rethrow e;
        end
      end
    end
    
    function plot_rename(pdb, src, dst)
      assert(isfield(pdb.db, src), '%s: plot ''%s'' not found', ...
        mfilename, src);
      assert(~isfield(pdb.db, dst), '%s: plot ''%s'' exists', ...
        mfilename, dst)
      pdb.db.(dst) = pdb.db.(src);
      pdb.db.(dst).name = dst;
      pdb.db = rmfield(pdb.db, src);
      pdb.save_db();
    end
    
    function plot_copy(pdb, src, dst)
      assert(isfield(pdb.db, src), '%s: plot ''%s'' not found', ...
        mfilename, src);
      assert(~isfield(pdb.db, dst), '%s: plot ''%s'' exists', ...
        mfilename, dst)
      pdb.db.(dst) = pdb.db.(src);
      pdb.db.(dst).name = dst;
      pdb.save_db();
    end
    
    function plot_chown(pdb, name, owner)
      assert(isfield(pdb.db, name), '%s: plot ''%s'' not found', ...
        mfilename, name);
      [pdb.db.(name).id ownerOK] = pdb.plot_id(name, owner); %#ok<NASGU>
      pdb.save_db();
    end
    
    function plot_swap(pdb, p1, p2)
      assert(isfield(pdb.db, p1), '%s: plot ''%s'' not found', ...
        mfilename, src);
      assert(isfield(pdb.db, p2), '%s: plot ''%s'' not found', ...
        mfilename, src);
      tmp         = pdb.db.(p1);
      pdb.db.(p1) = pdb.db.(p2);
      pdb.db.(p2) = tmp;
      pdb.save_db();
    end
    
    function plot_delete(pdb, name)
      if isfield(pdb.db, name)
        trashid = sprintf('trash%03d_%s', pdb.trash.nextid, name);
        pdb.trash.nextid = pdb.trash.nextid+1;
        pdb.trash.(trashid) = pdb.db.(name);
        pdb.db = rmfield(pdb.db, name);
        pdb.save_db();
      end
    end
    
    function plot_list_trash(pdb)
      plots = fieldnames(pdb.trash);
      idx   = strncmp('trash', plots, length('trash'));
      plots = plots(idx);
      for i=1:numel(plots)
        cp = pdb.trash.(plots{i});
        fprintf('% 3d : %-20s [%s]\n', ...
          sscanf(strtok(plots{i}, '_'),'trash%d'), cp.name, cp.id);
      end
    end
    
    function plot_empty_trash(pdb)
      pdb.trash = struct('nextid', 1);
    end
    
    function plot_view_trash(pdb, trnum)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      assert(isnumeric(trnum) && isscalar(trnum) && mod(trnum,1)==0, ...
        '%s: plot number must be an integer', mfilename);
      
      plots = fieldnames(pdb.trash);
      trid  = sprintf('trash%03d', trnum);
      idx   = strncmp(trid, plots, length(trid));
      name  = plots{idx};
      
      assert(isfield(pdb.trash, name), '%s: plot ''%s'' not found', ...
        mfilename, name);
      
      cp = pdb.trash.(name);
      try
        pdb.plot_init(cp.name, cp.id);
        pdb.paper_set_size(cp.PaperSize);
        pdb.plot_draw(cp);
        pdb.plot_exit();
      catch e
        pdb.plot_exit();
        rethrow e;
      end
    end
    
    function plot_restore(pdb, trnum, dst)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      assert(~isfield(pdb.db, dst), '%s: plot ''%s'' exists', ...
        mfilename, dst)
      assert(isnumeric(trnum) && isscalar(trnum) && mod(trnum,1)==0, ...
        '%s: plot number must be an integer', mfilename);
      
      plots = fieldnames(pdb.trash);
      trid  = sprintf('trash%03d', trnum);
      idx   = strncmp(trid, plots, length(trid));
      name  = plots{idx};
      
      assert(isfield(pdb.trash, name), '%s: plot ''%s'' not found', ...
        mfilename, name);
      
      pdb.db.(dst) = pdb.trash.(name);
      pdb.trash    = rmfield(pdb.trash, name);
      pdb.save_db();
    end
    
    function plot_open_owner(pdb, name)
      S = warning('off', 'backtrace');
      if nargin<2
        names = fieldnames(pdb.db);
        for i=1:numel(names)
          [fname flag] = pdb.find_owner(pdb.db.(names{i}).id);
          if flag
            open(fname)
          else
            warning('%s: owner ''%s'' of plot ''%s'' not found', mfilename, ...
              pdb.db.(names{i}).id, names{i}); %#ok<WNTAG>
          end
        end
        names = fieldnames(pdb.tmplt);
        for i=1:numel(names)
          [fname flag] = pdb.find_owner(pdb.tmplt.(names{i}).id);
          if flag
            open(fname)
          else
            warning('%s: owner ''%s'' of plot ''%s'' not found', mfilename, ...
              pdb.db.(names{i}).id, names{i}); %#ok<WNTAG>
          end
        end
      else
        if isfield(pdb.db, name)
          [fname flag] = pdb.find_owner(pdb.db.(name).id);
        elseif isfield(pdb.tmplt, name)
          [fname flag] = pdb.find_owner(pdb.tmplt.(name).id);
        else
          flag = false;
        end
        if flag
          open(fname)
        else
          warning('%s: owner ''%s'' of plot ''%s'' not found', mfilename, ...
            pdb.db.(name).id, name); %#ok<WNTAG>
        end
      end
      warning(S.state, 'backtrace');
    end
    
    function bbox_old = plot_bbox(pdb, name, bbox)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      assert(isfield(pdb.db, name), '%s: plot ''%s'' not found', ...
        mfilename, name);
      
      bbox_old = pdb.db.(name).bbox;
      if nargin>=3
        if isempty(bbox)
          pdb.db.(name).bbox(1) = [];
        else
          pdb.db.(name).bbox{1} = bbox;
        end
        pdb.save_db();
      end
      
    end
    
    function plot_set_bbox(pdb, name)
      bbox = pdb.plot_bbox(name);
      pdb.plot_bbox(name, bbox{3});
      pdb.replot(name);
    end
    
    function plot_align_axes(pdb, plots)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      [rows cols] = size(plots);
      
      % align columns
      for col = 1:cols
        bbox = pdb.plot_bbox(plots{1,col});
        dx1  = bbox{3}(1);
        dx2  = bbox{3}(3);
        for row = 2:rows
          bbox = pdb.plot_bbox(plots{row,col});
          dx1  = max(dx1, bbox{3}(1));
          dx2  = max(dx2, bbox{3}(3));
        end
        for row = 1:rows
          bbox = pdb.plot_bbox(plots{row,col});
          bbox{1}(1) = dx1;
          bbox{1}(3) = dx2;
          pdb.plot_bbox(plots{row,col}, bbox{1});
        end
      end
      
      % align rows
      for row = 1:rows
        bbox = pdb.plot_bbox(plots{row,1});
        dy1  = bbox{3}(2);
        dy2  = bbox{3}(4);
        for col = 2:cols
          bbox = pdb.plot_bbox(plots{row,col});
          dy1  = max(dy1, bbox{3}(2));
          dy2  = max(dy2, bbox{3}(4));
        end
        for col = 1:cols
          bbox = pdb.plot_bbox(plots{row,col});
          bbox{1}(2) = dy1;
          bbox{1}(4) = dy2;
          pdb.plot_bbox(plots{row,col}, bbox{1});
        end
      end
      
      % replot all figures
      for i=1:numel(plots)
        pdb.replot(plots{i});
      end
      
    end
    
    function plot_align_all_axes(pdb, plots)
      assert(~pdb.isplotting, '%s: close current plot first', mfilename)
      nplots = numel(plots);
      
      % align widths
      bbox = pdb.plot_bbox(plots{1});
      dx1  = bbox{3}(1);
      dx2  = bbox{3}(3);
      for k = 2:nplots
        bbox = pdb.plot_bbox(plots{k});
        dx1  = max(dx1, bbox{3}(1));
        dx2  = max(dx2, bbox{3}(3));
      end
      for k = 1:nplots
        bbox = pdb.plot_bbox(plots{k});
        bbox{1}(1) = dx1;
        bbox{1}(3) = dx2;
        pdb.plot_bbox(plots{k}, bbox{1});
      end
      
      % align heights
      bbox = pdb.plot_bbox(plots{1});
      dy1  = bbox{3}(2);
      dy2  = bbox{3}(4);
      for k = 2:nplots
        bbox = pdb.plot_bbox(plots{k});
        dy1  = max(dy1, bbox{3}(2));
        dy2  = max(dy2, bbox{3}(4));
      end
      for k = 1:nplots
        bbox = pdb.plot_bbox(plots{k});
        bbox{1}(2) = dy1;
        bbox{1}(4) = dy2;
        pdb.plot_bbox(plots{k}, bbox{1});
      end
      
      % replot all figures
      for i=1:numel(plots)
        pdb.replot(plots{i});
      end
      
    end
    
  end
  
  methods (Static, Access=public) % configuration function
    
    function set_db_path(figpath, mode)
      [cfgfile dbname] = plotdb.get_cfg();
      
      if nargin<2
        mode = plotdb.mode_ro;
      end
      assert(any(strcmpi(mode, { plotdb.mode_ro plotdb.mode_rw })), ...
        '%s: illegal mode, legal modes are ''%s'' and ''%s''', ...
        mfilename, plotdb.mode_ro, plotdb.mode_rw);
      
      figpath1 = figpath;
      figfile1 = fullfile(figpath1, dbname);
      mode1    = mode;
      
      if ~(exist(figfile1, 'file')==2) && strcmpi(mode1, plotdb.mode_rw)
        db    = struct(); %#ok<PROP,NASGU>
        trash = struct(); %#ok<PROP,NASGU>
        save(figfile1, 'db', 'trash');
      end
      save(cfgfile, 'figpath1', 'figfile1', 'mode1');
      
      fprintf('%s: figpath = ''%s''\n', mfilename, figpath1);
      fprintf('%s: dbfile  = ''%s''\n', mfilename, figfile1);
      fprintf('%s: configured figure data base with access ''%s''\n', ...
        mfilename, mode1);
    end
    
  end
  
  methods (Static, Access=private) % data base path functions
    
    function [cfgfile dbname] = get_cfg()
      cfgfile = mfilename('fullpath');
      cfgfile = fileparts(cfgfile);
      cfgfile = fullfile(cfgfile, 'figpath.mat');
      dbname  = 'plotdb.mat';
    end
    
  end
  
  methods (Access=private) % data base construction/destruction functions
    
    function init(pdb, fhan)
      pdb.init_paths();
      pdb.init_rc();
      pdb.init_db();
      pdb.fh = figure(fhan);
      clf(pdb.fh, 'reset');
      pdb.ah = axes();
      cla(pdb.ah,'reset');
      set(pdb.fh, 'Name', 'Plot DB', 'NumberTitle', 'off');
    end
    
    function init_paths(pdb)
      [cfgfile dbname] = pdb.get_cfg();
      
      if exist(cfgfile, 'file')==2
        load(cfgfile, 'figpath1', 'figfile1', 'mode1');
      else
        figpath1 = '';
        figfile1 = '';
        mode1    = plotdb.mode_ro;
      end
      
      figpath2 = pwd;
      figfile2 = fullfile(figpath2, dbname);
      
      if strcmp(figfile1, figfile2)
        pdb.figpath    = figpath1;
        pdb.dbfile     = figfile1;
        pdb.isreadonly = strcmpi(mode1, plotdb.mode_ro);
      else
        if exist(figfile2, 'file')==2
          pdb.figpath    = figpath2;
          pdb.dbfile     = figfile2;
          pdb.isreadonly = false;
        elseif ~isempty(figfile1)
          pdb.dbfile     = figfile1;
          pdb.figpath    = figpath1;
          pdb.isreadonly = strcmpi(mode1, plotdb.mode_ro);
        else
          pdb.figpath    = figpath2;
          pdb.dbfile     = figfile2;
          pdb.isreadonly = false;
        end
      end
      
      fprintf('%s: figpath = ''%s''\n', mfilename, pdb.figpath);
      fprintf('%s: dbfile  = ''%s''\n', mfilename, pdb.dbfile);
      if pdb.isreadonly
        fprintf('%s: access  = ''%s''\n', mfilename, plotdb.mode_ro);
      else
        fprintf('%s: access  = ''%s''\n', mfilename, plotdb.mode_rw);
      end
    end
    
    function init_db(pdb)
      if exist(pdb.dbfile, 'file')==2
        vars = who('-file', pdb.dbfile);
        vars = intersect(vars, { 'db' 'tmplt' 'trash' 'style'});
        data = load(pdb.dbfile, vars{:});
        for i=1:numel(vars)
          pdb.(vars{i}) = data.(vars{i});
        end
        fprintf('%s: data base loaded\n', mfilename);
        lockfile = fullfile(fileparts(pdb.dbfile), 'lock.txt');
        if exist(lockfile, 'file')==2
          pdb.isreadonly = true;
          fprintf('%s: data base was locked, changing access to ''%s''\n', ...
            mfilename, pdb.mode_ro);
        else
          pdb.has_lock = true;
          fhan = fopen(lockfile, 'w');
          fprintf(fhan, 'created by %s on %s\n', mfilename, ...
            datestr(now, 'dd-mmm-yyyy HH:MM:SS'));
          fclose(fhan);
        end
      else
        fprintf('%s: no data base found\n', mfilename);
      end
    end
    
    function save_db(pdb)
      if ~pdb.isreadonly
        db    = pdb.db; %#ok<PROP,NASGU>
        trash = pdb.trash; %#ok<PROP,NASGU>
        tmplt = pdb.tmplt; %#ok<PROP,NASGU>
        style = pdb.style; %#ok<PROP,NASGU>
        save(pdb.dbfile, 'db', 'trash', 'tmplt', 'style');
      end
    end
    
    function delete(pdb)
      if pdb.has_lock
        lockfile = fullfile(fileparts(pdb.dbfile), 'lock.txt');
        delete(lockfile);
      end
      for i=1:numel(pdb.ws)
        warning(pdb.ws(i).state, pdb.ws(i).identifier);
      end
      fprintf('%s: data base closed\n', mfilename);
      if pdb.fcl
        close(pdb.fh);
      end
    end
    
  end
  
  methods (Access=private) % data base gateway functions
    
    function [id ownerOK] = plot_id(pdb, name, owner, field)
      if nargin<4
        field = 'db';
      end
      
      id = '';
      while ~isempty(owner)
        [owner nm ext] = fileparts(owner);
        if any(strcmp(nm, pdb.roots))
          break
        end
        if isempty(id)
          if isempty(ext)
            id = nm;
          else
            id = [nm ext];
          end
        else
          if isempty(ext)
            id = sprintf('%s/%s', nm, id);
          else
            id = sprintf('%s%s/%s', nm, ext, id);
          end
        end
      end
      
      ownerOK = true;
      if isfield(pdb.(field), name)
        ownerOK = strcmpi(id, pdb.(field).(name).id);
        if nargout<2
          assert(ownerOK, ...
            '%s: plot/template/style with name ''%s'' already exists', ...
            mfilename, name);
        end
      end
    end
    
    function [fname flag] = find_owner(pdb, id)
      root = pwd;
      while ~isempty(root)
        fname = sprintf('%s.m', fullfile(root, id));
        flag = (2==exist(fname, 'file'));
        if flag
          return
        end
        [root nm] = fileparts(root);
        if any(strcmp(nm, pdb.roots))
          break
        end
      end
      if nargout<2
        error('%s: creator for id=''%s'' not found', mfilename, id);
      end
    end
    
    function plot_init(pdb, name, id, varargin)
      pdb.isplotting = true;
      pdb.init_curr_plot(name, id, varargin{:});
      clf(pdb.fh, 'reset');
      set(pdb.fh, 'Color', [1 1 1]);
      pdb.ah = axes();
      set(pdb.fh, 'Name', name);
      cla(pdb.ah,'reset');
      % see also paper_set_pos
      if ~isempty(pdb.curr_plot.bbox{1})
        iset = pdb.curr_plot.bbox{1};
        set(pdb.ah, 'Position', [iset(1:2) 1-iset(1:2)-iset(3:4)]);
        drawnow
      end
      pdb.plot_update();
    end
    
    function plot_update(pdb)
      [a b] = view;
      mode = pdb.curr_plot.axis{1};
      switch mode
        case 'normal'
          axis(pdb.ah, pdb.curr_plot.axis{2});
        case '+'
          border = pdb.curr_plot.axis{2};
          axis(pdb.ah, 'tight');
          if numel(border) == 2
            limits = [ get(pdb.ah, 'XLim') get(pdb.ah, 'YLim')];
          else
            limits = [ get(pdb.ah, 'XLim') get(pdb.ah, 'YLim')  get(pdb.ah, 'ZLim')];
          end
          for i=1:numel(border)
            d = 0.5*border(i)*(limits(2*i)-limits(2*i-1));
            limits(2*i-1) = limits(2*i-1)-d;
            limits(2*i)   = limits(2*i)  +d;
          end
          axis(pdb.ah, limits);
      end
      set(pdb.ah, pdb.curr_plot.axis{3:end});
      set(pdb.ah, pdb.curr_plot.box {:}    );
      set(pdb.ah, pdb.curr_plot.grid{:}    );
      view(a,b);
      drawnow
    end
    
    function plot_draw(pdb, name)
      if isstruct(name)
        pdb.plot_exec(name.cmds);
      elseif isfield(pdb.db, name)
        cp = pdb.db.(name);
        pdb.plot_exec(cp.cmds);
      end
    end
    
    function plot_exec(pdb, cmds)
      if ~isempty(cmds)
        cmdlist = cmds(:,1);
        f       = @(x) any(strcmpi(x, {'axis' 'view' 'xyz_axis' 'colormap' ...
          'camproj' 'campos' 'camva' 'camtarget'}));
        second  = cellfun(f, cmdlist);
        f       = @(x) any(strcmpi(x, {'textarrow' 'textbox'}));
        last    = cellfun(f, cmdlist);
        first   = ~( second | last );
        for k=find(first)'
          cmd = cmds{k,1};
          arg = cmds{k,2};
          pdb.(cmd)(arg{:});
        end
        for k=find(second)'
          cmd = cmds{k,1};
          arg = cmds{k,2};
          pdb.(cmd)(arg{:});
        end
        for k=find(last)'
          cmd = cmds{k,1};
          arg = cmds{k,2};
          pdb.(cmd)(arg{:});
        end
      end
    end
    
    function plot_save(pdb)
      if ~pdb.isreadonly
        plotfile = fullfile(pdb.figpath, pdb.curr_plot.name);
        pdb.paper_set_pos(pdb.curr_plot.PaperSize);
        pdb.save_db();
        print('-dpdf', plotfile);
        % print('-djpeg90', '-r150', plotfile);
        % saveas(pdb.fh, plotfile, 'fig');
        fprintf('%s: saved figure ''%s''\n', mfilename, pdb.curr_plot.name);
      end
    end
    
    function data = plot_window_init(pdb)
      data.wstyle = get(pdb.fh, 'WindowStyle');
      set(pdb.fh, 'WindowStyle', 'normal');
      drawnow
      data.fpos = get(pdb.fh, 'Position');
    end

    function plot_window_restore(pdb, data)
      set(pdb.fh, 'Position', data.fpos);
      drawnow
      set(pdb.fh, 'WindowStyle', data.wstyle);
    end
    
    function paper_set_size(pdb, psize)
      if strcmp(get(pdb.fh, 'WindowStyle'), 'normal')
        fw   = psize(1)*100;
        fh   = psize(2)*100; %#ok<PROP>
        fpos = get(pdb.fh, 'Position');
        set(pdb.fh, 'Position', [fpos(1) fpos(2)+fpos(4)-fh fw fh]); %#ok<PROP>
        drawnow
      end
    end

    function paper_set_pos(pdb, psize)
      pw = psize(1);
      ph = psize(2);
      set(pdb.fh, 'PaperUnits', 'inches');
      set(pdb.fh, 'PaperSize', psize);
      
      % opos = get(pdb.ah, 'OuterPosition');
      
      if isempty(pdb.curr_plot.bbox{1})
        bbox = get(pdb.ah, 'Position');
        iset = get(pdb.ah, 'TightInset');
        marg = pdb.curr_plot.margin;
        iset(1:2) = iset(1:2)+marg(1:2);
        iset(3:4) = iset(3:4)+marg(3:4);
        pdb.db.(pdb.curr_plot.name).bbox{2} = bbox;
        pdb.db.(pdb.curr_plot.name).bbox{3} = iset;
        
        bbox(1:2) = bbox(1:2)-iset(1:2);
        bbox(3:4) = bbox(3:4)+iset(1:2)+iset(3:4);
        
        l = -pw*bbox(1)/bbox(3);
        b = -ph*bbox(2)/bbox(4);
        w =  pw/bbox(3);
        h =  ph/bbox(4);
      else
        % iset = pdb.curr_plot.bbox{1};
        l = 0;
        b = 0;
        w = pw;
        h = ph;
      end
      
      set(pdb.fh, 'PaperPosition', [l b w h]);
      drawnow
      
    end

    function plot_exit(pdb)  
      pdb.isplotting = false;
      pdb.curr_plot  = struct();
    end
    
  end
  
  methods (Access=private) % plot resources
    
    function init_curr_plot(pdb, name, id, flag)
      pdb.curr_plot  = struct('name', name, 'id', id, ...
        'cmds', { {} }, 'box', {pdb.rc.box_on}, 'grid', {pdb.rc.grid_on}, ...
        'axis', {['normal' 'tight' pdb.rc.axis]}, 'PaperSize', [8 6], ...
        'margin', [0 0 0 0], 'bbox', {{[];[];[]}});
      if ~(nargin>=4 && strcmpi(flag, 'reset')) ...
          && isfield(pdb.db, name) && isfield(pdb.db.(name), 'bbox')
        pdb.curr_plot.bbox = pdb.db.(name).bbox;
      end
    end
    
    function init_rc(pdb)
      
      prc = struct('default', {{}});
      
      prc = add_colors(prc);
      prc = add_font_sizes(prc);
      prc = add_font_names(prc);
      
      prc = add_lines(prc);
      prc = add_markers(prc);
      prc = add_quivers(prc);
      
      prc = add_texts(prc);
      prc = add_boxes(prc);
      prc = add_arrows(prc);
      
      prc = add_axes_props(prc);
      
      pdb.rc = prc;
    end
    
  end
  
end

function prc = add_colors(prc)
white      = [1 1 1];
prc.grey10 = 0.9*white;
prc.grey20 = 0.8*white;
prc.grey30 = 0.7*white;
prc.grey40 = 0.6*white;
prc.grey50 = 0.5*white;
prc.grey60 = 0.4*white;
prc.grey70 = 0.3*white;
prc.grey80 = 0.2*white;
prc.grey90 = 0.1*white;
end

function prc = add_font_names(prc)
prc.font_name = 'Helvetica';
% prc.font_name = 'Helvetica Narrow';
end

function prc = add_font_sizes(prc)
prc.nmm  = 2;
prc.szm1 = 33;
prc.szm2 = 30;
prc.szm3 = 27;

prc.nmt  = 4;
prc.szt1 = 24;
prc.szt2 = 22;
prc.szt3 = 20;
prc.szt4 = 18;
end

function prc = add_lines(prc)
lw = [2 sqrt(2) 1];
ls = {'-' '--' ':'};

stnum = 1;
for i=1:numel(ls)
  for j=1:numel(lw)
    style       = sprintf('none%d', stnum);
    prc.(style) = {'LineStyle', 'none', 'LineWidth', lw(j), 'Color', 'black'};
    style       = sprintf('line%d', stnum);
    prc.(style) = {'LineStyle', ls{i}, 'LineWidth', lw(j), 'Color', 'black'};
    style       = sprintf('line%dw', stnum);
    prc.(style) = {'LineStyle', ls{i}, 'LineWidth', lw(j), 'Color', 'white'};
    for k=1:9
      color       = sprintf('grey%d', 10*k);
      style       = sprintf('line%dg%d', stnum, k);
      prc.(style) = {'LineStyle', ls{i}, 'LineWidth', lw(j), 'Color', prc.(color)};
      style       = sprintf('none%dg%d', stnum, k);
      prc.(style) = {'LineStyle', 'none', 'LineWidth', lw(j), 'Color', prc.(color)};
    end
    stnum = stnum + 1;
  end
end
end

function prc = add_markers(prc)
prc.marker1s  = {'Marker', '.', 'MarkerSize', 9};
prc.marker2s  = {'Marker', '.', 'MarkerSize', 9, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker3s  = {'Marker', '*', 'MarkerSize', 6, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker4s  = {'Marker', 'o', 'MarkerSize', 6, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'white'};
prc.marker5s  = {'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'white'};
prc.marker6s  = {'Marker', 'x', 'MarkerSize', 6};

prc.marker1   = {'Marker', '.', 'MarkerSize', 12};
prc.marker2   = {'Marker', '.', 'MarkerSize', 12, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker3   = {'Marker', '*', 'MarkerSize', 8, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker4   = {'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'white'};
prc.marker5   = {'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'white'};
prc.marker6   = {'Marker', 'x', 'MarkerSize', 8};

prc.marker1l  = {'Marker', '.', 'MarkerSize', 15};
prc.marker2l  = {'Marker', '.', 'MarkerSize', 15, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker3l  = {'Marker', '*', 'MarkerSize', 9.5, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'black'};
prc.marker4l  = {'Marker', 'o', 'MarkerSize', 9.5, 'MarkerEdgeColor', ...
  'black', 'MarkerFaceColor', 'white'};
prc.marker5l  = {'Marker', 'o', 'MarkerSize', 9.5, 'MarkerFaceColor', 'white'};
prc.marker6l  = {'Marker', 'x', 'MarkerSize', 9.5};
end

function prc = add_quivers(prc)
prc.qvr_line1 = {'LineStyle', '-', 'LineWidth',   1, 'Color', prc.grey70};
prc.qvr_line2 = {'LineStyle', '-', 'LineWidth', 0.5, 'Color', prc.grey70};

prc.qvr_arrow1 = {'ShowArrowHead', 'off', 'MaxHeadSize', 0.2};
prc.qvr_arrow2 = {'ShowArrowHead', 'on',  'MaxHeadSize', 0.2};

prc.qvr_marker1 = {'Marker', 'none', 'MarkerEdgeColor', 'auto', ...
  'MarkerFaceColor', 'auto', 'MarkerSize', 9};
prc.qvr_marker2 = {'Marker', '.', 'MarkerEdgeColor', 'auto', ...
  'MarkerFaceColor', 'auto', 'MarkerSize', 9};
end

function prc = add_texts(prc)
for i=1:prc.nmm
  sz          = sprintf('szm%d', i);
  style       = sprintf('math%d', i);
  prc.(style) = {'FontSize', prc.(sz), 'Interpreter', 'LaTeX', 'Color', ...
    'black', 'BackgroundColor', 'none', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
end
for i=1:prc.nmt
  sz          = sprintf('szt%d', i);
  style       = sprintf('text%d', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'normal', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'none', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('text%dd', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'demi', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'none', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('text%db', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'bold', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'none', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('text%dl', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'light', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'none', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};

  style       = sprintf('textw%d', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'normal', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'white', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('textw%dd', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'demi', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'white', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('textw%db', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'bold', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'white', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
  style       = sprintf('textw%dl', i);
  prc.(style) = {'FontSize', prc.(sz), 'FontName', prc.font_name, ...
    'FontWeight', 'light', 'Interpreter', 'none', 'Color', 'black', ...
    'BackgroundColor', 'white', 'EdgeColor', 'none', ...
    'LineStyle', '-', 'LineWidth', 1, 'Margin', 0.5, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline'};
end
end

function prc = add_boxes(prc)
for i=1:prc.nmm
  sz          = sprintf('szm%d', i);
  style       = sprintf('box_math%d', i);
  prc.(style) = {'FontSize', prc.(sz), 'TextColor', 'black', 'Interpreter', ...
  'LaTeX', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
  style       = sprintf('box_math%db', i); % bold is virtual, test for 'b' at end
  prc.(style) = {'FontSize', prc.(sz), 'TextColor', 'black', 'Interpreter', ...
  'LaTeX', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
end
for i=1:prc.nmt
  sz          = sprintf('szt%d', i);
  style       = sprintf('box_text%d', i);
  prc.(style) = {'FontName', prc.font_name, 'FontSize', prc.(sz), ...
  'FontWeight', 'normal', 'TextColor', 'black', 'Interpreter', 'none', ...
  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
  style       = sprintf('box_text%dd', i);
  prc.(style) = {'FontName', prc.font_name, 'FontSize', prc.(sz), ...
  'FontWeight', 'demi', 'TextColor', 'black', 'Interpreter', 'none', ...
  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
  style       = sprintf('box_text%db', i);
  prc.(style) = {'FontName', prc.font_name, 'FontSize', prc.(sz), ...
  'FontWeight', 'bold', 'TextColor', 'black', 'Interpreter', 'none', ...
  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
  style       = sprintf('box_text%dl', i);
  prc.(style) = {'FontName', prc.font_name, 'FontSize', prc.(sz), ...
  'FontWeight', 'light', 'TextColor', 'black', 'Interpreter', 'none', ...
  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
end
prc.box_box1   = {'EdgeColor', 'none', 'LineWidth', 0.5, ...
  'Margin', 0, 'BackgroundColor', 'none', 'FitBoxToText', 'on'};
prc.box_box2   = {'EdgeColor', 'black', 'LineWidth', 0.5, ...
  'Margin', 0, 'BackgroundColor', 'white', 'FitBoxToText', 'on'};
% style used in print_test_page
prc.box_text5  = {'FontName', 'Courier', 'FontSize', 16, ...
  'FontWeight', 'normal', 'TextColor', 'black', 'Interpreter', 'none', ...
  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'};
end

function prc = add_arrows(prc)
for i=1:prc.nmm
  bstyle       = sprintf('box_math%d', i);
  astyle       = sprintf('arr_math%d', i);
  prc.(astyle) = prc.(bstyle);
end
for i=1:prc.nmt
  bstyle       = sprintf('box_text%d', i);
  astyle       = sprintf('arr_text%d', i);
  prc.(astyle) = prc.(bstyle);
  bstyle       = sprintf('box_text%dd', i);
  astyle       = sprintf('arr_text%dd', i);
  prc.(astyle) = prc.(bstyle);
  bstyle       = sprintf('box_text%db', i);
  astyle       = sprintf('arr_text%db', i);
  prc.(astyle) = prc.(bstyle);
  bstyle       = sprintf('box_text%dl', i);
  astyle       = sprintf('arr_text%dl', i);
  prc.(astyle) = prc.(bstyle);
end
prc.arr_box1  = {'TextEdgeColor', 'none', 'TextLineWidth', 0.5, ...
  'TextMargin', 0, 'TextBackgroundColor', 'none'};
prc.arr_box2  = {'TextEdgeColor', 'black', 'TextLineWidth', 0.5, ...
  'TextMargin', 0, 'TextBackgroundColor', 'white'};
prc.arr_arrow1 = {'HeadStyle', 'plain', 'HeadLength', 8.0, ...
  'HeadWidth', 4.0, 'LineWidth', 1.0, 'Color', 'black'};
prc.arr_arrow2 = {'HeadStyle', 'none', 'LineWidth', 1.0, 'Color', 'black'};
end

function prc = add_axes_props(prc)
prc.box_on  = {'Box', 'on'};
prc.box_off = {'Box', 'off'};

prc.grid_on = {'GridLineStyle', ':', 'XGrid', 'on', ...
  'YGrid', 'on', 'ZGrid', 'on', 'XMinorGrid', 'off', 'YMinorGrid', ...
  'off', 'ZMinorGrid', 'off'};
prc.grid_off = {'GridLineStyle', ':', 'XGrid', 'off', ...
  'YGrid', 'off', 'ZGrid', 'off', 'XMinorGrid', 'off', 'YMinorGrid', ...
  'off', 'ZMinorGrid', 'off'};

prc.axis = {'FontName', prc.font_name, 'FontSize', prc.szt2, 'FontWeight', ...
  'normal', 'LineWidth', 0.75};
prc.equal = [prc.axis {'DataAspectRatio', [1 1 1], 'DataAspectRatioMode', ...
  'manual', 'PlotBoxAspectRatio', [3 4 4], 'PlotBoxAspectRatioMode', 'manual'}];

prc.lab_math = prc.math1;
prc.lab_text = prc.text2;
end

function varargout = str_deal(pref,list,defaults)
ii = min(nargout,numel(list));
for i=1:ii
  if isempty(pref)
    varargout{i} = list{i}; %#ok<AGROW>
  else
    varargout{i} = sprintf('%s_%s', pref, list{i}); %#ok<AGROW>
  end
end
for i=ii+1:nargout
  varargout{i} = defaults{i}; %#ok<AGROW>
end
end
