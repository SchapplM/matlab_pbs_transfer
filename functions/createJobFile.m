% This function creates the batch-file for the demanded cluster job.
% Therefor a template textfile is opened and the relevant dummy
% variables are exchanged by the required values set in jobSettings.m.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function ps = createJobFile(bs, ps)

%% Load content of template batch file
if ~isfield(bs, 'scheduler')
  error('Field "scheduler" not defined for batch settings');
elseif strcmp(bs.scheduler, 'PBS')
  templatefile = fullfile(ps.locPath, 'templateFiles', 'batchJob_PBS.sh.template');
elseif strcmp(bs.scheduler, 'SLURM')
  templatefile = fullfile(ps.locPath, 'templateFiles', 'batchJob_SLURM.sh.template');
else
  error('Case "%s" not defined for batch setting "scheduler"', bs.scheduler);
end
fileID = fopen(templatefile, 'r');
s = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

%% Loop line-wise through batch script, post-process and save
ps.dateString = datestr(datetime('now'), 'yyyymmdd_HHMMSS');
ps.extUploadFolderConcrete = [ps.extUploadFolder, '/upload', ps.dateString];
[hours, minutes] = getHoursAndMinutes(bs.time);
% Open output file for writing
fileID = fopen(fullfile(ps.locUploadFolder, bs.batFileName), 'w');
for i = 1:length(s{1})
  line = s{1}{i};
  % exchange PBS variables
  line = strrep(line, '?NODES?', num2str(bs.nodes));
  line = strrep(line, '?PPN?', num2str(bs.ppn));
  line = strrep(line, '?HOURS?', hours);
  line = strrep(line, '?MINUTES?', minutes);
  line = strrep(line, '?MEMORY?', num2str(bs.mem));
  line = strrep(line, '?NAME?', bs.name);
  line = strrep(line, '?MAILADDRESS?', bs.mailName);
  line = strrep(line, '?MAILTYPE?', bs.mailType);
  % If using SLURM, using all partitions is done by leaving out the line
  % on a PBS cluster, the term "all" has to be entered by the user.
  if (strcmp(bs.scheduler, 'SLURM') && isempty(bs.queue)) && ...
      contains(line, '--partition=')
    continue
  end
  line = strrep(line, '?QUEUE?', bs.queue);
  % exchange other variables
  line = strrep(line, '?MATVERSION?', bs.matVersion);
  line = strrep(line, '?WORKDIR?', ps.extUploadFolderConcrete);
  line = strrep(line, '?MATFILE?', bs.matFileName);
  
  % write batch file
  fprintf(fileID, '%s\n', line);
end
fclose(fileID);
