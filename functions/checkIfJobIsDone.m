% This function connects via ssh2 protocol to the host and checks
% whether the submitted job has been terminated. Therefor this function 
% looks for the textfile JOBNAME.oJOBID (which is produced after the job is terminated) on the home or execution dir on
% the server side and checks its content.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function [boolDone, ps, bs] = checkIfJobIsDone(ps, bs_in)

%% ssh2 config
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);     % configurate ssh2 connection
ssh2_conn = ssh2_command(ssh2_conn, 'ls -la *ninjas*');

%% ask for jobID
ps.jobID = str2num(input('What is your job-ID?\n', 's'));

%% check if job is done
load([ps.locPath, '/jobIDs/jobID', num2str(ps.jobID), '.mat'], 'jobID', ...
  'dateString', 'jobName', 'bs'); % load locally saved jobID and dateString
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
if(jobID ~= 0)                                                      % if jobID looks real...
    filename = [jobName, '.o', num2str(jobID)];
    [ssh2_conn, cmd] = ssh2_command(ssh2_conn, ['file ', filename]);% try to open file

    if(strcmp(cmd{1,1}(end-9:end), 'ASCII text'))                   % check whether the content of the jobfile is correct
        boolDone = 1;
    end
end

%% close ssh2
ssh2_conn = ssh2_close(ssh2_conn);                                  % close connection


