function [prob data sol] = povar_sol2orb(prob, oid, varargin)

str   = coco_stream(varargin{:});
run   = str.get;
if ischar(str.peek)
  soid = str.get;
else
  soid = oid;
end
lab = str.get;

stbid = coco_get_id(soid, 'po.seg.var');
[data sol] = coco_read_solution(stbid, run, lab);
prob = po_sol2orb(prob, oid, run, soid, lab);
toid = coco_get_id(oid, 'po.seg');
prob = var_coll_add(prob, toid, data.dfdxdxhan, data.dfdxdphan);

end