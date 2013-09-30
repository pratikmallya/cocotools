function [opts hscont] = hscont_get_settings(opts, prefix)

fid    = coco_get_id(prefix, 'hscont');
hscont = coco_get(opts, fid);

defaults.collocation  = 'coll';
defaults.tf_weight    = 1.1;
defaults.bifurcations = 'off';

hscont = coco_set(defaults, hscont);

% switch vareqn on if necessary
if strcmp(hscont.bifurcations, 'on')
  fid  = coco_get_id(prefix, 'coll');
  coll = coco_get(opts, fid);
  if isfield(coll, 'vareqn')
    if strcmp(coll.vareqn, 'off')
      opts = coco_set(opts, fid, 'vareqn', 'track');
    end
  else
    opts = coco_set(opts, fid, 'vareqn', 'track');
  end
end

end
