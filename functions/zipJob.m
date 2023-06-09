% create and start a job for zipping the log file of a previous job
% 
% Input:
% ssh2_conn
%   Object for the SSH connection
% ps
%   personal settings
% bs
%   batch settings
% jobID
%   ID of the job from which the log file shall be compressed
% startsettings_in [optional], struct. 
%   .waittime_max: maximum waiting time in case of no success for job start
%   .retry_interval: interval for retry of job start in seconds

% Moritz Schappler, 2023/02/26
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function zipJob(ssh2_conn, ps, bs, jobID, startsettings_in)

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
% Process settings for waiting time. Use the same waiting time for the zip
% job as for the previous productive job and the same default values
if nargin < 5
  startsettings_in = struct();
end
startsettings_gen = struct('waittime_max', 3600*3, 'retry_interval', 60);
for f = fields(startsettings_gen)'
  if isfield(startsettings_in, f{1})
    startsettings_gen.(f{1}) = startsettings_in.(f{1});
  end
end

fileID = fopen(templatefile, 'r');
s = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

%% Create a second job file for zipping the log file
jobfile = fullfile(ps.locPath, 'templateFiles', 'batchJob_ziplog.sh');
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
fprintf(fileID, 'LOGFILE=$(echo $SLURM_JOB_ID | cut -d"." -f1).log\n');
fprintf(fileID, 'LOGFILETOZIP=%d.log\n', jobID);
fprintf(fileID, 'cd %s\n', ps.extUploadFolderConcrete);
fprintf(fileID, 'echo "Zip job for log file $LOGFILETOZIP" > $LOGFILE\n');
fprintf(fileID, 'echo "Start: `date`" >> $LOGFILE\n');
fprintf(fileID, 'if [ -f $LOGFILETOZIP ]; then\n');
% Write verbosity output of gzip (going to stderr) to the log
fprintf(fileID, 'gzip $LOGFILETOZIP -v 2>> $LOGFILE\n');
fprintf(fileID, 'fi\n');
fprintf(fileID, 'echo "End: `date`" >> $LOGFILE\n');

%% Upload the zip job start file
cd(fullfile(ps.locPath, 'templateFiles'));
while true
  try
    ssh2_conn = sftp_put(ssh2_conn, 'batchJob_ziplog.sh', ...
      ps.extUploadFolderConcrete);
    break
  catch err
    if contains(err.message, 'Sorry, this connection is closed')
      pause(3); % short wait to avoid flooding the server with request
      disp('SSH connection was closed. Restart session.');
      ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);
      continue
    else
      warning('zipJob:SSH_error', 'Error uploading the zip job via ssh: %s', err.message);
    end
  end
end
cd(fullfile(ps.locPath));

%% Start zip job
bs2 = bs;
bs2.batFileName = 'batchJob_ziplog.sh';
startsettings = startsettings_gen;
startsettings.afterany = jobID;
jobID2 = startJob(ssh2_conn, ps, bs2, startsettings);
fprintf('jobID for logging results: %d\n', jobID2);