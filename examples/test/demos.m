% test suite for coco toolboxes

tm = tic;

coco_test  = {  }; % test only these examples if non-empty

coco_demos = {'coneA' 'coneB' 'cusp' 'pitchfork' ... % alcont
  'coneD' ...                                        % empty toolbox
... %  'coneC' ...                                        % alcont + 2d-covering
  'bratu' 'pwlin' ...                                % bvp
  'impact' ...                                       % hscont
  'pneta' 'tor' ...                                  % pocont
  'pnet_imf' ...                                     % imfcont
  };

%% execute demos and generate report information

if ~isempty(coco_test)
  coco_demos = coco_test;
end

OK_demos  = {};
ERR_demos = {};

cur_dir = pwd;

for i=1:numel(coco_demos)
  coco_demo = coco_demos{i};
  fprintf('\n\n**************************************************\n');
  fprintf('running demo %s\n\n', coco_demo);
  
  cd(coco_demo);
  figure(1);
  
  try
    run 'demo';
    OK_demos = [ OK_demos ; { coco_demo } ]; %#ok<AGROW>
  catch exception
    ERR_demos = [ ERR_demos ; { coco_demo exception } ]; %#ok<AGROW>
  end
  
  cd(cur_dir);
end

%% issue report for each demo

fprintf('\n\n**************************************************\n');
fprintf('**************************************************\n\n');

tm = ceil(toc(tm)/60);
fprintf('Elapsed time for all demos is %d minutes.\n', tm);

fprintf('\nError messages\n');
fprintf('==============\n\n');

for i=1:size(ERR_demos, 1)
  fprintf('**************************************************\n');
  fprintf('Demo %s returned with error:\n\n', ERR_demos{i,1});
  fprintf(2, '%s\n', ERR_demos{i,2}.getReport());
end

fprintf('Summary\n');
fprintf('=======\n\n');

fprintf('Demos completed successfully\n');
fprintf('----------------------------\n');
for i=1:size(OK_demos, 1)
  fprintf(' %s', OK_demos{i});
end
fprintf('\n\n');

fprintf('Demos returning with error\n');
fprintf('--------------------------\n');
for i=1:size(ERR_demos, 1)
  fprintf(' %s', ERR_demos{i,1});
end
fprintf('\n\n');
fprintf('See individual error reports above.\n');
