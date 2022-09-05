% This function connects via ssh2 protocol to the host and checks
% whether the submitted job has been terminated. Therefor this function 
% looks for the textfile JOBNAME.oJOBID (which is produced after the job is terminated) on the home or execution dir on
% the server side and checks its content.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function [boolDone, ps, bs] = checkIfJobIsDone(ps, bs_in)

%% ssh2 config
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);

%% ask for jobID (if not given)
if ~isfield(ps, 'jobID') || ps.jobID == 0
  ps.jobID = str2double(input('What is your job-ID?\n', 's'));
end
%% check if job is done
jobfilename = fullfile(ps.locPath,'jobIDs',['jobID',num2str(ps.jobID),'.mat']);
if ~exist(jobfilename, 'file')
  warning('File with job data from uploading the job not found. Proceed anyway.');
  % This occurs if the job is started from a different machine than the one
  % downloading the job.
  % Try finding the job information on the computing cluster.
  % Search for log and output files in the expected directories and extract
  % the required information to proceed checking the status of the job.
  [ssh2_conn, cmd] = ssh2_command(ssh2_conn, ...
    ['find ', ps.extUploadFolder, ' -name "', num2str(ps.jobID), '.log*"']);
  if isempty(cmd)
    error('Log file not found on server');
  end
  tokens = regexp(cmd{1}, [ps.extUploadFolder, '/upload([\d_]+)/'], 'tokens');
  if isempty(tokens)
    error('No match of dateString in file path on server');
  end
  dateString = tokens{1}{1};
  jobID = ps.jobID;
  % Get job name from eventual output file in main directory
  [ssh2_conn, cmd] = ssh2_command(ssh2_conn, ...
    ['find ~', ' -maxdepth 1 -name "*.o', num2str(ps.jobID), '"']);
  if isempty(cmd{1})
    warning('No output file found on server');
  else
    tokens = regexp(cmd{1}, ['/([a-zA-Z0-9_]+).o', num2str(ps.jobID), '$'], 'tokens');
    if isempty(tokens)
      error('No match of jobName in file path on server');
    end
    jobName = tokens{1}{1};
  end
else
  load(jobfilename, 'jobID', ...
    'dateString', 'jobName', 'bs'); % load locally saved jobID and dateString
end
% Get Job settings (stored when submitting the job).
if ~exist('bs', 'var')
  bs = bs_in;
end
% Get job name. Necessary for generating the file name of status files
if ~exist('jobName', 'var')
  % use job name from the batch settings. Can be outdated, if other
  % jobs were prepared between start and download of the current job
  jobName = bs.name;
else
  % Use the saved job name from the jobs mat file and use it for down-
  % loading the data
  bs.name = jobName;
end
ps.dateString = dateString;
ps.extDownloadFolder = strrep(ps.extDownloadFolder, ...
    '$UPLOADDIR$', ['upload', ps.dateString]);
boolDone = 0;
if(jobID ~= 0) % if jobID looks real...
  for i_queue = 1:2 % Look for SLURM and PBS output format
    if i_queue == 1 % SLURM
      filename = ['slurm-', num2str(jobID), '.out'];
    else % PBS
      filename = [jobName, '.o', num2str(jobID)];
    end
    [ssh2_conn, cmd] = ssh2_command(ssh2_conn, ['file ', filename]); % try to open file
    if(strcmp(cmd{1,1}(end-9:end), 'ASCII text'))
      boolDone = 1;  % content of the jobfile is correct
      break;
    end
  end
end

%% close ssh2
ssh2_close(ssh2_conn);
