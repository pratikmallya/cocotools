classdef coco_parser_concept_study < handle
  % COCO_PARSER simple parser class.
  
  properties ( Access = private )
    tokens = {}
    idx    = 1
    num    = 0
  end
  
  methods
    
    function p = coco_parser(tokens)
      assert(nargin==1 && iscell(tokens), ...
        '%s: input must be a cell array', mfilename);
      p.tokens = tokens;
      p.num    = numel(tokens);
    end
    
% varargin = { @f [@dfdx [@dfdp]] t0 x0 p0 [mode [dx0]] ['end_coll'] }
    function varargout = parse(regexp)
      assert(ischar(regexp), ...
        '%s: parsing grammar must be a string', mfilename);
      i=1;
      n=length(regexp);
      out = {};
      while i<=n
        while regexp(i)==' '
          i = i+1;
        end
        switch regexp(i)
          case '('
            [i o] = p.parse_subexp(regexp, i);
          case '['
            [i o] = p.parse_optexp(regexp, i);
          case {'{' '}' '!'}
            error('%s: unexpected ''%c'' at position %d in parsing grammar', ...
              mfilename, regexp(i), i);
          otherwise
            [i o] = p.parse_token(regexp, i);
        end
        out = [ out o ]; %#ok<AGROW>
      end
      for i=1:numel(out)
        varargout{i} = out{i};
      end
    end
    
    function t = peek(p)
      if p.idx<=p.num
        t = p.tokens{p.idx};
      else
        t = [];
      end
    end
    
    function t = get(p)
      if p.idx<=p.num
        t = p.tokens{p.idx};
      else
        t = [];
      end
      p.idx = p.idx + 1;
    end
    
    function flag = isempty(p)
      flag = (p.idx>p.num);
    end
    
  end
  
  methods (Access = private)
    
    function [i o] = parse_token(p, regexp, i)
      switch regexp(i)
        
        case '@'
          if regexp(i+1) == '!'
            empty_flag = false;
            i          = i+1;
          else
            empty_flag = true;
          end
          [i cell_flag] = p.remove_token(regexp, i+1);
          t = p.peek;
          if cell_flag
            if ~iscell(t)
              t = { t };
            end
            e = empty_flag & cellfun('isempty', t);
            c = cellfun('isclass', t, 'function_handle');
          else
            e = empty_flag & isempty(t);
            c = isa(t, 'function_handle');
          end
          if all( e | c )
            o     = t;
            p.idx = p.idx+1;
          elseif empty_flag
            o = [];
          else
            error('%s: expected (cell array of) function handle(s) at position %d', ...
              mfilename, p.idx);
          end
          
        otherwise
          [i cell_flag] = p.remove_token(regexp, i);
          t = p.peek;
          if cell_flag && ~iscell(t)
            t = { t };
          end
          o     = t;
          p.idx = p.idx+1;
          
      end
    end
    
    function [i o] = parse_optexp(p, regexp, i)
    end
    
    function [i o] = parse_subexp(p, regexp, i)
    end
  end
  
  methods (Static = true, Access = private)
    
    function [i cell_flag] = remove_token(regexp, i)
      while ~any(regexp(i)=='{ ')
        i = i+1;
      end
      if regexp(i)=='{' && regexp(i+1)=='}'
        i = i+1;
        cell_flag = true;
      else
        cell_flag = fales;
      end
    end
    
  end
  
end

