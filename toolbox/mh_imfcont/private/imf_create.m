function opts = imf_create(opts, prefix, func)

%% save original function
fid  = coco_get_id(prefix, 'func');
opts = coco_add_slot(opts, fid, @coco_save_data,  func, 'save_full');

%% set up and initialise boundary conditions
[opts pidx] = imf_add_BC(opts, prefix);

%% add external parameters if top-level toolbox
if isempty(prefix)
  opts = coco_add_parameters(opts, prefix, pidx, 1:numel(pidx));
end

end

