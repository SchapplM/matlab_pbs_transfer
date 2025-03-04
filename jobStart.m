% Upload and submit your job
% 
% Input:
% settings
%   structure with the fields of userSettings.m and jobSettings.m that will
%   be overwritten regarding the content of the files. This can be used
%   when calling this function from another Matlab script.
% startsettings_in
%   Fields from cluster dependency management: afterok, afternotok, ...
%   The fields are given to the job query command and determine
%   the logic of multiple dependencies. See `man qsub` on the cluster.
%   Each of these fields has for a value an array with job IDs.
%   Additionally, the fields of the input structure from startJob.m can be
%   set as well to define dependencies for starting the job.
%   .waittime_max: maximum waiting time in case of no success for job start
%   .retry_interval: interval for retry of job start in seconds
% 
% Output:
% jobID
%   unique identifier of the queried Job in the computing cluster

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobID = jobStart(settings, startsettings_in)

%% Init
% add path to subfunctions
olddir = pwd();
cd(fullfile(fileparts(which('jobStart.m')))); % required for some relative paths to work
fcndir = fullfile(fileparts(which('jobStart.m')), 'functions');
addpath(fcndir);
addpath(fullfile(fcndir, 'matlab-ssh'));

if nargin < 2
  startsettings_in = struct();
end
startsettings_gen = struct('waittime_max', inf, 'retry_interval', 60); % for general settings
for f = fields(startsettings_in)'
  if isfield(startsettings_gen, f{1})
    startsettings_gen.(f{1}) = startsettings_in.(f{1});
  end
end
%% general settings
if ~exist('userSettings.m', 'file')
  error(['The file userSettings.m has to be created as a modified copy ', ...
    'from the directory templateFiles and put in the root directory']);
end
[ps, bs] = userSettings(); % load user settings
ps = jobAuthentication(ps);  % load personal authentication data
ps = jobSettings(ps, bs); % load personal settings
setUpBasics(); % unzip external functions, etc.
% Overwrite settings from the batch file with the ones given to the fcn
if nargin >= 1
  for f = fields(settings)'
    if isfield(bs, f{1})
      bs.(f{1}) = settings.(f{1});
    elseif isfield(ps, f{1})
      ps.(f{1}) = settings.(f{1});
    else
      warning('Field %s of the input structure can not be processed', f{1});
    end
  end
end
%% create and upload batch job file
ps = createJobFile(bs, ps);

%% Initialize SSH session
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password, ps.port);

%% upload personal data from upload folder by using sftp-protocol
t0 = tic();
while true % try uploading until successful or timeout
  try
    ssh2_conn = uploadUserData(ssh2_conn, ps);
    break;
  catch err
    warning('jobStart:SSH_error', 'Error uploading the job via ssh: %s', err.message);
  end
  if toc(t0) > startsettings_gen.waittime_max
    break;
  end
  fprintf('Retry job upload in %1.1fs for the next %1.1f min.\n', ...
    startsettings_gen.retry_interval, (startsettings_gen.waittime_max-toc(t0))/60);
  pause(startsettings_gen.retry_interval);
  ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);
end
dateString = ps.dateString;

%% start job
jobID = startJob(ssh2_conn, ps, bs, startsettings_in);
disp(['Your jobID: ', num2str(jobID)]);
if ~exist('jobIDs', 'file'), mkdir('jobIDs'); end
jobName = bs.name;
save(fullfile(ps.locPath, 'jobIDs', ['jobID', num2str(jobID), '.mat']), ...
  'jobID', 'dateString', 'jobName', 'bs');

%% create and start second job file for zipping the log file
zipJob(ssh2_conn, ps, bs, jobID, startsettings_in);

%% Exit (no more closing of connection necessary)
cd(olddir);
