% Upload and submit your job
% 
% Input:
% settings
%   structure with the fields of userSettings.m and jobSettings.m that will
%   be overwritten regarding the content of the files. This can be used
%   when calling this function from another Matlab script.
% startsettings
%   Additionally, the fields of the input structure from startJob.m can be
%   set as well to define dependencies for starting the job.
%   The order of fields is given to the job query command and determines
%   the logic of multiple dependencies. See `man qsub` on the cluster.
%   fields: afterok, afternotok, ...
%   values: array with job IDs
% 
% Output:
% jobID
%   unique identifier of the queried Job in the computing cluster

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobID = jobStart(settings, startsettings)

%% Init
% add path to subfunctions
olddir = pwd();
cd(fullfile(fileparts(which('jobStart.m')))); % required for some relative paths to work
fcndir = fullfile(fileparts(which('jobStart.m')), 'functions');
addpath(fcndir);
addpath(fullfile(fcndir, 'matlab-ssh2-master','ssh2'));

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

%% upload personal data from upload folder by using sftp-protocol
uploadUserData(ps);
dateString = ps.dateString;

%% start job
if nargin < 2
  startsettings = []; % Placeholder
end
jobID = startJob(ps, startsettings);
disp(['Your jobID: ', num2str(jobID)]);
if ~exist('jobIDs', 'file'), mkdir('jobIDs'); end
jobName = bs.name;
save([ps.locPath, '/jobIDs/jobID', num2str(jobID), '.mat'], ...
  'jobID', 'dateString', 'jobName', 'bs');

%% Exit
cd(olddir);