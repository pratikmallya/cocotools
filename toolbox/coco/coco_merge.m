function A = coco_merge(A, B, varargin)
% COCO_MERGE(A, B, [filter]) merge (selected) fields of B into A.
A = coco_opts_tree.merge(A, B, varargin{:});
end
