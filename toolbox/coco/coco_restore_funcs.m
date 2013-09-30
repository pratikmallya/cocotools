function opts = coco_restore_funcs(opts, all_funcs)
opts.efunc = all_funcs.efunc;
opts.slots = all_funcs.slots;
if isfield(all_funcs, 'events')
  opts.efunc.events = all_funcs.events;
  opts.efunc.ev     = all_funcs.ev;
else
  if isfield(opts.efunc, 'events')
    opts.efunc = rmfield(opts.efunc, {'ev' 'events'});
  end
end
coco_func_data.pointers('set', all_funcs.ptrs);
end
