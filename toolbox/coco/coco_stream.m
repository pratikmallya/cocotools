classdef coco_stream < handle
  % COCO_STREAM convert cell array to stream object.
  
  properties ( Access = private )
    tokens = {}
  end
  
  methods
    
    function p = coco_stream(varargin)
      if nargin==1 && isa(varargin{1}, 'coco_stream')
        p = varargin{1};
      else
        p.tokens = varargin;
      end
    end
    
    function [t flag] = peek(p, varargin)
      if isempty(p.tokens)
        t    = [];
        flag = false;
      else
        t    = p.tokens{1};
        flag = true;
      end
      if nargin>=2 && strcmp('cell', varargin{1}) && ~iscell(t)
        t = { t };
      end
    end
    
    function varargout = get(p, varargin)
      for i=1:max(1,nargout)
        [varargout{i} flag] = p.peek(varargin{:});
        if flag
          p.tokens(1) = [];
        end
      end
    end
    
    function p = put(p, varargin)
      p.tokens = [varargin p.tokens];
    end
    
    function skip(p, n)
      if nargin==1
        p.tokens(1:min(1,end)) = [];
      else
        p.tokens(1:min(n,end)) = [];
      end
    end
    
    function flag = isempty(p)
      flag = isempty(p.tokens);
    end
    
    function n = numel(p)
      n = numel(p.tokens);
    end
    
  end
  
end
