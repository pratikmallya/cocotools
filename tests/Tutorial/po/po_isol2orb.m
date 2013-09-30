% varargin = { coll }
% coll = { @f [@dfdx [@dfdp]] t0 x0 [pnames] p0 }
%!po_isol2sol
function prob = po_isol2orb(prob, oid, varargin)

tbid   = coco_get_id(oid, 'po');
str    = coco_stream(varargin{:});
segoid = coco_get_id(tbid, 'seg');
prob   = coll_isol2seg(prob, segoid, str);

data = struct();
data = po_init_data(prob, tbid, data);
prob = po_close_orb(prob, tbid, data);

end %!end_po_isol2sol