dir_names = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

fname = mfilename('fullpath');
root  = fileparts(fname);

fprintf('Test 1: no directory exists:\n');
res1 = {};
for name = dir_names
  dir_name1 = name;
  dir_name2 = fullfile(root, 'data', name);
  dir_name3 = sprintf('%s\\data\\%s', root, name);
  res = { ...
    dir_name1, exist(dir_name1), ...
    dir_name2, exist(dir_name2), ...
    dir_name3, exist(dir_name3) ...
    }; %#ok<EXIST>
  fprintf('exist(''%s'')=%d, exist(''%s'')=%d, exist(''%s'')=%d\n', res{:});
  [mkstat mkmsg mkmsgid]=mkdir(dir_name2);
  [rmstat rmmsg rmmsgid]=rmdir(fullfile(root, 'data'), 's');
  res1 = [ res1 ; res {mkstat mkmsg mkmsgid rmstat rmmsg rmmsgid} ]; %#ok<AGROW>
end

fprintf('Test 2: directory ''data'' exists:\n');
[mkstat mkmsg mkmsgid]=mkdir(fullfile(root, 'data'));
if ~mkstat
  error(mkmsg);
end
res2 = {};
for name = dir_names
  dir_name1 = name;
  dir_name2 = fullfile(root, 'data', name);
  dir_name3 = sprintf('%s\\data\\%s', root, name);
  res = { ...
    dir_name1, exist(dir_name1), ...
    dir_name2, exist(dir_name2), ...
    dir_name3, exist(dir_name3) ...
    }; %#ok<EXIST>
  fprintf('exist(''%s'')=%d, exist(''%s'')=%d, exist(''%s'')=%d\n', res{:});
  [mkstat mkmsg mkmsgid]=mkdir(dir_name2);
  [rmstat rmmsg rmmsgid]=rmdir(dir_name2, 's');
  res2 = [ res2 ; res {mkstat mkmsg mkmsgid rmstat rmmsg rmmsgid} ]; %#ok<AGROW>
end

fprintf('Test 3: directory ''data/?'' exists:\n');
res3 = {};
for name = dir_names
  dir_name1 = name;
  dir_name2 = fullfile(root, 'data', name);
  dir_name3 = sprintf('%s\\data\\%s', root, name);
  [mkstat mkmsg mkmsgid]=mkdir(dir_name2);
  res = { ...
    dir_name1, exist(dir_name1), ...
    dir_name2, exist(dir_name2), ...
    dir_name3, exist(dir_name3) ...
    }; %#ok<EXIST>
  fprintf('exist(''%s'')=%d, exist(''%s'')=%d, exist(''%s'')=%d\n', res{:});
  [rmstat rmmsg rmmsgid]=rmdir(dir_name2, 's');
  res3 = [ res3 ; res {mkstat mkmsg mkmsgid rmstat rmmsg rmmsgid} ]; %#ok<AGROW>
end

rmdir(fullfile(root, 'data'), 's');

save 'results' res1 res2 res3;
