% create and start a job for zipping the log file of a previous job

% Philipp Kortmann, 2023/02/26
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function zipJob(ssh2_conn, ps, bs, jobID)

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

%% Create a second job file for zipping the log file
jobfile = fullfile(ps.locPath, 'templateFiles', 'batchJob_log.sh');
fileID = fopen(jobfile, 'w');
for i = 1:length(s{1})
  line = s{1}{i};
  % exchange PBS variables (with other values than above)
  line = strrep(line, '?NODES?', '1');
  line = strrep(line, '?PPN?', '1');
  line = strrep(line, '?HOURS?', '0');
  line = strrep(line, '?MINUTES?', '10');
  line = strrep(line, '?MEMORY?', '1');
  line = strrep(line, '?NAME?', ['zip_log_', num2str(jobID)]);
  line = strrep(line, '?MAILADDRESS?', bs.mailName);
  line = strrep(line, '?MAILTYPE?', bs.mailType);
  if (strcmp(bs.scheduler, 'SLURM') && isempty(bs.queue)) && ...
      contains(line, '--partition=') % see createJobFile.m
    continue
  end
  % start after the first empty line. This marks the end of the scheduler
  % commands at the top of the script. Has to match the template files.
  if isempty(line), break; end
  % write batch file
  fprintf(fileID, '%s\n', line);
end

fprintf(fileID, 'LOGFILE=%s/%d.log\n', ps.extUploadFolderConcrete, jobID);
fprintf(fileID, 'if [ -f $LOGFILE ]; then\n');
fprintf(fileID, 'gzip $LOGFILE\n');
fprintf(fileID, 'fi\n');

%% Upload the zip job start file
cd(fullfile(ps.locPath, 'templateFiles'));
ssh2_conn = sftp_put(ssh2_conn, 'batchJob_log.sh', ...
  ps.extUploadFolderConcrete);
cd(fullfile(ps.locPath));

%% Start zip job
bs2 = bs;
bs2.batFileName = 'batchJob_log.sh';
startsettings = struct('afterany', jobID);
jobID2 = startJob(ssh2_conn, ps, bs2, startsettings);
fprintf('jobID for logging results: %d\n', jobID2);