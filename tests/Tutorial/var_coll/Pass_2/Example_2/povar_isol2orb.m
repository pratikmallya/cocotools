function prob = povar_isol2orb(prob, oid, varargin)

str = coco_stream(varargin{:});
prob = po_isol2orb(prob, oid, str);
oid  = coco_get_id(oid, 'po.seg');
dfdxdxhan = str.get;
dfdxdphan = str.get;
prob = var_coll_add(prob, oid, dfdxdxhan, dfdxdphan);

end