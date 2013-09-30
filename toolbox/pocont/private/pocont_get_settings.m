function [opts pocont] = pocont_get_settings(opts, prefix)

fid    = coco_get_id(prefix, 'pocont');
pocont = coco_get(opts, fid);

% bug: create file pocont_opts with documentation of the options below
defaults.collocation  = 'coll';
defaults.tf_weight    = 1.1;
defaults.bifurcations = 'off';
defaults.phase_cond   = 'internal';

pocont = coco_set(defaults, pocont);

% switch vareqn on if necessary
if strcmp(pocont.bifurcations, 'on')
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
