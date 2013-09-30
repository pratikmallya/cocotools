function run_demo_recipes(name,omit)
logfile = sprintf('%s.log', name);
if exist(fullfile(pwd,logfile), 'file')
  delete(logfile);
end
diary(logfile)
diary on
%echo(name,'on')
run(name)
%echo(name,'off')
echo off
diary off
p = fileparts(mfilename('fullpath'));
p = fullfile(p, 'patch_demo');
if exist(fullfile(pwd,logfile), 'file');
  % system(sprintf('bash -c "source ~/.bashrc && %s %s"', p, name));
  % system(sprintf('bash -c "%s %s"', p, name));
  if nargin>=2
    width = [6 16 29];
    if ischar(omit)
      omit = str2num(omit); %#ok<ST2NM>
    end
    system(sprintf('%s %s %d %d', p, name, width(omit), omit));
  else
    system(sprintf('%s %s', p, name));
  end
end
end
